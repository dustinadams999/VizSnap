//
//  UserRequest.m
//  WhatIsThis
//
//  Created by 原田 丞 on 12/03/07.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import "UserRequest.h"

@implementation UserRequest

@synthesize requestID = _requestID;
@synthesize isAnswered = _isAnswered;
@synthesize answer = _answer;

- (id)initWithID:(int)requestID
{
    if (self = [super init]) {
        self.requestID = requestID;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.requestID = [aDecoder decodeIntForKey:@"RequestID"];
        self.isAnswered= [aDecoder decodeBoolForKey:@"IsAnswered"];
        self.answer = [aDecoder decodeObjectForKey:@"Answer"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:self.requestID forKey:@"RequestID"];
    [aCoder encodeBool:self.isAnswered forKey:@"IsAnswered"];
    [aCoder encodeObject:self.answer forKey:@"Answer"];
}

@end
