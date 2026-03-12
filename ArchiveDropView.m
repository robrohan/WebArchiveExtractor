//
//  Apple Public Source License
//  http://www.opensource.apple.com/apsl/
//
//  Created by Vitaly Davidenko on 12/10/06.
//  Copyright 2006 Vitaly Davidenko.
//
//	Updated and refactored by Rob Rohan on 2007-09-18

#import "ArchiveDropView.h"
#import "Extractor.h"
#import "OutputType.h"

static void logMessage(NSTextView* log, NSColor* color, NSString* message)
{
	[log setEditable:YES];
	
	NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary: [log typingAttributes]];
	[dict setValue:color forKey:NSForegroundColorAttributeName];
	[log setTypingAttributes:dict];
    [log insertText: message replacementRange: [log selectedRange]];
    [log insertText: @"\n" replacementRange: [log selectedRange]];
    [log setEditable:NO];
	[log displayIfNeeded];
}

@implementation ArchiveDropView

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		// Add initialization code here
		[self registerForDraggedTypes:[NSArray arrayWithObjects: NSFilenamesPboardType, nil]];
		
		//set the drop target image
		NSImage *newImage = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForImageResource: @"extract_archive.png"]];
		[self setImage:newImage];
	}
	return self;
}

- (void)drawRect:(NSRect)rect
{
	NSRect ourBounds = [self bounds];
    NSImage *image = [self image];
    [super drawRect:rect];
    
    NSPoint centeredOrigin = NSMakePoint(
        ourBounds.origin.x + (ourBounds.size.width - image.size.width)  / 2.0,
        ourBounds.origin.y + (ourBounds.size.height - image.size.height) / 2.0
    );
    [image drawAtPoint:centeredOrigin
              fromRect:NSZeroRect
             operation:NSCompositingOperationSourceOver
              fraction:1.0];
}

- (void)setImage:(NSImage *)newImage
{
    _dropImage = newImage;
}

- (NSImage *)image
{
    return _dropImage;
}


- (void)logError:(NSString*) message
{
    printf("%s\n", message.UTF8String);
	logMessage(logOutput, [NSColor redColor], message);
}

- (void)logWarning:(NSString*) message
{
    printf("%s\n", message.UTF8String);
	logMessage(logOutput, [NSColor orangeColor], message);
}

- (void)logInfo:(NSString*) message
{
    printf("%s\n", message.UTF8String);
	logMessage(logOutput, [NSColor blueColor], message);
}

- (void)logResult:(NSString*) message
{
    printf("%s\n", message.UTF8String);
	logMessage(logOutput, [NSColor darkGrayColor], message);
}


- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	[logOutput selectAll:self];
    [logOutput insertText:@"" replacementRange:logOutput.selectedRange];
    NSPasteboard *pboard = [sender draggingPasteboard];
	
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        NSUInteger numberOfFiles = [files count];
        
        NSUInteger i;
        for (i=0; i<numberOfFiles; i++)
        {
            NSString* fileName = [files objectAtIndex:i];
            Extractor * extr = [[Extractor alloc] init];
            [extr extractAuto:fileName dropViewRef:self];
        }
    }
    return YES;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender 
{
    NSPasteboard *pboard;
    pboard = [sender draggingPasteboard];
	
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
		return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender 
{
}

- (void)draggingEnded:(id <NSDraggingInfo>)sender 
{
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    return YES;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
}

@end
