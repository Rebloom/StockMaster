//
//  RootViewController.m
//  StockMaster
//
//  Created by Rebloom on 14-7-21.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "RootViewController.h"
#import "TKAlertCenter.h"
#import "HomeViewController.h"
#import "SecondLoginViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)requestSettings
{
    [GFRequestManager connectWithDelegate:self action:Get_settings param:nil];
    [GFStaticData saveObject:[Utility dateTimeToStringLF:[NSDate date]] forKey:kTagSettingRefreshTime];
}

//请求首页可领奖个数
- (void)requestFeeling
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [GFRequestManager connectWithDelegate:self action:Get_stock_feeling_reward_num param:paramDic];
}

- (void)delayNoti
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KTAGBADGE object:[[[requestInfo objectForKey:@"data"] objectForKey:@"feeling_reward_num"] description]];
}

// 请求结束
- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    
    ASIFormDataRequest * formDataRequet = (ASIFormDataRequest *)request;
    
    if ([formDataRequet.action isEqualToString:Get_stock_feeling_reward_num])
    {        
        [self performSelector:@selector(delayNoti) withObject:nil afterDelay:1];
    }
    else if ([formDataRequet.action isEqualToString:Get_settings])
    {
        [GFStaticData saveObject:[[[[[requestInfo objectForKey:@"data"] objectForKey:@"client_conf"] objectForKey:@"refresh_time"] objectForKey:@"settings"] description] forKey:kTagRefreshSettingTime];
        [GFStaticData saveObject:[[[[[requestInfo objectForKey:@"data"] objectForKey:@"client_conf"] objectForKey:@"refresh_time"] objectForKey:@"top_notice"] description] forKey:kTagRefreshTopNoticeTime];
        [GFStaticData saveObject:[[[[[requestInfo objectForKey:@"data"] objectForKey:@"top_notice"] objectForKey:@"network"] objectForKey:@"language"] objectForKey:@"network_unreachable"] forKey:kTagRequestFailedText];
                
        NSDictionary * clientEnvDic = [[requestInfo objectForKey:@"data"] objectForKey:@"client_env"];
        
        if ([clientEnvDic objectForKey:@"is_open_withdraw"])
        {
            if([[clientEnvDic objectForKey:@"is_open_withdraw"] integerValue])
            {
                [GFStaticData saveObject:@"YES" forKey:kTagAppStoreClose];
            }
            else
            {
                [GFStaticData saveObject:nil forKey:kTagAppStoreClose];
            }
        }
        else
        {
            [GFStaticData saveObject:@"YES" forKey:kTagAppStoreClose];
        }
        
        NSDictionary * appVersionInfo = [[requestInfo objectForKey:@"data"] objectForKey:@"app_version"];
        [GFStaticData saveObject:appVersionInfo forKey:kTagAppVersionInfo];
        
        [self judgeToViewController];
    }
}

// 请求失败
- (void)requestFailed:(ASIHTTPRequest *)request
{
    [self judgeToViewController];
}

// 判断去哪个页面
- (void)judgeToViewController
{
    BOOL isFirst = [[UserInfoCoreDataStorage sharedInstance] isFirstUserLogin];
    BOOL isLogin = [[UserInfoCoreDataStorage sharedInstance] isCurrentUserLogin];
    NSString *weiXin = [[UserInfoCoreDataStorage sharedInstance] getSettingInfoWithKey:kTagIsWeiXinLogin];
    if (isLogin || isFirst || (weiXin != nil)) {
        // 已登录、第一次登录或微信登录后注销 进首页
        [self performSelector:@selector(toHomeViewController) withObject:nil afterDelay:.5];
    }
    else {
        // 手机登录后注销 进第二登录页
        [self performSelector:@selector(toSecondLoginViewController) withObject:nil afterDelay:.5];
    }
}

// 点击去打开下载新版的url
- (void)buttonClickedAtIndex:(NSInteger)index
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:versionURL]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    NSString * imageName = @"";
    if ([UIScreen mainScreen].bounds.size.height == 480.0)
    {
        imageName = @"Default";
    }
    else if([UIScreen mainScreen].bounds.size.height == 568.0)
    {
        imageName = @"Default-568h";
    }
    else if ([UIScreen mainScreen].bounds.size.height == 667.0)
    {
        imageName = @"default（750*1334）";
    }
    else if ([UIScreen mainScreen].bounds.size.height == 736.0)
    {
        imageName = @"default(1242*2208)";
    }
    
    UIImageView * welcome = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    [self.view addSubview:welcome];
    
    [self addAnimation];
    //3.0 暂不上线
    if ([[UserInfoCoreDataStorage sharedInstance] isCurrentUserLogin])
    {
        [self requestFeeling];
    }
    [self requestSettings];
}

// 用一个渐隐的动画过渡
- (void)addAnimation
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:1];
    [animation setType: kCATransitionFade];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.view.layer addAnimation:animation forKey:@"CATransition"];
}

// 去首页
- (void)toHomeViewController
{
    HomeViewController * HVC = [[HomeViewController alloc] init];
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:HVC];
    nav.navigationBarHidden = YES;
    [HVC setSelectedTab:TabSelectedFirst];
    [self presentViewController:nav animated:YES completion:nil];
}

// 去第二种登录的页面
- (void)toSecondLoginViewController
{
    SecondLoginViewController * SLVC = [[SecondLoginViewController alloc] init];
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:SLVC];
    nav.navigationBarHidden = YES;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
