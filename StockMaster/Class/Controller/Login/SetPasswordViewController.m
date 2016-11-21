//
//  SetPasswordViewController.m
//  StockMaster
//
//  Created by Rebloom on 14-8-1.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "SetPasswordViewController.h"
#import "MoreViewController.h"
#import "NSString+UIColor.h"
#import "UIImage+UIColor.h"
#import "HomeViewController.h"
#import "LoginViewController.h"
#import "SecondLoginViewController.h"

#define KTAGCLOSEBTN  300
#define KTAGSURE    400

@interface SetPasswordViewController ()

@end

@implementation SetPasswordViewController

@synthesize passPhone;
@synthesize flag;
@synthesize sms_code;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [firstPass becomeFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = KSelectNewColor;
    
    [headerView loadComponentsWithTitle:@"重置密码"];
    [headerView createLine];
    headerView.backgroundColor = kFontColorA;
    [headerView setStatusBarColor: kFontColorA];
    
    isFirst = NO;
    isSecond = NO;
    isBack = NO;
    
    UIButton * closeBtn = [[UIButton alloc] init];
    closeBtn.tag = KTAGCLOSEBTN;
    closeBtn.frame = CGRectMake(5, 20, 60, 44);
    closeBtn.backgroundColor = [UIColor clearColor];
    closeBtn.titleLabel.font = NormalFontWithSize(15);
    [closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [closeBtn setTitleColor:KFontNewColorA forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:closeBtn];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tap.delegate = self;
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    [self createUI];
}

// 初始化页面布局
-(void)createUI
{
    UIView * view = [[UIView alloc] init];
    view.frame = CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, 120);
    view.backgroundColor = kFontColorA;
    view.userInteractionEnabled = YES;
    [self.view addSubview:view];
    
    firstPass = [[GFTextField alloc] initWithFrame:CGRectMake(0, 0, screenWidth-15, 60)];
    firstPass.placeHolderColor = 1;
    firstPass.clearButtonMode = UITextFieldViewModeWhileEditing;
    firstPass.delegate = self;
    firstPass.backgroundColor = kFontColorA;
    firstPass.font = NormalFontWithSize(15);
    firstPass.textColor = kTitleColorA;
    firstPass.placeholder = @"请输入6-16密码";
    firstPass.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    firstPass.secureTextEntry = YES;
    [view addSubview:firstPass];
    
    secondPass = [[GFTextField alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(firstPass.frame)+1, screenWidth-15, 60)];
    secondPass.placeHolderColor = 1;
    secondPass.delegate = self;
    secondPass.backgroundColor = kFontColorA;
    secondPass.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    secondPass.clearButtonMode = UITextFieldViewModeWhileEditing;
    secondPass.font = NormalFontWithSize(15);
    secondPass.textColor = kTitleColorA;
    secondPass.placeholder = @"再次输入密码";
    secondPass.secureTextEntry = YES;
    [view addSubview:secondPass];
    
    for (int i = 0; i<2; i++) {
        UIImageView * imgView = [[UIImageView alloc]init];
        if (i == 0)
        {
            imgView.frame = CGRectMake(0, 59.5, screenWidth, 0.5);
        }
        else if (i == 1)
        {
            imgView.frame = CGRectMake(0, 119.5, screenWidth, 1);
        }
        imgView.image = [UIImage imageNamed:@"shadow_first"];
        [view addSubview:imgView];
    }
    
    UIButton * finishBtn = [[UIButton alloc] init];
    finishBtn.userInteractionEnabled = YES;
    finishBtn.enabled = NO;
    finishBtn.tag = KTAGSURE;
    finishBtn.layer.cornerRadius = 5;
    finishBtn.layer.masksToBounds = YES;
    finishBtn.frame = CGRectMake(20, CGRectGetMaxY(view.frame)+20, screenWidth-40, 44);
    finishBtn.titleLabel.font = NormalFontWithSize(15);
    [finishBtn setTitleColor:kFontColorA forState:UIControlStateNormal];
    [finishBtn setBackgroundColor:KColorHeader];
    [finishBtn setTitle:@"确定" forState:UIControlStateNormal];
    [finishBtn addTarget:self action:@selector(doneBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:finishBtn];
    
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

// 页面监听，点击页面输入框失去焦点
- (void)viewTapped:(id)sender
{
    if ([firstPass isFirstResponder])
    {
        [firstPass resignFirstResponder];
    }
    if ([secondPass isFirstResponder])
    {
        [secondPass resignFirstResponder];
    }
}

// 点击关闭按钮
- (void)closeOnClick:(UIButton*)sender
{
    [[CHNAlertView defaultAlertView] showContent:@"放弃重置密码" cancelTitle:@"放弃" sureTitle:@"不放弃" withDelegate:self withType:4];
    alertViewTag = 1;
}

// 弹窗提示的代理方法
-(void)buttonClickedAtIndex:(NSInteger)index
{
    if (alertViewTag == 1)
    {
        if (index == 0)
        {
            NSInteger count = self.navigationController.viewControllers.count;
            for (NSInteger i = count; i > 0; i--)
            {
                BasicViewController * bvc = self.navigationController.viewControllers[i-1];
                if ([bvc isKindOfClass:[SecondLoginViewController class]] ||
                    [bvc isKindOfClass:[MoreViewController class]] ||
                    [bvc isKindOfClass:[LoginViewController class]])
                {
                    // 已知可以从上面这些页面进入，返回到相应的上层页面
                    [self.navigationController popToViewController:bvc animated:YES];
                    return;
                }
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if (index == 1)
        {
            [firstPass becomeFirstResponder];
        }
    }
    else if(alertViewTag == 2)
    {
        [firstPass becomeFirstResponder];
    }
    else if (alertViewTag == 3)
    {
        [secondPass becomeFirstResponder];
    }
    else if (alertViewTag == 5)
    {
        [self backLastView];
    }
    
    return;
}

//返回发送验证码页面
- (void)backLastView
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:self.passPhone forKey:@"mobile"];
    [GFRequestManager connectWithDelegate:self action:Get_retrieve_password_sms_code param:paramDic];
}

// 点击完成按钮
- (void)doneBtnClicked:(id)sender
{
    if ([firstPass.text isEqualToString:secondPass.text])
    {
        NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
        [paramDic setObject:self.passPhone forKey:@"mobile"];
        [paramDic setObject:[Utility md5:firstPass.text] forKey:@"password"];
        [paramDic setObject:@"2" forKey:@"enc"];
        [GFRequestManager connectWithDelegate:self action:Submit_new_password param:paramDic];
    }
    else
    {
        [[CHNAlertView  defaultAlertView] showContent:@"两次密码不一致" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
        alertViewTag = 2;
    }
}

// 请求成功
- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    
    if ([[[requestInfo objectForKey:@"err_code"] description] isEqualToString:@"10035"])
    {
        [[CHNAlertView defaultAlertView] showContent:@"验证码已经过期，请重新获取" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
        alertViewTag = 5;
    }
    else
    {
        ASIFormDataRequest * formdataRequest = (ASIFormDataRequest *)request;
        if ([formdataRequest.action isEqualToString:Get_retrieve_password_sms_code])
        {
            if (self.navigationController && self.navigationController.viewControllers.count>1)
            {
                [self.navigationController popViewControllerAnimated:NO];
            }
        }
        else if ([formdataRequest.action isEqualToString:Submit_new_password])
        {
            NSDictionary *userInfo = [requestInfo objectForKey:@"data"];
            [[UserInfoCoreDataStorage sharedInstance] saveLoginUserInfo:userInfo];

            [[TKAlertCenter defaultCenter] postAlertWithMessage:@"修改成功" withType:ALERTTYPESUCCESS];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField == firstPass)
    {
        if (firstPass.text.length < 6 || firstPass.text.length > 16)
        {
            if (!isBack)
            {
                if (firstPass.text.length != 0)
                {
                    [firstPass resignFirstResponder];
                    [[CHNAlertView defaultAlertView] showContent:@"请输入6-16位密码" cancelTitle:nil sureTitle:nil withDelegate:self withType:6];
                    alertViewTag = 2;
                }
            }
            else
            {
                
            }
        }
    }
    if (textField == secondPass)
    {
        if (secondPass.text.length < 6 || secondPass.text.length > 16)
        {
            if (!isBack)
            {
                if (firstPass.text.length != 0)
                {
                    [secondPass resignFirstResponder];
                    [[CHNAlertView defaultAlertView] showContent:@"请输入6-16位密码" cancelTitle:nil sureTitle:nil withDelegate:self withType:6];
                    alertViewTag = 3;
                }
            }
            else
            {
                
            }
        }
    }
    
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    UIButton * btn = (UIButton*)[self.view viewWithTag:KTAGSURE];
    
    if (textField == firstPass)
    {
        if (string.length > 0 && ![string isEqualToString:@""])
        {
            isFirst = YES;
        }
        else if ([string isEqualToString:@""])
        {
            isFirst = NO;
        }
        else
        {
            if (firstPass.text.length > 1)
            {
                isFirst = YES;
            }
            else
            {
                isFirst = NO;
            }
        }
        
        if (secondPass.text.length > 0)
        {
            isSecond = YES;
        }
        else
        {
            isSecond = NO;
        }
    }
    
    if (textField == secondPass)
    {
        if (firstPass.text.length > 0)
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
        else if ([string isEqualToString:@""])
        {
            isSecond = NO;
        }
        else
        {
            if (secondPass.text.length > 1)
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
        [btn addTarget:self action:@selector(doneBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        btn.enabled = NO;
        [btn setBackgroundColor:KColorHeader];
        [btn setTintColor:kFontColorA];
    }
    
    return YES;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    isBack = NO;
    
    NSString * touchObject = NSStringFromClass([touch.view class]);
    
    if ([touchObject isEqualToString:@"UIButton"] && touch.view.tag != KTAGCLOSEBTN )
    {
        [[CHNAlertView defaultAlertView] dismiss];
        isBack = YES;
        return YES;
    }
    else if([touchObject isEqualToString:@"UIButton"] && touch.view.tag != KTAGSURE)
    {
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    UIButton * btn = (UIButton*)[self.view viewWithTag:KTAGSURE];
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
