#import "MenuDelegate.h"

@implementation MenuDelegate

- (IBAction)toggleLogWindow:(id)sender
{
	if ([logWindow isVisible]) {
		[logWindow close];
		[logMenuItem setTitle:@"Show Log"];
	} else {
		[logWindow makeKeyAndOrderFront:self];
		[logMenuItem setTitle:@"Hide Log"];
	}
}

@end
