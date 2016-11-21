//
//  CHNMacro.h
//  StockMaster
//
//  Created by Rebloom on 14-7-22.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#ifndef StockMaster_CHNMacro_h
#define StockMaster_CHNMacro_h

#define CHECKDATA(x) ([dic objectForKey:x])?[[dic objectForKey:x] description]:@""

#define MY_COLOR(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define NormalFontWithSize(x) [UIFont fontWithName:@"Helvetica" size:x]

#define BoldFontWithSize(x) [UIFont fontWithName:@"Helvetica-Bold" size:x]

#ifdef __DEBUG
//#define NSLog(...)

//#define HostAddress                 @"http://api.beta.aizhangzhang.com/"
//#define HostWithDrawAddress         @"http://m.beta.aizhangzhang.com/index.php/user/user_withdraw_rate?"

#define HostAddress                 @"http://api.qa.aizhangzhang.com/"
#define HostWithDrawAddress         @"http://m.qa.aizhangzhang.com/index.php/user/user_withdraw_rate?"

#else
#define NSLog(...)


#define HostAddress                 @"http://api.beta.aizhangzhang.com/"
#define HostWithDrawAddress         @"http://m.beta.aizhangzhang.com/index.php/user/user_withdraw_rate?"
//#define HostAddress                 @"http://api.aizhangzhang.com/"
//#define HostWithDrawAddress         @"http://m.aizhangzhang.com/index.php/user/user_withdraw_rate?"

#endif

#define UserAgreementUrl            @"http://m.aizhangzhang.com/html5/agreement.html"
#define SoftwareAgreementUrl        @"http://m.aizhangzhang.com/html5/permission_agreement.html"
#define VersionTipUrl(x)            @"http://m.aizhangzhang.com/html5/update_desc.html?client_version=x"
#define TradeRuleUrl                @"http://m.aizhangzhang.com/html5/trade_rule.html"
#define HelpUrl                     @"http://m.aizhangzhang.com/html5/help.html"
#define HelpCenterUrl               @"http://m.aizhangzhang.com/html5/helpcenter.html?from=app&client_type=ios&client_version=%@"

// 判断iPhone
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone4s ([UIScreen instancesRespondToSelector:@selector(currentMode)]? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) :NO)
#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)]? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) :NO)
#define iPhone6Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)]? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) :NO)

// 判断iOS 7
#define IOS7_OR_LATER ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending) 
#define  SURPLUSHEIGHT (IOS7_OR_LATER?64:44)

#define beginX ([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0?20:0)
#define beLowiOS7 [[[UIDevice currentDevice] systemVersion] floatValue]<7.0?YES:NO
#define screenHeight [UIScreen mainScreen].bounds.size.height
#define screenWidth  [UIScreen mainScreen].bounds.size.width
#define tabbarHeight  50

#define kAppVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define kBuildVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]
#define GFVersion [NSString stringWithFormat:@"v_%@", kAppVersion]
// 渠道
#define kTagChannelID           [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CHANNELID"]
#define kTagPackageID           [[[NSBundle mainBundle] infoDictionary] objectForKey:@"package_id"]
//#define kTagChannelID           @"beta"

#define kTagAppStoreClose       @"kTagAppStoreClose"

// 所有的通知都放在这里
#define kTagLoginFinishedNoti           @"kTagLoginFinishedNoti"
#define kTagBackNotification            @"kTagBackNotification"
#define kTagRequestFinished             @"kTagRequestFinished"
#define kTagRequestFailed               @"kTagRequestFailed"

#define kTagShowTabbarNoti              @"kTagShowTabbarNoti"
#define kTagHideTabbarNoti              @"kTagHideTabbarNoti"

#define kTagUpdatedStockList            @"kTagUpdatedStockList"

#define kTagUpdateMarketFrame           @"kTagUpdateMarketFrame"

#define kTagWXShareFinished             @"kTagWXShareFinished"

#define kTagWXShareFailed               @"kTagWXShareFailed"

#define kTagWXLoginRefresh              @"kTagWXLoginRefresh"

#define kTagStatusBarColorChanged       @"kTagStatusBarColorChanged"

#define kTagReceivedRemoteNoti          @"kTagReceivedRemoteNoti"

#define kTagPropCardNoti                @"kTagPropCardNoti"

#define kTagTopShadowHideNoti           @"kTagTopShadowHideNoti"
#define kTagTopShadowShowNoti           @"kTagTopShadowShowNoti"

#define kTagWXToRegisterVCNoti          @"kTagWXToRegisterVCNoti"

// 本地存储的键值对
#define kTagNeedToAlert                 @"kTagNeedToAlert"
#define kTagFromWithDraw                @"kTagFromWithDraw"

#define kTagBindBankCardDefaultInfo     @"kTagBindBankCardDefaultInfo"
#define kTagRequestAccessToken          @"kTagRequestAccessToken"
#define kTagWXLoginFromHome             @"kTagWXLoginFromHome"

#define kTagLoginDate1                  @"kTagLoginDate1"
#define kTagLoginDate2                  @"kTagLoginDate2"

#define kTagBuyShortTip                 @"kTagBuyShortTip"
#define kTagSellShortTip                @"kTagSellShortTip"

// 常量定义
#define kTagAdHeight     120
#define kTagTableOrigin  160
#define kTagHeaderHeight 40
#define kTagFooterHeight 70
#define kTagProductTableHeight 120
#define kTagTableFrame CGRectMake(0, beginX+45, screenWidth, screenHeight-45-beginX)
#define kTagTableDownFrame  CGRectMake(0, beginX+165, screenWidth, screenHeight-165)
#define HeaderViewHeight    (iPhone6Plus?233:iPhone6?211:180)

#define kLineGreen          @"#42ad8b"
#define kLineRed            @"#df5d57"

#define kTagEncryptorKey    @"iZ(Z^nCao7d-@4f]"
#define kTagEncryptorIV     @"I(P%CQxrm-~hJgfs"
#define kTagDecryptorKey    @"(hu@N6P+!]zQ#Fv3"
#define kTagDecryptorIV     @"T(nXSM#nch(CrW^U"

#define kFlagDepartRequestInfoString        @"faa8c21fc829a7b3d9150f00e91ffced"

// 新浪微博的Key
#define kSinaAppKey         @"4272920846"
#define kSinaRedirectURI    @"https://api.weibo.com/oauth2/default.html"

// 微信的Key
#define kWeiXinAppKey       @"wx566d2294c1e6792f"
#define kWeiXinAppSecret    @"0bf966288f8a21ca44a8900202789b95"

// QQ的ID与key
#define kQQAppID            @"1103377921"
#define kQQAppKey           @"TqmYFVwZ1u4wKxPc"

#ifdef __DEBUG
#define kGetuiID            @"ehXDF2j1jz5vMAEWOhKhl7"
#define kGetuiKey           @"WhPBNpRMujAWmDrWUn2Ly2"
#define kGetuiSecret        @"7Ic3aXiYLqAg48OGsiwUyA"

// 诸葛统计
#define kZhugeAppKey        @"291c2b207fd2414ebe77e216ebf12de2"
#define kZhugeSecretKey     @"a84a37e188444929bdea69fa8de61f40"

#else
// 个推的ID与key
#define kGetuiID            @"7gKY8SwufT7gthkkQf2dz9"
#define kGetuiKey           @"VBOtcxhgAJAo68qHpyG9n5"
#define kGetuiSecret        @"lkYCEx7Pmm7hY5lLGcyyfA"

// 诸葛统计
#define kZhugeAppKey        @"7a4eda897fc6418c82ef6aafe5dd75d6"
#define kZhugeSecretKey     @"ac10a872237946818dedf90edca95f45"

#endif

// 友盟统计的Key
#define kTagUMengKey        @"5417e74cfd98c565ed0753b4"
// 友盟分享组件的Key
#define kTagUMengShareKey   @"507fcab25270157b37000010"
// 友盟移动推广分析的Key
#define kTagUMengTrackKey   @"541f92b3fd98c582e502e3d0"

//环信常见问题
#define KTagQuestion        @"KTagQuestion"

#define KWeb                @"http://www.aizhangzhang.com/?cmd=index.html"

#define KTagTabbar          @"KTagTabbar"

// 标记已读消息
#define KTagRead            @"KTagRead"
// 获取配置刷新时间戳
#define kTagSettingRefreshTime              @"kTagSettingRefreshTime"
// 获取顶部提示刷新时间戳
#define kTagTopNoticeRefreshTime            @"kTagTopNoticeRefreshTime"
// 是否提示过更新时间戳
#define kTagUpdatedNoticeTime               @"kTagUpdatedNoticeTime"
// 刷新配置信息的频率
#define kTagRefreshSettingTime              @"kTagRefreshSettingTime"
// 刷新顶部信息的频率
#define kTagRefreshTopNoticeTime            @"kTagRefreshTopNoticeTime"
// 默认网络请求文件配置信息
#define kTagRequestFailedText               @"kTagRequestFailedText"
// 顶部提示文件
#define kTagTopNoticeInfo                   @"kTagTopNoticeInfo"
// app更新文件
#define kTagAppVersionInfo                  @"kTagAppVersionInfo"
// 用户当前财务key
#define kTagUserFinanceInfo                 @"kTagUserFinanceInfo"
// 首页猜大盘的key
#define kTagTaskInfoKey                     @"kTagTaskInfoKey"
// 热门股票信息的key
#define kTagHotStockInfo                    @"kTagHotStockInfo"
// 微信登陆的信息
#define kTagWeiXinLoginInfo                 @"kTagWeiXinLoginInfo"
// 微信的用户信息
#define kTagWeiXinUserInfo                  @"kTagWeiXinUserInfo"
// 判断是否微信登陆
#define kTagIsWeiXinLogin                   @"kTagIsWeiXinLogin"
// 涨涨首页三栏tab存储
#define kTagZhangZhang1                     @"kTagZhangZhang1"
#define kTagZhangZhang2                     @"kTagZhangZhang2"
#define kTagZhangZhang3                     @"kTagZhangZhang3"
// 感情度可领奖的股票代码
#define EmotionCode                         @"EmotionCode"
// 感情度可领奖的股票数组
#define EmotionArray                        @"EmotionArray"

#define  KTAGVCSWITCH   @"KTAGVCSWITCH"
#define  KTAGBADGE      @"KTAGBADGE"
#define  KTAGFLAG       @"KTAGFLAG"

typedef enum STOCKVCTAG
{
    FirstVCTag = 0,
    SecondVCTag,
    ThirdVCTag,
    FourthVCTag,
    FifthVCTag,
}_STOCKVCTAG;


#endif
