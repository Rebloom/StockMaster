//
//  UIImage+QRCodeGenerator.m
//
//  Created by Oscar Sanderson on 3/8/13.
//  Copyright (c) 2013 Oscar Sanderson. All rights reserved.
//

#import "UIImage+QRCodeGenerator.h"
#import "qrencode.h"

#define LOGO_WITH_AND_HEIGH 55.0

@implementation UIImage (QRCodeGenerator)

+ (UIImage *)mdQRCodeGenerator:(NSString *)qrString size:(NSInteger)size
{
    return [self mdQRCodeGenerator:qrString
                              size:size
                              logo:nil];
}

+ (UIImage *)mdQRCodeGenerator:(NSString *)qrString
                          size:(NSInteger)size
                          logo:(UIImage *)logo
{
    return [self mdQRCodeGenerator:qrString
                       lightColour:[UIColor whiteColor]
                        darkColour:[UIColor blackColor]
                         quietZone:1
                              size:size
                              logo:logo];
}

+ (UIImage*)mdQRCodeGenerator:(NSString*)qrString
                  lightColour:(UIColor*)lightColour
                   darkColour:(UIColor*)darkColour
                    quietZone:(NSInteger)quietZone
                         size:(NSInteger)size
                         logo:(UIImage *)logo
{
    UIImage *ret = nil;
    QRcode  *qr  = QRcode_encodeString([qrString UTF8String],0,QR_ECLEVEL_L,QR_MODE_8,1);
    
    int logQRSize = qr->width;
    int phyQRSize = logQRSize + (2 * quietZone);
    int scale     = size / phyQRSize;
    int imgSize   = phyQRSize * scale;
    
    // force image to be larger than requested, as requested size is too small!
    if ( scale < 1 )
        scale = 1;
    
    // generate the image
    {
        UIGraphicsBeginImageContext(CGSizeMake(imgSize,imgSize));
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        // init all pixels to 'light' colour
        CGRect bounds = CGRectMake(0,0,imgSize,imgSize);
        CGContextSetFillColorWithColor(ctx,lightColour.CGColor);
        CGContextFillRect(ctx,bounds);
        
        // set any 'dark' colour pixels
        {
            int x,y;
            
            CGContextSetFillColorWithColor(ctx,darkColour.CGColor);
            
            for ( y=0 ; y<logQRSize ; y++ )
                for ( x=0 ; x<logQRSize ; x++ )
                    if ( qr->data[(y*logQRSize)+x] & 1 )
                        CGContextFillRect(ctx,CGRectMake((quietZone+x)*scale,(quietZone+y)*scale,scale,scale));
        }
        
        
      //将logo 绘制到中央
        if(logo != nil)
        {
            UIImage *drawImge = [self baseOfImageZoomingWithSize:size/6.0 imag:logo];
            CGContextDrawImage(ctx, CGRectMake(size*2.5/6.0, size*2.5/6.0, size/6.0, size/6.0), flip(drawImge.CGImage));
            // generate the UIImage
        }
        
        CGImageRef imgRef = CGBitmapContextCreateImage(ctx);
        ret = [UIImage imageWithCGImage:imgRef];
        CGImageRelease(imgRef);
        UIGraphicsEndImageContext();
    }
    
    QRcode_free(qr);
    
    return ret;
}

/******************************************************************************/

+ (UIImage *)baseOfImageZoomingWithSize:(float)size imag:(UIImage *)img
{
    UIImage *scaleImage;
    UIGraphicsBeginImageContext(CGSizeMake(size, size));
    UIBezierPath *b = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size, size) cornerRadius:3.0];
    [[UIColor whiteColor] setFill];
    [b fill];
    
    [img drawInRect:CGRectMake(3, 3, size - 6, size - 6)];
    scaleImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaleImage;
}

CGImageRef flip(CGImageRef im)
{
    CGSize sz = CGSizeMake(CGImageGetWidth(im), CGImageGetHeight(im));
    UIGraphicsBeginImageContextWithOptions(sz, NO, 0);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0,sz.width , sz.height), im);
    CGImageRef result = [UIGraphicsGetImageFromCurrentImageContext() CGImage];
    UIGraphicsEndImageContext();
    return result;
}

@end
