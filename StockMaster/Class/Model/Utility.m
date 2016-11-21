//
//  Utility.m
//  StockMaster
//
//  Created by Rebloom on 14-8-6.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "Utility.h"
#import "ChineseInclude.h"
#import "CHNMacro.h"
@implementation Utility

#define signedKey       @"#8pi=7H#(Dv~mTMQ0d[dGwPBPVF$So+E74799nOWS=NOXt,qQ@a%f.3V17D1)$kqdbuufNUZvty+35n~#9$61dn%l#cdQ$qh"

static Utility * _sInst = nil;

+ (Utility*)instance{
    if (!_sInst) {
        _sInst = [[Utility alloc] init];
    }
    return _sInst;
}

+ (void)showLoadingInView:(UIView *)view_
{
    UIView *subview = [view_ viewWithTag:kTagLoadingView];
    if (subview) {
        [subview removeFromSuperview];
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200,200)];
    view.center = CGPointMake(view_.frame.size.width/2, view_.frame.size.height/2);
    view.tag = kTagLoadingView;
    UIActivityIndicatorView *active = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    active.center = CGPointMake(60, 100);
    [view addSubview:active];
    [active startAnimating];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    label.text = @"正在载入...";
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:14.0];
    label.textColor = MY_COLOR(51, 51, 51, 1);
    label.shadowColor = MY_COLOR(240, 240, 240, 1);
    label.center = CGPointMake(122, 100);
    [view addSubview:label];
    [view_ addSubview:view];
}

+ (void)hideLoadingInView:(UIView *)view_
{
    UIView *view = [view_ viewWithTag:kTagLoadingView];
    [view removeFromSuperview];
}

+ (NSString *)getDeviceType
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 2G";
    
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone3,3"])    return @"iPhone 4 (CDMA)";
    
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (A1533+A1453+CDMA)";
    
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (A1528+A1530+A1457+GSM)";
    
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6Plus";

    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";

    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch (1 Gen)";
    
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch (2 Gen)";
    
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch (3 Gen)";
    
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch (4 Gen)";
    
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    
    
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    
    if ([platform isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3";
    
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4";
    
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    
    
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";

    return platform;
}

+ (NSString *)getDeviceSystemVersion
{
    return [NSString stringWithFormat:@"%@_%@",[UIDevice currentDevice].systemName,[UIDevice currentDevice].systemVersion];
}

+ (NSString *)getDeviceID
{
    return @"";
}

+ (NSString *)dateFromString:(NSString *)dateString{
	
    dateString = [NSString stringWithFormat:@"%@ 00:00:00",dateString];
    
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	[dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
	
	NSDate *destDate = [dateFormatter dateFromString:dateString];
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)([destDate timeIntervalSince1970])];;
    
    return timeSp;
}

+ (NSInteger)dateTimeToYear:(NSDate *)_date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit |NSSecondCalendarUnit;
    NSDateComponents *dd = [cal components:unitFlags fromDate:_date];
    return (NSInteger)[dd year];
}

+ (NSInteger)dateTimeToMonth:(NSDate *)_date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit |NSSecondCalendarUnit;
    NSDateComponents *dd = [cal components:unitFlags fromDate:_date];
    return (NSInteger)[dd month];
}

+ (NSInteger)dateTimeToDay:(NSDate *)_date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit |NSSecondCalendarUnit;
    NSDateComponents *dd = [cal components:unitFlags fromDate:_date];
    return (NSInteger)[dd day];
}

+ (NSString *)dateTimeToStringLF:(NSDate *)_date
{
    long interval = [_date timeIntervalSince1970];
    return [NSString stringWithFormat:@"%ld",interval];
}

+ (NSString *)dateTimeToStringYMD:(NSDate *)_date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit |NSSecondCalendarUnit;
    NSDateComponents *dd = [cal components:unitFlags fromDate:_date];
    int y = (int)[dd year];
    int m = (int)[dd month];
    int d = (int)[dd day];
    
    return [NSString stringWithFormat:@"%d-%d-%d",y,m,d];
}

+ (NSString *)dateTimeToString:(NSDate *)_date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit |NSSecondCalendarUnit;
    NSDateComponents *dd = [cal components:unitFlags fromDate:_date];
    int m = (int)[dd month];
    int d = (int)[dd day];
    
    long interval = [_date timeIntervalSinceNow];
    interval = 0 - interval;
    if(interval < 60){
        return @"刚刚";
    }
    else if (interval <= 3600&&interval>=60) {
        return [NSString stringWithFormat:@"%i分钟前",(int)interval/60];
    }
    else if (interval <=60*60*24){
        return [NSString stringWithFormat:@"%i小时前",(int)interval/60/60];
    }
    else if (interval <=60*60*48){
        
        return @"昨天";
    }
    else
    {
        return [NSString stringWithFormat:@"%02d月%2d日",m,d];
    }
}

+ (float)Color:(NSString *)color RGB255:(NSInteger)type
{
    // 判断长度先
    if (color.length < 6) return 0;
    // 去掉空格等其他字符
    NSString *cString = [[color stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    
    if ([cString length] < 6 || [cString length] > 8) return 0;
    
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
    return ((float) colorARGB[type] / 255.0f);
}

+ (BOOL)checkPhoneNum:(NSString *)phoneNum
{
    NSString *regex = @"^(1[2-9])\\d{9}$";
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    BOOL isMatch = [pred evaluateWithObject:phoneNum];
    if(isMatch)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (BOOL)isPureInt:(NSString*)string
{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}


+  (NSString *)departString:(NSString *)string withType:(NSInteger)type
{
    if (string.length == 0) {
        return string;
    }
    
    NSString * returnStr = @"";
    if (string.length > 3)
    {
        returnStr = [string substringFromIndex:string.length-4];
    }
    NSString * returnString = @"";
    for (int i = 0; i < string.length; i++) {
        returnString = [string substringToIndex:string.length - i];
        if (returnString.length == 4)
        {
            break;
        }
    }
    if (type == 1)
    {
        returnStr = [returnString stringByAppendingString:@"..."];
    }
    if (type == 2)
    {
        returnStr = [@"**** **** ****" stringByAppendingString:returnStr];
    }
    if (type == 3) {
        NSString * str = [[string stringByPaddingToLength:4 withString:string startingAtIndex:0] stringByAppendingString:@"**** ****"];
        returnStr = [str stringByAppendingString:returnStr];
    }
    if (type == 4){
        NSString * str = [[string stringByPaddingToLength:3 withString:string startingAtIndex:0]stringByAppendingString:@"****"];
        returnStr = [str stringByAppendingString:returnStr];
    }
    return returnStr;
}

+ (NSString *)departDateString:(NSString *)dateString
{
    dateString = [NSString stringWithFormat:@"%@-%@-%@",[dateString substringToIndex:2],[dateString substringWithRange:NSMakeRange(2, 2)],[dateString substringFromIndex:4]];
    return dateString;
}

+ (NSUInteger)lenghtWithString:(NSString *)string
{
    NSUInteger len = string.length;
    // 汉字字符集
    NSString * pattern  = @"[\u4e00-\u9fa5]";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    // 计算中文字符的个数
    NSInteger numMatch = 0;
    if (len>0)
    {
        numMatch = [regex numberOfMatchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, len)];
    }
    return len + numMatch;
}

+ (NSString *)replaceUnicode:(NSString *)unicodeStr
{
    NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
                                                           mutabilityOption:NSPropertyListImmutable
                                                                     format:NULL
                                                           errorDescription:NULL];
    
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
}

+ (NSString*)DataToJsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

+ (NSString *)dictionaryDataToSignString:(NSDictionary *)orderDic
{
    NSString * signedString = @"";
    
    // 签名字符串键值以升序排列
    NSArray *dictAllKey = [orderDic allKeys];
    NSArray *sortAllKey = [dictAllKey sortedArrayUsingComparator:
                              ^NSComparisonResult(id obj1, id obj2)
                              {
                                  return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
                              }];
    
    for (NSString * dictKey in sortAllKey)
    {
        id object = [orderDic objectForKey:dictKey];
        if ([object isKindOfClass:[NSString class]]) {
            NSString * value = (NSString *)object;
            signedString = [signedString stringByAppendingString:[NSString stringWithFormat:@"%@=%@&",dictKey,value]];
        }
        else if ([object isKindOfClass:[NSDictionary class]]) {
            // 签名字符串键值以升序排列
            NSDictionary * dic = (NSDictionary *)object;
            NSArray *tempDictKey = [dic allKeys];
            NSArray *sortDictKey = [tempDictKey sortedArrayUsingComparator:
                                       ^NSComparisonResult(id obj1, id obj2)
                                       {
                                           return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
                                       }];
            
            for (NSString * key in sortDictKey)
            {
                signedString = [signedString stringByAppendingString:[NSString stringWithFormat:@"%@_%@=%@&",dictKey, key,[dic objectForKey:key]]];
            }
        }
    }
    
    signedString = [signedString substringToIndex:signedString.length-1];
    
    signedString = [signedString stringByAppendingString:signedKey];
    
    signedString = [Utility md5:signedString];
        
    signedString = [signedKey stringByAppendingString:signedString];
    
    signedString = [Utility sha1:signedString];
    
    return signedString;
}

+ (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}


+ (NSString*)sha1:(NSString *)str
{
    const char *cstr = [str cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:str.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    if ([[Utility instance] is64bit])
    {
        CC_SHA1(data.bytes, (CC_LONG) data.length, digest);
    }
    else
    {
        CC_SHA1(data.bytes, (CC_LONG) data.length, digest);
    }
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

- (BOOL)is64bit
{
#if defined(__LP64__) && __LP64__
    return YES;
#else
    return NO;
#endif
}


@end
