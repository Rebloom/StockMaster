//
//  BasicViewController.m
//  StockMaster
//
//  Created by Rebloom on 14-7-22.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import "SearchViewController.h"
#import "SecondLoginViewController.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"

@interface BasicViewController () <UIGestureRecognizerDelegate>

@end

@implementation BasicViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    for (ASIFormDataRequest * request in [RequestQueue instance].requestList)
    {
        if ([request.action isEqualToString:Get_stock_data]
            || [request.action isEqualToString:Get_withdraw_home]
            || [request.action isEqualToString:Get_user_bank_card]
            || [request.action isEqualToString:Get_sms_code]
            || [request.action isEqualToString:Get_user_home]
            || [request.action isEqualToString:Get_top_withdraw_money]
            || [request.action isEqualToString:Get_user_performance]
            || [request.action isEqualToString:Get_faq_list]
            || [request.action isEqualToString:Get_invitation_task]
            || [request.action isEqualToString:Get_invitation_friends_num]
            || [request.action isEqualToString:Get_user_info]
            || [request.action isEqualToString:Get_stock_feeling_reward_num]
            || [request.action isEqualToString:Get_index_stock])
        {
            // 这些个请求要保留
        }
        else
        {
            [request cancel];
            request.delegate = nil;
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    headerView = [[HeaderView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, beginX+45)];
    headerView.delegate = self;
    [self.view addSubview:headerView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideTop) name:kTagTopShadowHideNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTopShadow) name:kTagTopShadowShowNoti object:nil];
    
    statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 20)];
    [self.view addSubview:statusBarView];
    
    topShadowView = [[UIView alloc] initWithFrame:CGRectMake(0, -110, screenWidth, 90)];
    topShadowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
    [self.view addSubview:topShadowView];
    
    topShowImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 90)];
    [topShadowView addSubview:topShowImage];
    
    topShowText = [[UILabel alloc] initWithFrame:CGRectMake(15, 28, screenWidth-40, 40)];
    topShowText.backgroundColor = [UIColor clearColor];
    topShowText.textColor = [UIColor whiteColor];
    topShowText.font = NormalFontWithSize(14);
    topShowText.numberOfLines = 2;
    [topShadowView addSubview:topShowText];
    
    closeImage = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-40, 30, 30, 30)];
    closeImage.image = [UIImage imageNamed:@"icon_close_home"];
    [topShadowView addSubview:closeImage];
    
    UIButton * shadowBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 90)];
    [shadowBtn addTarget:self action:@selector(shadowViewClicked:) forControlEvents:UIControlEventTouchUpInside];
    [topShadowView addSubview:shadowBtn];
    
    bCloseBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth-50, 10, 50, 70)];
    [bCloseBtn addTarget:self action:@selector(hideTopShadow) forControlEvents:UIControlEventTouchUpInside];
    [topShadowView addSubview:bCloseBtn];
    // Do any additional setup after loading the view.
}

- (void)shadowViewClicked:(id)sender
{
    NSURL * url = [NSURL URLWithString:@""];
    NSString * title = @"";

    UserInfoEntity *userInfo = [[UserInfoCoreDataStorage sharedInstance] getCurrentUserInfo];
    NSDictionary * topNoticeInfo = [GFStaticData getObjectForKey:kTagTopNoticeInfo forUser:userInfo.uid];
    
    if (isFailedShow || ![[UserInfoCoreDataStorage sharedInstance] isCurrentUserLogin] ||
        [[UserInfoCoreDataStorage sharedInstance] getSettingInfoWithKey:[Utility dictionaryDataToSignString:topNoticeInfo]])
    {
        return;
    }
    
    NSDictionary * noticeInfo = [topNoticeInfo objectForKey:@"notice_conf"];
    if ([[noticeInfo objectForKey:@"href"] description].length && [noticeInfo objectForKey:@"href_title"])
    {
        url = [NSURL URLWithString:[noticeInfo objectForKey:@"href"]];
        title = [noticeInfo objectForKey:@"href_title"];
        
        GFWebViewController * GWVC = [[GFWebViewController alloc] init];
        GWVC.requestUrl = url;
        GWVC.title = title;
        GWVC.flag = 0;
        GWVC.pageType = WebViewTypePresent;
        [self pushToViewController:GWVC];
    }
}

- (void)showTopShadow
{
    if (![NSStringFromClass([self class]) isEqualToString:@"FirstViewController"] ||
        ![[UserInfoCoreDataStorage sharedInstance] isCurrentUserLogin])
    {
        return;
    }
    
    UserInfoEntity *userInfo = [[UserInfoCoreDataStorage sharedInstance] getCurrentUserInfo];
    NSDictionary * topNoticeInfo = [GFStaticData getObjectForKey:kTagTopNoticeInfo forUser:userInfo.uid];
    if (!topNoticeInfo)
    {
        return;
    }
    
    if (isShow || ![[UserInfoCoreDataStorage sharedInstance] isCurrentUserLogin] ||
        [[UserInfoCoreDataStorage sharedInstance] getSettingInfoWithKey:[Utility dictionaryDataToSignString:topNoticeInfo]])
    {
        return;
    }
    
    NSInteger noticeType = [[topNoticeInfo objectForKey:@"notice_type"] integerValue];
    
    NSDictionary * noticeInfo = [topNoticeInfo objectForKey:@"notice_conf"];
    
    NSString * currentTime = [Utility dateTimeToStringLF:[NSDate date]];
    
    if (noticeType == 0)
    {
        return;
    }
    else if (noticeType == 1)
    {
        if (currentTime.doubleValue > [[noticeInfo objectForKey:@"start_time"] doubleValue] && currentTime.doubleValue < [[noticeInfo objectForKey:@"end_time"] doubleValue])
        {
            topShowImage.hidden = NO;
            topShowText.hidden = YES;
            NSURL * imageUrl = [NSURL URLWithString:[noticeInfo objectForKey:@"pic_src"]];
            [topShowImage sd_setImageWithURL:imageUrl placeholderImage:nil options:SDWebImageRefreshCached];
        }
        else
        {
            return;
        }
    }
    else if (noticeType == 2)
    {
        if (currentTime.doubleValue > [[noticeInfo objectForKey:@"start_time"] doubleValue] && currentTime.doubleValue < [[noticeInfo objectForKey:@"end_time"] doubleValue])
        {
            topShowText.hidden = NO;
            topShowImage.hidden = YES;
            topShowText.text = [noticeInfo objectForKey:@"text"];
        }
        else
        {
            return;
        }
    }
    else if (noticeType == 3)
    {
        NSString * date1 = [[UserInfoCoreDataStorage sharedInstance] getSettingInfoWithKey:kTagLoginDate1];
        NSString * Date2 = [[UserInfoCoreDataStorage sharedInstance] getSettingInfoWithKey:kTagLoginDate2];
        if ([date1 isEqualToString:[[noticeInfo objectForKey:@"prev_trade_days"] objectAtIndex:1]] && [Date2 isEqualToString:[[noticeInfo objectForKey:@"prev_trade_days"] objectAtIndex:2]])
        {
            return;
        }
        if (currentTime.doubleValue > [[noticeInfo objectForKey:@"start_time"] doubleValue] && currentTime.doubleValue < [[noticeInfo objectForKey:@"end_time"] doubleValue])
        {
            topShowText.hidden = NO;
            topShowImage.hidden = YES;
            topShowText.text = [[topNoticeInfo objectForKey:@"notice_conf"] objectForKey:@"text"];
        }
        else
        {
            return;
        }
    }
    
    isShow = YES;
    bCloseBtn.hidden = NO;
    closeImage.hidden = NO;
    [UIView beginAnimations:@"Animation" context:nil];
    [UIView setAnimationDuration:.5];
    topShadowView.frame = CGRectMake(0, 0, screenWidth, 90);
    [UIView commitAnimations];
    headerView.hidden = YES;
    [self.view bringSubviewToFront:topShadowView];
}

- (void)hideTop
{
    UserInfoEntity *userInfo = [[UserInfoCoreDataStorage sharedInstance] getCurrentUserInfo];
    NSDictionary * topNoticeInfo = [GFStaticData getObjectForKey:kTagTopNoticeInfo forUser:userInfo.uid];
    if (!topNoticeInfo)
    {
        return;
    }
    [self hideAnimate];
}

- (void)hideTopShadow
{
    UserInfoEntity *userInfo = [[UserInfoCoreDataStorage sharedInstance] getCurrentUserInfo];
    if ([GFStaticData getObjectForKey:kTagTopNoticeInfo forUser:userInfo.uid])
    {
        NSDictionary * topNoticeInfo = [GFStaticData getObjectForKey:kTagTopNoticeInfo forUser:userInfo.uid];
        [[UserInfoCoreDataStorage sharedInstance] saveSettingInfoWithKey:[Utility dictionaryDataToSignString:topNoticeInfo] value:@"YES"];
    }
    [self hideAnimate];
}

- (void)hideAnimate
{
    isShow = NO;
    [UIView beginAnimations:@"Animation" context:nil];
    [UIView setAnimationDuration:.5];
    topShadowView.frame = CGRectMake(0, -110, screenWidth, 90);
    [UIView commitAnimations];
    headerView.hidden = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if ([NSStringFromClass([self class]) isEqualToString:@"FirstViewController"] ||
        [NSStringFromClass([self class]) isEqualToString:@"SecondViewController"] ||
        [NSStringFromClass([self class]) isEqualToString:@"ThirdViewController"] ||
        [NSStringFromClass([self class]) isEqualToString:@"FourthViewController"] ||
        [NSStringFromClass([self class]) isEqualToString:@"FifthViewController"] ||
        [NSStringFromClass([self class]) isEqualToString:@"HomeViewController"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kTagShowTabbarNoti object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kTagHideTabbarNoti object:nil];
    }
    
    if ([NSStringFromClass([self class]) isEqualToString:@"FirstViewController"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kTagTopShadowShowNoti object:nil];
    }
    
    [self getSettings];
    [self getTopNoticeInfo];
    
    // 设置划动返回手势
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
}

- (void)getSettings
{
    NSDate * date = [NSDate date];
    if ([GFStaticData getObjectForKey:kTagSettingRefreshTime])
    {
        double refreshTime = [[GFStaticData getObjectForKey:kTagRefreshSettingTime] doubleValue];
        if ([[Utility dateTimeToStringLF:date] doubleValue] - [[GFStaticData getObjectForKey:kTagSettingRefreshTime] doubleValue] > (refreshTime?refreshTime:60*60*3))
        {
            if ([[UserInfoCoreDataStorage sharedInstance] isCurrentUserLogin])
            {
                [GFRequestManager connectWithDelegate:self action:Get_settings param:nil];
                [GFStaticData saveObject:[Utility dateTimeToStringLF:date] forKey:kTagSettingRefreshTime];
            }
        }
    }
    else
    {
        if ([[UserInfoCoreDataStorage sharedInstance] isCurrentUserLogin])
        {
            [GFRequestManager connectWithDelegate:self action:Get_settings param:nil];
            [GFStaticData saveObject:[Utility dateTimeToStringLF:date] forKey:kTagSettingRefreshTime];
        }
    }
}

- (void)getTopNoticeInfo
{
    NSDate * date = [NSDate date];
    if ([GFStaticData getObjectForKey:kTagTopNoticeRefreshTime])
    {
        double refreshTime = [[GFStaticData getObjectForKey:kTagRefreshSettingTime] doubleValue];
        if ([[Utility dateTimeToStringLF:date] doubleValue] - [[GFStaticData getObjectForKey:kTagTopNoticeRefreshTime] doubleValue] > (refreshTime?refreshTime:60*60*3))
        {
            if ([[UserInfoCoreDataStorage sharedInstance] isCurrentUserLogin])
            {
                [GFRequestManager connectWithDelegate:self action:Get_top_notice param:nil];
                [GFStaticData saveObject:[Utility dateTimeToStringLF:date] forKey:kTagTopNoticeRefreshTime];
            }
        }
    }
    else
    {
        if ([[UserInfoCoreDataStorage sharedInstance] isCurrentUserLogin])
        {
            [GFRequestManager connectWithDelegate:self action:Get_top_notice param:nil];
            [GFStaticData saveObject:[Utility dateTimeToStringLF:date] forKey:kTagTopNoticeRefreshTime];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    if ([NSStringFromClass([self class]) isEqualToString:@"FirstViewController"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kTagTopShadowHideNoti object:nil];
    }
    
    // 取消划动返回手势
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    
}
- (void)pushToViewController:(BasicViewController *)controller
{
    CATransition *animation = [CATransition animation];
    
    [animation setDuration:0.3];
    
    [animation setType: kCATransitionMoveIn];
    
    [animation setSubtype: kCATransitionFromRight];
    
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    
    [self.navigationController pushViewController:controller animated:NO];
    
    [self.navigationController.view.layer addAnimation:animation forKey:nil];
}

- (void)subPushToViewController:(BasicViewController *)controller
{
    CATransition *animation = [CATransition animation];
    
    [animation setDuration:0.3];
    
    [animation setType: kCATransitionMoveIn];
    
    [animation setSubtype: kCATransitionFromTop];
    
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    
    [self.navigationController pushViewController:controller animated:NO];
    
    [self.navigationController.view.layer addAnimation:animation forKey:nil];
}

- (void)presentViewController:(BasicViewController *)controller
{
    CATransition *animation = [CATransition animation];
    
    [animation setDuration:1];
    
    [animation setType: kCATransitionMoveIn];
    
    [animation setSubtype: kCATransitionFromBottom];
    
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    
    [self presentViewController:controller animated:NO completion:nil];
    
    [self.view.layer addAnimation:animation forKey:nil];
}

- (void)back
{
    if (self.navigationController && self.navigationController.viewControllers.count>1)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)backToRootViewController
{
    if (self.navigationController && self.navigationController.viewControllers.count>1)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)buttonClicked:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    if (btn.tag == 1)
    {
        [self back];
    }
    else if (btn.tag == 5) {
        [self backToRootViewController];
    }
}

-(void)buttonClickedAtIndex:(NSInteger)index
{
    return;
}

-(void)backToLogin
{
    [[UserInfoCoreDataStorage sharedInstance] currentUserLogout];
    SecondLoginViewController * LGVC = [[SecondLoginViewController alloc] init];
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:LGVC];
    nav.navigationBarHidden = YES;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    ASIFormDataRequest * formDataRequet = (ASIFormDataRequest *)request;
    
    if ([formDataRequet.action isEqualToString:@"WXLOGIN"])
    {
        [[UserInfoCoreDataStorage sharedInstance] saveSettingInfoWithKey:kTagRequestAccessToken value:nil];
        NSDictionary * back = [request.responseString objectFromJSONString];
        
        if ([[back objectForKey:@"errcode"] integerValue])
        {
            [[CHNAlertView defaultAlertView] showContent:@"授权失败" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
            
        }
        else
        {
            [[UserInfoCoreDataStorage sharedInstance] saveSettingInfoWithKey:kTagWeiXinLoginInfo value:back];
            NSMutableDictionary * param = [NSMutableDictionary dictionary];
            [param setObject:[back objectForKey:@"unionid"] forKey:@"weixin_union_id"];
            [param setObject:[[back objectForKey:@"access_token"] description] forKey:@"weixin_access_token"];
            [GFRequestManager connectWithDelegate:self action:Submit_user_weixin_login  param:param];
            
            [self getWXUserInfoWithCode:[back objectForKey:@"access_token"]];
        }
        
        return;
    }
    else if ([formDataRequet.action isEqualToString:@"WXUSERINFO"])
    {
        NSDictionary * back = [request.responseString objectFromJSONString];
        [[UserInfoCoreDataStorage sharedInstance] saveSettingInfoWithKey:kTagWeiXinUserInfo value:back];
        return;
    }
    
    if (isFailedShow)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kTagTopShadowHideNoti object:nil];
        isFailedShow = NO;
    }

    NSString * encodeString = [request.responseString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    //NSLog(@"res is %@",encodeString);
    
    encodeString = [encodeString stringByReversed];
        
    NSString * decodeString = [encodeString authCodeDecoded:kTagDecryptorKey];
    
    requestInfo = [[[[decodeString componentsSeparatedByString:kFlagDepartRequestInfoString] lastObject] objectFromJSONString] mutableCopy];

    if (requestInfo)
    {
        if ([formDataRequet.action isEqualToString:Get_settings])
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
        }
        else if ([formDataRequet.action isEqualToString:Get_top_notice])
        {
            if ([[UserInfoCoreDataStorage sharedInstance] isCurrentUserLogin])
            {
                UserInfoEntity *userInfo = [[UserInfoCoreDataStorage sharedInstance] getCurrentUserInfo];
                [GFStaticData saveObject:[requestInfo objectForKey:@"data"] forKey:kTagTopNoticeInfo forUser:userInfo.uid];
                [self showTopShadow];
            }
        }
        else if ([formDataRequet.action isEqualToString:Submit_user_weixin_login])
        {
            if ([[requestInfo objectForKey:@"err_code"] integerValue])
            {
                if ([[requestInfo objectForKey:@"err_code"] integerValue] == 10146||[[requestInfo objectForKey:@"err_code"] integerValue] == 10147)
                {
                    if ([[UserInfoCoreDataStorage sharedInstance] getSettingInfoWithKey:kTagWXLoginFromHome])
                    {
                        RegisterViewController * RVC = [[RegisterViewController alloc] init];
                        RVC.type = 1;
                        RVC.bindString = [requestInfo objectForKey:@"message"];
                        [self pushToViewController:RVC];
                    }
                    else
                    {
                         [[NSNotificationCenter defaultCenter] postNotificationName:kTagWXToRegisterVCNoti object:[[requestInfo objectForKey:@"message"] description]];
                    }
                    return;
                }
            }
            else
            {
                NSDictionary *userInfo = [requestInfo objectForKey:@"data"];
                [[UserInfoCoreDataStorage sharedInstance] saveLoginUserInfo:userInfo];
                [[UserInfoCoreDataStorage sharedInstance] saveSettingInfoWithKey:kTagIsWeiXinLogin value:@"YES"];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kTagLoginFinishedNoti object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:kTagWXLoginRefresh object:nil];
            }
        }
        
        if ([[requestInfo objectForKey:@"err_code"] integerValue])
        {
            //2.0版本 暂用  err_code  = 10019 表示再其他设备登陆  老版本 503
            ASIFormDataRequest * formDataRequest = (ASIFormDataRequest *)request;
            formDataRequest.action = @"";
            
            if ([[requestInfo objectForKey:@"err_code"] integerValue] == 10019)
            {
                // 错误情况处理
                
                [[TKAlertCenter defaultCenter] postAlertWithMessage:[requestInfo objectForKey:@"message"] withType:ALERTTYPEERROR];
                [self performSelector:@selector(backToLogin) withObject:nil afterDelay:2];
            }
            else if ([[requestInfo objectForKey:@"err_code"] integerValue] == 10053)
            {
                //提现进去绑定银行卡，如果没绑定过身份证不做提示（邀请送现金时用到）
            }
            else if ([[requestInfo objectForKey:@"err_code"] integerValue] == 10055)
            {
                //手机号已注册
            }
            else if ([[requestInfo objectForKey:@"err_code"] integerValue] == 10056)
            {
                //手机号未注册
            }
            else
            {
                NSLog(@"request.action is %@",formDataRequest.action);
                NSLog(@"requestInfo is %@",requestInfo);
                // 错误情况处理
                [[CHNAlertView defaultAlertView] showContent:[requestInfo objectForKey:@"message"] cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
            }
        }
    }
    else
    {
        NSLog(@"back is %@",request.responseString);
        ASIFormDataRequest * formDataRequest = (ASIFormDataRequest *)request;
        NSLog(@"actions is %@",formDataRequest.action);
        formDataRequest.action = @"";
        [[CHNAlertView defaultAlertView] showContent:@"服务器繁忙，请稍后" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
    }
}

- (void)getWXUserInfoWithCode:(NSString *)code
{
    NSString * path = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",code,kWeiXinAppKey];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:path]];
    [request setRequestMethod:@"GET"];
    [request setCachePolicy:ASIDoNotReadFromCacheCachePolicy];
    request.delegate = self;
    request.action = @"WXUSERINFO";
    [request startAsynchronous];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    isFailedShow = YES;
    [[UserInfoCoreDataStorage sharedInstance] saveSettingInfoWithKey:kTagRequestAccessToken value:nil];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([NSStringFromClass([self class]) isEqualToString:@"FirstViewController"] ||
        [NSStringFromClass([self class]) isEqualToString:@"SecondViewController"] ||
        [NSStringFromClass([self class]) isEqualToString:@"ThirdViewController"] ||
        [NSStringFromClass([self class]) isEqualToString:@"FourthViewController"] ||
        [NSStringFromClass([self class]) isEqualToString:@"FifthViewController"] ||
        [NSStringFromClass([self class]) isEqualToString:@"HomeViewController"])
    {
        if (isShow)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kTagTopShadowHideNoti object:nil];
        }
        topShowText.hidden = NO;
        topShowImage.hidden = YES;
        bCloseBtn.hidden = YES;
        closeImage.hidden = YES;
        topShowText.text = [GFStaticData getObjectForKey:kTagRequestFailedText]?[GFStaticData getObjectForKey:kTagRequestFailedText]:@"网络连接失败";
        
        isShow = YES;
        [UIView beginAnimations:@"Animation" context:nil];
        [UIView setAnimationDuration:.5];
        topShadowView.frame = CGRectMake(0, 0, screenWidth, 90);
        [UIView commitAnimations];
        headerView.hidden = YES;
        [self.view bringSubviewToFront:topShadowView];
    }
    else
    {
        [[CHNAlertView defaultAlertView] showContent:@"网络连接失败" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[UITableViewCell alloc] initWithFrame:CGRectZero];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [MBProgressHUD hideHUDForView:self.view animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
