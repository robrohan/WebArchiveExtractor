//
//  Apple Public Source License
//  http://www.opensource.apple.com/apsl/
//
//  Created by Vitaly Davidenko on 12/10/06.
//  Copyright 2006 Vitaly Davidenko.
//
//	Updated and refactored by Rob Rohan on 2007-09-18
#import "WebArchiveController.h"

@implementation WebArchiveController

- (void)awakeFromNib {
	[mainWindow setDelegate:self];
}

- (void)windowWillClose:(NSNotification *)aNotification {
	[NSApp terminate:self];
}

@end