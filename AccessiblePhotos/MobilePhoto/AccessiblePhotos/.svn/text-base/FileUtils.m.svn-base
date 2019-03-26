//
//  FileUtils.m
//  TurnByTurn
//
//  Created by 原田 丞 on 12/04/21.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import "FileUtils.h"

@implementation FileUtils

+ (NSString *)userDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

+ (NSString *)pathToUserDataFile:(NSString *)filename
{
    return [[FileUtils userDocumentsDirectory] stringByAppendingPathComponent:filename];
}

+ (void)encodeObject:(id)object forKey:(NSString *)key toUserDataFile:(NSString *)filename
{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:object forKey:key];
    [archiver finishEncoding];
    NSLog(@"############## Encoding object and writing to file %@", [FileUtils pathToUserDataFile:filename]);
    [data writeToFile:[FileUtils pathToUserDataFile:filename] atomically:YES];
}

+ (id)decodeObjectForKey:(NSString *)key fromUserDataFile:(NSString *)filename
{
    id object = nil;
    NSString *path = [FileUtils pathToUserDataFile:filename];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        object = [FileUtils decodeObjectForKey:key fromData:data];
    }
    
    return object;
}

+ (id)decodeObjectForKey:(NSString *)key fromData:(NSData *)data
{
    id object = nil;
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    object = [unarchiver decodeObjectForKey:key];
    [unarchiver finishDecoding];
    
    return object;
}

@end
