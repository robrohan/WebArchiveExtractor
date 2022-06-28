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
    [image drawAtPoint:(ourBounds.origin) fromRect:rect operation:NSCompositingOperationSourceOver fraction:1];
}

- (void)setImage:(NSImage *)newImage
{
    _dropImage = newImage;
}

- (NSImage *)image
{
    return _dropImage;
}

////////////////////////////////////////////////////////////////

- (void)logError:(NSString*) message
{
    printf("\x1b[1;91m%s\x1b[0m\n", message.UTF8String);
	logMessage(logOutput, [NSColor redColor], message);
}

- (void)logWarning:(NSString*) message
{
    printf("\x1b[33m%s\x1b[0m\n", message.UTF8String);
	logMessage(logOutput, [NSColor orangeColor], message);
}

- (void)logInfo:(NSString*) message
{
    printf("\x1b[34m%s\x1b[0m\n", message.UTF8String);
	logMessage(logOutput, [NSColor blueColor], message);
}

- (void)logResult:(NSString*) message
{
    printf("\x1b[1;32m%s\x1b[0m\n", message.UTF8String);
	logMessage(logOutput, [NSColor darkGrayColor], message);
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	[logOutput selectAll:self];
    [logOutput insertText:@"" replacementRange:logOutput.selectedRange];
    NSPasteboard *pboard = [sender draggingPasteboard];
	
	//get the user selected output type
	//HACK alert. I need to figure out a better way to do this. I thought the User
	//types from the select box would get an object, but it only returns a string :-/
	NSString * outputType = [[userDefaults values] valueForKey:@"WAEOutputType"];
	NSXMLDocumentContentKind type = NSXMLDocumentXHTMLKind;
	if ( [outputType isEqualToString:@"HTML"] ) {
		type = NSXMLDocumentHTMLKind;
	} else if ( [outputType isEqualToString:@"XML"] ) {
		type = NSXMLDocumentXMLKind;
	} else if ( [outputType isEqualToString:@"XHTML"] ) {
		type = NSXMLDocumentXHTMLKind;
	} else if ( [outputType isEqualToString:@"Text"] ) {
		type = NSXMLDocumentTextKind;
	}
	
	NSString * URLPrepend = [[userDefaults values] valueForKey:@"WAEURLOffset"];
	if (URLPrepend == nil || [URLPrepend length] == 0) {
		URLPrepend = @"";
	}
	
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        NSUInteger numberOfFiles = [files count];
		//NSLog(@"%i\n", numberOfFiles);
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
    // NSDragOperation sourceDragMask;
	
    // sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
	
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
		/*
		 if (sourceDragMask & NSDragOperationLink) {
			 return NSDragOperationLink;
		 } else if (sourceDragMask & NSDragOperationCopy) {
			 return NSDragOperationCopy;
		 }
		 */
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
	//[self setNeedsDisplay:YES];
}

@end
