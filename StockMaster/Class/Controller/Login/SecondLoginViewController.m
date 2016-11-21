//
//  SecondLoginViewController.m
//  StockMaster
//
//  Created by dalikeji on 14/12/3.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "SecondLoginViewController.h"
#import "RegisterViewController.h"
#import "ForgetPasswordViewController.h"
#import "LoginViewController.h"
#import "UserInfoCoreDataStorage.h"

@interface SecondLoginViewController ()
{
    UserInfoEntity *userInfo;
}
@end

@implementation SecondLoginViewController

- (void)dealloc
{
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [passWordTf becomeFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    userInfo = [[UserInfoCoreDataStorage sharedInstance] getCurrentUserInfo];
    
    self.view.backgroundColor = KSelectNewColor;
    
    [headerView setStatusBarColor:kFontColorA];
    
    [self createUI];
    
    UITapGestureRecognizer * viewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    viewTap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:viewTap];
}

// 初始化页面布局
- (void)createUI
{
    UIImageView * view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, screenWidth, 240)];
    view.userInteractionEnabled = YES;
    view.backgroundColor = kFontColorA;
    [self.view addSubview:view];
    
    for(int i = 0; i<2 ;i++)
    {
        UIImageView * imageView = [[UIImageView alloc ]init];
        imageView.image = [UIImage imageNamed:@"shadow_first"];
        if (i == 0)
        {
            imageView.frame = CGRectMake(0, 60, screenWidth, 1);
        }
        if (i == 1) {
            imageView.frame = CGRectMake(0, 240, screenWidth, 1);
        }
        [view addSubview:imageView];
    }
    
    NSArray * arr = @[@"注册",@"找密码",@"换账号"];
    for (int i = 0; i<3; i++) {
        UIButton * btn = [[UIButton alloc] init];
        btn.tag = i;
        if (i == 0)
        {
            btn.frame = CGRectMake(0, 10, 60, 49);
        }
        else if (i == 1)
        {
            btn.frame = CGRectMake(screenWidth/2-50, 10, 100, 49);
        }
        else if (i == 2)
        {
            btn.frame = CGRectMake(screenWidth-70, 10, 60, 49);
        }
        btn.titleLabel.font = NormalFontWithSize(16);
        [btn setTitle:[arr objectAtIndex:i] forState:UIControlStateNormal];
        [btn setTitleColor:KFontNewColorD forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor whiteColor]];
        [btn addTarget:self action:@selector(btnLoginOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:btn];
        [view bringSubviewToFront:btn];
    }
    
    UIImageView * bgView = [[UIImageView alloc ] init];
    bgView.frame = CGRectMake(screenWidth/2-40, 80, 80, 80);
    bgView.layer .masksToBounds = YES;
    bgView.layer.cornerRadius = 40;
    
    if (userInfo != nil)
    {
        // 去掉头像url后面的参数，因为参数为随机变动时间
        NSArray *urlArray = [userInfo.head componentsSeparatedByString:@"?"];
        NSString *headUrl = urlArray.firstObject;
        [bgView sd_setImageWithURL:[NSURL URLWithString:headUrl]
                   placeholderImage:[UIImage imageNamed:@"icon_user_default"]
                            options:SDWebImageRefreshCached];
    }
    else
    {
        bgView.image = [UIImage imageNamed:@"icon_user_default"];
    }
    
    [view addSubview:bgView];
    
    UIView  *  alphaView = [[UIView alloc]init];
    alphaView.frame = CGRectMake(screenWidth/2-40, 80, 80, 80) ;
    alphaView.layer.cornerRadius = 40;
    alphaView.layer.masksToBounds =YES;
    alphaView.backgroundColor = @"#000000".color;
    alphaView.alpha = 0.3;
    [view addSubview:alphaView];
    
    UIButton * phoneBtn = [[UIButton alloc] init];
    phoneBtn.tag = 2;
    phoneBtn.layer.cornerRadius = 40;
    phoneBtn.layer.masksToBounds = YES;
    phoneBtn.backgroundColor = [UIColor clearColor];
    phoneBtn.frame = CGRectMake(screenWidth/2-40, 80, 80, 80);
    
    if (userInfo != nil)
    {
        phoneBtn.titleLabel.text = userInfo.mobile;
        [phoneBtn setTitle:userInfo.mobile forState:UIControlStateNormal];
    }
    phoneBtn.titleLabel.font = NormalFontWithSize(13);
    [phoneBtn setTitleColor:kFontColorA forState:UIControlStateNormal];
    [phoneBtn addTarget:self action:@selector(btnLoginOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:phoneBtn];
    
    
    UILabel * lineLabel = [[UILabel alloc] init];
    lineLabel.frame = CGRectMake(0, 180, screenWidth, 0.5);
    lineLabel.backgroundColor = KColorHeader;
    [view addSubview:lineLabel];
    
    UIImageView * imgView = [[UIImageView alloc] init];
    imgView.image = [UIImage imageNamed:@"suo"];
    imgView.frame = CGRectMake(20, 199, 22.5, 22.5);
    [view addSubview:imgView];
    
    passWordTf = [[GFTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imgView.frame)+5, 181, screenWidth-60, 59)];
    passWordTf.placeHolderColor = 1;
    passWordTf.placeholder = @"输入密码";
    passWordTf.secureTextEntry = YES;
    passWordTf.clearButtonMode = UITextFieldViewModeWhileEditing;
    passWordTf.delegate = self;
    passWordTf.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    passWordTf.textColor = KFontNewColorA;
    passWordTf.font = NormalFontWithSize(15);
    [view addSubview:passWordTf];
    
    
    UIButton * loginBtn = [[UIButton alloc] init];
    loginBtn.userInteractionEnabled = YES;
    loginBtn.enabled = NO;
    loginBtn.tag = 100;
    loginBtn.layer.cornerRadius = 5;
    loginBtn.layer.masksToBounds = YES;
    loginBtn.frame = CGRectMake(20, CGRectGetMaxY(view.frame)+20, screenWidth-40, 44);
    loginBtn.titleLabel.font = NormalFontWithSize(15);
    [loginBtn setTitleColor:kFontColorA forState:UIControlStateNormal];
    [loginBtn setBackgroundColor:KColorHeader];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(loginBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
    
    UILabel * tipLabel = [[UILabel alloc] init];
    tipLabel.frame = CGRectMake(0,screenHeight - 52 - 14, screenWidth, 14);
    tipLabel.text = @"免费炒股,大赚真钱";
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.font = NormalFontWithSize(14);
    tipLabel.textColor = KFontNewColorC;
    tipLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tipLabel];
    
    UIImageView * imageIv = [[UIImageView alloc] init];
    imageIv . frame = CGRectMake(screenWidth/2-15, CGRectGetMinY(tipLabel.frame) - 10 - 23, 30, 23);
    imageIv.image = [UIImage imageNamed:@"zhangzhang"];
    [self.view addSubview:imageIv];
    
}

// 点击注册按钮或忘记密码按钮或登录按钮
- (void)btnLoginOnClick:(UIButton*)sender
{
    if (sender.tag == 0)
    {
        RegisterViewController * RVC = [[RegisterViewController alloc] init];
        [self pushToViewController:RVC];
    }
    else if (sender.tag == 1)
    {
        ForgetPasswordViewController * FPVC = [[ForgetPasswordViewController alloc] init];
        FPVC.type = 2;
        FPVC.phoneNum = userInfo.mobile;
        [self pushToViewController: FPVC];
    }
    else if (sender.tag == 2)
    {
        LoginViewController * LVC = [[LoginViewController alloc ]init];
        [self pushToViewController:LVC];
    }
}

// 点击登录的请求
- (void)loginBtnOnClick:(UIButton*)sender
{
    if (passWordTf.text.length)
    {
        if (userInfo.mobile.length == 11)
        {
            NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
            [paramDic setObject:userInfo.mobile forKey:@"mobile"];
            [paramDic setObject:[Utility md5:passWordTf.text] forKey:@"password"];
            [paramDic setObject:@"2" forKey:@"enc"];
            [GFRequestManager connectWithDelegate:self action:Submit_user_login param:paramDic];
        }
        else
        {
            [[CHNAlertView defaultAlertView] showContent:@"请输入有效的手机号" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
        }
    }
    else
    {
        [[CHNAlertView defaultAlertView] showContent:@"请输入有效的手机号码" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
    }
}

- (void)buttonClickedAtIndex:(NSInteger)index
{
    [passWordTf becomeFirstResponder];
}

// 请求成功
- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    ASIFormDataRequest * formdataRequest = (ASIFormDataRequest *)request;
    if ([formdataRequest.action isEqualToString:Submit_user_login])
    {
        NSDictionary *userDict = [requestInfo objectForKey:@"data"];
        [[UserInfoCoreDataStorage sharedInstance] saveLoginUserInfo:userDict];
        userInfo = [[UserInfoCoreDataStorage sharedInstance] getCurrentUserInfo];
        [[UserInfoCoreDataStorage sharedInstance] saveSettingInfoWithKey:kTagIsWeiXinLogin value:nil];

        [[NSNotificationCenter defaultCenter] postNotificationName:kTagLoginFinishedNoti object:nil];
        
        HomeViewController * HVC = [[HomeViewController alloc] init];
        [HVC setSelectedTab:TabSelectedFirst];
        [HVC showTabbar];
        [self presentViewController:HVC animated:NO completion:nil];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    UIButton * btn = (UIButton*)[self.view viewWithTag:100];
    
    if (textField == passWordTf)
    {
        if (string.length > 0 && ![string isEqualToString:@""])
        {
            btn.enabled = YES;
            [btn setBackgroundColor:kRedColor];
            [btn setTitleColor:kFontColorA forState:UIControlStateNormal];
            [btn setBackgroundImage:KBtnSelectNewColorA.image forState:UIControlStateHighlighted];
            [btn setBackgroundImage:KBtnSelectNewColorA.image forState:UIControlStateSelected];
            [btn addTarget:self action:@selector(loginBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            if (passWordTf.text.length > 1)
            {
                btn.enabled = YES;
                [btn setBackgroundColor:kRedColor];
                [btn setTitleColor:kFontColorA forState:UIControlStateNormal];
                [btn setBackgroundImage:KBtnSelectNewColorA.image forState:UIControlStateHighlighted];
                [btn setBackgroundImage:KBtnSelectNewColorA.image forState:UIControlStateSelected];
                [btn addTarget:self action:@selector(loginBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
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

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    UIButton * btn = (UIButton*)[self.view viewWithTag:100];
    btn.enabled = NO;
    [btn setBackgroundColor:KColorHeader];
    [btn setTintColor:kFontColorA];
    
    return YES;
}

// 点击页面，输入框失去焦点
- (void)viewTapped:(UITapGestureRecognizer*)ges
{
    if([passWordTf isFirstResponder])
    {
        [passWordTf resignFirstResponder];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
