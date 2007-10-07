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

- (void) setEntryFileName:(NSString *) filename;
{
    //NSString *temp = [filename retain];
	NSString *temp = [filename copy];
    [entryFileName release];
    entryFileName = temp;
}

- (NSString *) entryFileName;
{
    return entryFileName;
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
		m_resources = [[NSMutableSet set] retain];
		m_resourceLookupTable = [[NSMutableDictionary dictionary] retain];
	}
	
	NSData * webArchiveContent = [NSData dataWithContentsOfFile:pathToWebArchive];
	WebArchive * archive = [[WebArchive alloc] initWithData:webArchiveContent];
	
	
	m_mainResource = [[archive mainResource] retain] ;
	[self addResource:m_mainResource];
	
	NSArray * subresources = [archive  subresources];
	if (subresources)
	{
		WebResource* resource;
		int i;
		for (i=0; i<[subresources count]; i++)
		{
			resource = (WebResource*) [subresources objectAtIndex:i];
			[self addResource:resource];
		}	
	}
	
	[archive release];
}


-(void) addResource:(WebResource *)resource
{
	[m_resources addObject:resource];
	
	//url of resource
	NSURL* url = [resource URL];
	NSString* absoluteString = [url absoluteString];
	NSString* path = [url path];
	
	//NSLog(@"resource url absoluteString = %s\n", [absoluteString cString] );
    [m_resourceLookupTable setObject:resource forKey:absoluteString];
	
	//NSLog(@"resource url path = %s\n", [path cString] );
	[m_resourceLookupTable setObject:resource forKey:path];
	
	BOOL isFile = [url isFileURL];
	if (isFile)
	{
		//todo
	}
}

- (NSString *) extractResources:(NSString *) path 
{
	NSFileManager * fm = [NSFileManager defaultManager];
	BOOL isDirectory = YES; 
	
	if ([fm fileExistsAtPath:path isDirectory:  &isDirectory])
	{
		if ([fm removeFileAtPath:path handler:nil]==NO)
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
	
	if ([fm createDirectoryAtPath:path attributes:nil]!=YES) 
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
	if ([urlPath isEqual:@"/"])
	{
		//spec case - main resource name is equals site name
		urlPath=@"/__index.html";
	}
	
	NSMutableString * filePath = [NSMutableString stringWithCapacity:[path length]+[urlPath length]];
	[filePath appendString:path];
	
	NSArray * components = [urlPath componentsSeparatedByString:@"/"];
	
	int i;
	for (i=0; i<[components count]; i++)
	{
		NSString * fname = (NSString*) [components objectAtIndex:i];
		if ([fname length] > 0)
		{
			[filePath appendString:@"/"];
			[filePath appendString:fname];
			
			if (i+1 == [components count])
			{
				//last path component - write file
				[self outputResource:resource filePath:filePath packagePath:path];
			}			
			else
			{
				//create directory
				BOOL isDirectory = YES; 
				if (![fm fileExistsAtPath:filePath isDirectory: &isDirectory] && [fm createDirectoryAtPath:filePath attributes:nil]!=YES)
				{
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

- (void) outputResource: (WebResource *) resource filePath: (NSString*) filePath packagePath: (NSString*) packagePath
{
	if (resource == m_mainResource) {
		NSStringEncoding encoding;
		if ([@"UTF-8" isEqualToString: [m_mainResource textEncodingName]]) {
			encoding = NSUTF8StringEncoding;
		} else {
			encoding = NSISOLatin1StringEncoding;
		}

		NSString * source = [[[NSString alloc] autorelease] initWithData:[resource data] 
																encoding: encoding];
		
		NSLog(
			  NSLocalizedStringFromTable(@"resource encoding is", @"InfoPlist", @"Resource encoding"), 
			  [resource textEncodingName]
		);
		
		NSError * err = nil;
		NSXMLDocument * doc = [NSXMLDocument alloc];
		doc = [doc initWithXMLString: source options: NSXMLDocumentTidyHTML error: &err];
		
		if (doc != nil)	{
			[doc autorelease];
			//process images
			err = nil;
			NSArray* images = [doc nodesForXPath:@"descendant::node()[@src] | descendant::node()[@href]" 
										   error: &err];
			if (err != nil) {
				NSLog(
					  NSLocalizedStringFromTable(
												 @"cannot execute xpath", 
												 @"InfoPlist", 
												 @"Xpath execute error"
												 )
					  );
			} else {
				int i;
				for (i=0; i<[images count]; i++) {
					
					NSXMLElement * link = (NSXMLElement*) [images objectAtIndex: i];
					NSXMLNode* href = [link attributeForName: @"href"];
					
					if (href == nil) {
						href = [link attributeForName: @"src"];
					}
					
					if (href != nil) {
						NSString * hrefValue = [href objectValue];
						WebResource * res = [m_resourceLookupTable objectForKey:hrefValue];
						
						if (res != nil) {
							[href setObjectValue:[[[res URL] path] substringFromIndex:1] ];
						}
					}
				}
			}
			
			NSString * filePathXHtml = composeEntryPointPath(packagePath, [self entryFileName]);
			
			[doc setCharacterEncoding: @"UTF-8"];
			
			if (![[doc XMLDataWithOptions: NSXMLDocumentXHTMLKind] writeToFile: filePathXHtml atomically: NO]) {
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

- (void) dealloc {
	[m_mainResource release];
	[m_resources release];
	[m_resourceLookupTable release];
	[super dealloc];
}

@end
