//
//  CapturedContextManager.m
//  NewAppPrototype
//
//  Created by 原田 丞 on 12/07/12.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import "CapturedContextManager.h"
#import "CapturedContextDateBasedGrouper.h"

@implementation CapturedContextManager
{
    NSString *dataDirPath;
    NSString *capturedContextListFilePath;
    NSMutableArray *capturedContexts;
    
    CapturedContextDateBasedGrouper *dateBasedGrouper;
}

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
        
        capturedContexts = [NSMutableArray new];
        dateBasedGrouper = [CapturedContextDateBasedGrouper new];
        
        [self reloadCapturedContextList];
        
        NSLog(@"Read in %d captured contexts.", self.capturedContexts.count);
    }
    return self;
}

#pragma mark - Property accessor methods

- (NSArray *)capturedContexts
{
    return [NSArray arrayWithArray:capturedContexts];
}

- (TreeNode *)dateBasedGroupingRoot
{
    return dateBasedGrouper.groupingRootNode;
}

#pragma mark - Public instance methods

// Re-initializes the list of CapturedContexts by reading in the CapturedContexts.plist
// from disk.
- (void)reloadCapturedContextList
{
    NSLog(@"### START Reload captured context list");
    
    [capturedContexts removeAllObjects];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:capturedContextListFilePath])
    {
        NSData *data = [[NSData alloc] initWithContentsOfFile:capturedContextListFilePath];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        capturedContexts = [unarchiver decodeObjectForKey:@"CapturedContextList"];
        [unarchiver finishDecoding];
    }
    
    [self recreateGroupings];

    NSLog(@"### FINISHED Reload captured context list");
}

// Save out the CapturedContext list to disk.
- (void)saveCapturedContextList
{
    NSLog(@"### START Save captured context list");

    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:capturedContexts forKey:@"CapturedContextList"];
    [archiver finishEncoding];
    [data writeToFile:capturedContextListFilePath atomically:YES];

    NSLog(@"### FINISHED Save captured context list");
}

- (void)addCapturedContext:(CapturedContext *)capturedContext
{
    [capturedContext updatePlacemark:^{
        [self saveCapturedContextList];
    }];
    [capturedContexts addObject:capturedContext];
    [self addToGroupings:capturedContext];
    [self saveCapturedContextList];
}

- (void)permanentlyDeleteCapturedContext:(CapturedContext *)capturedContext
{
    NSError *error = nil;
    
    [capturedContexts removeObject:capturedContext];
    
    // Remove the photo file.
    if ([[NSFileManager defaultManager] removeItemAtPath:capturedContext.photoFilePath error:&error] == NO)
    {
        NSLog(@"ERROR: removing photo at %@, error: %@", capturedContext.photoFilePath, [error localizedDescription]);
    }
    
    // Remove the audio file.
    error = nil;
    if ([[NSFileManager defaultManager] removeItemAtPath:capturedContext.ambientAudioFilePath error:&error] == NO)
    {
        NSLog(@"ERROR: removing audio at %@, error: %@", capturedContext.ambientAudioFilePath, [error localizedDescription]);
    }
    
    // Remove the memo file.
    error = nil;
    if ([[NSFileManager defaultManager] removeItemAtPath:capturedContext.memoFilePath error:&error] == NO)
    {
        NSLog(@"ERROR: removing memo at %@, error: %@", capturedContext.memoFilePath, [error localizedDescription]);
    }

    [self removeFromGroupings:capturedContext];
    [self saveCapturedContextList];
}

- (void)permanentlyDeleteAllCapturedContexts
{
    for (CapturedContext *capturedContext in self.capturedContexts)
    {
        [self permanentlyDeleteCapturedContext:capturedContext];
    }
}

#pragma mark - Private instance methods

- (void)addToGroupings:(CapturedContext *)capturedContext
{
    [dateBasedGrouper addCapturedContext:capturedContext];
}

- (void)removeFromGroupings:(CapturedContext *)capturedContext
{
    [dateBasedGrouper removeCapturedContext:capturedContext];
}

- (void)recreateGroupings
{
    // Recreate the date-based grouper
    [dateBasedGrouper reset];
    for (CapturedContext *capturedContext in self.capturedContexts)
    {
        [dateBasedGrouper addCapturedContext:capturedContext]; 
    }
}

@end
