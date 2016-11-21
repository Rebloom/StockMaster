//
//  LoginViewController.m
//  StockMaster
//
//  Created by Rebloom on 14-7-28.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "LoginViewController.h"
#import "ASIHTTPRequest.h"
#import "UIImage+UIColor.h"
#import "ASIFormDataRequest.h"
#import "ForgetPasswordViewController.h"
#import "UserInfoCoreDataStorage.h"

#define KRedirectURI   @"https://api.weibo.com/oauth2/default.html"
#define TencentAppID   @"1102859979"

#define TAGBUTTON   10086
#define KTagForgetBtn   10010
@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize flag;
@synthesize loginPhone;
@synthesize abandonType;

- (void)dealloc
{
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if (phone && !self.loginPhone)
    {
        [phone becomeFirstResponder];
    }
    else if (self.loginPhone)
    {
        [phone resignFirstResponder];
        [password becomeFirstResponder];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WXLoginFinished:) name:kTagWXShareFinished object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WXLoginRefresh:) name:kTagWXLoginRefresh object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wxToLoginRegisterViewController:) name:kTagWXToRegisterVCNoti object:nil];
    self.view.backgroundColor =KSelectNewColor;
    
    [headerView loadComponentsWithTitle:@"登录"];
    if (abandonType != 1)
    {
        [self buttonBack];
    }
    else
    {
        UIButton * registerBtnOnClick = [[UIButton alloc]init];
        registerBtnOnClick.frame = CGRectMake(-5, 20, 80, 44);
        registerBtnOnClick.titleLabel.font = NormalFontWithSize(15);
        registerBtnOnClick.backgroundColor = [UIColor clearColor];
        [registerBtnOnClick setTitle:@"注册" forState:UIControlStateNormal];
        [registerBtnOnClick setTitleColor:kRedColor forState:UIControlStateNormal];
        [registerBtnOnClick addTarget:self action:@selector(registerBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];;
        [headerView addSubview:registerBtnOnClick];
        
    }
    [headerView createLine];
    headerView.backgroundColor = kFontColorA;
    [headerView setStatusBarColor: kFontColorA];
    
    isSecond = NO;
    isBack = NO;
    
    UIButton * forgetBtn = [[UIButton alloc]init];
    forgetBtn.frame = CGRectMake(screenWidth-80, 20, 80, 44);
    forgetBtn.tag = KTagForgetBtn;
    forgetBtn.titleLabel.font = NormalFontWithSize(15);
    forgetBtn.backgroundColor = [UIColor clearColor];
    forgetBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20);
    [forgetBtn setTitle:@"忘记密码" forState:UIControlStateNormal];
    [forgetBtn setTitleColor:kRedColor forState:UIControlStateNormal];
    [forgetBtn addTarget:self action:@selector(forgetBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];;
    [headerView addSubview:forgetBtn];
    
    UITapGestureRecognizer * viewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    viewTap.cancelsTouchesInView = NO;
    viewTap.delegate = self;
    [self.view addGestureRecognizer:viewTap];
    
    [self createUI];
}

- (void)wxToLoginRegisterViewController:(NSNotification *)noti
{
    RegisterViewController * RVC = [[RegisterViewController alloc] init];
    RVC.type = 1;
    RVC.bindString = (NSString *)[noti object];
    [self pushToViewController:RVC];
}

- (void)buttonBack
{
    UIButton * backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, beginX, 60, kTagHeaderHeight)];
    backButton.tag = TAGBUTTON;
    UIImageView * backImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, beginX+13, 11, 20)];
    [backImage setBackgroundColor:[UIColor clearColor]];
    backImage.image = [UIImage imageNamed:@"jiantou-zuo"];
    [headerView addSubview:backImage];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:backButton];
    
}

// 初始化页面布局
- (void)createUI
{
    UIView * bgView = [[UIView alloc] init ];
    bgView.frame = CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, 120);
    bgView.userInteractionEnabled = YES;
    bgView.backgroundColor = kFontColorA;
    [self.view addSubview:bgView];
    
    for (int i = 0; i<2; i++)
    {
        UIImageView * lineIv = [[UIImageView alloc] init];
        lineIv.image = [UIImage imageNamed:@"shadow_first"];
        if (i == 0)
        {
            lineIv.frame = CGRectMake(0, 59.5, screenWidth, 0.5);
        }
        else if (i == 1)
        {
            lineIv.frame = CGRectMake(0, 119, screenWidth, 1);
        }
        [bgView addSubview:lineIv];
    }
    
    phone = [[GFTextField alloc] initWithFrame:CGRectMake(0, 0, screenWidth-12, 60)];
    phone.delegate = self;
    phone.clearButtonMode = UITextFieldViewModeWhileEditing;
    phone.placeholder = @"手机号码";
    phone.textColor = KFontNewColorA;
    if (loginPhone)
    {
        phone.text = self.loginPhone;
    }
    phone.placeHolderColor = 1;
    phone.font = NormalFontWithSize(15);
    phone.keyboardType = UIKeyboardTypeNumberPad;
    [bgView addSubview:phone];
    [phone becomeFirstResponder];
    
    
    password = [[GFTextField alloc] initWithFrame:CGRectMake(0, 60, screenWidth-12, 60)];
    password.placeholder = @"密码";
    password.secureTextEntry = YES;
    password.placeHolderColor = 1;
    password.clearButtonMode = UITextFieldViewModeWhileEditing;
    password.delegate = self;
    password.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    password.textColor = KFontNewColorA;
    password.font = NormalFontWithSize(15);
    [bgView addSubview:password];
    
    UIButton * loginBtn = [[UIButton alloc] init];
    loginBtn.userInteractionEnabled = YES;
    loginBtn.enabled = NO;
    loginBtn.tag = 100;
    loginBtn.layer.cornerRadius = 5;
    loginBtn.layer.masksToBounds = YES;
    loginBtn.frame = CGRectMake(20, CGRectGetMaxY(bgView.frame)+20, screenWidth-40, 44);
    loginBtn.titleLabel.font = NormalFontWithSize(15);
    [loginBtn setTitleColor:kFontColorA forState:UIControlStateNormal];
    [loginBtn setBackgroundColor:KColorHeader];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(loginBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
    
    UIButton * WXLoginBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(loginBtn.frame)+20, screenWidth, 60)];
    WXLoginBtn.backgroundColor = @"#f5f5f5".color;
    [WXLoginBtn addTarget:self action:@selector(WXLogin) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:WXLoginBtn];
    
    UIImageView * WXIcon = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth/2-60, 16, 29, 27.5)];
    WXIcon.image = [UIImage imageNamed:@"icon_weixin"];
    WXIcon.userInteractionEnabled = NO;
    [WXLoginBtn addSubview:WXIcon];
    
    UILabel * WXLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(WXIcon.frame)+9, 0, 100, 60)];
    WXLabel.text = @"微信登录";
    WXLabel.userInteractionEnabled = NO;
    WXLabel.backgroundColor = [UIColor clearColor];
    WXLabel.font = NormalFontWithSize(15);
    WXLabel.textColor = @"#494949".color;
    WXLabel.textAlignment = NSTextAlignmentLeft;
    [WXLoginBtn addSubview:WXLabel];
    
    UILabel * tipLabel = [[UILabel alloc] init];
    tipLabel.frame = CGRectMake(0,screenHeight - 52 - 14, screenWidth, 14);
    tipLabel.text = @"免费炒股,大赚真钱";
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.font = NormalFontWithSize(14);
    tipLabel.textColor = KFontNewColorC;
    tipLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tipLabel];
    
    UIImageView * imageView = [[UIImageView alloc] init];
    imageView . frame = CGRectMake(screenWidth/2-15, CGRectGetMinY(tipLabel.frame) - 10 - 23, 30, 23);
    imageView.image = [UIImage imageNamed:@"zhangzhang"];
    [self.view addSubview:imageView];
}

- (void)WXLogin
{
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        [[CHNAlertView defaultAlertView] showContent:@"网络连接失败" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
    }
    else
    {
        // 判断是不是从首页登录，如果是标识YES 从微信登录返回后直接push到register页面，如果不是标识nil，发通知让FirstViewController来push到register页面
        [[UserInfoCoreDataStorage sharedInstance] saveSettingInfoWithKey:kTagWXLoginFromHome value:nil];
        SendAuthReq * req = [[SendAuthReq alloc] init];
        req.openID = kWeiXinAppKey;
        req.scope = @"snsapi_userinfo";
        req.state = @"weixin_login";
        [WXApi sendReq:req];
    }
}

- (void)WXLoginFinished:(NSNotification *)noti
{
    BaseResp * resp = [noti object];
    if (resp.errCode == 0)
    {
        if ([resp isKindOfClass:[SendAuthResp class]])
        {
            SendAuthResp * sendAuthResp = (SendAuthResp *)resp;
            if (sendAuthResp.code)
            {
                [self getAccessTokenWithCode:sendAuthResp.code];
            }
        }
    }
}

- (void)getAccessTokenWithCode:(NSString *)code
{
    UserInfoCoreDataStorage *coreDataStorage = [UserInfoCoreDataStorage sharedInstance];
    if (![coreDataStorage getSettingInfoWithKey:kTagRequestAccessToken])
    {
        [coreDataStorage saveSettingInfoWithKey:kTagRequestAccessToken value:@"YES"];
        NSString * path = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",kWeiXinAppKey,kWeiXinAppSecret, code];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:path]];
        [request setRequestMethod:@"GET"];
        [request setCachePolicy:ASIDoNotReadFromCacheCachePolicy];
        request.delegate = self;
        request.action = @"WXLOGIN";
        [[RequestQueue instance].requestList addObject:request];
        [request startAsynchronous];
    }
}

- (void)WXLoginRefresh:(NSNotification *)noti
{
    HomeViewController * HVC = [[HomeViewController alloc] init];
    [HVC setSelectedTab:TabSelectedFirst];
    [HVC showTabbar];
    [self presentViewController:HVC animated:NO completion:nil];
}

// 点击页面，输入失去焦点
- (void)viewTapped:(id)sender
{
    if ([phone isFirstResponder])
    {
        [phone resignFirstResponder];
    }
    if ([password isFirstResponder])
    {
        [password resignFirstResponder];
    }
}

// 点击忘记密码
- (void)forgetBtnOnClick:(UIButton*)sender
{
    ForgetPasswordViewController * FPVC = [[ForgetPasswordViewController alloc] init];
    FPVC.type = 2;
    FPVC.phoneNum = [phone.text copy];
    [self pushToViewController:FPVC];
}

// 点击登录密码
-(void)loginBtnOnClick:(UIButton *)sender
{
    if (phone.text.length == 11)
    {
        NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
        [paramDic setObject:phone.text forKey:@"mobile"];
        [paramDic setObject:[Utility md5:password.text] forKey:@"password"];
        [paramDic setObject:@"2" forKey:@"enc"];
        [GFRequestManager connectWithDelegate:self action:Submit_user_login param:paramDic];
    }
    else
    {
        [[CHNAlertView defaultAlertView] showContent:@"请输入有效的手机号码" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
    }
}

- (void)registerBtnOnClick:(UIButton*)sender
{
    RegisterViewController * RVC = [[RegisterViewController alloc] init];
    [self pushToViewController:RVC];
}

// 弹窗点击的代理方法
-(void)buttonClickedAtIndex:(NSInteger)index
{
    [phone becomeFirstResponder];
}

// 请求成功
- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    ASIFormDataRequest * formdataRequest = (ASIFormDataRequest *)request;
    [[UserInfoCoreDataStorage sharedInstance] saveSettingInfoWithKey:kTagRequestAccessToken value:nil];
    if ([formdataRequest.action isEqualToString:Submit_user_login])
    {
        NSDictionary *userDict = [requestInfo objectForKey:@"data"];
        if ([userDict objectForKey:@"nickname"]) {
            [[UserInfoCoreDataStorage sharedInstance] saveLoginUserInfo:userDict];
            UserInfoEntity *userInfo = [[UserInfoCoreDataStorage sharedInstance] getCurrentUserInfo];
            [[UserInfoCoreDataStorage sharedInstance] saveSettingInfoWithKey:kTagIsWeiXinLogin value:nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kTagLoginFinishedNoti object:nil];
            
            // 诸葛统计（用户登录）
            NSMutableDictionary *user = [NSMutableDictionary dictionary];
            user[@"用户id"] = userInfo.uid;
            user[@"用户名"] = userInfo.nickname;
            user[@"手机"] = userInfo.mobile;
            [[Zhuge sharedInstance] track:@"用户登录" properties:user];
            
            HomeViewController * HVC = [[HomeViewController alloc] init];
            if (self.selectType == 2 )
            {
                [HVC setSelectedTab:TabSelectedSecond];
            }
            else if (self.selectType == 3)
            {
                [HVC setSelectedTab:TabSelectedThird];
            }
            else if (self.selectType == 4)
            {
                [HVC setSelectedTab:TabSelectedFourth];
            }
            else if (self.selectType == 5 )
            {
                [HVC setSelectedTab:TabSelectedFifth];
            }
            else
            {
                [HVC setSelectedTab:TabSelectedFirst];
            }
            [HVC showTabbar];
            [self presentViewController:HVC animated:NO completion:nil];
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [super requestFailed:request];
    [[UserInfoCoreDataStorage sharedInstance] saveSettingInfoWithKey:kTagRequestAccessToken value:nil];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([phone isFirstResponder])
    {
        [basicScrollView scrollRectToVisible:CGRectMake(0, phone.frame.origin.y+100, screenWidth, screenHeight) animated:YES];
    }
    if ([password isFirstResponder])
    {
        [basicScrollView scrollRectToVisible:CGRectMake(0, password.frame.origin.y+100, screenWidth, screenHeight) animated:YES];
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    UIButton * btn = (UIButton*)[self.view viewWithTag:100];
    
    if (textField == phone)
    {
        if (string.length > 0 && ![string isEqualToString:@""])
        {
            isFirst = YES;
        }
        else
        {
            if (phone.text.length > 1)
            {
                isFirst = YES;
            }
            else
            {
                isFirst = NO;
            }
        }
        if (password.text.length > 0)
        {
            isSecond = YES;
        }
        else
        {
            isSecond = NO;
        }
    }
    
    if (textField == password)
    {
        if (phone.text.length > 0)
        {
            isFirst = YES;
        }
        else
        {
            isFirst = NO;
        }
        
        if (string.length > 0 && ![string isEqualToString:@""])
        {
            isSecond = YES;
        }
        else
        {
            if (password.text.length > 1)
            {
                isSecond = YES;
            }
            else
            {
                isSecond = NO;
            }
        }
    }
    
    if (isFirst && isSecond)
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
        [btn setTintColor:KFontNewColorB];
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    UIButton * btn = (UIButton*)[self.view viewWithTag:100];
    btn.enabled = NO;
    [btn setBackgroundColor:KColorHeader];
    [btn setTintColor:KFontNewColorB];
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    isBack = NO;
    
    NSString * touchObject = NSStringFromClass([touch.view class]);
    
    if ([touchObject isEqualToString:@"UIButton"] && touch.view.tag == TAGBUTTON)
    {
        [[CHNAlertView defaultAlertView] dismiss];
        isBack = YES;
        return YES;
    }
    else if ([touchObject isEqualToString:@"UIButton"] && touch.view.tag == KTagForgetBtn)
    {
        [[CHNAlertView defaultAlertView] dismiss];
        isBack = YES;
        return YES;
    }
    else if ([touchObject isEqualToString:@"UIButton"] && touch.view.tag == 100)
    {
        return YES;
    }
    else if ([touchObject isEqualToString:@"UIButton"] && touch.view.tag != 100)
    {
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField == phone)
    {
        if (phone.text.length == 0 || phone.text.length == 11 )
        {
            
        }
        else
        {
            if (!isBack)
            {
                [[CHNAlertView defaultAlertView] showContent:@"请输入有效的手机号" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
            }
        }
    }
    else if (textField == password)
    {
        if (password.text.length == 0 || (password.text.length > 5 && password.text.length <17))
        {
            
        }
        else
        {
            if (!isBack )
            {
                [[CHNAlertView defaultAlertView] showContent:@"请输入6-16位密码" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
            }
        }
    }
    return YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
}

// 点击返回处理
- (void)back
{
    if (self.flag == 1)
    {
        HomeViewController * HVC = [[HomeViewController alloc] init];
        [HVC setSelectedTab:TabSelectedFirst];
        [HVC showTabbar];
        [self presentViewController:HVC animated:NO completion:nil];
    }
    else
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end