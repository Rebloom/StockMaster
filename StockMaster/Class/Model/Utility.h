//
//  Utility.h
//  StockMaster
//
//  Created by Rebloom on 14-8-6.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#include <AdSupport/AdSupport.h>
#include <sys/utsname.h>
#include <CommonCrypto/CommonDigest.h>

#import <Foundation/Foundation.h>
#import "GFStaticData.h"
#import "NSString+UIColor.h"
#import "NSString+Encryptor.h"

#define kTagLoadingView   10241024

@interface Utility : NSObject 

+ (Utility *)instance;

+ (void)showLoadingInView:(UIView *)view_;

+ (void)hideLoadingInView:(UIView *)view_;

+ (NSString *)getDeviceType;
+ (NSString *)getDeviceSystemVersion;
+ (NSString *)getDeviceID;

+ (NSString *)dateTimeToStringLF:(NSDate *)_date;

+ (NSString *)dateTimeToStringYMD:(NSDate *)_date;

+ (NSString *)dateFromString:(NSString *)dateString;

+ (NSInteger)dateTimeToYear:(NSDate *)_date;

+ (NSInteger)dateTimeToMonth:(NSDate *)_date;

+ (NSInteger)dateTimeToDay:(NSDate *)_date;

+ (NSString *)dateTimeToString:(NSDate *)_date;

+ (float)Color:(NSString *)Color RGB255:(NSInteger)type;

+ (BOOL)checkPhoneNum:(NSString *)phoneNum;

+ (BOOL)isPureInt:(NSString*)string;

+ (NSString *)departString:(NSString *)string withType:(NSInteger)type;

+ (NSString *)departDateString:(NSString *)dateString;

+ (NSUInteger) lenghtWithString:(NSString *)string;

+ (NSString *)replaceUnicode:(NSString *)unicodeStr;

+ (NSString *)DataToJsonString:(id)object;

+ (NSString *)dictionaryDataToSignString:(NSDictionary *)orderDic;

+ (NSString *)md5:(NSString *)str;

+ (NSString *)sha1:(NSString *)str;

@end
