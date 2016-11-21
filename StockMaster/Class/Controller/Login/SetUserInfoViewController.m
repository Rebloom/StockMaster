//
//  SetUserInfoViewController.m
//  StockMaster
//
//  Created by dalikeji on 14/12/2.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "SetUserInfoViewController.h"
#import "FirstViewController.h"
#import "HomeViewController.h"
#import "SecondLoginViewController.h"

#define NAMETF    1030
#define PASSWORD  1040
#define REPASSWORD  1050

@interface SetUserInfoViewController ()

@end

@implementation SetUserInfoViewController

@synthesize code;
@synthesize phone;

- (void)dealloc
{
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [passTf becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated

{
    [super viewWillDisappear:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = KSelectNewColor;
    [headerView loadComponentsWithTitle:@"注册(3/3)"];
    [headerView createLine];
    headerView.backgroundColor = kFontColorA;
    [headerView setStatusBarColor: kFontColorA];
    isFirst = NO;
    isSecond = NO;
    isThird = NO;
    flag = 0;
    scrollView = [[UIScrollView alloc] init];
    scrollView.frame = CGRectMake(0, CGRectGetMaxY(headerView.frame) , screenWidth, screenHeight);
    scrollView.delegate = self;
    if (iPhone4s)
    {
        scrollView.contentSize = CGSizeMake(screenWidth, screenHeight+60);
    }
    scrollView. backgroundColor = KSelectNewColor;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    UIButton * closeBtn = [[UIButton alloc] init];
    closeBtn.frame = CGRectMake(0, 20, 60, 44);
    closeBtn.backgroundColor = [UIColor clearColor];
    closeBtn.titleLabel.font = NormalFontWithSize(15);
    closeBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [closeBtn setTitleColor:KFontNewColorA forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:closeBtn];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tap.delegate = self;
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    [self createUI];
    isRequestRegister = NO;
}

// 初始化页面布局
- (void)createUI
{
    UIView * view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0,screenWidth , 180);
    view.backgroundColor = kFontColorA;
    view.userInteractionEnabled = YES;
    [scrollView addSubview:view];
    for (int i =0 ; i<3; i++)
    {
        UIImageView * iv = [[UIImageView alloc] init];
        iv.image = [UIImage imageNamed:@"shadow_first"];
        if (i == 0)
        {
            iv.frame = CGRectMake(0, 59, screenWidth, 0.5);
        }
        else if (i == 1)
        {
            iv.frame = CGRectMake(0, 119, screenWidth, 0.5);
        }
        else if (i == 2)
        {
            iv.frame = CGRectMake(0, 178.8, screenWidth, 1);
        }
        [view addSubview:iv];
    }
    passTf = [[GFTextField alloc] initWithFrame:CGRectMake(0, 0, screenWidth-15, 60)];
    passTf.secureTextEntry = YES;
    passTf.placeHolderColor = 1;
    passTf.tag = PASSWORD;
    passTf.placeholder = @"设置密码";
    passTf.clearButtonMode = UITextFieldViewModeWhileEditing;
    passTf.delegate = self;
    passTf.textColor = KFontNewColorA;
    passTf.font = NormalFontWithSize(15);
    [view addSubview:passTf];
    rePassTf = [[GFTextField alloc] initWithFrame:CGRectMake(0, 60, screenWidth-15, 60)];
    rePassTf.secureTextEntry = YES;
    rePassTf.placeHolderColor = 1;
    rePassTf.tag = REPASSWORD;
    rePassTf.placeholder = @"确认密码";
    rePassTf.clearButtonMode = UITextFieldViewModeWhileEditing;
    rePassTf.delegate = self;
    rePassTf.textColor = KFontNewColorA;
    rePassTf.font = NormalFontWithSize(15);
    [view addSubview:rePassTf];
    [view bringSubviewToFront:rePassTf];
    nameTf = [[GFTextField alloc] initWithFrame:CGRectMake(0, 120, screenWidth-80, 60)];
    nameTf.delegate = self;
    nameTf.tag = NAMETF;
    nameTf.placeholder = @"设置用户名";
    nameTf.clearButtonMode = UITextFieldViewModeWhileEditing;
    nameTf.textColor = KFontNewColorA;
    nameTf.placeHolderColor = 1;
    nameTf.font = NormalFontWithSize(15);
    nameTf.keyboardType = UIKeyboardTypeDefault;
    [view addSubview:nameTf];
    
    UIButton * changeBtn = [[UIButton alloc] init];
    changeBtn.userInteractionEnabled = YES;
    changeBtn.frame = CGRectMake(screenWidth-70, 120, 60, 60);
    changeBtn.titleLabel.font = NormalFontWithSize(15);
    [changeBtn setTitleColor:KFontNewColorD forState:UIControlStateNormal];
    [changeBtn setTitle:@"随机" forState:UIControlStateNormal];
    [changeBtn setBackgroundColor:[UIColor clearColor]];
    [changeBtn addTarget:self action:@selector(randomBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:changeBtn];
    
    UIButton * startBtn = [[UIButton alloc] init];
    startBtn.userInteractionEnabled = YES;
    startBtn.enabled = NO;
    startBtn.tag = 100;
    [startBtn addTarget:self action:@selector(startBtnOnClick) forControlEvents:UIControlEventTouchUpInside];
    startBtn.layer.cornerRadius = 5;
    startBtn.layer.masksToBounds = YES;
    startBtn.frame = CGRectMake(20, CGRectGetMaxY(view.frame)+20, screenWidth-40, 44);
    startBtn.titleLabel.font = NormalFontWithSize(15);
    [startBtn setTitleColor:kFontColorA forState:UIControlStateNormal];
    [startBtn setBackgroundColor:KColorHeader];
    [startBtn setTitle:@"领取5000.00" forState:UIControlStateNormal];
    [scrollView addSubview:startBtn];
    
    UILabel * tipLabel = [[UILabel alloc] init];
    tipLabel.frame = CGRectMake(0,screenHeight -65 - 52 - 14, screenWidth, 14);
    tipLabel.text = @"免费炒股,大赚真钱";
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.font = NormalFontWithSize(14);
    tipLabel.textColor = KFontNewColorC;
    tipLabel.backgroundColor = [UIColor clearColor];
    [scrollView  addSubview:tipLabel];
    UIImageView * imageView = [[UIImageView alloc] init];
    imageView . frame = CGRectMake(screenWidth/2-15, CGRectGetMinY(tipLabel.frame) - 10 - 23, 30, 23);
    imageView.image = [UIImage imageNamed:@"zhangzhang"];
    [scrollView addSubview:imageView];
}

//生成随机昵称
- (void)randomBtnOnClick:(UIButton*)sender
{
    nameTf.text = @"";
    [nameTf resignFirstResponder];
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [GFRequestManager connectWithDelegate:self action:Get_rand_nickname param:paramDic];
}

// 设置密码，生成新用户的请求
- (void)requestResign
{
    if (!isRequestRegister)
    {
        isRequestRegister = YES;
        NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
        [paramDic setObject:self.phone forKey:@"mobile"];
        [paramDic setObject:[Utility md5:passTf.text] forKey:@"password"];
        [paramDic setObject:nameTf.text forKey:@"nickname"];
        [paramDic setObject:self.code forKey:@"sms_code"];
        [paramDic setObject:@"2" forKey:@"enc"];
        [GFRequestManager connectWithDelegate:self action:Submit_user_register param:paramDic];
    }
}

//返回发送验证码页面
- (void)backLastView
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:self.phone forKey:@"mobile"];
    [GFRequestManager connectWithDelegate:self action:Get_user_register_sms_code param:paramDic];
}

// 请求成功
- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    
    
    if ([[[requestInfo objectForKey:@"err_code"] description] isEqualToString:@"10035"])
    {
        
        [[CHNAlertView defaultAlertView] showContent:@"验证码已经过期，请重新获取" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
        flag = 2;
    }
    else if ([[[requestInfo objectForKey:@"err_code"] description] isEqualToString:@"10058"])
    {
        isRequestRegister = NO;
    }
    else
    {
        ASIFormDataRequest * formdataRequest = (ASIFormDataRequest *)request;
        if ([formdataRequest.action isEqualToString:Get_user_register_sms_code])
        {
            if (self.navigationController && self.navigationController.viewControllers.count>1)
            {
                [self.navigationController popViewControllerAnimated:NO];
            }
        }
        else if ([formdataRequest.action isEqualToString:Submit_user_register])
        {
            isRequestRegister = NO;
            if ([[[requestInfo objectForKey:@"err_code"]description] isEqualToString:@"0"])
            {
                NSMutableDictionary *userDict = [[requestInfo objectForKey:@"data"] mutableCopy];
                userDict[@"nickname"] = nameTf.text;
                userDict[@"mobile"] = self.phone;
                userDict[@"head"] = @"";
                userDict[@"signature"] = @"";
                [[UserInfoCoreDataStorage sharedInstance] saveLoginUserInfo:userDict];
                UserInfoEntity *userInfo = [[UserInfoCoreDataStorage sharedInstance] getCurrentUserInfo];
                [[UserInfoCoreDataStorage sharedInstance] saveSettingInfoWithKey:kTagIsWeiXinLogin value:nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kTagLoginFinishedNoti object:nil];

                HomeViewController * HVC = [[HomeViewController alloc] init];
                [HVC setSelectedTab:TabSelectedFirst];
                [HVC showTabbar];
                [self presentViewController:HVC animated:NO completion:nil];
                // 诸葛统计（用户注册-注册完成）
                NSMutableDictionary *user = [NSMutableDictionary dictionary];
                user[@"用户id"] = userInfo.uid;
                user[@"用户名"] = userInfo.nickname;
                user[@"手机"] = userInfo.mobile;
                [[Zhuge sharedInstance] track:@"用户注册-注册完成" properties:user];
            }
        }
        else if ([formdataRequest.action isEqualToString:Get_rand_nickname])
        {
            [nameTf resignFirstResponder];
            nameTf.text = [[requestInfo objectForKey:@"data"] objectForKey:@"nickname"];
            if (nameTf.text.length > 0)
            {
                isFirst = YES;
            }
            else
            {
                isFirst = NO;
            }
            UIButton * btn = (UIButton*)[self.view viewWithTag:100];
            if (isFirst && isSecond && isThird)
            {
                btn.enabled = YES;
                [btn setBackgroundColor:kRedColor];
                [btn setTitleColor:kFontColorA forState:UIControlStateNormal];
                [btn setBackgroundImage:KBtnSelectNewColorA.image forState:UIControlStateHighlighted];
                [btn setBackgroundImage:KBtnSelectNewColorA.image forState:UIControlStateSelected];
            }
            else
            {
                btn.enabled = NO;
                [btn setBackgroundColor:KColorHeader];
                [btn setTintColor:kFontColorA];
            }
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [super requestFailed:request];
    isRequestRegister = NO;
}

// 点击关闭按钮
- (void)closeOnClick:(UIButton*)sender
{
    [self textFieldresignFirstResponder];
    [[CHNAlertView defaultAlertView] showContent:@"未完成注册，是否放弃" cancelTitle:@"放弃" sureTitle:@"不放弃" withDelegate:self withType:4];
    flag = 1;
}

- (void)buttonClickedAtIndex:(NSInteger)index

{
    //flag = 1 返回登陆页面;   =2 返回上一页面重新下发验证码;  =3 弹出昵称框;  = 4 弹出密码框; = 5 弹出确认密码框
    if (flag == 1)
    {
        if (index == 0)
        {
            NSInteger count = self.navigationController.viewControllers.count;
            for (NSInteger i = count; i > 0; i--)
            {
                BasicViewController * bvc = self.navigationController.viewControllers[i-1];
                if ([bvc isKindOfClass:[FirstViewController class]] ||
                    [bvc isKindOfClass:[SecondLoginViewController class]])
                {
                    // 已知可以从上面页面进入，返回到相应的上层页面
                    [self.navigationController popToViewController:bvc animated:YES];
                    return;
                }
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if (index == 1)
        {
            return;
        }
    }
    else if (flag == 2)
    {
        [self backLastView];
    }
    else if (flag == 3)
    {
        [nameTf becomeFirstResponder];
    }
    else if (flag == 4)
    {
        [passTf becomeFirstResponder];
    }
    else if (flag == 5)
    {
        [rePassTf becomeFirstResponder];
    }
    return;
}

// 点击开始提交用户信息
- (void)startBtnOnClick
{
    NSInteger length = [Utility lenghtWithString:nameTf.text];
    if (length < 32)
    {
        
    }
    else
    {
        [self textFieldresignFirstResponder];
        [[CHNAlertView defaultAlertView] showContent:@"昵称最多为32个字符" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
        flag = 3;
    }
    if ([passTf.text isEqualToString:rePassTf.text])
    {
        [self requestResign];
    }
    else
    {
        [self textFieldresignFirstResponder];
        [[CHNAlertView  defaultAlertView] showContent:@"两次密码不一致" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
        flag = 4;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    UIButton * btn = (UIButton*)[self.view viewWithTag:100];
    if (textField == nameTf)
    {
        if (nameTf.text.length > 32)
        {
            nameTf.text = [nameTf.text stringByReplacingCharactersInRange:NSMakeRange(nameTf.text.length-1, 1) withString:@""];
        }
        if (string.length > 0 && ![string isEqualToString:@""])
        {
            isFirst = YES;
        }
        else
        {
            if (nameTf.text.length > 1)
            {
                isFirst = YES;
            }
            else
            {
                isFirst = NO;
            }
        }
        if (passTf.text.length > 0)
        {
            isSecond = YES;
        }
        else
        {
            isSecond = NO;
        }
        if (rePassTf.text.length > 0)
        {
            isThird = YES;
        }
        else
        {
            isThird = NO;
        }
    }
    if (textField == passTf)
    {
        if (string.length > 0 && ![string isEqualToString:@""])
        {
            isSecond = YES;
        }
        else
        {
            if (passTf.text.length > 1)
            {
                isSecond = YES;
            }
            else
            {
                isSecond = NO;
            }
        }
        if (nameTf.text.length > 0)
        {
            isFirst = YES;
        }
        else
        {
            isFirst = NO;
        }
        if (rePassTf.text.length > 0)
        {
            isThird = YES;
        }
        else
        {
            isThird = NO;
        }
    }
    if (textField == rePassTf)
    {
        if (string.length > 0 && ![string isEqualToString:@""])
        {
            isThird = YES;
        }
        else
        {
            if (rePassTf.text.length > 1)
            {
                isThird = YES;
            }
            else
            {
                isThird = NO;
            }
        }
        if (nameTf.text.length > 0)
        {
            isFirst = YES;
        }
        else
        {
            isFirst = NO;
        }
        if (passTf.text.length > 0)
        {
            isSecond = YES;
        }
        else
        {
            isSecond = NO;
        }
    }
    if (isFirst && isSecond && isThird)
    {
        btn.enabled = YES;
        [btn setBackgroundColor:kRedColor];
        [btn setTitleColor:kFontColorA forState:UIControlStateNormal];
        [btn setBackgroundImage:KBtnSelectNewColorA.image forState:UIControlStateHighlighted];
        [btn setBackgroundImage:KBtnSelectNewColorA.image forState:UIControlStateSelected];
    }
    else
    {
        btn.enabled = NO;
        [btn setBackgroundColor:KColorHeader];
        [btn setTintColor:kFontColorA];
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField == passTf)
    {
        if ((passTf.text.length < 6 && passTf.text.length != 0) || passTf.text.length > 16)
        {
            [self textFieldresignFirstResponder];
            [passTf resignFirstResponder];
            [rePassTf resignFirstResponder];
            [nameTf resignFirstResponder];
            [[CHNAlertView defaultAlertView] showContent:@"请输入6-16位密码" cancelTitle:nil sureTitle:nil withDelegate:self withType:6];
            flag = 4;
        }
    }
    if (textField == rePassTf)
    {
        if ((rePassTf.text.length < 6 && rePassTf.text.length != 0) || rePassTf.text.length > 16)
        {
            [self textFieldresignFirstResponder];
            [[CHNAlertView defaultAlertView] showContent:@"请输入6-16位密码" cancelTitle:nil sureTitle:nil withDelegate:self withType:6];
            flag = 5;
        }
    }
    if (nameTf.text.length > 0)
    {
        isFirst = YES;
    }
    else
    {
        isFirst = NO;
    }
    UIButton * btn = (UIButton*)[self.view viewWithTag:100];
    if (isFirst && isSecond && isThird)
    {
        btn.enabled = YES;
        [btn setBackgroundColor:kRedColor];
        [btn setTitleColor:kFontColorA forState:UIControlStateNormal];
        [btn setBackgroundImage:KBtnSelectNewColorA.image forState:UIControlStateHighlighted];
        [btn setBackgroundImage:KBtnSelectNewColorA.image forState:UIControlStateSelected];
    }
    else
    {
        btn.enabled = NO;
        [btn setBackgroundColor:KColorHeader];
        [btn setTintColor:kFontColorA];
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    UIButton * btn = (UIButton*)[self.view viewWithTag:100];
    btn.enabled = NO;
    [btn setBackgroundColor:KColorHeader];
    [btn setTintColor:kFontColorA];
    if (textField == nameTf)
    {
        isFirst = NO;
    }
    if (textField == passTf)
    {
        isSecond = NO;
    }
    if (textField == rePassTf)
    {
        isThird = NO;
    }
    return YES;
}

// 点击页面，输入框失去焦点
- (void)viewTapped:(id)sender
{
    [self textFieldresignFirstResponder];
}

- (void)textFieldresignFirstResponder
{
    if ([nameTf isFirstResponder])
    {
        [nameTf resignFirstResponder];
    }
    else if ([passTf isFirstResponder])
    {
        [passTf resignFirstResponder];
    }
    else if ([rePassTf isFirstResponder])
    {
        [rePassTf resignFirstResponder];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
