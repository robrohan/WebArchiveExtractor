//
//  OutputTypeController.m
//  WebArchiveExtractor
//
//  Created by Rob Rohan on 10/8/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "OutputTypeController.h"
#import "OutputType.h"

@implementation OutputTypeController

- (id) init
{
	[super init];
	outputTypeList = [[NSMutableArray alloc] init];
	
	//setup all the basic types
	OutputType * tmp = [[OutputType alloc] init];
	[tmp setDisplayText: @"XML"];
	[tmp setDocumentContentKind: NSXMLDocumentXMLKind];
	[outputTypeList addObject: tmp];
	[tmp release];
	
	tmp = [[OutputType alloc] init];
	[tmp setDisplayText: @"HTML"];
	[tmp setDocumentContentKind: NSXMLDocumentHTMLKind];
	[outputTypeList addObject: tmp];
	[tmp release];
	
	tmp = [[OutputType alloc] init];
	[tmp setDisplayText: @"XHTML"];
	[tmp setDocumentContentKind: NSXMLDocumentXHTMLKind];
	[outputTypeList addObject: tmp];
	[tmp release];

	/* tmp = [[OutputType alloc] init];
	[tmp setDisplayText: @"Text"];
	[tmp setDocumentContentKind: NSXMLDocumentTextKind];
	[outputTypeList addObject: tmp];
	[tmp release]; */
	
	return self;
}

- (NSMutableArray *) outputTypeList
{
	return outputTypeList;
}

- (void) setOutputTypeList: (NSMutableArray *) list
{
	//not used we are pre-population the array on object
	//creation. Changing can be added later if needed...
}

- (void)addObserver:(NSObject *)anObserver 
		 forKeyPath:(NSString *)keyPath
			options:(NSKeyValueObservingOptions)options 
			context:(void *)context
{
	//like setting the array, the list wont change durring program
	//execution so just devnull observers.
}

- (void)removeObserver:(NSObject *)anObserver 
			forKeyPath:(NSString *)keyPath
{
	//like setting the array, the list wont change durring program
	//execution so just devnull observers.
}

- (void) dealloc
{
	NSLog(@"Destroying %@", self);
	[outputTypeList release];
	[super dealloc];
}

@end
