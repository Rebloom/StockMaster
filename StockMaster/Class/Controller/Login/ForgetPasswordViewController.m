//
//  ForgetPasswordViewController.m
//  StockMaster
//
//  Created by dalikeji on 14-8-29.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "RegisterViewController.h"
#import "ForgetPasswordViewController.h"
#import "NSString+UIColor.h"
#import "UIImage+UIColor.h"
#import "TKAlertCenter.h"

@interface ForgetPasswordViewController ()

@end

@implementation ForgetPasswordViewController

@synthesize type;
@synthesize phoneNum;

- (void)dealloc
{
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (!self)
    {
        self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    if (phone)
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
    
    [headerView backButton];
    [headerView createLine];
    // 根据不同type设置标题
    if (type == 1)
    {
        [headerView loadComponentsWithTitle:@"修改密码"];
    }
    else if (type == 2)
    {
        [headerView loadComponentsWithTitle:@"找回密码(1/2)"];
    }
    headerView.backgroundColor = kFontColorA;
    [headerView setStatusBarColor: kFontColorA];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    [self createUI];
}

// 初始化界面
- (void)createUI
{
    UIView * whiteView = [[UIView alloc] init];
    whiteView.backgroundColor = kFontColorA;
    whiteView.frame = CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, 60);
    [self.view addSubview:whiteView];
    
    phone = [[GFTextField alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth-15, 60)];
    phone.placeHolderColor = 1;
    phone.delegate = self;
    phone.backgroundColor = kFontColorA;
    phone.placeholder = @"请输入您的手机号";
    phone.font = NormalFontWithSize(15);
    phone.clearButtonMode = UITextFieldViewModeWhileEditing;
    phone.textColor = KFontNewColorA;
    if (self.phoneNum)
    {
        phone.text = self.phoneNum;
    }
    phone.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:phone];
    [phone becomeFirstResponder];
    
    UIImageView * iv = [[UIImageView alloc] init];
    iv.frame = CGRectMake(0, CGRectGetMaxY(phone.frame), screenWidth, 1);
    iv.image = [UIImage imageNamed:@"shadow_first"];
    [self.view addSubview:iv];
    
    
    UIButton * nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(phone.frame)+20, screenWidth-40, 44)];
    nextBtn.userInteractionEnabled = YES;
    nextBtn.enabled = NO;
    nextBtn.tag = 100;
    nextBtn.layer.cornerRadius = 5;
    nextBtn.layer.masksToBounds = YES;
    nextBtn.titleLabel.font = NormalFontWithSize(15);
    [nextBtn setTitleColor:kFontColorA forState:UIControlStateNormal];
    [nextBtn setBackgroundColor:KColorHeader];
    [nextBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(nextBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextBtn];
    
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

// 点击下一步
- (void)nextBtnClicked:(UIButton *)sendeer
{
    if (phone.text.length)
    {
        if (phone.text.length == 11)
        {
            NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
            [paramDic setObject:phone.text forKey:@"mobile"];
            [GFRequestManager connectWithDelegate:self action:Get_retrieve_password_sms_code param:paramDic];
        }
        else
        {
            [[CHNAlertView defaultAlertView] showContent:@"请输入有效的手机号码" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
        }
    }
    else
    {
        [[CHNAlertView defaultAlertView] showContent:@"请输入有效的手机号码" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
    }
}

// 弹窗点击代理方法
- (void)buttonClickedAtIndex:(NSInteger)index
{
    [phone becomeFirstResponder];
}

// 请求成功
- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    
    if ([[requestInfo objectForKey:@"err_code"] integerValue] == 10056)
    {
        [self createActionSheet];
    }
    else
    {
        ASIFormDataRequest * formDataRequest = (ASIFormDataRequest *)request;
        if([formDataRequest.action isEqualToString:Get_retrieve_password_sms_code])
        {
            [GFStaticData saveObject:phone.text forKey:kTagCheckMobile];
            if ([[requestInfo objectForKey:@"message"] isEqualToString:@"Success"]) {
                CheckCodeViewController * CCVC = [[CheckCodeViewController alloc] init];
                CCVC.passPhone = [phone.text copy];
                if (type == 1)
                {
                    CCVC.flag = 2;
                }
                else if (type == 2 || type == 3)
                {
                    CCVC.flag = 3;
                }
                [self pushToViewController:CCVC];
            }
        }
    }
}

// 初始化自定义actionSheet
- (void)createActionSheet
{
    if (!mainView)
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
    feetView.hidden = NO;
    feetView.userInteractionEnabled = YES;
    feetView.frame = CGRectMake(0, screenHeight - 202, screenWidth, 202);
    [self.view addSubview:feetView];
    [self.view bringSubviewToFront:feetView];
    
    
    UILabel * tipLabel = [[UILabel alloc] init];
    tipLabel.frame = CGRectMake( 20, 20, 200, 16);
    tipLabel.font = NormalFontWithSize(13);
    tipLabel.text = @"该手机尚未注册过";
    tipLabel.textAlignment = NSTextAlignmentLeft;
    tipLabel.textColor = KFontNewColorA;
    tipLabel.backgroundColor = [UIColor clearColor];
    [feetView addSubview:tipLabel];
    
    UIButton * registerBtn = [[UIButton alloc] init];
    registerBtn.frame = CGRectMake(20, CGRectGetMaxY(tipLabel.frame )+20, screenWidth-40, 44);
    registerBtn.tag = 1002;
    registerBtn.tintColor = kFontColorA;
    registerBtn.layer.cornerRadius = 5;
    registerBtn.layer.masksToBounds = YES;
    registerBtn.titleLabel.font = NormalFontWithSize(16);
    [registerBtn setTitle:@"直接注册" forState:UIControlStateNormal];
    [registerBtn setBackgroundImage:[KFontNewColorD image] forState:UIControlStateNormal];
    [registerBtn setBackgroundImage:[KBtnSelectNewColorA image ] forState:UIControlStateSelected];
    [registerBtn setBackgroundImage:[KBtnSelectNewColorA image] forState:UIControlStateHighlighted];
    [registerBtn addTarget:self action:@selector(registerBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [feetView addSubview:registerBtn];
    
    UIButton * cancelBtn = [[UIButton alloc] init];
    cancelBtn.frame = CGRectMake(20, CGRectGetMaxY(registerBtn.frame)+20, screenWidth-40, 44);
    cancelBtn.layer.cornerRadius = 5;
    cancelBtn.layer.masksToBounds = YES;
    cancelBtn.titleLabel.font = NormalFontWithSize(16);
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:KFontNewColorA forState:UIControlStateNormal];
    [cancelBtn setBackgroundImage:[KSelectNewColor1 image] forState:UIControlStateNormal];
    [cancelBtn setBackgroundImage:[KSelectNewColor2 image ] forState:UIControlStateSelected];
    [cancelBtn setBackgroundImage:[KSelectNewColor2 image] forState:UIControlStateHighlighted];
    [cancelBtn addTarget:self action:@selector(cancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
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

- (void)handleTimer
{
    mainView.hidden = YES;
    feetView.hidden = YES;
    [phone becomeFirstResponder];
    
    feetView.frame = CGRectMake(0, screenHeight - 202, screenWidth, 202);
    [self clearSubview];
}

// 清除视图块子视图
- (void)clearSubview
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

// 点击注册按钮
- (void)registerBtnClicked:(UIButton*)sender
{
    RegisterViewController * LVC = [[RegisterViewController alloc] init];
    mainView.hidden = YES;
    LVC.registPhone = [phone.text copy];
    [self pushToViewController:LVC];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([phone isFirstResponder])
    {
        mainView.hidden =YES;
    }
    
    UIButton * btn = (UIButton*)[self.view viewWithTag:100];
    if (![phone.text isEqualToString:@""] )
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
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    UIButton * btn = (UIButton*)[self.view viewWithTag:100];
    
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

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    UIButton * btn = (UIButton*)[self.view viewWithTag:1024];
    btn.enabled = NO;
    [btn setBackgroundColor:KColorHeader];
    [btn setTintColor:KFontNewColorB];
    
    return YES;
}

// 点击界面，输入失去焦点
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
