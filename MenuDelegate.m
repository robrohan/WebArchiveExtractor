#import "MenuDelegate.h"

@implementation MenuDelegate

- (IBAction)toggleLogWindow:(id)sender
{
	if ([logWindow isVisible]) {
		[logWindow close];
        [logMenuItem setTitle: NSLocalizedString(@"Show Log", @"Show the log")];
	} else {
		[logWindow makeKeyAndOrderFront:self];
        [logMenuItem setTitle: NSLocalizedString(@"Hide Log", @"Hide the log")];
	}
}

@end
