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
	
    
    // Prompt the user to choose a directory for saving files
    NSURL *selectedDirectoryURL = [self selectDirectory];
    if (!selectedDirectoryURL) {
        // No directory was selected
        return NO;
    }
    
    if ( [[pboard types] containsObject:NSPasteboardTypeFileURL] ) {
        // This used to just return an array, now it can return an array
        // or an NSString. It's always cool when functions can return different types
        id pasteboardContent = [pboard propertyListForType:NSPasteboardTypeFileURL];
        NSArray *urls = nil;
        if ([pasteboardContent isKindOfClass:[NSArray class]]) {
            urls = pasteboardContent;
        } else if ([pasteboardContent isKindOfClass:[NSString class]]) {
            urls = @[pasteboardContent];
        }
        NSUInteger numberOfFiles = [urls count];

        NSUInteger i;
        for (i=0; i<numberOfFiles; i++)
        {
            NSString *filePath = [urls objectAtIndex:i];
            NSURL *fileURL = [NSURL URLWithString:filePath];
            // Sandboxing can make the URLs look nuts. Try to un-messup the URLS
            if ([filePath hasPrefix:@"file:///.file"]) {
                // Resolve the special URL to a real path
                fileURL = [fileURL URLByResolvingSymlinksInPath];
            }
            NSString *fileName = [fileURL path];
            
            // Instead of using the original directory, use the user-selected directory
            NSString * outputPath = [selectedDirectoryURL.path stringByAppendingPathComponent:[fileName lastPathComponent]];
            outputPath = [outputPath stringByDeletingPathExtension]; // Remove file extension
            
            Extractor * extr = [[Extractor alloc] init];
            [extr setOutputPath:outputPath];
            [extr extractAuto:fileName dropViewRef:self];
        }
    }
    return YES;
}

- (NSURL *)selectDirectory {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:NO];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setTitle:@"Select an Extraction Directory"];
    [NSApp activateIgnoringOtherApps:YES];
    // Show the panel and check if the user selected a directory
    if ([openPanel runModal] == NSModalResponseOK) {
        return [openPanel URL];
    }
    return nil;
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
