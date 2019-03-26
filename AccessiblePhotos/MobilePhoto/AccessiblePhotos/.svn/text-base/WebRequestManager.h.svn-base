//
//  WebRequestManager.h
//  TurnByTurn
//
//  Created by 原田 丞 on 12/03/23.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "User.h"

@interface RequestSubmission : NSObject

@property (nonatomic, assign) NSDate *timestamp;
@property (nonatomic, assign) int requestId;
@property (nonatomic, copy) NSString *group;
@property (nonatomic, copy) NSString *question;
@property (nonatomic, strong) NSMutableArray *media;
@property (nonatomic, copy) NSString *responseURL;

+ (RKObjectMapping*)objectMapping;

@end


@interface RequestResponse : NSObject

@property (nonatomic, assign) int requestId;
@property (nonatomic, copy) NSString *answer;

+ (RKObjectMapping*)objectMapping;

@end


@protocol WebRequestManagerDelegate <NSObject>

@optional

- (void)startedUploadingImage;
- (void)uploadedImageBytes:(int)uploadedBytes outOfTotalBytes:(int)totalBytes;
- (void)finishedUploadingImageAtURL:(NSString *)imageURL withRequestID:(int)requestID;
- (void)failedUploadingImage;
- (void)gotResponse:(RequestResponse *)response toRequest:(RequestSubmission *)request;

@end

@interface WebRequestManager : NSObject <RKRequestDelegate>

@property (nonatomic, weak) id <WebRequestManagerDelegate> delegate;

+ (WebRequestManager *)sharedManager;

- (void)uploadImage:(UIImage *)image forUser:(User *)user toGroup:(NSString *)group withMessage:(NSString *)message;

@end
