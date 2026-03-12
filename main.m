//
//  main.m
//  WebArchiveExtractor
//
//  Created by Rob Rohan on 9/18/07.
//  Copyright __MyCompanyName__ 2007. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Extractor.h"
#include <unistd.h>

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
    int opt;
    NSString *fileName = nil;
    NSString *dirName = nil;
    
    while ((opt = getopt(argc, (char * const *)argv, "hi:o:")) != -1) {
        switch (opt) {
            case 'h':
                printf("Usage: %s [-h] [-i WebArchiveFile] [-o OuputDirectory]\n", argv[0]);
                printf("  -h                 Show this help message\n");
                printf("  -i WebArchiveFile  The WebArchive (.webarchive) file\n");
                printf("  -o OuputDirectory  The directory to output extracted data\n");
                exit(0);

            case 'i':
                fileName = [NSString stringWithUTF8String:optarg];
                break;

            case 'o':
                dirName = [NSString stringWithUTF8String:optarg];
                break;

            case '?':
                // XCode and friends pass other flags we need to
                // just ignore.
                break;
        }
    }
    
    if (fileName != nil)
    {
        Extractor * extr = [[Extractor alloc] init];
        if(dirName != nil)
        {
            [extr setOutputPath:dirName];
        }
        [extr extractAuto:fileName dropViewRef:nil];
        exit(0);
    }

    return NSApplicationMain(argc, (const char **) argv);
}
