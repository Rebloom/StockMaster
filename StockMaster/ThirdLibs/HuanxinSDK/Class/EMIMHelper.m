//
//  EMIMHelper.m
//  CustomerSystem-ios
//
//  Created by dhc on 15/3/28.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "EMIMHelper.h"

#import "EaseMob.h"
#import "LocalDefine.h"

static EMIMHelper *helper = nil;

@implementation EMIMHelper

@synthesize appkey = _appkey;
@synthesize cname = _cname;

@synthesize username = _username;
@synthesize password = _password;

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        _appkey = [userDefaults objectForKey:kAppKey];

        _appkey = kDefaultAppKey;

//        UserInfoEntity * userInfo = [[UserInfoCoreDataStorage sharedInstance] getCurrentUserInfo];
//        _appkey = [Utility departString:userInfo.mobile withType:4];
        if ([_appkey length] == 0) {
            _appkey = kDefaultAppKey;
            [userDefaults setObject:_appkey forKey:kAppKey];
        }
        
        _cname = [userDefaults objectForKey:kCustomerName];
        if ([_cname length] == 0) {
            _cname = kDefaultCustomerName;
            [userDefaults setObject:_cname forKey:kCustomerName];
        }
        
        _username = [userDefaults objectForKey:@"username"];
        _password = [userDefaults objectForKey:@"password"];
    }
    
    return self;
}

+ (instancetype)defaultHelper
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[EMIMHelper alloc] init];
    });
    
    return helper;
}

#pragma mark - login

- (void)loginEasemobSDK
{
    EaseMob *easemob = [EaseMob sharedInstance];
    if (![easemob.chatManager isLoggedIn] || ([_username length] == 0 || [_password length] == 0)) {
        if ([_username length] == 0 || [_password length] == 0) {
            UIDevice *device = [UIDevice currentDevice];//创建设备对象
            NSString *deviceUID = [[NSString alloc] initWithString:[[device identifierForVendor] UUIDString]];
            if ([deviceUID length] == 0) {
                CFUUIDRef uuid = CFUUIDCreate(NULL);
                if (uuid)
                {
                    deviceUID = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
                    CFRelease(uuid);
                }
            }
            UserInfoEntity * userInfo = [[UserInfoCoreDataStorage sharedInstance] getCurrentUserInfo];
            _username = userInfo.mobile;
            _password = @"123456";
            [easemob.chatManager asyncRegisterNewAccount:_username password:_password withCompletion:^(NSString *username, NSString *password, EMError *error) {
                if (!error || error.errorCode == EMErrorServerDuplicatedAccount) {
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:@"username" forKey:_username];
                    [userDefaults setObject:@"password" forKey:_password];
                    [easemob.chatManager asyncLoginWithUsername:_username password:_password];
                }
            } onQueue:nil];
        }
        else{
            [easemob.chatManager asyncLoginWithUsername:_username password:_password];
        }
    }
}

#pragma mark - info

- (void)setCname:(NSString *)cname
{
    if ([cname length] > 0 && ![cname isEqualToString:_cname]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:cname forKey:kCustomerName];
        _cname = cname;
    }
}

- (void)refreshHelperData
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _appkey = [userDefaults objectForKey:kAppKey];
    if ([_appkey length] == 0) {
        _appkey = kDefaultAppKey;
        [userDefaults setObject:_appkey forKey:kAppKey];
    }
    
    _cname = [userDefaults objectForKey:kCustomerName];
    if ([_cname length] == 0) {
        _cname = kDefaultCustomerName;
        [userDefaults setObject:_cname forKey:kCustomerName];
    }
    
    [userDefaults removeObjectForKey:@"username"];
    [userDefaults removeObjectForKey:@"password"];
    _username = nil;
    _password = nil;
}

@end
