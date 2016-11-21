//
//  UIImage+QRCodeGenerator.h
//
//  Created by Oscar Sanderson on 3/8/13.
//  Copyright (c) 2013 Oscar Sanderson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (QRCodeGenerator)

/******************************************************************************/

+ (UIImage *)mdQRCodeGenerator:(NSString *)qrString size:(NSInteger)size;

+ (UIImage *)mdQRCodeGenerator:(NSString *)qrString
                          size:(NSInteger)size
                          logo:(UIImage *)logo;

+ (UIImage*)mdQRCodeGenerator:(NSString*)qrString
                lightColour:(UIColor*)lightColour
                 darkColour:(UIColor*)darkColour
                  quietZone:(NSInteger)quietZone
                         size:(NSInteger)size
                         logo:(UIImage *)logo;

/******************************************************************************/

@end
