//
//  DrawCashViewController.m
//  StockMaster
//
//  Created by Rebloom on 14-7-31.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "DrawCashViewController.h"
#import "WithDrawCashViewController.h"
#import "FourthViewController.h"
#import "UIImage+UIColor.h"
#import "CardViewController.h"
#import "EarnMoneyViewController.h"

@interface DrawCashViewController ()

@end

@implementation DrawCashViewController

@synthesize card_no;
@synthesize idcard;
@synthesize mobile;
@synthesize real_name;
@synthesize bankType;
@synthesize cardID;
@synthesize cardBank;
@synthesize cardName;
@synthesize cardDrawCash;
@synthesize branchBankID;

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
    [self Countdown];
    checkCodeBtn.userInteractionEnabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [drawCashTimer invalidate];
    [super viewWillDisappear:YES];
}

- (void)requestSmsCode
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:mobile forKey:@"mobile"];
    [GFRequestManager connectWithDelegate:self action:Get_sms_code param:paramDic];
}

-( void)requestAddCard
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:real_name forKey:@"real_name"];
    [paramDic setObject:card_no forKey:@"bank_account"];
    [paramDic setObject:mobile forKey:@"mobile"];
    [paramDic setObject:idcard forKey:@"idcard"];
    [paramDic setObject:branchBankID forKey:@"branch_bank_id"];
    [paramDic setObject:phone.text forKey:@"sms_code"];
    [GFRequestManager connectWithDelegate:self action:Submit_bank_card param:paramDic];
    
    // 诸葛统计（绑定银行卡）
    [[Zhuge sharedInstance] track:@"绑定银行卡" properties:nil];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    
    ASIFormDataRequest * formDataRequest = (ASIFormDataRequest *)request;
    if ([formDataRequest.action isEqualToString:Submit_bank_card])
    {
        for(BasicViewController * bvc in self.navigationController.viewControllers)
        {
            NSInteger  temp = [[GFStaticData getObjectForKey:KTagCardBack] integerValue];
            //为1时  代表从赚钱模块进入绑定银行卡； 为2时  代表从其他页面
            
            [GFStaticData saveObject:[[requestInfo objectForKey:@"data"]mutableCopy] forKey:KTagCardInfo];
            
            if (temp == 1)
            {
                if ([bvc isKindOfClass:[FourthViewController class]])
                {
                    [self.navigationController popToViewController:bvc animated:YES];
                    break;
                }
            }
            else
            {
                if ([bvc isKindOfClass:[CardViewController class]])
                {
                    [self.navigationController popToViewController:bvc animated:YES];
                    break;
                }
                else if ([bvc isKindOfClass:[EarnMoneyViewController class]])
                {
                    [self.navigationController popToViewController:bvc animated:YES];
                    break;
                }
                else if ([bvc isKindOfClass:[WithDrawCashViewController class]])
                {
                    [self.navigationController popToViewController:bvc animated:YES];
                    break;
                }
            }
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    messageArr = [[NSMutableArray alloc] initWithCapacity:5];
    [headerView loadComponentsWithTitle:@"添加银行卡"];
    [headerView backButton];
    [headerView createLine];
    headerView.backgroundColor = kFontColorA;
    [headerView setStatusBarColor: kFontColorA];
    
    self.view.backgroundColor =KSelectNewColor;
    
    [GFStaticData saveObject:@"" forKey:KTagCardInfo];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    [self createUI];
    [self requestSmsCode];
}


-(void)createUI
{
    UIImageView * topView = [[UIImageView alloc] init];
    topView.userInteractionEnabled = YES;
    topView.frame = CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, 60);
    topView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:topView];
    
    UILabel * tipLb = [[UILabel alloc] init];
    tipLb.frame = CGRectMake(10, 0, 80, 60);
    tipLb.text = @"已发送短信至";
    tipLb.textAlignment = NSTextAlignmentCenter;
    tipLb.textColor = KFontNewColorA;
    tipLb.font = NormalFontWithSize(13);
    tipLb.backgroundColor = [UIColor clearColor];
    [topView addSubview:tipLb];
    
    UILabel * phoneLabel = [[UILabel alloc] init];
    phoneLabel.frame = CGRectMake(CGRectGetMaxX(tipLb.frame), 0, 100, 60);
    phoneLabel.text = [Utility departString:self.mobile  withType:4];
    phoneLabel.textAlignment = NSTextAlignmentLeft;
    phoneLabel.textColor = KFontNewColorD;
    phoneLabel.font = NormalFontWithSize(13);
    phoneLabel.backgroundColor = [UIColor clearColor];
    [topView addSubview:phoneLabel];
    
    checkCodeBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth-120, 0,110, 60)];
    codeFlag=1;
    [checkCodeBtn  setBackgroundImage:[[UIColor clearColor] image] forState:UIControlStateNormal] ;
    [checkCodeBtn setTitle:@"重新发送" forState:UIControlStateNormal];
    [checkCodeBtn setTitleColor:KFontNewColorD forState:UIControlStateNormal];
    [checkCodeBtn addTarget:self action:@selector(getCheckCodeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    checkCodeBtn.titleLabel.font = NormalFontWithSize(13);
    [topView addSubview:checkCodeBtn];
    
    phone = [[GFTextField alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topView.frame), screenWidth, 60)];
    phone.placeHolderColor = 1;
    phone.clearButtonMode = UITextFieldViewModeWhileEditing;
    phone.backgroundColor = kFontColorA;
    phone.delegate = self;
    [phone becomeFirstResponder];
    phone.keyboardType = UIKeyboardTypeNumberPad;
    phone.placeholder = @"请输入验证码";
    phone.font = NormalFontWithSize(14);
    phone.textColor = kTitleColorA;
    [self.view addSubview:phone];
    
    UIButton * nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(phone.frame)+20, screenWidth-40, 44)];
    nextBtn.tintColor = kFontColorA;
    nextBtn.enabled = NO;
    [nextBtn setBackgroundColor:KColorHeader];
    [nextBtn setTintColor:KFontNewColorB];
    nextBtn.tag = 1024;
    nextBtn.layer.cornerRadius = 5;
    nextBtn.layer.masksToBounds = YES;
    nextBtn.titleLabel.font = NormalFontWithSize(16);
    [nextBtn setTitle:@"确 定" forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(submitBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextBtn];
}

- (void)viewTapped:(id)sender
{
    if ([phone isFirstResponder])
    {
        [phone resignFirstResponder];
    }
}

-(void)getCheckCodeBtnClicked
{
    [self requestSmsCode];
    [self Countdown];
}

-(void)Countdown
{
    [checkCodeBtn setTitle:@"60秒后重新发送" forState:UIControlStateNormal];
    
    date = [[NSDate alloc] init];
    
    time = 60;
    drawCashTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                     target:self
                                                   selector:@selector(handleTimer)
                                                   userInfo:nil
                                                    repeats:YES];
    checkCodeBtn.userInteractionEnabled = NO;
}


- (void)handleTimer
{
    if (time == 0) {
        [drawCashTimer pauseTimer];
        checkCodeBtn.userInteractionEnabled = YES;
        [checkCodeBtn setTitle:@"重新发送" forState:UIControlStateNormal];
        [checkCodeBtn setTitleColor:KFontNewColorD forState:UIControlStateNormal];
    }
    else
    {
        [checkCodeBtn setTitle:[NSString stringWithFormat:@"%d秒后重新发送",time] forState:UIControlStateNormal];
        [checkCodeBtn setTitleColor:KFontNewColorB forState:UIControlStateNormal];
        
        NSDate * nowDate = [NSDate date];
        NSTimeInterval now = [nowDate timeIntervalSinceDate:date];
        
        time = 60-now;
    }
}

- (void)submitBtnClicked:(id)sender
{
    if (phone.text.length>0)
    {
        [self requestAddCard];
    }
    else
    {
        [[CHNAlertView defaultAlertView] showContent:@"请填写验证码" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    
    UIButton * btn = (UIButton*)[self.view viewWithTag:1024];
    btn.enabled = NO;
    [btn setBackgroundColor:KColorHeader];
    [btn setTintColor:KFontNewColorB];
    
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    UIButton * btn = (UIButton*)[self.view viewWithTag:1024];
    if (textField == phone)
    {
        NSInteger i = phone.text.length;
        if ([string isEqualToString:@""] && i>0)
        {
            i = i -2;
        }
        if (i >2)
        {
            btn.enabled = YES;
            [btn setBackgroundColor:kRedColor];
            [btn setTitleColor:kFontColorA forState:UIControlStateNormal];
            [btn setBackgroundImage:KBtnSelectNewColorA.image forState:UIControlStateHighlighted];
            [btn setBackgroundImage:KBtnSelectNewColorA.image forState:UIControlStateSelected];
            [btn addTarget:self action:@selector(submitBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            btn.enabled = NO;
            [btn setBackgroundColor:KColorHeader];
            [btn setTintColor:KFontNewColorB];
        }
    }
    
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
