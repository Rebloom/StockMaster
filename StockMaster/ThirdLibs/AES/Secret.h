//
//  Secret.h
//  StockMaster
//
//  Created by Rebloom on 15/4/1.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GTMBase64.h"
#import "NSData+AES.h"
#import "NSString+Reverse.h"
#import "GFBase64.h"

@interface Secret : NSObject

+ (NSString*) AES128Encrypt:(NSString *)plainText;

+ (NSString*) AES128Decrypt:(NSString *)encryptText;

+ (NSString*)encodeBase64String:(NSString *)input;
+ (NSString*)decodeBase64String:(NSString *)input;
+ (NSString*)encodeBase64Data:(NSData *)data;
+ (NSString*)decodeBase64Data:(NSData *)data;


@end
