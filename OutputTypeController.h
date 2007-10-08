//
//  OutputTypeController.h
//  WebArchiveExtractor
//
//  Created by Rob Rohan on 10/8/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface OutputTypeController : NSObject {
	NSMutableArray * outputTypeList;
	NSObject * currentlySelectedItem;
}

- (NSMutableArray *) outputTypeList;

- (void) setOutputTypeList: (NSMutableArray *) list;

////// for key-value change observing ////////
- (void)addObserver:(NSObject *)anObserver 
		 forKeyPath:(NSString *)keyPath
			options:(NSKeyValueObservingOptions)options 
			context:(void *)context;

- (void)removeObserver:(NSObject *)anObserver 
			forKeyPath:(NSString *)keyPath;

@end
