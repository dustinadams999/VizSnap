//
//  UserDataManager.m
//  WhatIsThis
//
//  Created by 原田 丞 on 12/03/07.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import <RestKit/RestKit.h>
#import "UserManager.h"
#import "NSDictionary+JSON.h"

@interface UserManager () <RKRequestDelegate, RKObjectLoaderDelegate>

@property (nonatomic, readwrite, strong) User* currentUser;

@end

@implementation UserManager {
    RKObjectManager* objectManager;
    RKClient *rkClient;
    
    NSString *authenticatingUserId;
    NSMutableData *downloadedData;
    void (^authenticationCallback)(User*, NSString*);
}

static NSString *const kServerBaseURL = @"https://at-mobile.trl.ibm.com";
// FIX: a hack for now to get [NSData dataWithContentsOfURL] to work.
static NSString *const kUnsecureServerBaseURL = @"http://at-mobile.trl.ibm.com";
//static NSString *const kServerBaseURL = @"http://localhost:8080";
static NSString *const kUserRequestURL = @"/maps/api/users/json";

@synthesize currentUser = _currentUser;

+ (UserManager*)sharedManager
{
    static dispatch_once_t pred;
    static UserManager* sharedManager = nil;
    dispatch_once(&pred, ^{ sharedManager = [[self alloc] init]; });
    return sharedManager;
}

- (id)init
{
    if ((self = [super init])) {
        [self loadUserFromCache];
        
        rkClient = [RKClient clientWithBaseURL:[NSURL URLWithString:kServerBaseURL]];
        [RKClient sharedClient].disableCertificateValidation = YES;

        objectManager = [RKObjectManager objectManagerWithBaseURL:[NSURL URLWithString:kServerBaseURL]];
        objectManager.serializationMIMEType = RKMIMETypeJSON;
        objectManager.acceptMIMEType = RKMIMETypeJSON;
    }
    return self;
}

- (void)authenticateWithUserID:(NSString*)userId password:(NSString*)password callback:(void (^)(User*, NSString*))callback
{
    [self logoutCurrentUser];
    authenticationCallback = callback;
    authenticatingUserId = userId;
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"get-credential", @"action",
                            userId, @"userId",
                            password, @"password",
                            nil];
    
    [rkClient post:kUserRequestURL params:params delegate:self];
}

- (void)logoutCurrentUser
{
    if (self.currentUser != nil) {
        [self saveUserToCache:nil];
        self.currentUser = nil;
    }
}

- (User*)loadUserFromCache
{
    NSString* credential = [[NSUserDefaults standardUserDefaults] objectForKey:@"credential"];
    NSString* userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    
    self.currentUser = nil;
    if (credential != nil && userId != nil) {
        self.currentUser = [[User alloc] initWithUserId:userId credential:credential supporterGroups:[self getSupporterGroupsForUserWithCredential:credential]];
    }
    
    return self.currentUser;
}

- (NSArray *)getSupporterGroupsForUserWithCredential:(NSString *)credential
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"get-groups", @"action",
                            credential, @"credential",
                            nil];
    
    NSString *urlString = [[kUnsecureServerBaseURL stringByAppendingString:kUserRequestURL] stringByAppendingQueryParameters:params];

    NSError *error;
    NSDictionary *jsonDict = [NSDictionary dictionaryWithContentsOfJSONURLString:urlString error:&error];

    return jsonDict.allKeys;
}

- (void)saveUserToCache:(User *)user
{
    NSString *userId = nil;
    NSString *credential = nil;
    
    if (user != nil) {
        userId = user.userId;
        credential = user.credential;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"userId"];
    [[NSUserDefaults standardUserDefaults] setObject:credential forKey:@"credential"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)successfullyAuthenticatedUser:(User *)user
{
    authenticatingUserId = nil;
    
    [self saveUserToCache:user];

    self.currentUser = user;
    
    if (authenticationCallback != nil) {
        authenticationCallback(self.currentUser, nil);
    }
}

- (void)failedToAuthenticateUser:(NSString *)errorMessage
{
    authenticatingUserId = nil;

    if (authenticationCallback != nil) {
        authenticationCallback(nil, errorMessage);
    }
}

#pragma mark - RKRequestDelegate

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
    if ([request isPOST] && [kUserRequestURL isEqualToString:[request.URL path]]) {
        if ([response isOK]) {
            id<RKParser> parser = [[RKParserRegistry sharedRegistry] parserForMIMEType:RKMIMETypeJSON];
            NSError *error = nil;
            NSDictionary *jsonData = [parser objectFromString:[response bodyAsString] error:&error];
            if (jsonData != nil) {
                NSString *credential = nil;
                if ((credential = [jsonData objectForKey:@"credential"]) != nil) {
                    [self successfullyAuthenticatedUser:[[User alloc] initWithUserId:authenticatingUserId credential:credential supporterGroups:[self getSupporterGroupsForUserWithCredential:credential]]];
                    return;
                }
            }
        }

        [self failedToAuthenticateUser:@"Unable to log in."];
    }
}

- (void)requestDidTimeout:(RKRequest *)request
{
    [self failedToAuthenticateUser:@"Unable to connect to the authentication server."];
}

- (void)requestDidCancelLoad:(RKRequest *)request
{
    [self failedToAuthenticateUser:@"Unable to connect to the authentication server."];
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error
{
    [self failedToAuthenticateUser:@"Unable to connect to the authentication server."];
}

#pragma mark - RKObjectLoaderDelegate

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    NSLog(@"RouteFetcher: Encountered RestKit error while getting routes: %@", error);
    
    NSString *errorMessage = [NSString stringWithFormat:@"Error accessing %@.", objectLoader.URL];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:errorMessage
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];

    // FIX: 
    NSDictionary *data = objectLoader.userData;
    FavoritePOIsFetcherCallback callback = [data objectForKey:@"callback"];
    if (callback != nil) {
        callback();
    }
}

@end
