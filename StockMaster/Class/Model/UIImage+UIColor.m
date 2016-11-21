//
//  UIImage+UIColor.m
//  UBoxOnline
//
//  Created by ubox on 13-3-21.
//  Copyright (c) 2013年 ubox. All rights reserved.
//

#import "UIImage+UIColor.h"

#pragma mark - UIImage (UIColor)

@implementation UIImage (UIColor)

// 给透明区域上上色
- (UIImage *)changeImageColor:(UIColor *)theColor {
    UIGraphicsBeginImageContext(self.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    CGContextSaveGState(ctx);
    CGContextClipToMask(ctx, area, self.CGImage);
    [theColor set];
    CGContextFillRect(ctx, area);
    CGContextRestoreGState(ctx);
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    CGContextDrawImage(ctx, area, self.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

// 图片置灰
- (UIImage *)changeImageToGrayColor {
    
    UIImage *baseImage = [self changeMaskColor:[UIColor whiteColor]];
    CGRect imageRect = CGRectMake(0, 0, baseImage.size.width, baseImage.size.height);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(nil,
                                                 baseImage.size.width,
                                                 baseImage.size.height,
                                                 8,
                                                 0,
                                                 colorSpace,
                                                 kCGImageAlphaNone);
    CGContextDrawImage(context, imageRect, [baseImage CGImage]);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    
    return newImage;
}

// 给遮罩透明区域上上色
- (UIImage *)changeMaskColor:(UIColor *)theColor {
    UIGraphicsBeginImageContext(self.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, self.size.width, self.size.height);
    
    // To show the difference with an image mask, we take the above image and process it to extract
    // the alpha channel as a mask.
    // Allocate data
    NSMutableData *data = [NSMutableData dataWithLength:area.size.width * area.size.height * 1];
    // Create a bitmap context
    CGContextRef context = CGBitmapContextCreate([data mutableBytes], area.size.width, area.size.height, 8, area.size.width, NULL, kCGImageAlphaOnly);
    // Set the blend mode to copy to avoid any alteration of the source data
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    // Draw the image to extract the alpha channel
    CGContextDrawImage(context, CGRectMake(0.0, 0.0, area.size.width, area.size.height), self.CGImage);
    // Now the alpha channel has been copied into our NSData object above, so discard the context and lets make an image mask.
    CGContextRelease(context);
    // Create a data provider for our data object (NSMutableData is tollfree bridged to CFMutableDataRef, which is compatible with CFDataRef)
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((CFMutableDataRef)data);
    // Create our new mask image with the same size as the original image
    CGImageRef maskImage = CGImageMaskCreate(area.size.width, area.size.height, 8, 8, area.size.height, dataProvider, NULL, YES);
    // And release the provider.
    CGDataProviderRelease(dataProvider);
    
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    CGContextSaveGState(ctx);
    CGContextClipToMask(ctx, area, maskImage);
    [theColor set];
    CGContextFillRect(ctx, area);
    CGContextRestoreGState(ctx);
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    CGContextDrawImage(ctx, area, self.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Release mask Image
    CGImageRelease(maskImage);
    return newImage;
}

@end

#pragma mark - UIColor (UIImage)

@implementation UIColor (UIImage)

// 通过颜色返回一个1*1大小的纯色图片
- (UIImage *)image {
    
    CGRect imageRect = CGRectMake(0, 0, 1, 1);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(nil,
                                                 1,
                                                 1,
                                                 8,
                                                 4,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast);
    CGContextSetFillColorWithColor(context, [self CGColor]);
    CGContextFillRect(context, imageRect);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    
    return newImage;
}

@end
