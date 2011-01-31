/*
 *  FireSQLLogger.m
 *  FirePluginTemplate
 *
 *  Created by Graham Booker on Fri Feb 20 2004.
 *  Copyright (c) 2004 Fire Development Team. All rights reserved.
 *  
 *  Permission is hereby granted, free of charge, to any person obtaining
 *  a copy of this software and associated documentation files (the "Software"),
 *  to deal in the Software without restriction, including without limitation
 *  the rights to use, copy, modify, merge, publish, distribute, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, provided that the above copyright notice(s) and this
 *  permission notice appear in all copies of the Software and that both the
 *  above copyright notice(s) and this permission notice appear in supporting
 *  documentation.
 *
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT OF THIRD PARTY RIGHTS.
 *  IN NO EVENT SHALL THE COPYRIGHT HOLDER OR HOLDERS INCLUDED IN THIS NOTICE BE
 *  LIABLE FOR ANY CLAIM, OR ANY SPECIAL INDIRECT OR CONSEQUENTIAL DAMAGES, OR
 *  ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER
 *  IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT
 *  OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 *
 *  Except as contained in this notice, the name of a copyright holder shall not
 *  be used in advertising or otherwise to promote the sale, use or other dealings
 *  in this Software without prior written authorization of the copyright holder. 
 */


/*
 * Notes on using this template:
 * 1) Rename the class!  This template will be loaded as a bundle into Fire's image.
 *    Only one implementation of a particular class is allowed in the image at any
 *    point in time.
 * 2) The defines below are a guide to helping you set which calls are made to your
 *    plugin.  More detailed information is provided with the function called.
 *    Uncomment the appropriate types for your plugin.
 * 3) This project assumes that fire's source directory is in ../fire
 *    You can change this value in the compiler include directories.
 * 4) Edit the project plist.  In XCode, expand the target section, double click the
 *    target there, and hit properties.  Edit the identifier to something unique, and
 *    set the PricipalClass name to match this class name.  More properties are available
 *    by hitting "Open Info.plist as File" such as version requirements.
 */

#import "FireSQLLogger.h"
#import "FirePlugin.h"
#import "PluginDefines.h"
#import "MessageItem.h"
#import "BuddyItem.h"

#import "Account.h"
#import "ServiceItem.h"
#import "NSAttributedStringAdditions.h"
#import "MainController.h"

#import "libpq-fe.h"

#define DOES_INCOMING_MSG
//#define DOES_INCOMING_CTL
#define DOES_OUTGOING_MSG
//#define DOES_BUDDY_LOGGED_ON
//#define DOES_BUDDY_LOGGED_OFF
//#define DOES_BUDDY_CHANGED_STATUS
#define DOES_QUIT

@interface FireSQLLogger (PRIVATE)
- (void)addMessage:(NSString *)message dest:(NSString *)destName source:(NSString *)sourceName sendDisplay:(NSString *)sendDisp destDisplay:(NSString *)destDisp sendServe:(NSString *)s_service recServe:(NSString *)r_service;
@end

@implementation FireSQLLogger

/*
 * OK, this is just to tell us that we have been loaded and in what way
 * If the user explicitly loaded us, we may want to do something about it
 * Return YES to say everything is OK.
 */
+ (BOOL)initPlugin:(NSBundle *)bundle autoload:(BOOL)yn
{
    return YES;
}

/*
 * Get our instance
 */
+ (id) pluginInstance
{
    static id shared = nil;
    
    if(shared == nil){
        shared = [[FireSQLLogger alloc] init];
    }
    return shared;
}

- (id) init{
    self = [super init];
    
    description = [[NSDictionary dictionaryWithObjectsAndKeys:
        @"Template Plugin", FIRE_PLUGIN_NAME_KEY,
        [NSArray arrayWithObjects:
#ifdef DOES_INCOMING_MSG
            [NSNumber numberWithInt:FIRE_PLUGIN_INCOMING_MSG],
#endif
#ifdef DOES_INCOMING_CTL
            [NSNumber numberWithInt:FIRE_PLUGIN_INCOMING_CTL],
#endif
#ifdef DOES_OUTGOING_MSG
            [NSNumber numberWithInt:FIRE_PLUGIN_OUTGOING_MSG],
#endif
#ifdef DOES_BUDDY_LOGGED_ON
            [NSNumber numberWithInt:FIRE_PLUGIN_BUDDY_LOGGED_ON],
#endif
#ifdef DOES_BUDDY_LOGGED_OFF
            [NSNumber numberWithInt:FIRE_PLUGIN_BUDDY_LOGGED_OFF],
#endif
#ifdef DOES_BUDDY_CHANGED_STATUS
            [NSNumber numberWithInt:FIRE_PLUGIN_BUDDY_CHANGED_STATUS],
#endif
#ifdef DOES_QUIT
            [NSNumber numberWithInt:FIRE_PLUGIN_QUIT],
#endif
            nil], FIRE_PLUGIN_TYPES_KEY,
        [NSNumber numberWithInt:FIRE_CURRENT_PLUGIN_API_VERSION], FIRE_PLUGIN_API_VERSION_NUMBER_KEY,
        nil] retain];
    
	conn = PQconnectdb("");
    if (PQstatus(conn) == CONNECTION_BAD)
    {
        NSLog(@"Connection to database failed: %s", PQerrorMessage(conn));
        
    }
	
    return self;
}

- (void) dealloc
{
    [description release];
    [super dealloc];
}

/*
 * Leting us know that we are being activated.
 * Return YES to say everything is OK
 */
- (BOOL)activate
{
    return YES;
}

/*
 * Letting us know that we are being deactivated.
 */
- (void)deactivate
{
}

/*
 * Get our description to say what kind of plugin we are.
 * May be called a lot, so it is best to cache this info like
 * this template does.
 */
- (NSDictionary *)pluginDescription
{
    return description;
}

/*
 * Called when our prefs are being saved.  To induce this,
 * call [[PluginController sharedInstance] savePrefsForPlugin:self];
 */
- (NSDictionary *)prefs
{
    return nil;
}

/*
 * Sets our prefs as loaded from config.  Called at the end of activate
 * newPrefs may be nil!!!
 */
- (void)setPrefs:(NSDictionary *)newPrefs
{
}

/*
 * Letting us show our pref window, usually because the user
 * requested it.  window may be nil!
 */
- (void)showPrefsOverWindow:(NSWindow *)window
{
}


#ifdef DOES_INCOMING_MSG
/*
 * Called on each incoming message after dencryption, validation, control, translation,
 *  and service markup decoding.
 * At the moment, dict will be nil, but is here for future expantion
 * All data is contained within the MessageItem
 * 
 * return value
 *  YES will end processing of this message and kill it, without being displayed or logged.
 *  NO will let the message continue processing
 */

- (BOOL)incomingMessage:(MessageItem *)msg additionalData:(NSDictionary *)dict
{
    BuddyItem *sender = [msg buddy];
    NSString *sender_sn = [sender buddyNameForLogging];
    NSString *sender_display = [sender displayName];
    Account *account = [msg account];
    NSString *serviceName = [[account service] serviceName];
    NSString *receiver_sn = [account userName];
    NSString *receiver_display = [[MainController mainController] myScreenNameForAccount:account];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[msg timeStamp]];
    NSString *htmlmsg = [[msg attributedMessage] HTMLWithOptions:[NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithBool:YES], @"NSHTMLUseExactFontSizes",
                        [NSNumber numberWithBool:YES], @"NSHTMLNoAbsolutePath",
                        nil]];
    
	[self addMessage:htmlmsg
				dest:receiver_sn
			  source:sender_sn
		 sendDisplay:sender_display
		 destDisplay:receiver_display
		   sendServe:serviceName
			recServe:serviceName];
	
    return NO;
}
#endif
#ifdef DOES_INCOMING_CTL
/*
 * Called on each incoming message after dencryption, validation, and control.
 * At the moment, dict will be nil, but is here for future expantion
 * All data is contained within the MessageItem
 * 
 * return value
 *  YES will end processing of this message and kill it, without being displayed or logged.
 *  NO will let the message continue processing
 */

- (BOOL)incomingCtlMessage:(MessageItem *)msg additionalData:(NSDictionary *)dict
{
    return NO;
}
#endif
#ifdef DOES_OUTGOING_MSG
/*
 * Called on each outgoing message after checking if message can be sent and control.
 * At the moment, dict will be nil, but is here for future expantion
 * All data is contained within the MessageItem
 * 
 * return value
 *  YES will end processing of this message and kill it, without being displayed, logged, or sent.
 *  NO will let the message continue processing
 */

- (BOOL)outgoingMessage:(MessageItem *)msg additionalData:(NSDictionary *)dict
{
    BuddyItem *receiver = [msg buddy];
    NSString *receiver_sn = [receiver buddyNameForLogging];
    NSString *receiver_display = [receiver displayName];
    Account *account = [msg account];
    NSString *sender_sn = [account userName];
    NSString *sender_display = [[MainController mainController] myScreenNameForAccount:account];
    NSString *serviceName = [[account service] serviceName];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[msg timeStamp]];
    NSString *htmlmsg = [[msg attributedMessage] HTMLWithOptions:[NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithBool:YES], @"NSHTMLUseExactFontSizes",
        [NSNumber numberWithBool:YES], @"NSHTMLNoAbsolutePath",
        nil]];
    
	[self addMessage:htmlmsg
				dest:receiver_sn
			  source:sender_sn
		 sendDisplay:sender_display
		 destDisplay:receiver_display
		   sendServe:serviceName
			recServe:serviceName];
	
    return NO;
}
#endif
#ifdef DOES_BUDDY_LOGGED_ON
/*
 * Called on each buddy logging on
 * At the moment, dict contains:
 *   Account in FIRE_PLUGIN_ACCOUNT_KEY
 *   If the buddy was already online in FIRE_PLUGIN_ALREADY_ON_KEY
 *      Some services tell you that the buddy has logged on again to give you status updates
 * 
 * return value
 *  YES will end processing of plugins for this event
 *  NO will continue processing
 */

- (BOOL)buddyLoggedOn:(BuddyItem *)buddy additionalData:(NSDictionary *)dict
{
    return NO;
}
#endif
#ifdef DOES_BUDDY_LOGGED_OFF
/*
 * Called on each buddy logging off
 * At the moment, dict contains:
 *   Account in FIRE_PLUGIN_ACCOUNT_KEY
 * 
 * return value
 *  YES will end processing of plugins for this event
 *  NO will continue processing
 */

- (BOOL)buddyLoggedOff:(BuddyItem *)buddy additionalData:(NSDictionary *)dict
{
    return NO;
}
#endif
#ifdef DOES_BUDDY_CHANGED_STATUS
/*
 * Called on each buddy logging on
 * At the moment, dict contains:
 *   Account in FIRE_PLUGIN_ACCOUNT_KEY
 *   Old status in FIRE_PLUGIN_OLD_STATUS
 *   New status in FIRE_PLUGIN_NEW_STATUS
 * 
 * return value
 *  YES will end processing of plugins for this event
 *  NO will continue processing
 */

- (BOOL)buddyChangedStatus:(BuddyItem *)buddy additionalData:(NSDictionary *)dict
{
    return NO;
}
#endif

#ifdef DOES_QUIT
/*
 * Called when fire is quitting
 * At the moment, dict is nil
 * 
 * return value
 *  YES will end processing of plugins for this event (You should not do this)
 *  NO will continue processing
 */

- (BOOL)quitting:(id)object additionalData:(NSDictionary *)dict
{
	PQfinish(conn);
    return NO;
}
#endif

- (void)addMessage:(NSString *)message
               dest:(NSString *)destName
             source:(NSString *)sourceName
        sendDisplay:(NSString *)sendDisp
        destDisplay:(NSString *)destDisp
          sendServe:(NSString *)s_service
           recServe:(NSString *)r_service

{
    NSString	*sqlStatement;
	
    char	escapeMessage[[message length] * 2 + 1];
    char	escapeSender[[sourceName length] * 2 + 1];
    char	escapeRecip[[destName length] * 2 + 1];
    char	escapeSendDisplay[[sendDisp length] * 2 + 1];
    char	escapeRecDisplay[[destDisp length] * 2 + 1];
    
    PGresult *res;
	
    PQescapeString(escapeMessage, [message UTF8String], [message length]);
    PQescapeString(escapeSender, [sourceName UTF8String], [sourceName length]);
    PQescapeString(escapeRecip, [destName UTF8String], [destName length]);
    PQescapeString(escapeSendDisplay, [sendDisp UTF8String], [sendDisp length]);
    PQescapeString(escapeRecDisplay, [destDisp UTF8String], [destDisp length]);
    
    sqlStatement = [NSString stringWithFormat:@"insert into adium.message_v (sender_sn, recipient_sn, message, sender_service, recipient_service, sender_display, recipient_display) values (\'%s\',\'%s\',\'%s\', \'%@\', \'%@\', \'%s\', \'%s\')", 
		escapeSender, escapeRecip, escapeMessage, s_service, r_service, escapeSendDisplay, escapeRecDisplay];
    
    res = PQexec(conn, [sqlStatement UTF8String]);
    if (!res || PQresultStatus(res) != PGRES_COMMAND_OK) {
        NSLog(@"Insertion failed");
		NSLog(@"%s / %s\n%@", PQresStatus(PQresultStatus(res)), PQresultErrorMessage(res), sqlStatement);

        if (res) {
            PQclear(res);
        }
        
        if (PQresultStatus(res) == PGRES_NONFATAL_ERROR) {
            //Disconnect and reconnect.
            PQfinish(conn);
            conn = PQconnectdb("");
            if (PQstatus(conn) == CONNECTION_BAD)
            {
                NSLog(@"%s", PQerrorMessage(conn));
            } else {
                NSLog(@"Connection to PostgreSQL successfully made.");
            }
        }
    }
    if(res) {
        PQclear(res);
    }
}

@end