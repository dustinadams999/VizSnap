//
//  UIImage+Utilities.h
//  AccessiblePhotos
//
//  Created by 原田 丞 on 12/07/24.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import <UIKit/UIKit.h>


// There's a bug when creating CI Images from PNG vs JPEG
// This is a workaround
CIImage *ciImageFromPNG(NSString *pngFileName);

@interface UIImage (Utilities)

// Extract a subimage
- (UIImage *) subImageWithBounds:(CGRect) rect;

// This is a bug workaround for creating a UIImage from a CIImage
+ (UIImage *) imageWithCIImage: (CIImage *) aCIImage orientation: (UIImageOrientation) anOrientation;
@end
