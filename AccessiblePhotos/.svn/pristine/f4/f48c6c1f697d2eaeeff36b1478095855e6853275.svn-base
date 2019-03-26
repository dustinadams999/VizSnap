//
//  WebRequestManager.m
//  TurnByTurn
//
//  Created by 原田 丞 on 12/03/23.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//


#import "WebRequestManager.h"
#import "UserManager.h"
#import "NSData+Base64.h"


static NSString *const kRequestMediaDataTypeImage = @"image";
static NSString *const kRequestMediaDataTypeAudio = @"audio";
static NSString *const kRequestMediaDataTypeVideo = @"video";

static NSString *const kRequestMediaDataContentTypeImage = @"image/jpeg";
static NSString *const kRequestMediaDataContentTypeAudio = @"audio/ogg";
static NSString *const kRequestMediaDataContentTypeVideo = @"video/ogg";

@interface RequestMediaData : NSObject

@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *contentType;
@property (nonatomic, copy) NSString *contents;

+ (RKObjectMapping*)objectMapping;

- (void)encodeContent:(NSData *)content;

@end

@implementation RequestMediaData

@synthesize type;
@synthesize contentType;
@synthesize contents;

+ (RKObjectMapping*)objectMapping
{
    static dispatch_once_t pred;
    static RKObjectMapping *objectMapping = nil;
    dispatch_once(&pred, ^{
        objectMapping = [RKObjectMapping mappingForClass:[self class]];
        [objectMapping mapAttributes:@"type", @"contentType", @"contents", nil];
    });
    return objectMapping;
}

- (void)encodeContent:(NSData *)rawContent
{
    self.contents = [rawContent base64Encoding];
}

@end




@implementation RequestSubmission

@synthesize timestamp = _timestamp;
@synthesize requestId = _requestId;
@synthesize group = _group;
@synthesize question = _question;
@synthesize media = _media;
@synthesize responseURL = _responseURL;

+ (RKObjectMapping*)objectMapping
{
    static dispatch_once_t pred;
    static RKObjectMapping *objectMapping = nil;
    dispatch_once(&pred, ^{
        objectMapping = [RKObjectMapping mappingForClass:[self class]];
        [objectMapping mapAttributes:@"requestId", @"group", @"question", nil];
        [objectMapping mapKeyPath:@"location" toAttribute:@"responseURL"];
        [objectMapping mapKeyPath:@"media" toRelationship:@"media" withMapping:[RequestMediaData objectMapping]];
    });
    return objectMapping;
}

- (id)init
{
    if ((self = [super init])) {
        _media = [[NSMutableArray alloc] init];
    }
    return self;
}

@end



@implementation RequestResponse

@synthesize requestId = _requestId;
@synthesize answer = _answer;

+ (RKObjectMapping*)objectMapping
{
    static dispatch_once_t pred;
    static RKObjectMapping *objectMapping = nil;
    dispatch_once(&pred, ^{
        objectMapping = [RKObjectMapping mappingForClass:[self class]];
        [objectMapping mapAttributes:@"requestId", @"answer", nil];
    });
    return objectMapping;
}

@end



@interface WebRequestManager () <RKObjectLoaderDelegate>

- (void)setCookieWithCredential:(NSString*)credential;

@end

@implementation WebRequestManager {
    RKObjectManager* objectManager;
    
    NSMutableArray *pendingRequests;
    NSTimer *pollingTimer;
    BOOL isPolling;
    
    // FIX: ack, hack to distinguish when sending data for image upload
    BOOL isUploadingImage;
    
    
    NSString *loadedResponseString;
}

static double const kPollingInterval = 2.0;
static NSString * const kNoAnswerYet = @"No answer yet... Thank you for your patience.";

static NSString *const kServerBaseURL = @"http://crowdsms.trl.ibm.com";
static NSString *const kRequestPostPath = @"/csms/iquery/requests";
static NSString *const kRequestAnswerPullPath = @"/csms/iquery/requests";

@synthesize delegate = _delegate;

+ (WebRequestManager *)sharedManager
{
    static dispatch_once_t pred;
    static WebRequestManager *sharedManager = nil;
    dispatch_once(&pred, ^{ sharedManager = [[self alloc] init]; });
    return sharedManager;
}

- (id)init
{
    if ((self = [super init])) {
        objectManager = [RKObjectManager objectManagerWithBaseURL:[NSURL URLWithString:kServerBaseURL]];
        objectManager.serializationMIMEType = RKMIMETypeJSON;
        objectManager.acceptMIMEType = RKMIMETypeJSON;
        
        [objectManager.mappingProvider setSerializationMapping:[[RequestMediaData objectMapping] inverseMapping] forClass:[RequestMediaData class]];
        [objectManager.mappingProvider setSerializationMapping:[[RequestSubmission objectMapping] inverseMapping] forClass:[RequestSubmission class]];

        [objectManager.router routeClass:[RequestSubmission class] toResourcePath:kRequestPostPath forMethod:RKRequestMethodPOST];
        
        pendingRequests = [[NSMutableArray alloc] init];
    }
    return self;
}

static inline double radians (double degrees) {return degrees * M_PI/180.0;}

- (void)uploadImage:(UIImage *)image forUser:(User *)user toGroup:(NSString *)group withMessage:(NSString *)message
{
    if (user != nil) {
        [self setCookieWithCredential:user.credential];
        
//        CGSize size = image.size;

//        CGAffineTransform transform = CGAffineTransformIdentity;
//        transform = CGAffineTransformTranslate(transform, size.width / 2.0, size.height / 2.0);
//        transform = CGAffineTransformRotate(transform, radians(90.0));
//        transform = CGAffineTransformScale(transform, 1.0, -1.0);
//        
//        UIGraphicsBeginImageContext(size);
//        CGContextRef context = UIGraphicsGetCurrentContext();
//
//        CGContextConcatCTM(context, transform);
//        
//        CGContextDrawImage(context, CGRectMake(-size.width / 2.0, -size.height / 2.0, size.width, size.height), image.CGImage);
//        
////        image = UIGraphicsGetImageFromCurrentImageContext();
//
////        UIGraphicsEndImageContext();
//        image = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];
//        UIGraphicsEndImageContext();


        
        NSData *imageData = UIImageJPEGRepresentation(image, 0.75); 
            
        RequestSubmission *requestSubmission = [[RequestSubmission alloc] init];
        requestSubmission.group = group;
        requestSubmission.question = message;
        
        RequestMediaData *mediaData = [[RequestMediaData alloc] init];
        mediaData.type = kRequestMediaDataTypeImage;
        mediaData.contentType = kRequestMediaDataContentTypeImage;
        [mediaData encodeContent:imageData];
        
        [requestSubmission.media addObject:mediaData];
     
        isUploadingImage = YES;
        [objectManager postObject:requestSubmission usingBlock:^(RKObjectLoader *loader) {
            loader.delegate = self;
            loader.targetObject = requestSubmission;
            loader.objectMapping = [RequestSubmission objectMapping];
        }];
    }
}

- (void)setCookieWithCredential:(NSString*)credential
{
    NSString * encodedCredential = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)credential, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8 );

    // Set cookie.
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    [cookieProperties setObject:@"requesterCredential" forKey:NSHTTPCookieName];
    [cookieProperties setObject:encodedCredential forKey:NSHTTPCookieValue];
    [cookieProperties setObject:@"crowdsms.trl.ibm.com" forKey:NSHTTPCookieDomain];
    [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
    
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
}

- (void)startPolling
{
    if (isPolling == NO) {
        pollingTimer = [NSTimer scheduledTimerWithTimeInterval:kPollingInterval target:self selector:@selector(pollingTimerTriggered:) userInfo:nil repeats:YES];
        isPolling = YES;
    }
}

- (void)stopPolling
{
    if (isPolling == YES) {
        [pollingTimer invalidate];
        pollingTimer = nil;
        isPolling = NO;
    }
}

- (void)pollingTimerTriggered:(NSTimer *)timer
{
    NSLog(@"#### Polling");
    [objectManager loadObjectsAtResourcePath:kRequestAnswerPullPath usingBlock:^(RKObjectLoader *loader) {
        loader.objectMapping = [RequestResponse objectMapping];
        loader.delegate = self;
    }];
}


#pragma mark - RKObjectLoaderDelegate

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    if ([kRequestPostPath isEqualToString:[objectLoader.response.request.URL path]] && objects.count > 0) {
        if ([[objects objectAtIndex:0] isKindOfClass:[RequestSubmission class]]) {
            isUploadingImage = NO;
            
            RequestSubmission *request = [objects objectAtIndex:0];
            NSLog(@"Got result augmented: ID=%d, question=%@, group=%@, responseURL=%@", request.requestId, request.question, request.group, request.responseURL);
            
            if ([self.delegate respondsToSelector:@selector(finishedUploadingImageAtURL:withRequestID:)])
            {
                [self.delegate finishedUploadingImageAtURL:request.responseURL withRequestID:request.requestId];
            }
            
            [pendingRequests addObject:request];
            
            // FIX: uncomment when What's This supporter UI is actually working
            [self startPolling];
        } else if ([[objects objectAtIndex:0] isKindOfClass:[RequestResponse class]]) {
            for (RequestResponse *requestResponse in objects) {
                for (RequestSubmission *request in pendingRequests) {
                    if (request.requestId == requestResponse.requestId &&
                        [requestResponse.answer isEqualToString:kNoAnswerYet] == NO) {
                        
                        if ([self.delegate respondsToSelector:@selector(gotResponse:toRequest:)])
                        {
                            [self.delegate gotResponse:requestResponse toRequest:request];
                        }
                        
                        [pendingRequests removeObject:request];
                        break;
                    }
                }
            }
            
            if (pendingRequests.count == 0) {
                [self stopPolling];
            }
        }
    } else {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error"
                                                          message:@"Unable to retrieve RequestSubmissionResult from response."
                                                         delegate:self
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];

        NSLog(@"Unable to retrieve RequestSubmissionResult from response.");
        if (isUploadingImage) {
            isUploadingImage = NO;
            if ([self.delegate respondsToSelector:@selector(failedUploadingImage)])
            {
                [self.delegate failedUploadingImage];
            }
        }
    }
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    NSLog(@"Failed to submit request: %@", error);
    if (loadedResponseString != nil){
        NSLog(@"%@", loadedResponseString);
    }
    
    if (isUploadingImage) {
        isUploadingImage = NO;
        if ([self.delegate respondsToSelector:@selector(failedUploadingImage)])
        {
            [self.delegate failedUploadingImage];
        }
    }
}

#pragma mark - RestKit delegates

- (void)requestDidStartLoad:(RKRequest *)request
{
    if (isUploadingImage) {
        if ([self.delegate respondsToSelector:@selector(startedUploadingImage)])
        {
            [self.delegate startedUploadingImage];
        }
    }
}

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
    // DEBUG
    loadedResponseString = response.bodyAsString;
    NSLog(@"#### loaded response: %@", loadedResponseString);
}

- (void)request:(RKRequest *)request didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if (isUploadingImage) {
        if ([self.delegate respondsToSelector:@selector(uploadedImageBytes:outOfTotalBytes:)])
        {
            [self.delegate uploadedImageBytes:totalBytesWritten outOfTotalBytes:totalBytesExpectedToWrite];
        }
    }
}

@end
