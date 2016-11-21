//
//  CheckCodeViewController.m
//  StockMaster
//
//  Created by Rebloom on 14-8-1.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "CheckCodeViewController.h"
#import "NSString+UIColor.h"
#import "UIImage+UIColor.h"
#import "SetUserInfoViewController.h"
#import "SetPasswordViewController.h"
#import "HomeViewController.h"

@interface CheckCodeViewController ()

@end

@implementation CheckCodeViewController

@synthesize passPhone;
@synthesize passCode;
@synthesize flag;
@synthesize type;

- (void)dealloc
{
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self Countdown];
    getBtn.userInteractionEnabled = NO;
    [phone becomeFirstResponder];
    phone.text = @"";
}

- (void)viewWillDisappear:(BOOL)animated
{
    [checkTimer invalidate];
    [super viewWillDisappear:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor =KSelectNewColor;
    //flag=1 注册页 / flag = 2 修改密码 / flag = 3 忘记密码
    if (flag == 1)
    {
        if (type == 1)
        {
            [headerView loadComponentsWithTitle:@"绑定手机号"];
        }
        else
        {
            [headerView loadComponentsWithTitle:@"注册(2/3)"];
        }
    }
    else if(flag == 2)
    {
        [headerView loadComponentsWithTitle:@"获取验证码"];
    }
    else if (flag == 3)
    {
        [headerView loadComponentsWithTitle:@"找回密码(2/2)"];
    }
    [headerView backButton];
    [headerView createLine];
    headerView.backgroundColor = kFontColorA;
    [headerView setStatusBarColor: kFontColorA];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    [self createUI];
}

// 初始化页面布局
- (void)createUI
{
    UIImageView * topView = [[UIImageView alloc] init];
    topView.userInteractionEnabled = YES;
    topView.frame = CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, 59);
    topView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:topView];
    
    UIImageView * firstIv = [[UIImageView alloc] init];
    firstIv.frame = CGRectMake(0, CGRectGetMaxY(topView.frame), screenWidth, 1);
    firstIv.image = [UIImage imageNamed:@"shadow_first"];
    [self.view addSubview:firstIv];
    
    
    UILabel * tipLb = [[UILabel alloc] init];
    tipLb.frame = CGRectMake(20, 0, 80, 60);
    tipLb.text = @"已发送短信至";
    tipLb.textAlignment = NSTextAlignmentCenter;
    tipLb.textColor = KFontNewColorA;
    tipLb.font = NormalFontWithSize(13);
    tipLb.backgroundColor = [UIColor clearColor];
    [topView addSubview:tipLb];
    
    UILabel * phoneLabel = [[UILabel alloc] init];
    phoneLabel.frame = CGRectMake(CGRectGetMaxX(tipLb.frame), 0, 100, 60);
    if(flag == 1 || flag == 3)
    {
        phoneLabel.text = [Utility departString:self.passPhone  withType:4];
    }
    else if (flag == 2)
    {
        phoneLabel.text = [NSString stringWithFormat:@"%@",[Utility departString:self.passPhone withType:4]];
    }
    phoneLabel.textAlignment = NSTextAlignmentLeft;
    phoneLabel.textColor = KFontNewColorD;
    phoneLabel.font = NormalFontWithSize(13);
    phoneLabel.backgroundColor = [UIColor clearColor];
    [topView addSubview:phoneLabel];
    
    getBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth-125, 0,110, 60)];
    getBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    [getBtn  setBackgroundImage:[[UIColor clearColor] image] forState:UIControlStateNormal] ;
    [getBtn setTitle:@"重新发送" forState:UIControlStateNormal];
    [getBtn setTitleColor:KFontNewColorD forState:UIControlStateNormal];
    [getBtn addTarget:self action:@selector(getOnClick) forControlEvents:UIControlEventTouchUpInside];
    getBtn.titleLabel.font = NormalFontWithSize(13);
    [topView addSubview:getBtn];
    
    UIView * whiteView = [[UIView alloc] init];
    whiteView.backgroundColor = kFontColorA;
    whiteView.frame =CGRectMake(0, CGRectGetMaxY(topView.frame), screenWidth, 60);
    [self.view addSubview:whiteView];
    
    phone = [[GFTextField alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topView.frame), screenWidth-15, 60)];
    phone.placeHolderColor = 1;
    phone.delegate = self;
    phone.clearButtonMode = UITextFieldViewModeWhileEditing;
    phone.backgroundColor = kFontColorA;
    phone.keyboardType = UIKeyboardTypeNumberPad;
    phone.placeholder = @"请输入验证码";
    phone.font = NormalFontWithSize(14);
    phone.textColor = kTitleColorA;
    [self.view addSubview:phone];
    
    UIImageView * iv = [[UIImageView alloc] init];
    iv.frame = CGRectMake(0, CGRectGetMaxY(phone.frame)+0.5, screenWidth, 1);
    iv.image = [UIImage imageNamed:@"shadow_first"];
    [self.view addSubview:iv];
    
    UIButton * nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(phone.frame)+20, screenWidth-40, 44)];
    nextBtn.tag = 1024;
    nextBtn.enabled = NO;
    nextBtn.layer.cornerRadius = 5;
    nextBtn.layer.masksToBounds = YES;
    [nextBtn setTintColor:kFontColorA];
    [nextBtn setBackgroundColor:KColorHeader];
    nextBtn.titleLabel.font = NormalFontWithSize(16);
    [nextBtn setTitle:@"确 定" forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(nextBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextBtn];
}

// 点击了页面收起输入
- (void)viewTapped:(id)sender
{
    if ([phone isFirstResponder])
    {
        [phone resignFirstResponder];
    }
}

// 点击获取验证码
- (void)getOnClick
{
    [self regetCheckCode];
    [self Countdown];
}

// 倒计时
- (void)Countdown
{
    [getBtn setTitle:@"60秒后重新发送" forState:UIControlStateNormal];
    
    date = [[NSDate alloc] init];
    
    time = 60;
    checkTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                  target:self
                                                selector:@selector(handleTimer)
                                                userInfo:nil
                                                 repeats:YES];
    getBtn.userInteractionEnabled = NO;
}

- (void)handleTimer
{
    if (time == 0) {
        [checkTimer pauseTimer];
        getBtn.userInteractionEnabled = YES;
        getBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        [getBtn setTitle:@"重新发送" forState:UIControlStateNormal];
        [getBtn setTitleColor:KFontNewColorD forState:UIControlStateNormal];
    }
    else
    {
        [getBtn setTitle:[NSString stringWithFormat:@"%d秒后重新发送",(int)time] forState:UIControlStateNormal];
        [getBtn setTitleColor:KFontNewColorB forState:UIControlStateNormal];
        
        NSDate * nowDate = [NSDate date];
        NSTimeInterval now = [nowDate timeIntervalSinceDate:date];
        
        time = 60-now;
    }
}

// 点击下一步
- (void)nextBtnClicked:(id)sender
{
    if (type == 1)
    {
        NSDictionary * wxLoginInfo = [[UserInfoCoreDataStorage sharedInstance] getSettingInfoWithKey:kTagWeiXinLoginInfo];
        NSDictionary * userInfo = [[UserInfoCoreDataStorage sharedInstance] getSettingInfoWithKey:kTagWeiXinUserInfo];
        NSMutableDictionary * param = [NSMutableDictionary dictionary];
        
        [param setObject:[wxLoginInfo objectForKey:@"access_token"] forKey:@"weixin_access_token"];

        [param setObject:[userInfo objectForKey:@"unionid"] forKey:@"weixin_union_id"];
        [param setObject:[userInfo objectForKey:@"nickname"] forKey:@"nickname"];
        [param setObject:[userInfo objectForKey:@"country"] forKey:@"weixin_country"];
        [param setObject:[userInfo objectForKey:@"province"] forKey:@"weixin_province"];
        [param setObject:[userInfo objectForKey:@"city"] forKey:@"weixin_city"];
        [param setObject:[userInfo objectForKey:@"sex"] forKey:@"weixin_sex"];
        [param setObject:[userInfo objectForKey:@"openid"] forKey:@"weixin_open_id"];
        [param setObject:[userInfo objectForKey:@"headimgurl"] forKey:@"weixin_headimgurl"];
        
        [param setObject:@"2" forKey:@"enc"];
        [param setObject:phone.text forKey:@"sms_code"];
        [param setObject:self.passPhone forKey:@"mobile"];
        
        [GFRequestManager connectWithDelegate:self action:Submit_user_register param:param];
    }
    else
    {
        NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
        [paramDic setObject:self.passPhone forKey:@"mobile"];
        [paramDic setObject:phone.text forKey:@"sms_code"];
        [GFRequestManager connectWithDelegate:self action:Submit_check_sms_code param:paramDic];
    }
}

// 重新获取验证码
- (void)regetCheckCode
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:self.passPhone forKey:@"mobile"];
    if (flag == 1)
    {
        [GFRequestManager connectWithDelegate:self action:Get_user_register_sms_code param:paramDic];
    }
    else if (flag == 2 || flag == 3)
    {
        [GFRequestManager connectWithDelegate:self action:Get_retrieve_password_sms_code param:paramDic];
    }
}

// 请求成功
- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    
    ASIFormDataRequest * formdataRequest = (ASIFormDataRequest *)request;
    if ([formdataRequest.action isEqualToString:Submit_check_sms_code])
    {
        if (flag == 1)
        {
            SetUserInfoViewController * SUIVC = [[SetUserInfoViewController alloc] init];
            SUIVC.phone = self.passPhone;
            SUIVC.code = phone.text;
            [self pushToViewController:SUIVC];
        }
        else if (flag == 2 ||flag == 3)
        {
            SetPasswordViewController * SPVC = [[SetPasswordViewController alloc] init];
            SPVC.passPhone = self.passPhone;
            SPVC.sms_code = phone.text;
            [self pushToViewController:SPVC];
        }
        [GFStaticData saveObject:self.passPhone forKey:kTagCheckMobile];
    }
    else if ([formdataRequest.action isEqualToString:Submit_user_register])
    {
        if (type == 1)
        {
            NSMutableDictionary *userDict = [[requestInfo objectForKey:@"data"] mutableCopy];
            NSDictionary * weixinUser = [[UserInfoCoreDataStorage sharedInstance] getSettingInfoWithKey:kTagWeiXinUserInfo];
            userDict[@"nickname"] = weixinUser[@"nickname"];
            userDict[@"mobile"] = self.passPhone;
            userDict[@"head"] = weixinUser[@"headimgurl"];
            userDict[@"signature"] = @"";
            
            [[UserInfoCoreDataStorage sharedInstance] saveLoginUserInfo:userDict];
            [[UserInfoCoreDataStorage sharedInstance] saveSettingInfoWithKey:kTagIsWeiXinLogin value:@"YES"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kTagLoginFinishedNoti object:nil];

            HomeViewController * HVC = [[HomeViewController alloc] init];
            [HVC setSelectedTab:TabSelectedFirst];
            [HVC showTabbar];
            [self presentViewController:HVC animated:NO completion:nil];
        }
    }
}

// 弹窗提示的代理方法
- (void)buttonClickedAtIndex:(NSInteger)index
{
    [phone becomeFirstResponder];
}

// 键盘监听的代理方法
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    UIButton * btn = (UIButton*)[self.view viewWithTag:1024];
    
    if (textField == phone)
    {
        if (string.length > 0 && ![string isEqualToString:@""])
        {
            btn.enabled = YES;
            [btn setBackgroundColor:kRedColor];
            [btn setTitleColor:kFontColorA forState:UIControlStateNormal];
            [btn setBackgroundImage:KBtnSelectNewColorA.image forState:UIControlStateHighlighted];
            [btn setBackgroundImage:KBtnSelectNewColorA.image forState:UIControlStateSelected];
            [btn addTarget:self action:@selector(nextBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            if (phone.text.length > 1)
            {
                btn.enabled = YES;
                [btn setBackgroundColor:kRedColor];
                [btn setTitleColor:kFontColorA forState:UIControlStateNormal];
                [btn setBackgroundImage:KBtnSelectNewColorA.image forState:UIControlStateHighlighted];
                [btn setBackgroundImage:KBtnSelectNewColorA.image forState:UIControlStateSelected];
                [btn addTarget:self action:@selector(nextBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            }
            else
            {
                btn.enabled = NO;
                [btn setBackgroundColor:KColorHeader];
                [btn setTintColor:kFontColorA];
            }
        }
    }
    
    return YES;
}

// 键盘点击消除按钮
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    UIButton * btn = (UIButton*)[self.view viewWithTag:1024];
    btn.enabled = NO;
    [btn setBackgroundColor:KColorHeader];
    [btn setTintColor:kFontColorA];
    
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
