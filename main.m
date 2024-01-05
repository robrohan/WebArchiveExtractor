//
//  main.m
//  WebArchiveExtractor
//
//  Created by Rob Rohan on 9/18/07.
//  Copyright __MyCompanyName__ 2007. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Extractor.h"

/** Check for input filename in CLI args, if any.
 *  Input arg qualifies as either:
 *      - arg at index 1 that does not start with "-"
 *      - arg directly after an arg that matches exactly "-i"
 *  Return index of filename, or 0 on failure
 */
char * findInputArg(int argc, char *argv[]) {
    if (argc < 2) { return nil; }
    if (argv[1][0]!='-') { return argv[1]; }
    for (int i=1; i<argc-1; i++) {
        if (strcmp(argv[i], "-i")==0) {
            return argv[i+1];
        }
    }
    return nil;
}

/** Check for out dirname in CLI args, if any.
 *  Must be:
 *      - arg directly after an arg that matches exactly "-o"
 *  Return indx of dirname, or 0 on failure
 */
char * findOutputArg(int argc, char *argv[]) {
    if (argc < 3) { return nil; }
    for (int i=1; i<argc-1; i++) {
        if (strcmp(argv[i], "-o")==0) {
            return argv[i+1];
        }
    }
    return nil;
}


int main(int argc, char *argv[])
{
    char * iN = findInputArg(argc, argv);
    char * oN = findOutputArg(argc, argv);
    if (iN != nil) {
        NSString *fileName = [NSString stringWithCString:iN encoding:NSASCIIStringEncoding];
        Extractor * extr = [[Extractor alloc] init];
        if (oN != nil) {
            NSString *dirName = [NSString stringWithCString:oN encoding:NSASCIIStringEncoding];
            [extr setOutputPath:dirName];
        }
        
        [extr extractAuto:fileName dropViewRef:nil];
        exit(0);
    }

    return NSApplicationMain(argc,  (const char **) argv);
}

