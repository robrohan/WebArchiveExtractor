//
//  OutputType.h
//  WebArchiveExtractor
//
//  Created by Rob Rohan on 10/8/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface OutputType : NSObject {
	NSString * displayText;
	int documentContentKind;
}

- (void) setDisplayText: (NSString *) displayText;
- (NSString *) displayText;

- (void) setDocumentContentKind: (int) kind;
- (int) documentContentKind;

@end
