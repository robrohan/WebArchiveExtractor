//
//  Exctractor.m
//  ExtractorAction
//
//  Created by Vitaly Davidenko on 12/10/06.
//  Copyright 2006 Vitaly Davidenko.
//
//  Apple Public Source License
//  http://www.opensource.apple.com/apsl/
//
//	Updated and refactored by Rob Rohan on 2007-09-18

#import "Extractor.h"


static NSString* composeEntryPointPath(NSString* packagePath, NSString* indexName)
{
	return [packagePath stringByAppendingPathComponent:indexName];
}

@implementation Extractor

- (id) init
{
	self = [super init];
    if(self != nil) {
        ///////////////////////////////////
        // initialize properties with userDefaults settings
        
        //get the user defined index name
        entryFileName = [[userDefaults values] valueForKey:@"WAEIndexName"];
        if (entryFileName == nil || [entryFileName length] == 0) {
            entryFileName = @"index.html";
        }
        
        //default to XHTML if there is nothing else
        contentKind = NSXMLDocumentXHTMLKind;
        
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
        
        // get url prepend
        NSString * URLPrepend = [[userDefaults values] valueForKey:@"WAEURLOffset"];
        if (URLPrepend == nil || [URLPrepend length] == 0) {
            URLPrepend = @"";
        }
        
        // set default output path
        outputPath = @"";
        ///////////////////////////////////

    }
	return self;
}

-(void) extractAuto:(NSString *)fileName
        dropViewRef:(ArchiveDropView *)dropViewRef
{
    // If not running with gui, save relative to CWD
    // Also make an ArchiveDropView for logging
    NSString * dirPath = [fileName stringByDeletingLastPathComponent];
    if (dropViewRef == nil) {
        dirPath = @"./";
        dropViewRef = [[ArchiveDropView alloc] init];
    }
    [dropViewRef logInfo:[NSString stringWithFormat: NSLocalizedStringFromTable(@"processing", @"InfoPlist", @"processing file: 1 name"), fileName] ];
    

    if ([fileName hasSuffix:@"webarchive"])
    {
        NSFileManager * fm = [NSFileManager defaultManager];
        NSString * archiveName = [[fileName lastPathComponent] stringByDeletingPathExtension];
        
        // return if not readable
        if (![fm isReadableFileAtPath:fileName]) {
            [dropViewRef logError:NSLocalizedStringFromTable(@"cannot read", @"InfoPlist", @"")];
            return;
        }
        
        if ([fm isWritableFileAtPath:dirPath])
        {
            // set output path to archiveName if empty
            if ([outputPath isEqual: @""]) {
                outputPath  =  [dirPath stringByAppendingPathComponent: archiveName];
            }
            
            NSUInteger i = 0;
            while([fm fileExistsAtPath:outputPath])
            {
                [dropViewRef logWarning:[NSString stringWithFormat: NSLocalizedStringFromTable(@"folder exists", @"InfoPlist", @"folder already exists: 1 name"), outputPath]];
                NSString * dirName = [archiveName stringByAppendingString:@"-%tu"];
                outputPath  = [dirPath stringByAppendingPathComponent: [NSString stringWithFormat: dirName, i++]];
            }
            
            [self loadWebArchive: fileName];
            [self setURLPrepend: URLPrepend];
            NSString * mainResourcePath = [self extractResources: outputPath];

            if (mainResourcePath != nil) {
                [dropViewRef logResult:[NSString stringWithFormat: NSLocalizedStringFromTable(@"extract success", @"InfoPlist", @"extract success 1=folder name 2=main file"), outputPath, mainResourcePath]];
            } else {
                [dropViewRef logError:NSLocalizedStringFromTable(@"unknown", @"InfoPlist", @"")];
            }
            
        } else {
            [dropViewRef logError:NSLocalizedStringFromTable(@"cannot write", @"InfoPlist", @"")];
        }
    }
    else
    {
        [dropViewRef logError:NSLocalizedStringFromTable(@"not archive", @"InfoPlist", @"")];
    }
}


-(void) loadWebArchive:(NSString*) pathToWebArchive
{
	if (m_resources)
	{
		[m_resources removeAllObjects];
		[m_resourceLookupTable removeAllObjects];
	}
	else
	{
		m_resources = [NSMutableSet set];
		m_resourceLookupTable = [NSMutableDictionary dictionary];
	}
	
	NSData * webArchiveContent = [NSData dataWithContentsOfFile:pathToWebArchive];
	WebArchive * archive = [[WebArchive alloc] initWithData:webArchiveContent];
	
	
	/* Added method parseWebArchive to more easily deal with subframeArchives in a looping fashion
	 Deal with main resource first...may or may not cover it all - Robert Covington artlythere@kagi.com
	12/12/11
	 */
	
	[self parseWebArchive:archive ];
	
	 /*
	 Check for SubFrameArchives - catches anything left over...some sites using frames will
	  invoke this and otherwise would generate only a single HTML index file
	  - Robert Covington artlythere@kagi.com 12/12/11
	 */
// TODO: Causes bad thread access. don't want to bother with this at the moment
#if 0
	NSArray * subArchives = [archive subframeArchives];

    if (subArchives)
    {
        NSUInteger i;
        for (i=0; i<[subArchives count]; i++)
        {
            WebArchive * nuArchive = [WebArchive alloc];
            nuArchive = [subArchives objectAtIndex:i];
            if (nuArchive)
            {
                [self parseWebArchive:nuArchive];
            }
        }

    }  /* end subArchive processing */
#endif
}  /* end method */


-(void) parseWebArchive:(WebArchive *) archiveToParse
{
	/* Added method parseWebArchive to more easily deal with subframeArchives in a looping fashion
	- Robert Covington artlythere@kagi.com
	 12/12/11
	 */
	m_mainResource = [archiveToParse mainResource];
	[self addResource:m_mainResource];
	
	NSArray * subresources = [archiveToParse subresources];
	if (subresources)
	{
		WebResource* resource;
		NSUInteger i;
		for (i=0; i<[subresources count]; i++)
		{
			resource = (WebResource*) [subresources objectAtIndex:i];
			[self addResource:resource];
		}
	}
	
	// [archiveToParse release];
}


-(void) addResource:(WebResource *)resource
{
	[m_resources addObject:resource];
	
	//url of resource
	NSURL* url = [resource URL];
	NSString* absoluteString = [url absoluteString];
	NSString* path = [url path];
	
	if(path != nil) {
		[m_resourceLookupTable setObject:resource forKey:absoluteString];
		[m_resourceLookupTable setObject:resource forKey:path];
	}
}

- (NSString *) extractResources:(NSString *) path
{
	NSFileManager * fm = [NSFileManager defaultManager];
	BOOL isDirectory = YES;
	
	if ([fm fileExistsAtPath:path isDirectory:  &isDirectory])
	{
        //removeItemAtURL:error:
		if ([fm removeItemAtPath:path error:nil] == NO)
		{
			NSLog(
				  NSLocalizedStringFromTable(
											 @"cannot delete",
											 @"InfoPlist",
											 @"cannot delete file - path first param"
											 ),
				  path
				  );
			return nil;
		}
	}
	
    if([fm createDirectoryAtPath:path withIntermediateDirectories:true attributes:nil error:nil] == NO)
	{
		NSLog(
			  NSLocalizedStringFromTable(
										 @"cannot create",
										 @"InfoPlist",
										 @"cannot create file - path first param"
										 ),
			  path
			  );
		return nil;
	}
	
	NSEnumerator *enumerator = [m_resources objectEnumerator];
	id value;
	while ((value = [enumerator nextObject])) {
		WebResource * resource = (WebResource*) value;
		[self extractResource: resource packagePath:path];
	}
	
	return composeEntryPointPath(path, [self entryFileName]);
}


- (void) extractResource:(WebResource *) resource packagePath: (NSString*) path
{
	NSFileManager * fm = [NSFileManager defaultManager];
	
	NSString * urlPath = [[resource URL] path];
	if ([urlPath isEqual:@"/"]) {
		//spec case - main resource name is equals site name
		urlPath=@"/__index.html";
	}
	
	NSMutableString * filePath = [NSMutableString stringWithCapacity:[path length]+[urlPath length]];
	[filePath appendString:path];
	
	NSArray * components = [urlPath componentsSeparatedByString:@"/"];
	
	NSUInteger i;
	for (i=0; i<[components count]; i++) {
		NSString * fname = (NSString*) [components objectAtIndex:i];
		
		if ([fname length] > 0)	{
			[filePath appendString:@"/"];
			[filePath appendString:fname];
			
			if (i+1 == [components count]) {
				//last path component - write file
				[self outputResource:resource filePath:filePath packagePath:path];
			} else {
				//create directory
				BOOL isDirectory = YES;
				if (![fm fileExistsAtPath:filePath isDirectory: &isDirectory] && [fm createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil] != YES) {
					NSLog(
						  NSLocalizedStringFromTable(
													 @"cannot create",
													 @"InfoPlist",
													 @"cannot create file - path first param"
													 ),
						  filePath
						  );
					return;
				}
				
			}
		}
		
	}
}

- (void) outputResource: (WebResource *) resource
			   filePath: (NSString*) filePath
			packagePath: (NSString*) packagePath
{
	if (resource == m_mainResource) {
		NSString *encodingString = [m_mainResource textEncodingName];
		NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef) encodingString));

		NSString * source = [[NSString alloc] initWithData:[resource data]
																encoding: encoding];
		
#if 0
		NSLog(
			  NSLocalizedStringFromTable(@"resource encoding is", @"InfoPlist", @"Resource encoding"),
			  [resource textEncodingName]
		);
#endif
		
		NSError * err = nil;
		NSXMLDocument * doc = [NSXMLDocument alloc];
		doc = [doc initWithXMLString: source options: NSXMLDocumentTidyHTML error: &err];
        
		/*
		 Returns the kind of document content for output.
		- (NSXMLDocumentContentKind)documentContentKind
		 
		Discussion
			Most of the differences among content kind have to do with the handling of content-less
			tags such as <br>. The valid NSXMLDocumentContentKind constants are
			NSXMLDocumentXMLKind, NSXMLDocumentXHTMLKind, NSXMLDocumentHTMLKind,
			and NSXMLDocumentTextKind.
		*/
		[doc setDocumentContentKind: contentKind];
		
		if (doc != nil)	{
			//process images
			err = nil;
			
			NSArray* images = [doc nodesForXPath:@"descendant::node()[@src] | descendant::node()[@href]"
										   error: &err];
			if (err != nil) {
				NSLog(@"%@",
					  NSLocalizedStringFromTable(
												 @"cannot execute xpath",
												 @"InfoPlist",
												 @"Xpath execute error"
												 )
					  );
			} else {
				NSUInteger i;
				for (i=0; i<[images count]; i++) {
					
					NSXMLElement * link = (NSXMLElement *) [images objectAtIndex: i];
					NSXMLNode * href = [link attributeForName: @"href"];
					
					if (href == nil) {
						href = [link attributeForName: @"src"];
					}
					
					if (href != nil) {
						NSString * hrefValue = [href objectValue];
						WebResource * res = [m_resourceLookupTable objectForKey: hrefValue];
						
						if (res != nil) {
							[href setObjectValue: [NSString stringWithFormat:@"%@%@", [self URLPrepend], [[[res URL] path] substringFromIndex:1]]];
						}
					}
				}
			}
			
			NSString * filePathXHtml = composeEntryPointPath(packagePath, [self entryFileName]);
			
			[doc setCharacterEncoding: @"UTF-8"];

			if (![[doc XMLDataWithOptions: NSXMLDocumentTidyHTML] writeToFile: filePathXHtml atomically: NO]) {
				NSLog(
					  NSLocalizedStringFromTable(
												 @"cannot write xhtml",
												 @"InfoPlist",
												 @"xhtml file error"
												 ),
					  filePath
					  );
			}
		} else {
			NSLog(
				  NSLocalizedStringFromTable(
											 @"error code",
											 @"InfoPlist",
											 @"extractor error. error code first param"
											 ),
				  [[err userInfo] valueForKey:NSLocalizedDescriptionKey]
				  );
		}
	} else {
		if (![[resource data] writeToFile:filePath atomically:NO]) {
			NSLog(
				NSLocalizedStringFromTable(
										   @"cannot write xhtml",
										   @"InfoPlist",
										   @"xhtml file error"
										   ),
				filePath
			);
		}
	}
}

- (void) setEntryFileName:(NSString *) filename;
{
    entryFileName = [filename copy];
}

- (NSString *) entryFileName;
{
    return entryFileName;
}

- (void) setURLPrepend:(NSString *) url
{
    URLPrepend = [url copy];
}

- (NSString *) URLPrepend
{
	return URLPrepend;
}

- (void) setContentKind:(NSXMLDocumentContentKind) kind
{
	contentKind = kind;
}

- (NSXMLDocumentContentKind) contentKind
{
	return contentKind;
}

- (void) setOutputPath: (NSString*) path
{
    outputPath = path;
}

@end
