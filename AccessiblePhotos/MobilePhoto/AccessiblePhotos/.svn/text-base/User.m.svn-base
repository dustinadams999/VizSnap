//
//  User.m
//  TurnByTurn
//
//  Created by 原田 丞 on 12/04/02.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import "User.h"
#import "UserManager.h"
#import "FileUtils.h"

@implementation User {
}

NSString *const kUnansweredRequestsKey = @"UnansweredRequests";
NSString *const kAnsweredRequestsKey = @"AnsweredRequests";

@synthesize credential = _credential;
@synthesize userId = _userId;
@synthesize unansweredRequests = _unansweredRequests;
@synthesize answeredRequests = _answeredRequests;

@synthesize supporterGroups = _supporterGroups;

- (id)initWithUserId:(NSString*)userId credential:(NSString *)credential supporterGroups:(NSArray *)supporterGroups
{
    if ((self = [super init])) {
        self.userId = userId;
        self.credential = credential;
        _supporterGroups = [NSArray arrayWithArray:supporterGroups];
        
        [self loadUserData];
    }
    
    return self;
}

- (NSString *)userDataFileName
{
    return [NSString stringWithFormat:@"%@_UserData.plist", self.userId];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"UserId: %@\nCredential: %@ Supporter groups: %@",
            self.userId, self.credential, self.supporterGroups];
}

- (void)loadUserData
{
    NSMutableArray* answeredRequests = nil;
    NSMutableArray* unansweredRequests = nil;
    
    NSString *path = [FileUtils pathToUserDataFile:[self userDataFileName]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        
        // Load user requests.
        @try {
            answeredRequests = [unarchiver decodeObjectForKey:kAnsweredRequestsKey];
            unansweredRequests = [unarchiver decodeObjectForKey:kUnansweredRequestsKey];
        }
        @catch (NSException *ex) {
            NSLog(@"User: unable to load user requests from archive.");
        }
        
        [unarchiver finishDecoding];
    }
    
    if (answeredRequests == nil) {
        answeredRequests = [NSMutableArray new];
    }
    self.answeredRequests = answeredRequests;
    
    if (unansweredRequests == nil) {
        unansweredRequests = [NSMutableArray new];
    }
    self.unansweredRequests = unansweredRequests;
}

- (void)saveUserData
{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    
    [archiver encodeObject:self.answeredRequests forKey:kAnsweredRequestsKey];
    [archiver encodeObject:self.unansweredRequests forKey:kUnansweredRequestsKey];
    
    [archiver finishEncoding];
    NSString *path = [FileUtils pathToUserDataFile:[self userDataFileName]];
    [data writeToFile:path atomically:YES];
}

@end

