//
//  NSString+UIColor.m
//  UBoxOnline
//
//  Created by ubox on 13-3-21.
//  Copyright (c) 2013年 ubox. All rights reserved.
//

#import "NSString+UIColor.h"

@implementation NSString (UIColor)

// 获取由当前的NSString转换来的UIColor
- (UIColor*)color {
    // 判断长度先
    if (self.length < 6) return nil;
    // 去掉空格等其他字符
    NSString *cString = [[self stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    
    if ([cString length] < 6 || [cString length] > 8) return nil;
    
    static int COLOR_LENGTH = 4;
    // Alpha Red Green Blue
    unsigned int colorARGB[COLOR_LENGTH];
    for (int i = 0; i < 4; i++) {
        // 先初始化为所有都是255
        colorARGB[COLOR_LENGTH-i-1] = 255;
        
        // 根据子字符串进行数字转换
        NSString *subString = [cString substringFromIndex: cString.length < 2 ? 0 : cString.length - 2];
        cString = [cString substringToIndex:cString.length < 2 ? cString.length : cString.length - 2];
        if (subString.length) {
            [[NSScanner scannerWithString:subString] scanHexInt:&colorARGB[COLOR_LENGTH-i-1]];
        }
    }

    return [UIColor colorWithRed:((float) colorARGB[1] / 255.0f)
                           green:((float) colorARGB[2] / 255.0f)
                            blue:((float) colorARGB[3] / 255.0f)
                           alpha:((float) colorARGB[0] / 255.0f)];
}

@end
