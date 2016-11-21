//
//  NSString+UIColor.h
//  UBoxOnline
//
//  Created by ubox on 13-3-21.
//  Copyright (c) 2013年 ubox. All rights reserved.
//

#import <Foundation/Foundation.h>

// 用于扩展NSString,转换UIColor
@interface NSString (UIColor)

// 获取由当前的NSString转换来的UIColor
- (UIColor*)color;

@end
