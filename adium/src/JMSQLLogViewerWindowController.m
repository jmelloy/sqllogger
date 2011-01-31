/*-------------------------------------------------------------------------------------------------------*\
| Adium, Copyright (C) 2001-2004, Adam Iser  (adamiser@mac.com | http://www.adiumx.com)                   |
\---------------------------------------------------------------------------------------------------------/
 | This program is free software; you can redistribute it and/or modify it under the terms of the GNU
 | General Public License as published by the Free Software Foundation; either version 2 of the License,
 | or (at your option) any later version.
 |
 | This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
 | the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
 | Public License for more details.
 |
 | You should have received a copy of the GNU General Public License along with this program; if not,
 | write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 \------------------------------------------------------------------------------------------------------ */
/*
 * $Revision: 1.16 $
 * $Date: 2004/06/25 01:19:46 $
 * $Author: jmelloy $
 */

#import "JMSQLLogViewerWindowController.h"
#import "AISQLLoggerPlugin.h"
#import "libpq-fe.h"

#define SQL_LOG_VIEWER_NIB			@"SQLLogViewer"
#define KEY_LOG_VIEWER_WINDOW_FRAME		@"Log Viewer Frame"
#define	PREF_GROUP_CONTACT_LIST			@"Contact List"
#define KEY_LOG_VIEWER_GROUP_STATE		@"Log Viewer Group State"	//Expand/Collapse state of groups


@interface JMSQLLogViewerWindowController (PRIVATE)
- (void)scanAvailableLogs;
- (void)makeActiveLogsForServiceID:(NSString *)inUserID;
- (void)sortSelectedLogArrayForTableColumn:(NSTableColumn *)tableColumn direction:(BOOL)direction;
- (void)displayLogAtPath:(NSString *)messageDate from:(NSString *)fromUserID to:(NSString *)toUserID;
- (void)setDatabaseConnections;
@end

int _sortStringWithKey(id objectA, id objectB, void *key);
int _sortStringWithKeyBackwards(id objectA, id objectB, void *key);
int _sortDateWithKey(id objectA, id objectB, void *key);
int _sortDateWithKeyBackwards(id objectA, id objectB, void *key);

@implementation JMSQLLogViewerWindowController

static JMSQLLogViewerWindowController *sharedSQLViewerInstance = nil;
+ (id)logViewerWindowController
{
    if(!sharedSQLViewerInstance){
        sharedSQLViewerInstance = [[self alloc] initWithWindowNibName:SQL_LOG_VIEWER_NIB];
    }

    return(sharedSQLViewerInstance);
}

+ (void)closeSharedInstance
{
    if(sharedSQLViewerInstance){
        [sharedSQLViewerInstance closeWindow:nil];
    }
}

//init
- (id)initWithWindowNibName:(NSString *)windowNibName
{
    //init
    availableLogArray = nil;
    selectedLogArray = nil;
    selectedColumn = nil;
    sortDirection = 0;

	NSString	*connInfo;
	id			tmp;
	
	connInfo = [NSString stringWithFormat:@"host=\'%@\' port=\'%@\' user=\'%@\' password=\'%@\' dbname=\'%@\' sslmode=\'prefer\'", 
						(tmp = url) ? tmp: @"", (tmp = port) ? tmp: @"", (tmp = username) ? tmp: NSUserName(), 
				   (tmp = password) ? tmp: @"", (tmp = database) ? tmp: NSUserName()];
	
	
    conn = PQconnectdb([connInfo cString]);

    if (PQstatus(conn) == CONNECTION_BAD)
    {
        [[adium interfaceController] handleErrorMessage:@"Connection to database for Log Viewer failed." withDescription:@"Check your settings and try again."];
        NSLog(@"%s", PQerrorMessage(conn));
    }

    [super initWithWindowNibName:windowNibName];

    return(self);
}

-(void)setDatabaseConnections {
	NSDictionary	*preferenceDict = [[adium preferenceController] preferencesForGroup:PREF_GROUP_SQL_LOGGING];
	
	username = [preferenceDict objectForKey:KEY_SQL_USERNAME];
	url = [preferenceDict objectForKey:KEY_SQL_URL];
	port = [preferenceDict objectForKey:KEY_SQL_PORT];
	database = [preferenceDict objectForKey:KEY_SQL_DATABASE];
	password = [preferenceDict objectForKey:KEY_SQL_PASSWORD];
}

//
- (void)dealloc
{    
    PQfinish(conn);

    [super dealloc];
}

//Setup the window before it is displayed
- (void)windowDidLoad
{
    NSString	*savedFrame;

    //Restore the window position
    savedFrame = [[[adium preferenceController] preferencesForGroup:PREF_GROUP_WINDOW_POSITIONS] objectForKey:KEY_LOG_VIEWER_WINDOW_FRAME];
    if(savedFrame){
        [[self window] setFrameFromString:savedFrame];
    }else{
        [[self window] center];
    }

    //Scan the user's logs    
    [self scanAvailableLogs];

    //Sort by date
    selectedColumn = [[tableView_results tableColumnWithIdentifier:@"Date"] retain];
}

//Close the window
- (IBAction)closeWindow:(id)sender
{
    if([self windowShouldClose:nil]){
        [[self window] close];
    }
}

//Called as the window closes
- (BOOL)windowShouldClose:(id)sender
{
    //Save the window position
    [[adium preferenceController] setPreference:[[self window] stringWithSavedFrame]
                                         forKey:KEY_LOG_VIEWER_WINDOW_FRAME
                                          group:PREF_GROUP_WINDOW_POSITIONS];

    [sharedSQLViewerInstance autorelease]; sharedSQLViewerInstance = nil;
    [selectedLogArray release]; selectedLogArray = nil;
    [availableLogArray release]; availableLogArray = nil;
    [selectedColumn release]; selectedColumn = nil;
    
    return(YES);
}

//Prevent the system from moving our window around
- (BOOL)shouldCascadeWindows
{
    return(NO);
}

//Select and display the logs for the specified contact
- (void)showLogsForContact:(AIListContact *)contact
{
    NSEnumerator	*groupEnumerator;
    NSDictionary	*groupDict;
    NSEnumerator	*contactEnumerator;
    NSDictionary	*contactDict;
    int			selectedRow;

    if(contact){
        //Find this contact in our log list
        groupEnumerator = [availableLogArray objectEnumerator];
        while((groupDict = [groupEnumerator nextObject])){
    
            contactEnumerator = [[groupDict objectForKey:@"Contents"] objectEnumerator];
            while((contactDict = [contactEnumerator nextObject])){
    
                if([(NSString *)[contactDict objectForKey:@"UID"] isEqualToString:[contact UID]] &&
                [(NSString *)[contactDict objectForKey:@"ServiceID"] isEqualToString:[contact serviceID]]){
                    
                    //Expand the containing group
                    [outlineView_contacts expandItem:groupDict];
                        
                    //Select the contact, and scroll it visible
                    selectedRow = [outlineView_contacts rowForItem:contactDict];
                    if(selectedRow != NSNotFound){
                        [outlineView_contacts selectRow:selectedRow byExtendingSelection:NO];
                        [outlineView_contacts scrollRowToVisible:selectedRow];
                    }
                    
                    //Update the displayed logs
                    [self outlineViewSelectionDidChange:nil];
    
                    //Exit early
                    return;
                }
            }
        }
    }
}

//Scans the available logs, and builds the contact list in the viewer
- (void)scanAvailableLogs
{
    NSEnumerator	*enumerator;
    NSDictionary	*dictionary;

    NSMutableDictionary	*groupDict = [NSMutableDictionary dictionary];
    NSMutableDictionary	*contactDict = [NSMutableDictionary dictionary];

    PGresult 		*accountRes;
    NSString		*sqlStatement;
    int 		i;

    //Process each account (Everyone in im.users)
    sqlStatement = [NSString stringWithString:@"select user_id, scramble(username), service from im.users"];
    accountRes = PQexec(conn, [sqlStatement UTF8String]);
    if (!accountRes || PQresultStatus(accountRes) != PGRES_TUPLES_OK) {
        NSLog(@"%s / %s\n%@", PQresStatus(PQresultStatus(accountRes)), PQresultErrorMessage(accountRes), sqlStatement);
        [[adium interfaceController] handleErrorMessage:@"Account Selection failed." withDescription:@"Account Selection Failed"];
        if(accountRes) {
            PQclear(accountRes);
        }
    } else {
        for(i = 0; i < PQntuples(accountRes); i++){
            NSString	*accountUID, *serviceID;
            NSString	*userID;
            NSString	*serverGroup = nil;
            NSString	*contactKey;
            
            //Get the account UID and ServiceID
            accountUID = [NSString stringWithCString:PQgetvalue(accountRes, i, 1)];
            serviceID = [NSString stringWithCString:PQgetvalue(accountRes, i, 2)];
            userID = [NSString stringWithCString:PQgetvalue(accountRes, i, 0)];
            serverGroup = @"Strangers";
			
			
            //Find the group this contact is in on our contact list
            AIListContact	*contact = [[adium contactController] contactInGroup:nil withService:serviceID UID:accountUID];
            /*
			if(contact){
                serverGroup = [[contact containingGroup] UID];
            }
            if(!serverGroup) serverGroup = @"Strangers"; //Default group
			 */

            //Make sure this groups is in our available group dict
            if(![groupDict objectForKey:serverGroup]){
                [groupDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:serverGroup, @"UID", [NSMutableArray array], @"Contents", nil] forKey:serverGroup];
            }
			 

            //Make sure the handle is in our available handle array
            contactKey = [NSString stringWithFormat:@"%@.%@", serviceID, accountUID];
            if(![contactDict objectForKey:contactKey]){
                [contactDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:accountUID, @"UID", serviceID, @"ServiceID", serverGroup, @"Group", userID, @"userID", nil] forKey:contactKey];
            }
        }
        
        PQclear(accountRes);
    }
                     
    //Build a sorted available log array from our dictionaries
    //Yes, it'd be easier to just use arrays above, but using dictionaries (and transfering the results to an array) gives us a very nice speed boost.
    [availableLogArray release];
    availableLogArray = [[NSMutableArray alloc] init];

    //Fill all groups
    enumerator = [[contactDict allValues] objectEnumerator];
    while(dictionary = [enumerator nextObject]){
        [[[groupDict objectForKey:[dictionary objectForKey:@"Group"]] objectForKey:@"Contents"] addObject:dictionary]; //Add the contact to the group
    }

    //Sort group contents and add them to the main array
    enumerator = [[groupDict allValues] objectEnumerator];
    while(dictionary = [enumerator nextObject]){
        [[dictionary objectForKey:@"Contents"] sortUsingFunction:_sortStringWithKey context:@"UID"]; //Sort the group
        [availableLogArray addObject:dictionary]; //Add it to our available log array
    }

    //Sort the main array
    [availableLogArray sortUsingFunction:_sortStringWithKey context:@"UID"];
    [outlineView_contacts reloadData];
}

//Puts the specified contact's logs in the 'active logs' section of the viewer
- (void)makeActiveLogsForServiceID:(NSString *)inUserID
{
    NSString		*dateSQL;
    PGresult		*dateRes;
    int			i;
    
    //Flush old selected array
    [selectedLogArray release]; selectedLogArray = [[NSMutableArray alloc] init];

    dateSQL = [NSString stringWithFormat:@"select distinct on(message_date) scramble(sender_sn), scramble(recipient_sn), message_date::date, date_part(\'year\', message_date) as year, date_part(\'month\', message_date) as month, date_part(\'day\', message_date) as day, sender_id, recipient_id from im.simple_message_v where sender_id = %@ or recipient_id = %@", inUserID, inUserID];

    dateRes = PQexec(conn, [dateSQL UTF8String]);
    if (!dateRes || PQresultStatus(dateRes) != PGRES_TUPLES_OK) {
        [[adium interfaceController] handleErrorMessage:@"Date Selection Failed" withDescription:@"Date Selection Failed"];
        NSLog(@"%s / %s\n%@", PQresStatus(PQresultStatus(dateRes)), PQresultErrorMessage(dateRes), dateSQL);
        if(dateRes) {
            PQclear(dateRes);
        }
    } else {
        for(i = 0; i < PQntuples(dateRes); i++) {
            NSDate 	*logDate = [NSCalendarDate dateWithYear:atoi(PQgetvalue(dateRes, i, 3)) month:atoi(PQgetvalue(dateRes, i, 4)) day:atoi(PQgetvalue(dateRes, i, 5)) hour:0 minute:0 second:0 timeZone:[NSTimeZone defaultTimeZone]];
            NSString	*from, *to, *message_date, *fromUserID, *toUserID;
            
            from = [NSString stringWithCString:PQgetvalue(dateRes, i, 0)];
            to = [NSString stringWithCString:PQgetvalue(dateRes, i, 1)];
            message_date = [NSString stringWithCString:PQgetvalue(dateRes, i, 2)];
            fromUserID = [NSString stringWithCString:PQgetvalue(dateRes, i, 6)];
            toUserID = [NSString stringWithCString:PQgetvalue(dateRes, i, 7)];
            
            [selectedLogArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                logDate, @"Date", to, @"To", from, @"From",
                message_date, @"MessageDate", fromUserID, @"fromUserID", toUserID, @"toUserID", nil]];
        }
        PQclear(dateRes);
    }

    //Sort the logs correctly
    [self sortSelectedLogArrayForTableColumn:selectedColumn direction:sortDirection];

    //Reload/redisplay
    [tableView_results reloadData];

    //Select the top log
    [tableView_results selectRow:0 byExtendingSelection:NO];
    [self tableViewSelectionDidChange:nil];
}

//Sorts the selected log array and adjusts the selected column
- (void)sortSelectedLogArrayForTableColumn:(NSTableColumn *)tableColumn direction:(BOOL)direction
{
    int		selectedRow;
    id		selectedObject = nil;
    NSString	*identifier;

    //If there already was a sorted column, remove the indicator image from it.
    if(selectedColumn && selectedColumn != tableColumn){
        [tableView_results setIndicatorImage:nil inTableColumn:selectedColumn];
    }

    //Set the indicator image in the newly selected column
    [tableView_results setIndicatorImage:[NSImage imageNamed:(direction ? @"NSAscendingSortIndicator" : @"NSDescendingSortIndicator")]
                           inTableColumn:tableColumn];

    //Set the highlighted table column.
    [tableView_results setHighlightedTableColumn:tableColumn];
    [selectedColumn release]; selectedColumn = [tableColumn retain];
    sortDirection = direction;

    //Deselect all selected rows.
    selectedRow = [tableView_results selectedRow];
    if(selectedRow >= 0 && selectedRow < [selectedLogArray count]){
        selectedObject = [selectedLogArray objectAtIndex:selectedRow];
    }
    [tableView_results deselectAll:nil];

    //Resort the data
    identifier = [selectedColumn identifier];
    if([identifier isEqualToString:@"To"] || [identifier isEqualToString:@"From"]){
        [selectedLogArray sortUsingFunction:(sortDirection ? _sortStringWithKeyBackwards : _sortStringWithKey)
                                    context:identifier];

    }else if([identifier isEqualToString:@"Date"]){
        [selectedLogArray sortUsingFunction:(sortDirection ? _sortDateWithKeyBackwards : _sortDateWithKey)
                                    context:identifier];

    }

    //Reload the data
    [tableView_results reloadData];

    //Reapply the selection
    if(selectedObject){
        [tableView_results selectRow:[selectedLogArray indexOfObject:selectedObject] byExtendingSelection:NO];
    }
}

//Displays the contents of the specified log in our window
- (void)displayLogAtPath:(NSString *)messageDate from:(NSString *)fromUserID to:(NSString *)toUserID
{
    NSAttributedString	*logText;
    NSMutableString	*rawLogText;
    NSString		*logSQL;
    PGresult		*logRes;
    int 		i,j;
    //Load the log

    logSQL = [NSString stringWithFormat:@"select \'<div class=\"' || case when sender_id = %@ then 'send' else 'receive' end || '\"><span class=\"timestamp\">\' || to_char(message_date, \'HH24:MM:SS\') || '</span> ' as time, \'<span class=\"sender\">' || scramble(sender_sn) || ':</span> ' as sender, \'<pre class=\"message\">' || message || '</pre></div>\n' as message_contents from im.simple_message_v where ((sender_id = %@ and recipient_id = %@) or (sender_id = %@ and recipient_id = %@)) and message_date > \'%@\'::date and message_date < \'%@\'::date + 1 order by message_date", fromUserID, fromUserID, toUserID, toUserID, fromUserID, messageDate, messageDate];

    logRes = PQexec(conn, [logSQL UTF8String]);
    rawLogText = [NSMutableString stringWithString:@""];
    
    if(!logRes || PQresultStatus(logRes) != PGRES_TUPLES_OK) {
        NSLog(@"%s / %s\n%@", PQresStatus(PQresultStatus(logRes)), PQresultErrorMessage(logRes), logSQL);
        [[adium interfaceController] handleErrorMessage:@"Log Selection failed." withDescription:@"Log Selection Failed"];
        if(logRes) {
            PQclear(logRes);
        }
    } else {
        for(i = 0; i < PQntuples(logRes); i++) {
            for(j = 0; j < PQnfields(logRes); j++) {
                NSString *log;
                
                log = [NSString stringWithCString:PQgetvalue(logRes, i, j)];

                [rawLogText appendString:log];
                
            }
        }
        
        PQclear(logRes);
    }
    logText = [[[NSAttributedString alloc] initWithAttributedString:[AIHTMLDecoder decodeHTML:rawLogText]] autorelease];
    
    [[textView_content textStorage] setAttributedString:logText];
    
    //Scroll to the top
    [textView_content scrollRangeToVisible:NSMakeRange(0,0)];    
}

// Contact list outline view
//
- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item
{
    if(item == nil){
        return([availableLogArray objectAtIndex:index]);
    }else{
        return([[item objectForKey:@"Contents"] objectAtIndex:index]);
    }
}

//
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if([item objectForKey:@"Contents"]){
        return(YES);
    }else{
        return(NO);
    }
}

//
- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if(item == nil){
        return([availableLogArray count]);
    }else if([item isKindOfClass:[NSDictionary class]]){
        return([[item objectForKey:@"Contents"] count]);
    }else{
        return(0);
    }
}

//
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    return([item objectForKey:@"UID"]);
}

//
- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    int	row = [outlineView_contacts selectedRow];

    if(row != NSNotFound){
        NSDictionary	*contactDict = [outlineView_contacts itemAtRow:row];

        [self makeActiveLogsForServiceID:[contactDict objectForKey:@"userID"]];

    }
}

//
- (void)outlineView:(NSOutlineView *)outlineView setExpandState:(BOOL)state ofItem:(id)item
{
    NSDictionary	*preferenceDict = [[adium preferenceController] preferencesForGroup:PREF_GROUP_CONTACT_LIST];
    NSMutableDictionary	*groupStateDict = [[preferenceDict objectForKey:KEY_LOG_VIEWER_GROUP_STATE] mutableCopy];

    if(!groupStateDict) groupStateDict = [[NSMutableDictionary alloc] init];

    //Save the group new state
    [groupStateDict setObject:[NSNumber numberWithBool:state]
                       forKey:[item objectForKey:@"UID"]];

    [[adium preferenceController] setPreference:groupStateDict forKey:KEY_LOG_VIEWER_GROUP_STATE group:PREF_GROUP_CONTACT_LIST];
    [groupStateDict release];
}

//
- (BOOL)outlineView:(NSOutlineView *)outlineView expandStateOfItem:(id)item
{
    NSDictionary	*preferenceDict = [[adium preferenceController] preferencesForGroup:PREF_GROUP_CONTACT_LIST];
    NSMutableDictionary	*groupStateDict = [preferenceDict objectForKey:KEY_LOG_VIEWER_GROUP_STATE];
    NSNumber		*expandedNum;

    //Lookup the group's saved state
    expandedNum = [groupStateDict objectForKey:[item objectForKey:@"UID"]];

    //Correctly expand/collapse the group
    if(!expandedNum || [expandedNum boolValue] == YES){ //Default to expanded
        return(YES);
    }else{
        return(NO);
    }
}


// Log Matches table view 

- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
    return([selectedLogArray count]);
}

//
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
    NSString	*identifier = [tableColumn identifier];
    NSString	*value = nil;
    
    if([identifier isEqualToString:@"To"]){
        value = [[selectedLogArray objectAtIndex:row] objectForKey:@"To"];
        
    }else if([identifier isEqualToString:@"From"]){
        value = [[selectedLogArray objectAtIndex:row] objectForKey:@"From"];

    }else if([identifier isEqualToString:@"Date"]){
        value = [[[selectedLogArray objectAtIndex:row] objectForKey:@"Date"] descriptionWithCalendarFormat:@"%B %d, %Y"];
        
    }
    
    return(value);
}


- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    int	row = [tableView_results selectedRow];

    if(row >= 0 && row < [selectedLogArray count]){
        NSDictionary	*logDict = [selectedLogArray objectAtIndex:row];

        [self displayLogAtPath:[logDict objectForKey:@"MessageDate"]
                          from:[logDict objectForKey:@"fromUserID"]
                            to:[logDict objectForKey:@"toUserID"]];
    }
}


- (void)tableView:(NSTableView*)tableView didClickTableColumn:(NSTableColumn *)tableColumn
{    
    //Sort the log array & reflect the new column
    [self sortSelectedLogArrayForTableColumn:tableColumn
                                   direction:(selectedColumn == tableColumn ? !sortDirection : sortDirection)];
}


// Sorting
int _sortStringWithKey(id objectA, id objectB, void *key){
    NSString	*stringA = [objectA objectForKey:key];
    NSString	*stringB = [objectB objectForKey:key];

    return([stringA compare:stringB]);
}
int _sortStringWithKeyBackwards(id objectA, id objectB, void *key){
    NSString	*stringA = [objectA objectForKey:key];
    NSString	*stringB = [objectB objectForKey:key];

    return([stringB compare:stringA]);
}
int _sortDateWithKey(id objectA, id objectB, void *key){
    NSDate	*stringA = [objectA objectForKey:key];
    NSDate	*stringB = [objectB objectForKey:key];

    return([stringB compare:stringA]);
}
int _sortDateWithKeyBackwards(id objectA, id objectB, void *key){
    NSDate	*stringA = [objectA objectForKey:key];
    NSDate	*stringB = [objectB objectForKey:key];

    return([stringA compare:stringB]);
}
@end

