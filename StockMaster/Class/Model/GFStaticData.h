//
//  GFStaticData.h
//  StockMaster
//
//  Created by Rebloom on 14-8-11.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utility.h"

#define kTagUserRealName    @"kTagUserRealName"
#define kTagWeiboToken      @"KTagWeiboToken"
#define kTagWXToken         @"KTagWXToken"
#define kTagTencentToken    @"KTagTencentToken"

#define kTagUserKeyClientID @"kTagUserKeyClientID"

#define kTagUserKeyLearned  @"kTagUserKeyLearned"
#define kTagCheckMobile     @"cheakMobile"

#define KTagInvitationCode  @"invitation_code"

// 存储的文件KEY
// 未登录的配置信息存到这个User下
#define kTagNoLoginUser         @"kTagNoLoginUser"
#define kTagBankList            @"kTagBankList"

#define kTagUserHolding         @"KTagUserHolding"
#define kTagStockList           @"kTagStockList"
#define KTagBankCard            @"KTagBankCard"
#define KTagCardInfo            @"KTageCardInfo"
#define KTagForBadge            @"KTagForBadge"//用户第一次安装显示赚钱badge

#define KTagCardBack            @"KTagCardBack"//为1时  代表从赚钱模块进入绑定银行卡； 为2时  代表从其他页面
#define KTagCashInfo            @"KTagCashInfo" //添加银行卡后返回提现页面传过去参数

#define kTagConjunctureStock    @"kTagConjunctureStock"
#define kTagCanDrawMoney        @"kTagCanDrawMoney"

@interface GFStaticData : NSObject

+ (GFStaticData *)defaultDataCenter;

+ (BOOL)saveObject:(id)object forKey:(NSString *)key;

+ (id)getObjectForKey:(NSString *)key;

+ (BOOL)saveObject:(id)data forKey:(NSString *)key forUser:(NSString *)user;

+ (id)getObjectForKey:(NSString*)key forUser:(NSString*)user;

@end
