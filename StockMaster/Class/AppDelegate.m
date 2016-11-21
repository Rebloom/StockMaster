//
//  AppDelegate.m
//  StockMaster
//
//  Created by Rebloom on 14-7-21.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import "EaseMob.h"
#import "EMIMHelper.h"
//for mac
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

//for idfa
#import <AdSupport/AdSupport.h>

@implementation AppDelegate
@synthesize wbtoken;
@synthesize window;
@synthesize wbCurrentUserID;

@synthesize gexinPusher;
@synthesize sdkStatus;
@synthesize HVC;

+(AppDelegate *)instance{
    UIApplication *app=[UIApplication sharedApplication];
    return (AppDelegate *)(app.delegate);
}

- (void)registerRemoteNotification
{
#ifdef __IPHONE_8_0
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        
        UIUserNotificationSettings *uns = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound) categories:nil];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:uns];
    } else {
        UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeBadge);
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
    }
#else
    UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeBadge);
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
#endif
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFinishedNoti:) name:kTagLoginFinishedNoti object:nil];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    // 向微信注册
    [WXApi registerApp:kWeiXinAppKey];
    
    // 向QQ注册
    tencentOAuth = [[TencentOAuth alloc] initWithAppId:kQQAppID
                                           andDelegate:self];
    
    // 新浪微博
    [WeiboSDK enableDebugMode:NO];
    [WeiboSDK registerApp:kSinaAppKey];
    
    // 友盟统计
    [MobClick startWithAppkey:kTagUMengKey reportPolicy:BATCH channelId:kTagChannelID];
    [MobClick setAppVersion:GFVersion];
    
    //友盟移动推广效果分析
    NSString * trackKey = kTagUMengTrackKey;
    NSString * deviceName = [[[UIDevice currentDevice] name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString * mac = [self macString];
    NSString * idfa = [self idfaString];
    NSString * idfv = [self idfvString];
    NSString * urlString = [NSString stringWithFormat:@"http://log.umtrack.com/ping/%@/?devicename=%@&mac=%@&idfa=%@&idfv=%@", trackKey, deviceName, mac, idfa, idfv];
    [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL: [NSURL URLWithString:urlString]] delegate:nil];
    
    //环信客服
    NSString *apnsCertName = @"chatdemo";
    [[EaseMob sharedInstance] registerSDKWithAppKey:[[EMIMHelper defaultHelper] appkey] apnsCertName:@""];
    // 需要在注册sdk后写上该方法
    [[EaseMob sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    [[EMIMHelper defaultHelper] loginEasemobSDK];
//    [[EaseMob sharedInstance].chatManager setIsAutoFetchBuddyList:YES];


    
    // 诸葛统计（渠道）
    [[[Zhuge sharedInstance] config] setChannel:kTagChannelID]; // 设置渠道
    [[Zhuge sharedInstance] startWithAppKey:kZhugeAppKey launchOptions:launchOptions];
    
    // 向个推注册
    [self registerGeTui];
    
    [self judgeUpdateStatus];
    
    NSDictionary* message = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (message) {
        NSString *payloadMsg = [message objectForKey:@"payload"];
        NSString *record = [NSString stringWithFormat:@"[APN]%@, %@", [NSDate date], payloadMsg];
        NSLog(@"record is %@",record);
    }
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    // 设置RootViewController为当前控制器
    RootViewController * RVC = [[RootViewController alloc] init];
    [self.window setRootViewController:RVC];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    HVC = [[HomeViewController alloc] init];
    
    return YES;
}

//友盟移动推广效果分析
- (NSString * )macString{
    int mib[6];
    size_t len;
    char *buf;
    unsigned char *ptr;
    struct if_msghdr *ifm;
    struct sockaddr_dl *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *macString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return macString;
}

- (NSString *)idfaString {
    
    NSBundle *adSupportBundle = [NSBundle bundleWithPath:@"/System/Library/Frameworks/AdSupport.framework"];
    [adSupportBundle load];
    
    if (adSupportBundle == nil) {
        return @"";
    }
    else{
        
        Class asIdentifierMClass = NSClassFromString(@"ASIdentifierManager");
        
        if(asIdentifierMClass == nil){
            return @"";
        }
        else{
            
            //for no arc
            //ASIdentifierManager *asIM = [[[asIdentifierMClass alloc] init] autorelease];
            //for arc
            ASIdentifierManager *asIM = [[asIdentifierMClass alloc] init];
            
            if (asIM == nil) {
                return @"";
            }
            else{
                
                if(asIM.advertisingTrackingEnabled){
                    return [asIM.advertisingIdentifier UUIDString];
                }
                else{
                    return [asIM.advertisingIdentifier UUIDString];
                }
            }
        }
    }
}

- (NSString *)idfvString
{
    if([[UIDevice currentDevice] respondsToSelector:@selector( identifierForVendor)]) {
        return [[UIDevice currentDevice].identifierForVendor UUIDString];
    }
    
    return @"";
}

//判断更新状态
- (void)judgeUpdateStatus
{
    NSDictionary * updateInfo = [GFStaticData getObjectForKey:kTagAppVersionInfo];
    if (updateInfo)
    {
        NSInteger updateStatus = [[updateInfo objectForKey:@"update_status"] integerValue];
        if (updateStatus == 0)
        {
            return;
        }
        else if (updateStatus == 1)
        {
            NSInteger remindType = [[updateInfo objectForKey:@"remind_type"] integerValue];
            
            if (remindType == 1)
            {
                [self performSelector:@selector(alertWithInfo:) withObject:updateInfo afterDelay:.5];
            }
            else if (remindType == 3)
            {
                if (![GFStaticData getObjectForKey:[Utility dateTimeToStringYMD:[NSDate date]]])
                {
                    // AlertWithInfo
                    [self performSelector:@selector(alertWithInfo:) withObject:updateInfo afterDelay:.5];
                }
            }
        }
        else if (updateStatus == 2)
        {
            // AlertWithForceUpdateInfo
            [self performSelector:@selector(alertForceUpdate:) withObject:updateInfo afterDelay:.5];
        }
    }
}

- (void)alertForceUpdate:(NSDictionary *)info
{
    [[CHNAlertView defaultAlertView] showContent:[info objectForKey:@"force_update_desc"] cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:7];
}

- (void)alertWithInfo:(NSDictionary *)info
{
    NSArray * versionDescArr = [[info objectForKey:@"version_desc"] objectForKey:@"body"];
    NSString * versionDesc = @"";
    for (NSString * desc in versionDescArr)
    {
        versionDesc = [[versionDesc stringByAppendingString:desc] stringByAppendingString:@"\n"];
    }
    [[CHNAlertView defaultAlertView] initWithNormalType:[info objectForKey:@"app_desc"] content:versionDesc cancelTitle:@"忽略" sureTitle:@"升级" withDelegate:self];
    
    [GFStaticData saveObject:@"YES" forKey:[Utility dateTimeToStringYMD:[NSDate date]]];
}

- (void)registerGeTui
{
    [self registerRemoteNotification];
    NSError *err = nil;
    gexinPusher = [GexinSdk createSdkWithAppId:kGetuiID
                                        appKey:kGetuiKey
                                     appSecret:kGetuiSecret
                                    appVersion:@"3.0.0"
                                      delegate:self
                                         error:&err];
}


- (void)GexinSdkDidRegisterClient:(NSString *)clientId
{
    [GFStaticData saveObject:clientId forKey:kTagUserKeyClientID];
    if ([[UserInfoCoreDataStorage sharedInstance] isCurrentUserLogin])
    {
        NSMutableDictionary * param = [NSMutableDictionary dictionary];
        [param setObject:clientId forKey:@"client_id"];
        [GFRequestManager connectWithDelegate:self action:Submit_user_app_push_bind param:param];
    }
}

- (void)GexinSdkDidReceivePayload:(NSString *)payloadId fromApplication:(NSString *)appId
{
    NSData * receivedData = [gexinPusher retrivePayloadById:payloadId];
    if (receivedData)
    {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:receivedData options:NSJSONReadingMutableContainers error:nil]  ;
        if (dic)
        {
            [self localNotiWithInfo:dic];
        }
    }
}

- (void)localNotiWithInfo:(NSDictionary *)info
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    if (notification != nil) {
        NSDate *now = [NSDate new];
        notification.fireDate = [now dateByAddingTimeInterval:1];//10秒后通知
        notification.repeatInterval = 0;//循环次数，kCFCalendarUnitWeekday一周一次
        notification.timeZone = [NSTimeZone defaultTimeZone];
        notification.applicationIconBadgeNumber = 1; //应用的红色数字
        notification.soundName = UILocalNotificationDefaultSoundName;//声音，可以换成alarm.soundName = @"myMusic.caf"
        //去掉下面2行就不会弹出提示框
        notification.alertBody = [Utility replaceUnicode:[info objectForKey:@"content"]];//提示信息 弹出提示框
        notification.userInfo = info; //添加额外的信息
        
        NSLog(@"info is %@",info);
    
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

- (void)loginFinishedNoti:(NSNotification *)noti
{
    if ([[UserInfoCoreDataStorage sharedInstance] isCurrentUserLogin] && [GFStaticData getObjectForKey:kTagUserKeyClientID])
    {
        NSMutableDictionary * param = [NSMutableDictionary dictionary];
        [param setObject:[GFStaticData getObjectForKey:kTagUserKeyClientID] forKey:@"client_id"];
        [GFRequestManager connectWithDelegate:self action:Submit_user_app_push_bind param:param];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userinfo
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    // [4-EXT]:处理APN
    NSString *payloadMsg = [userinfo objectForKey:@"payload"];
    NSString *record = [NSString stringWithFormat:@"[APN]%@, %@", [NSDate date], payloadMsg];
    [[CHNAlertView defaultAlertView] showContent:record cancelTitle:@"取消" sureTitle:@"确定" withDelegate:self withType:0];
    
    //SDK方法调用
    [[EaseMob sharedInstance] application:application didReceiveRemoteNotification:userinfo];
}

- (void)buttonClickedAtIndex:(NSInteger)index
{
    NSDictionary * updateInfo = [GFStaticData getObjectForKey:kTagAppVersionInfo];
    if (updateInfo)
    {
        NSInteger updateStatus = [[updateInfo objectForKey:@"update_status"] integerValue];
        if (index == 0)
        {
            if (updateStatus == 2)
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[updateInfo objectForKey:@"url"]]];
                exit(0);
            }
        }
        else if (index == 1)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[updateInfo objectForKey:@"url"]]];
        }
    }
}

- (void)delayExit
{
    exit(0);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    NSString * sendToken = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // [3]:向个推服务器注册deviceToken
    if (gexinPusher) {
        [gexinPusher registerDeviceToken:sendToken];
    }
    
    //SDK方法调用
    [[EaseMob sharedInstance] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];

}


-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSDictionary * dic = [notification userInfo];
    
    if ([[dic objectForKey:@"typeid"] integerValue] == 4)
    {
        StockInfoEntity * stockInfo = [[StockInfoCoreDataStorage sharedInstance] getStockInfoWithCode:[dic objectForKey:@"stock_code"] exchange:[dic objectForKey:@"stock_exchange"]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kTagReceivedRemoteNoti object:stockInfo];
    }
    else if ([[dic objectForKey:@"typeid"] integerValue] == 5)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kTagPropCardNoti object:dic];
    }
    
    //SDK方法调用
    [[EaseMob sharedInstance] application:application didReceiveLocalNotification:notification];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    NSString * receivedStr = [userInfo objectForKey:@"payload"];
    
    StockInfoEntity * stockInfo = nil;
    
    if ([receivedStr componentsSeparatedByString:@","].count == 3)
    {
        NSString * str2 = [[receivedStr componentsSeparatedByString:@","] objectAtIndex:1];
        NSString * str3 = [[receivedStr componentsSeparatedByString:@","] objectAtIndex:2];
        
        stockInfo = [[StockInfoCoreDataStorage sharedInstance] getStockInfoWithCode:[[str2 componentsSeparatedByString:@"stock_code="] lastObject] exchange:[[str3 componentsSeparatedByString:@"stock_exchange="] lastObject]];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTagReceivedRemoteNoti object:stockInfo];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    // [3-EXT]:如果APNS注册失败，通知个推服务器
    if (gexinPusher) {
        [gexinPusher registerDeviceToken:@""];
    }
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[EaseMob sharedInstance] applicationWillResignActive:application];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    //[gexinPusher destroy];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[EaseMob sharedInstance] applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[EaseMob sharedInstance] applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //[self registerGeTui];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[EaseMob sharedInstance] applicationDidBecomeActive:application];

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[EaseMob sharedInstance] applicationWillTerminate:application];
}

// 微博授权的回调，获取微博token并保存
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
   if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        NSString * WBToken = [(WBAuthorizeResponse *)response accessToken];
        [GFStaticData saveObject:WBToken forKey:kTagTencentToken];
    }
    else if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {
//        WBSendMessageToWeiboResponse* WBresponse = (WBSendMessageToWeiboResponse*)response;
//        NSString* accessToken = [WBresponse.authResponse accessToken];
//        if (accessToken)
//        {
//            self.wbtoken = accessToken;
//        }
//        NSString* userID = [WBresponse.authResponse userID];
//        if (userID) {
//            self.wbCurrentUserID = userID;
//        }

    }
}

-(void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [WXApi handleOpenURL:url delegate:self];
}


// * 推荐实现上面的方法，两个方法二选一实现即可
 - (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
     [WXApi handleOpenURL:url delegate:self];
    
//#if __QQAPI_ENABLE__
//     [QQApiInterface handleOpenURL:url delegate:(id)[QQAPIDemoEntry class]];
//#endif
//     if (YES == [TencentOAuth CanHandleOpenURL:url])
//     {
//         return [TencentOAuth HandleOpenURL:url];
//     }

     return YES;
 }

- (void)tencentDidLogin
{
    
}

- (void)tencentDidLogout
{
    
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
    
}

- (void)tencentDidNotNetWork
{
    
}

// 微信分享到朋友圈->复活的回调，通知页面
-(void)onResp:(BaseResp *)resp
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kTagWXShareFinished object:resp];
}

@end
