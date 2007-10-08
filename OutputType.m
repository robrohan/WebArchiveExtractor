//
//  OutputType.m
//  WebArchiveExtractor
//
//  Created by Rob Rohan on 10/8/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "OutputType.h"


@implementation OutputType

- (void) setDisplayText: (NSString *) text
{
	/* [text retain];
	[displayText release];
	displayText = text; */
	text = [text copy];
	[displayText release];
	displayText = text;
}

- (NSString *) displayText
{
	return displayText;
}

- (void) setDocumentContentKind: (int) kind
{
	documentContentKind = kind;
}

- (int) documentContentKind 
{
	return documentContentKind;
}


@end
