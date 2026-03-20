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

int main(int argc, char *argv[])
{
    int opt;
    NSString *fileName = nil;
    NSString *dirName = nil;
    NSString *url = nil;
    
    while ((opt = getopt(argc, (char * const *)argv, "ho:p:i:")) != -1) {
        switch (opt) {
            case 'h':
                printf("Usage: %s [-h] [-o <OuputDirectory>] [-p <URLPrepend>] -i <WebArchiveFile> \n", argv[0]);
                printf("  -h                 Show this help message\n");
                printf("  -i WebArchiveFile  The WebArchive (.webarchive) file\n");
                printf("  -o OuputDirectory  The directory to output extracted data (optional)\n");
                printf("  -p URLPrepend      URI to add to the front of the assets (optional)\n");
                exit(0);

            case 'i':
                fileName = [NSString stringWithUTF8String:optarg];
                break;

            case 'o':
                dirName = [NSString stringWithUTF8String:optarg];
                break;
                
            case 'p':
                url = [NSString stringWithUTF8String:optarg];
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
        if(url != nil)
        {
            [extr setURLPrepend:url];
        }
        [extr extractAuto:fileName dropViewRef:nil];
        exit(0);
    }

    return NSApplicationMain(argc, (const char **) argv);
}
