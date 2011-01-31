/*
 *  JMSQLLoggerAdvancePreferences.h
 *  Adium
 * 
 *
 */

@interface JMSQLLoggerAdvancedPreferences: AIPreferencePane {
    IBOutlet    NSButton			*checkbox_enableSQLLogging;
	IBOutlet	NSTextField			*text_Username;
	IBOutlet	NSSecureTextField   *text_Password;
	IBOutlet	NSTextField			*text_URL;
	IBOutlet	NSTextField			*text_Port;
	IBOutlet	NSTextField			*text_database;
}

@end
