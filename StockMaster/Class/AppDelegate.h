//
//  AppDelegate.h
//  StockMaster
//
//  Created by Rebloom on 14-7-21.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentApiInterface.h>
#import "GexinSdk.h"
#import "WXApi.h"
#import "WeiboSDK.h"
#import "MobClick.h"
#import "HomeViewController.h"

typedef enum {
    SdkStatusStoped,
    SdkStatusStarting,
    SdkStatusStarted
} SdkStatus;

@interface AppDelegate : UIResponder <UIApplicationDelegate,WXApiDelegate,WeiboSDKDelegate,TencentSessionDelegate,GexinSdkDelegate,CHNAlertViewDelegate>
{
    TencentOAuth * tencentOAuth ;
}

@property (nonatomic, strong) UIWindow *window;
@property (strong, nonatomic) NSString *wbtoken;
@property (strong, nonatomic) NSString *wbCurrentUserID;

@property (nonatomic, strong) GexinSdk * gexinPusher;
@property (nonatomic, assign) SdkStatus sdkStatus;
@property (nonatomic, strong) HomeViewController * HVC;

+(AppDelegate *)instance;

@end
