/* MenuDelegate */

#import <Cocoa/Cocoa.h>

@interface MenuDelegate : NSObject
{
    IBOutlet NSMenuItem *logMenuItem;
    IBOutlet NSPanel *logWindow;
}
- (IBAction)toggleLogWindow:(id)sender;
@end
