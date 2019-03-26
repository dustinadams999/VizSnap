//
//  CapturedContextManager.m
//  NewAppPrototype
//
//  Created by 原田 丞 on 12/07/12.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import "CapturedContextManager.h"
#import "CapturedContext.h"

@implementation CapturedContextManager
{
    NSString *dataDirPath;
    NSString *capturedContextListFilePath;
}

@synthesize capturedContexts = _capturedContexts;

static NSString *const kCapturedContextListFilename = @"CapturedContexts.plist";

+ (CapturedContextManager *)sharedManager
{
    static dispatch_once_t pred;
    static CapturedContextManager *sharedInstance = nil;
    dispatch_once(&pred, ^{ sharedInstance = [self new]; });
    return sharedInstance;
}

- (id)init
{
    if (self = [super init])
    {
        NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        dataDirPath = [dirPaths objectAtIndex:0];
        capturedContextListFilePath = [dataDirPath stringByAppendingPathComponent:kCapturedContextListFilename];
        
        _capturedContexts = [NSMutableArray new];
        
        [self reloadCapturedContextList];
        
        NSLog(@"Read in %d captured contexts.", self.capturedContexts.count);
        if (self.capturedContexts.count > 0)
        {
            for (CapturedContext *capturedContext in self.capturedContexts)
            {
                NSLog(@"  Timestamp: %@", capturedContext.timestamp);
            }
        }
    }
    return self;
}

// Re-initializes the list of CapturedContexts by reading in the CapturedContexts.plist
// from disk.
- (void)reloadCapturedContextList
{
    [_capturedContexts removeAllObjects];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:capturedContextListFilePath])
    {
        NSData *data = [[NSData alloc] initWithContentsOfFile:capturedContextListFilePath];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        _capturedContexts = [unarchiver decodeObjectForKey:@"CapturedContextList"];
        [unarchiver finishDecoding];
    }
}

// Save out the CapturedContext list to disk.
- (void)saveCapturedContextList
{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:_capturedContexts forKey:@"CapturedContextList"];
    [archiver finishEncoding];
    [data writeToFile:capturedContextListFilePath atomically:YES];
}

@end
