//
//  SetNicknameViewController.m
//  StockMaster
//
//  Created by Rebloom on 14-8-1.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//
#import "HomeViewController.h"
#import "SetNicknameViewController.h"
#import "NSString+UIColor.h"
#import "UIImage+UIColor.h"

@interface SetNicknameViewController ()

@end

@implementation SetNicknameViewController

@synthesize type;
@synthesize nameStr;


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
    [nickName becomeFirstResponder];
    [super viewWillAppear:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor =KSelectNewColor;
    
    /*
     type = 1  注册时设置昵称
     type = 2  注册时未设置昵称，第一次登陆后设置
     type = 3  登陆后，修改昵称
     */
    
    if (type != 2)
    {
        [headerView backButton];
    }
    if (type == 3)
    {
        [headerView loadComponentsWithTitle:@"修改昵称"];
    }
    else
    {
        [headerView loadComponentsWithTitle:@"设置昵称"];
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
    UILabel * lineLb = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, 0.5)];
    lineLb.backgroundColor = KLineNewBGColor3;
    [self.view addSubview:lineLb];
    
    UILabel * lineLb1 = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lineLb.frame), screenWidth, 0.5)];
    lineLb1.backgroundColor = KLineNewBGColor4;
    [self.view addSubview:lineLb1];
    
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = kFontColorA;
    view.frame = CGRectMake(0, CGRectGetMaxY(lineLb1.frame), screenWidth, 60);
    [self.view addSubview:view];
    
    nickName = [[GFTextField alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lineLb1.frame), screenWidth-19, 60)];
    nickName.placeHolderColor = 1;
    nickName.backgroundColor = kFontColorA;
    nickName.borderStyle = UITextBorderStyleNone;
    nickName.clearButtonMode = UITextFieldViewModeWhileEditing;
    nickName.font = NormalFontWithSize(15);
    nickName.delegate = self;
    nickName.textColor = kTitleColorA;
    if (type == 3)
    {
        nickName.text =nameStr ;
    }
    else
    {
        nickName.placeholder = @"请输入您的昵称";
    }
    [self.view addSubview:nickName];
    
    UILabel * lineLb3 = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(nickName.frame), screenWidth, 0.5)];
    lineLb3.backgroundColor = KLineNewBGColor1;
    [self.view addSubview:lineLb3];
    
    UILabel * lineLb4 = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lineLb3.frame), screenWidth, 0.5)];
    lineLb4.backgroundColor = KLineNewBGColor2;
    [self.view addSubview:lineLb4];
    
    UIButton * save = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(lineLb4.frame)+20, screenWidth-40, 44)];
    save.tag =100;
    save.layer.cornerRadius = 5;
    save.layer.masksToBounds = YES;
    if (type == 3)
    {
        save.enabled = YES;
        [save setBackgroundColor:kRedColor];
        [save setTitleColor:kFontColorA forState:UIControlStateNormal];
        [save setBackgroundImage:KBtnSelectNewColorA.image forState:UIControlStateHighlighted];
        [save setBackgroundImage:KBtnSelectNewColorA.image forState:UIControlStateSelected];
    }
    else
    {
        save.enabled = NO;
        [save setBackgroundColor:KColorHeader];
        [save setTintColor:kFontColorA];
    }
    save.titleLabel.font = NormalFontWithSize(16);
    [save setTitle:@"保 存" forState:UIControlStateNormal];
    [save addTarget:self action:@selector(saveBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:save];
    
    UILabel * ideaLabel = [[UILabel alloc] init];
    ideaLabel.frame = CGRectMake(0, screenHeight - 52-15, screenWidth, 15);
    ideaLabel.text = @"免费炒股，大赚真钱";
    ideaLabel.textAlignment = NSTextAlignmentCenter;
    ideaLabel.textColor = KFontNewColorC;
    ideaLabel.font = NormalFontWithSize(12);
    [self.view addSubview:ideaLabel];
    
    UIImageView * iconView = [[UIImageView alloc] init];
    iconView.frame = CGRectMake(screenWidth/2-15, CGRectGetMidY(ideaLabel.frame) - 20 -23, 30, 23);
    iconView.image = [UIImage imageNamed:@"zhangzhang"];
    [self.view addSubview:iconView];
}

- (void)viewTapped:(id)sender
{
    if ([nickName isFirstResponder])
    {
        [nickName resignFirstResponder];
    }
}

//  点击保存按钮
- (void)saveBtnClicked:(id)sender
{
    NSInteger length = [Utility lenghtWithString:nickName.text];
    
    if (length)
    {
        if (length < 32)
        {
            [self setNickNameRequest];
        }
        else
        {
            [[CHNAlertView defaultAlertView] showContent:@"昵称最多为32个字符" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
        }
    }
    else
    {
        [[CHNAlertView defaultAlertView] showContent:@"请输入昵称" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
    }
}

// 设置昵称的请求
- (void)setNickNameRequest
{
    if ([[UserInfoCoreDataStorage sharedInstance] isCurrentUserLogin])
    {
        // 登录了才可以修改昵称
        NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
        [paramDic setObject:nickName.text forKey:@"nickname"];
        [GFRequestManager connectWithDelegate:self action:Update_user_info param:paramDic];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{
    UIButton * btn = (UIButton*)[self.view viewWithTag:100];
    
    if (textField == nickName)
    {
        if (string.length > 0 && ![string isEqualToString:@""])
        {
            btn.enabled = YES;
            [btn setBackgroundColor:kRedColor];
            [btn setTitleColor:kFontColorA forState:UIControlStateNormal];
            [btn setBackgroundImage:KBtnSelectNewColorA.image forState:UIControlStateHighlighted];
            [btn setBackgroundImage:KBtnSelectNewColorA.image forState:UIControlStateSelected];
            [btn addTarget:self action:@selector(saveBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            if (nickName.text.length > 1)
            {
                btn.enabled = YES;
                [btn setBackgroundColor:kRedColor];
                [btn setTitleColor:kFontColorA forState:UIControlStateNormal];
                [btn setBackgroundImage:KBtnSelectNewColorA.image forState:UIControlStateHighlighted];
                [btn setBackgroundImage:KBtnSelectNewColorA.image forState:UIControlStateSelected];
                [btn addTarget:self action:@selector(saveBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
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

// 请求成功
- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    
    ASIFormDataRequest * formDataRequest = (ASIFormDataRequest *)request;
    if ([formDataRequest.action isEqualToString:Update_user_info])
    {
        NSDictionary *userInfo = [requestInfo objectForKey:@"data"];
        [[UserInfoCoreDataStorage sharedInstance] saveLoginUserInfo:userInfo];
        
        if (type == 3)
        {
            [[TKAlertCenter defaultCenter] postAlertWithMessage:@"修改成功" withType:ALERTTYPEERROR];
            [self performSelector:@selector(popLastView) withObject:nil afterDelay:1];
        }
        else if (type == 1)
        {
            HomeViewController * HVC = [[HomeViewController alloc] init];
            [HVC setSelectedTab:TabSelectedFirst];
            [self pushToViewController:HVC];
        }
        else if (type == 2)
        {
            [[TKAlertCenter defaultCenter] postAlertWithMessage:@"设置成功" withType:ALERTTYPEERROR];
            
            HomeViewController * HVC = [[HomeViewController alloc] init];
            [HVC setSelectedTab:TabSelectedFirst];
            [self pushToViewController:HVC];
        }
    }
}

- (void)popLastView
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
