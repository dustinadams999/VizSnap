//
//  CapturedContext.m
//  NewAppPrototype
//
//  Created by 原田 丞 on 12/07/12.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import "CapturedContext.h"
#import "LocationManager.h"
#import "Settings.h"
#import "FileUtils.h"
#import <AVFoundation/AVFoundation.h>

typedef void (^PlacemarkUpdateCompletionHandler)();

@implementation CapturedContext
{
    CLGeocoder *geocoder;
}

@synthesize timestamp = _timestamp;
@synthesize timeZone = _timeZone;
@synthesize uiImage = _uiImage;
@synthesize photoFilename = _photoFilename;
@synthesize photoFilePath = _photoFilePath;
@synthesize ambientAudioFilename = _ambientAudioFilename;
@synthesize ambientAudioFilePath = _ambientAudioFilePath;
@synthesize memoAudioFilename = _memoAudioFilename;
@synthesize memoFilePath = _memoFilePath;
@synthesize taggedForSending = _taggedForSending;
@synthesize ambientAudioDuration = _ambientAudioDuration;

@synthesize location = _location;
@synthesize heading = _heading;
@synthesize placemark = _placemark;
@synthesize keywords;


- (id)init
{
    if (self = [super init])
    {
        _timestamp = [NSDate date];
        _timeZone = [NSTimeZone localTimeZone];
        _location = ([Settings sharedInstance].saveLocationInfo ? [LocationManager sharedManager].location : nil);
        _heading = ([Settings sharedInstance].saveCompassInfo ? [LocationManager sharedManager].heading : nil);
        _placemark = nil;
        _taggedForSending = NO;
    }
    return self;
}

#pragma mark - Property accessor methods

- (void)setPhotoFilename:(NSString *)photoFilename
{
    _photoFilename = photoFilename;
    if (_photoFilename == nil)
    {
        _photoFilePath = nil;
    }
    else
    {
        _photoFilePath = [FileUtils pathToUserDataFile:_photoFilename];
    }
}

- (void)setAmbientAudioFilename:(NSString *)ambientAudioFilename
{
    _ambientAudioFilename = ambientAudioFilename;
    if (_ambientAudioFilename == nil)
    {
        _ambientAudioFilePath = nil;
    }
    else
    {
        // FIX: here, potentially add subdirectory based on username.
        _ambientAudioFilePath = [FileUtils pathToUserDataFile:_ambientAudioFilename];
    }
    [self updateAmbientAudioDuration];
}

- (void)setMemoAudioFilename:(NSString *)memoAudioFilename
{
    _memoAudioFilename = memoAudioFilename;
    if (_memoAudioFilename == nil)
    {
        _memoFilePath = nil;
    }
    else
    {
        // FIX: here, potentially add subdirectory based on username.
        _memoFilePath = [FileUtils pathToUserDataFile:_memoAudioFilename];
    }
}

- (BOOL)photoFileExists
{
    return (self.photoFilePath != nil && [[NSFileManager defaultManager] fileExistsAtPath:self.photoFilePath]);
}

- (BOOL)ambientAudioFileExists
{
    return (self.ambientAudioFilePath != nil && [[NSFileManager defaultManager] fileExistsAtPath:self.ambientAudioFilePath]);
}

- (BOOL)memoAudioFileExists
{
    return (self.memoFilePath != nil && [[NSFileManager defaultManager] fileExistsAtPath:self.memoFilePath]);
}

#pragma mark - Public instance methods

+ (NSString *)fullPathToDataFile:(NSString *)dataFileRelativePath
{
    // TODO: potentially add username subdirectory
    return [FileUtils pathToUserDataFile:dataFileRelativePath];
}

- (NSString *)timestampedFilenameWithSuffix:(NSString *)suffix extension:(NSString *)extension
{
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil)
    {
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy-MM-dd_HH.mm.ss_ZZZ";
        dateFormatter.timeZone = [NSTimeZone localTimeZone];
    }
    NSString *filename = [dateFormatter stringFromDate:self.timestamp];
    if (suffix != nil)
    {
        filename = [filename stringByAppendingString:suffix];
    }
    if (extension != nil)
    {
        filename = [filename stringByAppendingPathExtension:extension];
    }
    return filename;
}

- (void)updatePlacemark:(PlacemarkUpdateCompletionHandler)completionHandler
{
    if (_placemark == nil && _location != nil)
    {
        NSLog(@"Fetching placemark for location (%f, %f)", _location.coordinate.longitude, _location.coordinate.latitude);
        geocoder = [CLGeocoder new];
        
        PlacemarkUpdateCompletionHandler handlerCopy = nil;
        if (completionHandler != nil)
        {
            handlerCopy = [completionHandler copy];
        }
        
        [geocoder reverseGeocodeLocation:_location completionHandler:^(NSArray *placemarks, NSError *error)
         {
             geocoder = nil;
             NSLog(@"Got %d placemarks for location (%f, %f)", placemarks.count, _location.coordinate.longitude, _location.coordinate.latitude);
             if (placemarks.count > 0)
             {
                 // FIX: ignoring others?
                 _placemark = [placemarks objectAtIndex:0];
                 NSLog(@" Placemark: %@", _placemark);
                 if (handlerCopy != nil)
                 {
                     handlerCopy();
                 }
             }
         }];
    }
    else if (completionHandler != nil)
    {
        completionHandler();
    }
}

#pragma mark - NSCoding overrides

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        _timestamp = (NSDate *)[aDecoder decodeObjectForKey:@"timestamp"];
        _timeZone = (NSTimeZone *)[aDecoder decodeObjectForKey:@"timeZone"];
        _location = [aDecoder decodeObjectForKey:@"location"];
        _heading = [aDecoder decodeObjectForKey:@"heading"];
        _placemark = [aDecoder decodeObjectForKey:@"placemark"];
        _taggedForSending = [aDecoder decodeBoolForKey:@"taggedForSending"];
        _ambientAudioDuration = [aDecoder decodeDoubleForKey:@"ambientAudioDuration"];

        self.photoFilename = [aDecoder decodeObjectForKey:@"photoFilename"];
        self.ambientAudioFilename = [aDecoder decodeObjectForKey:@"ambientAudioFilename"];
        self.memoAudioFilename = [aDecoder decodeObjectForKey:@"memoAudioFilename"];
        
        if (_ambientAudioDuration == 0.0)
        {
            [self updateAmbientAudioDuration];
        }
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.timestamp forKey:@"timestamp"];
    [aCoder encodeObject:self.timeZone forKey:@"timeZone"];
    [aCoder encodeObject:self.location forKey:@"location"];
    [aCoder encodeObject:self.heading forKey:@"heading"];
    [aCoder encodeObject:self.placemark forKey:@"placemark"];
    [aCoder encodeBool:self.taggedForSending forKey:@"taggedForSending"];
    [aCoder encodeDouble:self.ambientAudioDuration forKey:@"ambientAudioDuration"];

    [aCoder encodeObject:self.photoFilename forKey:@"photoFilename"];
    [aCoder encodeObject:self.ambientAudioFilename forKey:@"ambientAudioFilename"];
    [aCoder encodeObject:self.memoAudioFilename forKey:@"memoAudioFilename"];
}

#pragma mark - Property accessor overrides

- (UIImage *)uiImage
{
    if (_uiImage == nil && [self photoFileExists])
    {
        // FIX: keeping a reference to the UIImage here may be slowing down viewAll,
        // where cells that are not shown anymore still has their images held onto.
        // FIX: but more likely, loading full-size image here for the small thumbnail in
        // cell view is probably worse.
        // TODO: save a thumbnail
        _uiImage = [UIImage imageWithContentsOfFile:self.photoFilePath];
        
    }
    return _uiImage;
}

- (NSString *)description
{
    return [NSDateFormatter localizedStringFromDate:self.timestamp dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterLongStyle];
}

#pragma mark - Private instance methods

- (void)updateAmbientAudioDuration
{
    if (self.ambientAudioFileExists)
    {
        AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:self.ambientAudioFilePath] options:nil];
        _ambientAudioDuration = CMTimeGetSeconds(audioAsset.duration);
    }
    else
    {
        _ambientAudioDuration = 0.0;
    }
}

@end
