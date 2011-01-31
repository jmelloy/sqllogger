/*-------------------------------------------------------------------------------------------------------*\
| AISQLLoggerPlugin 1.0 for Adium                                                                         |
| AISQLLoggerPlugin: Copyright (C) 2003 Jeffrey Melloy.                                                   |
| <jmelloy@visualdistortion.org> <http://www.visualdistortion.org/adium/>                                 |
| Adium: Copyright (C) 2001-2004 Adam Iser. <adamiser@mac.com> <http://www.adiumx.com>                    |---\
\---------------------------------------------------------------------------------------------------------/   |
  | This program is free software; you can redistribute it and/or modify it under the terms of the GNU        |
  | General Public License as published by the Free Software Foundation; either version 2 of the License,     |
  | or (at your option) any later version.                                                                    |
  |                                                                                                           |
  | This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even    |
  | the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General         |
  | Public License for more details.                                                                          |
  |                                                                                                           |
  | You should have received a copy of the GNU General Public License along with this program; if not,        |
  | write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.    |
  \----------------------------------------------------------------------------------------------------------*/

/**
 *
 * $Revision: 819 $
 * $Date: 2004-06-26 10:50:46 -0500 (Sat, 26 Jun 2004) $
 * $Author: jmelloy $
 *
 **/

#define KEY_SQL_LOGGER_ENABLE		@"Enable SQL Logging"
#define PREF_GROUP_SQL_LOGGING		@"SQLLogging"
#define SQL_LOGGING_DEFAULT_PREFS   @"SQLLogging"
#define KEY_SQL_USERNAME			@"Username"
#define KEY_SQL_PASSWORD			@"Password"
#define KEY_SQL_URL					@"URL"
#define KEY_SQL_PORT				@"Port"
#define KEY_SQL_DATABASE			@"Database"

#import "libpq-fe.h"
@class JMSQLLoggerAdvancedPreferences;

@interface AISQLLoggerPlugin : AIPlugin <AIPluginInfo> {
    JMSQLLoggerAdvancedPreferences  *advancedPreferences;
    PGconn                          *conn;

	NSString	*username;
	NSString	*url;
	NSString	*port;
	NSString	*database;
	NSString	*password;

	bool		observingContent;
}

@end
