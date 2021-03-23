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
	displayText = [text copy];
}

- (NSString *) displayText
{
	return displayText;
}

- (void) setDocumentContentKind: (NSXMLDocumentContentKind) kind
{
	documentContentKind = kind;
}

- (NSXMLDocumentContentKind) documentContentKind 
{
	return documentContentKind;
}


@end
