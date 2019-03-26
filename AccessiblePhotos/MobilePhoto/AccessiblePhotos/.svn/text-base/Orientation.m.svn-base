//
//  Orientation.m
//  AccessiblePhotos
//
//  Created by 原田 丞 on 12/07/24.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import "Orientation.h"

@implementation Orientation

+ (uint)exifOrientationFromUIOrientation:(UIImageOrientation)uiorientation
{
    if (uiorientation > 7) return 1;
    int orientations[8] = {1, 3, 6, 8, 2, 4, 5, 7};
    return orientations[uiorientation];
}

+ (UIImageOrientation)imageOrientationFromEXIFOrientation:(uint)exiforientation
{
    if ((exiforientation < 1) || (exiforientation > 8)) return UIImageOrientationUp;    
    int orientations[8] = {0, 4, 1, 5, 6, 2, 7, 3};
    return orientations[exiforientation];
}

+ (NSString *)nameOfDeviceOrientation:(UIDeviceOrientation)orientation
{
    NSArray *names = [NSArray 
                      arrayWithObjects:
                      @"Unknown",
                      @"Portrait",
                      @"Portrait Upside Down",
                      @"Landscape Left",
                      @"Landscape Right",
                      @"Face Up",
                      @"Face Down",
                      nil];
    return [names objectAtIndex:orientation];
}

+ (NSString *)currentDeviceOrientationName
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    return [Orientation nameOfDeviceOrientation:orientation];
}

+ (NSString *)imageOrientationNameFromOrientation:(UIImageOrientation)orientation
{
    NSArray *names = [NSArray 
                      arrayWithObjects:
                      @"Up",
                      @"Down",
                      @"Left",
                      @"Right",
                      @"Up-Mirrored",
                      @"Down-Mirrored",
                      @"Left-Mirrored",
                      @"Right-Mirrored",
                      nil];
    return [names objectAtIndex:orientation];
}

+ (NSString *)exifOrientationNameFromOrientation:(uint)orientation
{
    NSArray *names = [NSArray 
                      arrayWithObjects:
                      @"Undefined",
                      @"Top Left",
                      @"Top Right",
                      @"Bottom Right",
                      @"Bottom Left",
                      @"Left Top",
                      @"Right Top",
                      @"Right Bottom",
                      @"Left Bottom",
                      nil];
    return [names objectAtIndex:orientation];
}


+ (NSString *)imageOrientationNameForImage:(UIImage *)anImage
{
    return [Orientation imageOrientationNameFromOrientation:anImage.imageOrientation];
}

+ (BOOL)deviceIsLandscape
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    return UIDeviceOrientationIsLandscape(orientation);
}

+ (BOOL)deviceIsPortrait
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    return UIDeviceOrientationIsPortrait(orientation);
}

+ (UIImageOrientation)currentImageOrientationWithMirroring:(BOOL)isUsingFrontCamera
{
    switch ([UIDevice currentDevice].orientation) 
    {
        case UIDeviceOrientationPortrait:
            return isUsingFrontCamera ? UIImageOrientationRight : UIImageOrientationLeftMirrored;
        case UIDeviceOrientationPortraitUpsideDown:
            return isUsingFrontCamera ? UIImageOrientationLeft :UIImageOrientationRightMirrored;
        case UIDeviceOrientationLandscapeLeft:
            return isUsingFrontCamera ? UIImageOrientationDown :  UIImageOrientationUpMirrored;
        case UIDeviceOrientationLandscapeRight:
            return isUsingFrontCamera ? UIImageOrientationUp : UIImageOrientationDownMirrored;
        default:
            return  UIImageOrientationUp;
    }
}

// Expected Image orientation from current orientation and camera in use
+ (UIImageOrientation)currentImageOrientationUsingFrontCamera:(BOOL)isUsingFrontCamera shouldMirrorFlip:(BOOL)shouldMirrorFlip
{
    if (shouldMirrorFlip) 
        return [Orientation currentImageOrientationWithMirroring:isUsingFrontCamera];
    
    switch ([UIDevice currentDevice].orientation) 
    {
        case UIDeviceOrientationPortrait:
            return isUsingFrontCamera ? UIImageOrientationLeftMirrored : UIImageOrientationRight;
        case UIDeviceOrientationPortraitUpsideDown:
            return isUsingFrontCamera ? UIImageOrientationRightMirrored :UIImageOrientationLeft;
        case UIDeviceOrientationLandscapeLeft:
            return isUsingFrontCamera ? UIImageOrientationDownMirrored :  UIImageOrientationUp;
        case UIDeviceOrientationLandscapeRight:
            return isUsingFrontCamera ? UIImageOrientationUpMirrored :UIImageOrientationDown;
        default:
            return  UIImageOrientationUp;
    }
}

+ (uint)currentEXIFOrientationUsingFrontCamera:(BOOL)isUsingFrontCamera shouldMirrorFlip:(BOOL)shouldMirrorFlip
{
    return [Orientation exifOrientationFromUIOrientation:[Orientation currentImageOrientationUsingFrontCamera:isUsingFrontCamera shouldMirrorFlip:shouldMirrorFlip]];
}

// Does not take camera into account for both portrait orientations
// This is likely due to an ongoing bug
+ (uint)detectorEXIFUsingFrontCamera:(BOOL)isUsingFrontCamera shouldMirrorFlip:(BOOL)shouldMirrorFlip
{
    if (isUsingFrontCamera || [Orientation deviceIsLandscape])
        return [Orientation currentEXIFOrientationUsingFrontCamera:isUsingFrontCamera shouldMirrorFlip:shouldMirrorFlip];
    
    // Only back camera portrait  or upside down here. This bugs me a lot.
    // Detection happens but the geometry is messed.
    int orientation = [Orientation currentEXIFOrientationUsingFrontCamera:!isUsingFrontCamera shouldMirrorFlip:shouldMirrorFlip];
    return orientation;
}

@end
