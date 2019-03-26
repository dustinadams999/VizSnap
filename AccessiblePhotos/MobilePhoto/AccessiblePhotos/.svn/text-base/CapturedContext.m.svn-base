//
//  CapturedContext.m
//  NewAppPrototype
//
//  Created by 原田 丞 on 12/07/12.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import "CapturedContext.h"
#import "LocationManager.h"

@implementation CapturedContext
{
    CLGeocoder *geocoder;
}

@synthesize timestamp = _timestamp;
@synthesize uiImage = _uiImage;
@synthesize photoFilePath = _photoFilePath;
@synthesize audioFilePath = _audioFilePath;
@synthesize memoFilePath = _memoFilePath;
@synthesize hasMemo = _hasMemo;
@synthesize taggedForSending = _taggedForSending;

@synthesize location = _location;
@synthesize heading = _heading;
@synthesize placemark = _placemark;

- (id)init
{
    // If the no-parameter init is called, use the current time as the timestamp.
    if (self = [self initWithTimestamp:[NSDate date]
                              location:[LocationManager sharedManager].location
                               heading:[LocationManager sharedManager].heading
                             placemark:nil
                      taggedForSending:NO])
    {
    }
    return self;
}

- (id)initWithTimestamp:(NSDate *)timestamp location:(CLLocation *)location heading:(CLHeading *)heading placemark:(CLPlacemark *)placemark taggedForSending:(BOOL)taggedForSending
{
    if (self = [super init]) {
        _timestamp = timestamp;
        _location = location;
        _heading = heading;
        _placemark = placemark;
        _taggedForSending = taggedForSending;

        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy-MM-dd_HH.mm.ss";
        NSString *timestampString = [dateFormatter stringFromDate:self.timestamp];

        NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *dataDirPath = [dirPaths objectAtIndex:0];

        // Pre-format the photo and audio file paths based on the timestamp.
        _photoFilePath = [dataDirPath stringByAppendingPathComponent:timestampString];
        _photoFilePath = [_photoFilePath stringByAppendingPathExtension:@"jpg"];

        _audioFilePath = [dataDirPath stringByAppendingPathComponent:timestampString];
        _audioFilePath = [_audioFilePath stringByAppendingPathExtension:@"caf"];
        

        _memoFilePath = [dataDirPath stringByAppendingPathComponent:timestampString];
        _memoFilePath = [_memoFilePath stringByAppendingString:@"_memo"];
        _memoFilePath = [_memoFilePath stringByAppendingPathExtension:@"caf"];
        
        _hasMemo = FALSE;
        

        if (_placemark == nil && _location != nil)
        {
            NSLog(@"Fetching placemark for location (%f, %f)", _location.coordinate.longitude, _location.coordinate.latitude);
            geocoder = [CLGeocoder new];
            [geocoder reverseGeocodeLocation:_location completionHandler:^(NSArray *placemarks, NSError *error) {
                NSLog(@"Got %d placemarks for location (%f, %f)", placemarks.count, _location.coordinate.longitude, _location.coordinate.latitude);
                if (placemarks.count > 0)
                {
                    // FIX: ignoring others?
                    _placemark = [placemarks objectAtIndex:0];
                    NSLog(@" Placemark: %@", _placemark);
                }
            }];
        }

    }
    return self;
}

- (void)setHasMemo:(BOOL)mem
{
    _hasMemo = mem;
}

- (BOOL)photoFileExists
{
    return [[NSFileManager defaultManager] fileExistsAtPath:self.photoFilePath];
}

- (BOOL)audioFileExists
{
    return [[NSFileManager defaultManager] fileExistsAtPath:self.audioFilePath];
}

#pragma mark - NSCoding overrides

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [self initWithTimestamp:(NSDate *)[aDecoder decodeObjectForKey:@"timestamp"]
                              location:[aDecoder decodeObjectForKey:@"location"]
                               heading:[aDecoder decodeObjectForKey:@"heading"]
                             placemark:[aDecoder decodeObjectForKey:@"placemark"]
                      taggedForSending:[aDecoder decodeBoolForKey:@"taggedForSending"]])
    {
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.timestamp forKey:@"timestamp"];
    [aCoder encodeObject:self.location forKey:@"location"];
    [aCoder encodeObject:self.heading forKey:@"heading"];
    [aCoder encodeObject:self.placemark forKey:@"placemark"];
    [aCoder encodeBool:self.taggedForSending forKey:@"taggedForSending"];
}

#pragma mark - Property accessor overrides

- (void)setUiImage:(UIImage *)uiImage
{
    if (_uiImage != uiImage)
    {
        _uiImage = uiImage;
        NSData *imageData = UIImageJPEGRepresentation(uiImage, 0.8);
        [imageData writeToFile:self.photoFilePath atomically:YES];
    }
}

- (UIImage *)uiImage
{
    if (_uiImage == nil && [[NSFileManager defaultManager] fileExistsAtPath:self.photoFilePath])
    {
        _uiImage = [UIImage imageWithContentsOfFile:self.photoFilePath];
    }
    return _uiImage;
}

@end
