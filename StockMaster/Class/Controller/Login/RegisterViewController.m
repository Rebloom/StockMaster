//
//  RegisterViewController.m
//  StockMaster
//
//  Created by Rebloom on 14-8-1.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "RegisterViewController.h"
#import "NSString+UIColor.h"
#import "UIImage+UIColor.h"
#import "LoginViewController.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController
@synthesize type;
@synthesize registPhone;
@synthesize bindString;

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
    
    if(phone)
    {
        [phone becomeFirstResponder];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self clearSubview];
    [super viewWillDisappear:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = KSelectNewColor;
    if (type == 1)
    {
        [headerView loadComponentsWithTitle:@"绑定手机号"];
    }
    else
    {
        [headerView loadComponentsWithTitle:@"注册(1/3)"];
    }
    [headerView backButton];
    [headerView createLine];
    headerView.backgroundColor = kFontColorA;
    [headerView setStatusBarColor: kFontColorA];
    
    canRequest = YES;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    [self createUI];
    
    // 诸葛统计（用户注册-注册按钮）
    [[Zhuge sharedInstance] track:@"用户注册-注册按钮" properties:nil];
}

// 初始化页面布局
- (void)createUI
{
    UIView * topView = [[UIView alloc] init];
    topView.frame = CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, 60);
    topView.backgroundColor = kFontColorA;
    topView.userInteractionEnabled =YES;
    [self.view addSubview:topView];
    
    phone = [[GFTextField alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, 60)];
    phone.placeHolderColor = 1;
    phone.backgroundColor = kFontColorA;
    phone.delegate = self;
    
    if (type == 1)
    {
        UILabel * bindLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(headerView.frame), screenWidth, 60)];
        bindLabel.backgroundColor = [UIColor clearColor];
        bindLabel.font = NormalFontWithSize(13);
        bindLabel.textColor = KFontNewColorB;
        bindLabel.text = bindString;
        [self.view addSubview:bindLabel];
        
        topView.frame = CGRectMake(0, CGRectGetMaxY(bindLabel.frame), screenWidth, 60);
        phone.frame = CGRectMake(0, CGRectGetMaxY(bindLabel.frame), screenWidth, 60);
    }
    
    if (self.registPhone)
    {
        phone.text = self.registPhone;
    }
    else
    {
        phone.placeholder = @"手机号码";
    }
    phone.font = NormalFontWithSize(15);
    phone.textColor = kTitleColorA;
    phone.clearButtonMode = UITextFieldViewModeWhileEditing;
    phone.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:phone];
    
    nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(phone.frame)+20, screenWidth-40, 44)];
    nextBtn.tintColor = kFontColorA;
    nextBtn.tag = 100;
    nextBtn.layer.cornerRadius = 5;
    nextBtn.layer.masksToBounds = YES;
    nextBtn.titleLabel.font = NormalFontWithSize(16);
    [nextBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
    
    NSInteger i = phone.text.length;
    if (i >10)
    {
        nextBtn.enabled = YES;
        [nextBtn setBackgroundColor:kRedColor];
        [nextBtn setTitleColor:kFontColorA forState:UIControlStateNormal];
        [nextBtn setBackgroundImage:KBtnSelectNewColorA.image forState:UIControlStateHighlighted];
        [nextBtn setBackgroundImage:KBtnSelectNewColorA.image forState:UIControlStateSelected];
    }
    else
    {
        nextBtn.enabled = NO;
        [nextBtn setBackgroundColor:KColorHeader];
        [nextBtn setTintColor:kFontColorA];
    }
    [nextBtn addTarget:self action:@selector(nextBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextBtn];
    
    
    UIButton * clickBtn = [[UIButton alloc] init];
    clickBtn.frame = CGRectMake(20, CGRectGetMaxY(nextBtn.frame)+17, screenWidth-40, 30);
    clickBtn.backgroundColor = [UIColor clearColor];
    [clickBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clickBtn];
    
    UILabel * tipLabel = [[UILabel alloc] init];
    tipLabel.font = NormalFontWithSize(13);
    tipLabel.frame = CGRectMake(0, 0, CGRectGetWidth(clickBtn.frame), CGRectGetHeight(clickBtn.frame));
    tipLabel.numberOfLines = 0;
    if (screenWidth <=screenWidth)
    {
        tipLabel.textAlignment = NSTextAlignmentLeft;
    }
    else
    {
        tipLabel.textAlignment = NSTextAlignmentCenter;
    }
    NSString * str1 = @"点击按钮，即表示你同意";
    NSString * str2 = @"《涨涨科技许可及服务协议》";
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",str1,str2]];
    
    [str addAttribute:NSForegroundColorAttributeName value:KFontNewColorB range:NSMakeRange(0,str1.length)];
    [str addAttribute:NSForegroundColorAttributeName value:KFontNewColorD range:NSMakeRange(str1.length,str2.length)];
    
    [str addAttribute:NSFontAttributeName value:NormalFontWithSize(13) range:NSMakeRange(0,str1.length)];
    [str addAttribute:NSFontAttributeName value:NormalFontWithSize(13) range:NSMakeRange(str1.length,str2.length)];
    
    tipLabel.attributedText = str;
    [clickBtn addSubview:tipLabel];
}

// 点击注册协议
- (void)clickBtn:(UIButton * )sender
{
    GFWebViewController * GWVC = [[GFWebViewController alloc] init];
    GWVC.title = @"涨涨注册协议";
    GWVC.pageType = WebViewTypePresent;
    GWVC.flag = 0;
    GWVC.requestUrl = [NSURL URLWithString:UserAgreementUrl];
    [self  presentViewController:GWVC animated:YES completion:nil];
}

// 点击下一步
- (void)nextBtnClicked:(id)sender
{
    if (phone.text.length)
    {
        if (phone.text.length == 11)
        {
            NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
            [paramDic setObject:phone.text forKey:@"mobile"];
            [GFRequestManager connectWithDelegate:self action:Get_user_register_sms_code param:paramDic];
            feetView.frame = CGRectMake(0, screenHeight - 202, screenWidth, 202);
        }
        else
        {
            [[CHNAlertView defaultAlertView] showContent:@"请输入有效的手机号" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
        }
    }
    else
    {
        [[CHNAlertView defaultAlertView] showContent:@"请输入有效的手机号" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
    }
}

// 请求成功
- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    canRequest = YES;
    
    if ([[requestInfo objectForKey:@"err_code"] integerValue] == 10055)
    {
        [self createActionSheet];
    }
    else
    {
        ASIFormDataRequest * formdataRequest = (ASIFormDataRequest *)request;
        if ([formdataRequest.action isEqualToString:Get_user_register_sms_code])
        {
            CheckCodeViewController * CCVC = [[CheckCodeViewController alloc] init];
            CCVC.passPhone = phone.text;
            [GFStaticData saveObject:[phone.text copy] forKey:kTagCheckMobile];
            CCVC.flag = 1;
            CCVC.type = self.type;
            [self pushToViewController:CCVC];
        }
    }
}

// 请求失败
- (void)requestFailed:(ASIHTTPRequest *)request
{
    [super requestFailed:request];
    canRequest = YES;
}

// 错误弹窗点击按钮的代理方法
- (void)buttonClickedAtIndex:(NSInteger)index
{
    if (index == 0)
    {
        [phone becomeFirstResponder];
    }
    else if (index == 1)
    {
        ForgetPasswordViewController * fpvc = [[ForgetPasswordViewController alloc] init];
        fpvc.type = 2;
        [self pushToViewController:fpvc];
    }
    
    return;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == phone)
    {
        if (string.length > 0 && ![string isEqualToString:@""])
        {
            nextBtn.enabled = YES;
            [nextBtn setBackgroundColor:kRedColor];
            [nextBtn setTitleColor:kFontColorA forState:UIControlStateNormal];
            [nextBtn setBackgroundImage:KBtnSelectNewColorA.image forState:UIControlStateHighlighted];
            [nextBtn setBackgroundImage:KBtnSelectNewColorA.image forState:UIControlStateSelected];
            [nextBtn addTarget:self action:@selector(nextBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            if (phone.text.length > 1)
            {
                nextBtn.enabled = YES;
                [nextBtn setBackgroundColor:kRedColor];
                [nextBtn setTitleColor:kFontColorA forState:UIControlStateNormal];
                [nextBtn setBackgroundImage:KBtnSelectNewColorA.image forState:UIControlStateHighlighted];
                [nextBtn setBackgroundImage:KBtnSelectNewColorA.image forState:UIControlStateSelected];
                [nextBtn addTarget:self action:@selector(nextBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            }
            else
            {
                nextBtn.enabled = NO;
                [nextBtn setBackgroundColor:KColorHeader];
                [nextBtn setTintColor:kFontColorA];
            }
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    nextBtn.enabled = NO;
    [nextBtn setBackgroundColor:KColorHeader];
    [nextBtn setTintColor:kFontColorA];
    
    return YES;
}

// 初始化自定义actionSheet
- (void)createActionSheet
{
    if(!mainView)
    {
        mainView = [[UIView alloc] init];
    }
    mainView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    mainView.hidden = NO;
    mainView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:mainView];
    
    
    UIView * topView = [[UIView alloc] init];
    topView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    topView.alpha = 0.5;
    topView.backgroundColor = @"#000000".color;
    [mainView addSubview:topView];
    
    UIButton * hideBtn = [[UIButton alloc] init];
    hideBtn.frame = topView.frame;
    hideBtn.backgroundColor = [UIColor clearColor];
    [hideBtn addTarget:self action:@selector(cancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside
     ];
    [mainView addSubview:hideBtn];
    
    if (!feetView)
    {
        feetView = [[UIImageView alloc] init];
    }
    feetView.backgroundColor = [UIColor whiteColor];
    feetView.userInteractionEnabled = YES;
    feetView.hidden = NO;
    feetView.frame = CGRectMake(0, screenHeight - 202, screenWidth, 202);
    [self.view addSubview:feetView];
    [self.view bringSubviewToFront:feetView];
    
    UILabel * tipLabel = [[UILabel alloc] init];
    tipLabel.frame = CGRectMake( 20, 20, 200, 16);
    tipLabel.font = NormalFontWithSize(13);
    tipLabel.text = @"该手机已经注册过";
    tipLabel.textAlignment = NSTextAlignmentLeft;
    tipLabel.textColor = KFontNewColorA;
    tipLabel.backgroundColor = [UIColor clearColor];
    [feetView addSubview:tipLabel];
    
    UIButton * loginBtn = [[UIButton alloc] init];
    loginBtn.frame = CGRectMake(20, CGRectGetMaxY(tipLabel.frame )+20, screenWidth-40, 44);
    loginBtn.tag = 1002;
    loginBtn.tintColor = kFontColorA;
    loginBtn.layer.cornerRadius = 5;
    loginBtn.layer.masksToBounds = YES;
    loginBtn.titleLabel.font = NormalFontWithSize(16);
    [loginBtn setTitle:@"直接登录" forState:UIControlStateNormal];
    [loginBtn setBackgroundImage:[KFontNewColorD image] forState:UIControlStateNormal];
    [loginBtn setBackgroundImage:[KBtnSelectNewColorA image ] forState:UIControlStateSelected];
    [loginBtn setBackgroundImage:[KBtnSelectNewColorA image] forState:UIControlStateHighlighted];
    [loginBtn addTarget:self action:@selector(loginBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [feetView addSubview:loginBtn];
    
    UIButton * cancelBtn = [[UIButton alloc] init];
    cancelBtn.frame = CGRectMake(20, CGRectGetMaxY(loginBtn.frame)+20, screenWidth-40, 44);
    cancelBtn.layer.cornerRadius = 5;
    cancelBtn.layer.masksToBounds = YES;
    cancelBtn.titleLabel.font = NormalFontWithSize(16);
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setBackgroundImage:[KSelectNewColor1 image] forState:UIControlStateNormal];
    [cancelBtn setBackgroundImage:[KSelectNewColor2 image ] forState:UIControlStateSelected];
    [cancelBtn setBackgroundImage:[KSelectNewColor2 image] forState:UIControlStateHighlighted];
    [cancelBtn addTarget:self action:@selector(cancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn  setTitleColor:KFontNewColorA forState:UIControlStateNormal];
    [feetView addSubview:cancelBtn];
    
    CATransition *animation = [CATransition animation];
    
    [animation setDuration:0.5];
    
    [animation setType: kCATransitionMoveIn];
    
    [animation setSubtype: kCATransitionFromTop];
    
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    
    [feetView.layer addAnimation:animation forKey:nil];
}

// 点击取消按钮
- (void)cancelBtnClicked:(UIButton*)sender
{
    [UIView beginAnimations:@"Animation" context:nil];
    [UIView setAnimationDuration:0.4];
    feetView.frame = CGRectMake(0, screenHeight, screenWidth, 202);
    [UIView commitAnimations];
    [self performSelector:@selector(handleTimer) withObject:self afterDelay:0.4];
}

-(void)handleTimer
{
    mainView.hidden = YES;
    feetView.hidden = YES;
    feetView.frame = CGRectMake(0, screenHeight - 202, screenWidth, 202);
    [self clearSubview];
}

// 清除视图块子视图
-(void)clearSubview
{
    if (mainView)
    {
        for (UIView * view in mainView.subviews)
        {
            [view removeFromSuperview];
        }
    }
    if (feetView)
    {
        for (UIView * view in feetView.subviews)
        {
            feetView.backgroundColor = [UIColor clearColor];
            [view removeFromSuperview];
        }
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([phone isFirstResponder])
    {
        mainView.hidden =YES;
    }
    return YES;
}

// 点击登录按钮
- (void)loginBtnClicked:(UIButton*)sender
{
    LoginViewController * LVC = [[LoginViewController alloc] init];
    mainView.hidden = YES;
    LVC.loginPhone = [phone.text copy];
    [self pushToViewController:LVC];
}

- (void)viewTapped:(id)sender
{
    if ([phone isFirstResponder])
    {
        [phone resignFirstResponder];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
