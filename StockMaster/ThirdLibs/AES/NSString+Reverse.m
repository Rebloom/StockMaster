//
//  NSString+Reverse.m
//  StockMaster
//
//  Created by Rebloom on 15/4/1.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import "NSString+Reverse.h"

@implementation NSString (Reverse)

- (NSString *)stringByReversed
{
    NSMutableString *s = [NSMutableString string];
    for (NSUInteger i=self.length; i>0; i--) {
        [s appendString:[self substringWithRange:NSMakeRange(i-1, 1)]];
    }
    return s;
}

@end;
