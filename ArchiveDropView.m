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
	// [dict setValue:color forKey:NSForegroundColorAttributeName];
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
        [self registerForDraggedTypes:[NSArray arrayWithObjects: NSPasteboardTypeFileURL, nil]];
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
	logMessage(logOutput, [NSColor redColor], message);
}

- (void)logWarning:(NSString*) message
{
	logMessage(logOutput, [NSColor orangeColor], message);
}

- (void)logInfo:(NSString*) message
{
	logMessage(logOutput, [NSColor blueColor], message);
}

- (void)logResult:(NSString*) message
{
	logMessage(logOutput, [NSColor darkGrayColor], message);
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	[logOutput selectAll:self];
    [logOutput insertText:@"" replacementRange:logOutput.selectedRange];
    NSPasteboard *pboard = [sender draggingPasteboard];
	
	///////////////////////////////////
	// This probably shouldn't be here
	
	//get the user defined index name
	NSString * indexFileName = [[userDefaults values] valueForKey:@"WAEIndexName"];
	if (indexFileName == nil || [indexFileName length] == 0) {
		indexFileName = @"index.html";
	}
	
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
	///////////////////////////////////
	
    // Prompt the user to choose a directory for saving files
    NSURL *selectedDirectoryURL = [self selectDirectory];
    if (!selectedDirectoryURL) {
        // No directory was selected
        return NO;
    }

    if ( [[pboard types] containsObject:NSPasteboardTypeFileURL]) {
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
        //NSLog(@"%i\n", numberOfFiles);
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
			[self logInfo:[NSString stringWithFormat: NSLocalizedStringFromTable(@"processing", @"InfoPlist", @"processing file: 1 name"), fileName] ];
			
			if ([fileName hasSuffix:@"webarchive"])
			{
				NSFileManager * fm = [NSFileManager defaultManager];
				NSString * dirPath = [fileName stringByDeletingLastPathComponent];
				
                if (![dirPath hasSuffix:@"/"])
                    dirPath = [dirPath stringByAppendingString:@"/"];
                
                [self logInfo:[NSString stringWithFormat: @"using %@ directory", dirPath] ];
                
				if ([fm isWritableFileAtPath:dirPath])
				{
					NSString * archiveName = [[fileName lastPathComponent] stringByDeletingPathExtension];
					// NSString * outputPath  =  [dirPath stringByAppendingPathComponent: archiveName];
					
                    // Instead of using the original directory, use the user-selected directory
                    NSString * outputPath = [selectedDirectoryURL.path stringByAppendingPathComponent:[fileName lastPathComponent]];
                    outputPath = [outputPath stringByDeletingPathExtension]; // Remove file extension
                    outputPath = [outputPath stringByAppendingPathExtension:@"output"];  // Optional, change this as needed

					NSUInteger i = 0;
					while([fm fileExistsAtPath:outputPath])
					{
						[self logWarning:[NSString stringWithFormat: NSLocalizedStringFromTable(@"folder exists", @"InfoPlist", @"folder already exists: 1 name"), outputPath] ];
						NSString * dirName = [archiveName stringByAppendingString:@"-%tu"];
						outputPath  = [dirPath stringByAppendingPathComponent: [NSString stringWithFormat: dirName, i++]];
					}
					
					Extractor * extr = [[Extractor alloc] init];
					[extr loadWebArchive: fileName];
					[extr setEntryFileName: indexFileName];
					[extr setContentKind: type];
					[extr setURLPrepend: URLPrepend];
					NSString * mainResourcePath = [extr extractResources: outputPath];
                    
					[self logResult:[NSString stringWithFormat: NSLocalizedStringFromTable(@"extract success", @"InfoPlist", @"extract success 1=folder name 2=main file"), outputPath, mainResourcePath]];
					
				}
                else
                {
                    NSError *attributeserror = nil;
                    NSDictionary *sourceAttributes = [fm attributesOfItemAtPath:dirPath error: &attributeserror];
                    [self logInfo:[NSString stringWithFormat: @"%@ directory is not writable: %@ %@", dirPath, attributeserror, sourceAttributes] ];
                }
			}
			else
			{
				[self logError: NSLocalizedStringFromTable(@"not archive", @"InfoPlist", @"")];
			}
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
	
    if ([[pboard types] containsObject:NSPasteboardTypeFileURL]) {
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
