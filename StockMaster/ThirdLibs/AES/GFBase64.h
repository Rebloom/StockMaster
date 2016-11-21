//
//  GFBase64.h
//  StockMaster
//
//  Created by Rebloom on 15/4/2.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GFBase64 : NSObject

@end

@interface NSData (Base64)

+ (NSData *)dataWithBase64EncodedString:(NSString *)string;
- (NSString *)base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth;
- (NSString *)base64EncodedString;

@end


@interface NSString (Base64)

+ (NSString *)stringWithBase64EncodedString:(NSString *)string encoding:(NSStringEncoding)encoding;
+ (NSString *)stringWithBase64EncodedString:(NSString *)string;
- (NSString *)base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth;
- (NSString *)base64EncodedString:(NSStringEncoding)encoding;
- (NSString *)base64EncodedString;
- (NSString *)base64DecodedString:(NSStringEncoding)encoding;
- (NSString *)base64DecodedString;
- (NSData *)base64DecodedData;

- (NSString *)authCodeEncoded:(NSString *)key encoding:(NSStringEncoding)encoding;
- (NSString *)authCodeEncoded:(NSString *)key;
- (NSString *)authCodeDecoded:(NSString *)key encoding:(NSStringEncoding)encoding;
- (NSString *)authCodeDecoded:(NSString *)key;
@end

