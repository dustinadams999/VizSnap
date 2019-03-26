//
//  FileUtils.h
//  TurnByTurn
//
//  Created by 原田 丞 on 12/04/21.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileUtils : NSObject

+ (NSString *)pathToUserDocumentsDirectory;
+ (NSString *)pathToUserDataFile:(NSString *)filename;
+ (NSString *)pathToTempDataFile:(NSString *)filename;
+ (void)encodeObject:(id)object forKey:(NSString *)key toUserDataFile:(NSString *)filename;
+ (id)decodeObjectForKey:(NSString *)key fromUserDataFile:(NSString *)filename;
+ (id)decodeObjectForKey:(NSString *)key fromData:(NSData *)data;

+ (NSString *)timestampedFilenameWithSuffix:(NSString *)suffix extension:(NSString *)extension;

@end
