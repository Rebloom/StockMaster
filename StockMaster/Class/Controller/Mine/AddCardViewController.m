//
//  AddCardViewController.m
//  StockMaster
//
//  Created by Rebloom on 14-7-29.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "AddCardViewController.h"
#import "UIImage+UIColor.h"
#import "NSString+UIColor.h"
#import "DrawCashViewController.h"
#import "GFStaticData.h"
#import "UIImage+UIColor.h"
@interface AddCardViewController ()
{
    UserInfoEntity *userInfo;
}

@end

@implementation AddCardViewController

@synthesize cardType;
@synthesize drawCashNum;
@synthesize modelType;
@synthesize isFirst;
@synthesize transInfo;

- (void)dealloc
{
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

// 提交添加银行卡请求
- (void)requestSubmitCard
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    for (UIView * view in bgView.subviews)
    {
        if ([view isKindOfClass:[GFTextField class]])
        {
            GFTextField * gfTextField = (GFTextField *)view;
            if (gfTextField.tag == 100)
            {
                [paramDic setObject:gfTextField.text forKey:@"real_name"];
            }
            else if (gfTextField.tag == 103)
            {
                [paramDic setObject:gfTextField.text forKey:@"bank_account"];
            }
        }
    }
    [paramDic setObject:userInfo.mobile forKey:@"mobile"];
    [paramDic setObject:[transInfo objectForKey:@"idcard"] forKey:@"idcard"];
    [paramDic setObject:branchBankID forKey:@"branch_bank_id"];
    [GFRequestManager connectWithDelegate:self action:Submit_bank_card param:paramDic];

    // 诸葛统计（绑定银行卡）
    [[Zhuge sharedInstance] track:@"绑定银行卡" properties:nil];
}

// 请求成功
- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    ASIFormDataRequest * formDataRequest = (ASIFormDataRequest *)request;
    if([formDataRequest.action isEqualToString:Submit_bank_card])
    {
        if ([[requestInfo objectForKey:@"message"] isEqualToString:@"Success"])
        {
            [self back];
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [super requestFailed:request];
}

- (void)alertBtnClicked:(id)sender
{
    [[CHNAlertView defaultAlertView] showContent:transInfo?[[transInfo objectForKey:@"tips_branch"] description]:@"若支行列表中找不到自己的银行卡开户网点，可以选择就近网点" cancelTitle:nil sureTitle:nil withDelegate:self withType:6];
}

- (void)back
{
    isClose = YES;
    if (self.navigationController && self.navigationController.viewControllers.count>1)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    userInfo = [[UserInfoCoreDataStorage sharedInstance] getCurrentUserInfo];
    
    self.view.backgroundColor = KSelectNewColor;
    
    [headerView loadComponentsWithTitle:@"添加银行卡"];
    [headerView backButton];
    [headerView createLine];
    headerView.backgroundColor = kFontColorA;
    [headerView setStatusBarColor: kFontColorA];
    
    isClose = NO;
    isName = NO;
    isIdentify = NO;
    isMobile = NO;
    isCardId = NO;
        
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [self.view addGestureRecognizer:tap];
    
    bankArr = [[NSMutableArray alloc] initWithCapacity:10];
    manageDic = [GFStaticData getObjectForKey:KTagBankCard forUser:userInfo.uid];
    
    scrollView = [[UIScrollView alloc] init];
    scrollView.frame = CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, screenHeight);
    scrollView.delegate = self;
    if (iPhone4s)
    {
        if (isFirst)
        {
            scrollView.contentSize = CGSizeMake(screenWidth, screenHeight + 220);
        }
        else
        {
            scrollView.contentSize = CGSizeMake(screenWidth, screenHeight + 150);
        }
    }
    else
    {
        if (isFirst)
        {
            scrollView.contentSize = CGSizeMake(screenWidth, screenHeight + 150);
            
        }
        else
        {
            scrollView.contentSize = CGSizeMake(screenWidth, screenHeight + 80);
        }
    }
    scrollView.backgroundColor = KSelectNewColor;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    
    [self createUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self textFieldResignFirstResponder];
}

// 初始化界面布局
- (void)createUI
{
    bgView = [[UIImageView alloc] init];
    bgView.backgroundColor = [UIColor clearColor];
    bgView.userInteractionEnabled = YES;
    [scrollView addSubview:bgView];
    NSArray * titleArr = nil;
    NSArray * descArr = nil;
    if (isFirst) {
        titleArr = @[@"持卡人姓名", @"身份证号", @"选择银行卡", @"所属支行", @"银行卡号", @"验证手机"];
        descArr = @[@"填写您的真实姓名",@"填写您的身份证号",@"选择(储蓄)银行卡",@"选择支行",@"填写您的银行卡号",@"填写您的手机号"];
    }
    else
    {
        titleArr = [[NSArray alloc] initWithObjects: @"持卡人姓名", @"选择银行卡", @"所属支行", @"银行卡号",@"验证手机",nil];
        descArr = @[[transInfo objectForKey:@"real_name"],@"选择(储蓄)银行卡",@"选择支行",@"填写您的银行卡号",@"填写您的手机号"];
    }
    
    bgView.frame = CGRectMake(0, 0, screenWidth, 70+60*titleArr.count);
    
    UILabel * tipLb = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, screenWidth-40, 30)];
    tipLb.textAlignment = NSTextAlignmentLeft;
    
    if (transInfo)
    {
        tipLb.text = [transInfo objectForKey:@"tips_bind"];
    }
    else
    {
        if (isFirst)
        {
            tipLb.text = @"姓名、身份证信息一旦添加，无法更改\n且以后只能添加此姓名的银行卡，请仔细校验";
        }
        else
        {
            tipLb.text = @"您之前绑定过银行卡\n再次绑定只能绑定与之前持卡人相同的银行卡";
        }
    }

    tipLb.numberOfLines = 0;
    tipLb.font = NormalFontWithSize(13);
    tipLb.backgroundColor = [UIColor clearColor];
    tipLb.textColor = KFontNewColorB;
    [bgView addSubview:tipLb];

    for (int i = 0; i < titleArr.count; i++)
    {
        UIImageView * imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(0, 70+60*i, screenWidth, 59.5);
        imageView.userInteractionEnabled = YES;
        imageView.backgroundColor = kFontColorA;
        [bgView addSubview:imageView];
        
        UILabel * tempLb = [[UILabel alloc] init];
        tempLb.frame = CGRectMake(20, 70+60*i, 70, 59.5);
        tempLb.text = [titleArr objectAtIndex:i];
        tempLb.textAlignment = NSTextAlignmentLeft;
        tempLb.textColor = KFontNewColorB;
        tempLb.font = NormalFontWithSize(14);
        [bgView addSubview:tempLb];
        
        GFTextField * textField = [[GFTextField alloc] init];
        textField.tag = 100+i;
        textField.font = NormalFontWithSize(15);
        textField.textColor = KFontColorE;
        textField.delegate = self;
        textField.frame = CGRectMake(110, 70+60*i, screenWidth-150, 59.5);
        textField.placeHolderColor = 1;
        [bgView addSubview:textField];
        
        textField.placeholder = [descArr objectAtIndex:i];

        if (isFirst)
        {
            if (i == 2 || i == 3)
            {
                textField.userInteractionEnabled = NO;
                UIButton * btn = [[UIButton alloc] initWithFrame:textField.frame];
                btn.tag = i-1;
                [btn addTarget:self action:@selector(toSearchCardViewController:) forControlEvents:UIControlEventTouchUpInside];
                [bgView addSubview:btn];
                
                if (i == 3)
                {
                    UIButton * alertBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(textField.frame)+5, CGRectGetMinY(textField.frame), 60, 60)];
                    [alertBtn addTarget:self action:@selector(alertBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                    [bgView addSubview:alertBtn];
                    
                    UIImageView * alertImage = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(textField.frame)+5, CGRectGetMinY(textField.frame)+19, 22, 22)];
                    alertImage.image = [UIImage imageNamed:@"icon_jingshi"];
                    [bgView addSubview:alertImage];
                }
            }
            if (i == 5)
            {
                textField.userInteractionEnabled = NO;
                textField.text = [Utility departString:userInfo.mobile withType:4];
            }
        }
        else
        {
            if (i == 0)
            {
                textField.userInteractionEnabled = NO;
                textField.text = [transInfo objectForKey:@"real_name"];
            }
            
            if(i == 1 || i == 2)
            {
                textField.userInteractionEnabled = NO;
                UIButton * btn = [[UIButton alloc] initWithFrame:textField.frame];
                btn.tag = i;
                [btn addTarget:self action:@selector(toSearchCardViewController:) forControlEvents:UIControlEventTouchUpInside];
                [bgView addSubview:btn];
                
                if (i == 2)
                {
                    UIButton * alertBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(textField.frame)+5, CGRectGetMinY(textField.frame), 60, 60)];
                    [alertBtn addTarget:self action:@selector(alertBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                    [bgView addSubview:alertBtn];
                    
                    UIImageView * alertImage = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(textField.frame)+5, CGRectGetMinY(textField.frame)+19, 22, 22)];
                    alertImage.image = [UIImage imageNamed:@"icon_jingshi"];
                    [bgView addSubview:alertImage];
                }
            }
            if (i == 4)
            {
                textField.userInteractionEnabled = NO;
                textField.text = [Utility departString:userInfo.mobile withType:4];
            }
        }
    }

    submitBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(bgView.frame)+20, screenWidth-40, 44)];
    submitBtn.tintColor = kFontColorA;
    submitBtn.layer.cornerRadius = 5;
    submitBtn.layer.masksToBounds = YES;
    submitBtn.titleLabel.font = NormalFontWithSize(15);
    if (isFirst)
    {
        [submitBtn setTitle:@"下一步" forState:UIControlStateNormal];
    }
    else
    {
        [submitBtn setTitle:@"保 存" forState:UIControlStateNormal];
    }
    submitBtn.enabled = NO;
    [submitBtn setBackgroundColor:KColorHeader];
    [submitBtn setTintColor:kFontColorA];
    [submitBtn addTarget:self action:@selector(submitBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:submitBtn];
    [scrollView bringSubviewToFront:submitBtn];

    UIImageView * imageView = [[UIImageView alloc] init];
    imageView . frame = CGRectMake(screenWidth/2-15, CGRectGetMaxY(submitBtn.frame)+52, 30, 23);
    imageView.image = [UIImage imageNamed:@"zhangzhang"];
    [scrollView addSubview:imageView];

    UILabel * tipLabel = [[UILabel alloc] init];
    tipLabel.frame = CGRectMake(0, CGRectGetMaxY(imageView.frame)+10, screenWidth, 14);
    tipLabel.text = @"免费炒股,大赚真钱";
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.font = NormalFontWithSize(14);
    tipLabel.textColor = KFontNewColorC;
    tipLabel.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:tipLabel];
    
    changeBtn = [[UIButton alloc] init];
    changeBtn.userInteractionEnabled = YES;
    changeBtn.frame = CGRectMake(screenWidth-80, 70+60*(4+isFirst), 60, 60);
    changeBtn.titleLabel.font = NormalFontWithSize(15);
    [changeBtn setTitleColor:KFontNewColorD forState:UIControlStateNormal];
    [changeBtn setTitle:transInfo?[transInfo objectForKey:@"tips_mobile_text"]:@"换一换" forState:UIControlStateNormal];
    [changeBtn setBackgroundColor:[UIColor clearColor]];
    [changeBtn addTarget:self action:@selector(changeBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:changeBtn];
    changeBtn.hidden = YES;
    if ([[transInfo objectForKey:@"tips_is_show"] integerValue])
    {
        changeBtn.hidden = NO;
    }
}

- (void)toSearchCardViewController:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    
    if (btn.tag == 2 && !bankID.length)
    {
        [[CHNAlertView defaultAlertView] showContent:@"请先选择银行卡" cancelTitle:nil sureTitle:nil withDelegate:self withType:6];
        return;
    }
    
    SearchBankViewController * SBVC = [[SearchBankViewController alloc] init];
    SBVC.searchType = btn.tag;
    SBVC.bankID = bankID;
    SBVC.delegate = self;
    [self pushToViewController:SBVC];
}

- (void)didChooseBank:(NSDictionary *)bankInfo
{
    for (UIView * view in bgView.subviews)
    {
        if ([view isKindOfClass:[GFTextField class]])
        {
            GFTextField * gfTextField = (GFTextField *)view;
            if (isFirst)
            {
                if (gfTextField.tag == 102)
                {
                    gfTextField.text = [bankInfo objectForKey:@"bank_name"];
                }
                else if (gfTextField.tag == 103)
                {
                    gfTextField.text = @"";
                    branchName = @"";
                }
            }
            else
            {
                if (gfTextField.tag == 101)
                {
                    gfTextField.text = [bankInfo objectForKey:@"bank_name"];
                }
                else if (gfTextField.tag == 102)
                {
                    gfTextField.text = @"";
                    branchName = @"";
                }
            }
        }
    }
    [bgView reloadInputViews];
    bankID = [[bankInfo objectForKey:@"bank_id"] description];
    bankName = [[bankInfo objectForKey:@"bank_name"] description];

}

- (void)didChooseBranchBank:(NSDictionary *)branchBankInfo
{
    for (UIView * view in bgView.subviews)
    {
        if ([view isKindOfClass:[GFTextField class]])
        {
            GFTextField * gfTextField = (GFTextField *)view;
            if (isFirst)
            {
                if (gfTextField.tag == 103)
                {
                    gfTextField.text = [branchBankInfo objectForKey:@"branch_bank_name"];
                }
            }
            else
            {
                if (gfTextField.tag == 102)
                {
                    gfTextField.text = [branchBankInfo objectForKey:@"branch_bank_name"];
                }
            }
        }
    }
    [bgView reloadInputViews];
    branchBankID = [[branchBankInfo objectForKey:@"branch_bank_id"] description];
    branchName = [[branchBankInfo objectForKey:@"branch_bank_name"] description];
}

// 换银行卡需要呼叫客服
- (void)changeBtnOnClick:(UIButton*)sender
{
    if ([[transInfo objectForKey:@"tips_is_open_call"] integerValue])
    {
        NSString * contentString = [NSString stringWithFormat:@"%@,%@",transInfo?[transInfo objectForKey:@"tips_mobile_alert"]:@"为了您账户安全，修改验证手机号\n请联系客服",transInfo?[transInfo objectForKey:@"tips_telphone"]:@"400-666-5666"];
        [[CHNAlertView defaultAlertView] showContent:contentString cancelTitle:@"取消" sureTitle:@"呼叫" withDelegate:self withType:2];
    }
    else
    {
        [[CHNAlertView defaultAlertView] showContent:transInfo?[transInfo objectForKey:@"tips_mobile_alert"]:@"为了您账户安全，修改验证手机号\n请联系客服" cancelTitle:nil sureTitle:nil withDelegate:self withType:6];
    }
}

// 点击页面，输入框失去焦点
- (void)viewTapped:(id)sender
{
    for (UIView * view in bgView.subviews)
    {
        if ([view isKindOfClass:[GFTextField class]])
        {
            GFTextField * gfText = (GFTextField *)view;
            if ([gfText isFirstResponder])
            {
                [gfText resignFirstResponder];
            }
        }
    }
}

// 弹出框点击按钮代理方法
- (void)buttonClickedAtIndex:(NSInteger)index
{
    if (index == 1)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://4006665666"]];
    }
    return;
}

// 提交用户银行卡信息
- (void)submitBtnClicked:(UIButton*)sender
{
    GFTextField * realName = nil;
    GFTextField * identifiyNum = nil;
    GFTextField * cardID = nil;
    
    if (isFirst)
    {
        for (UIView * view in bgView.subviews)
        {
            if ([view isKindOfClass:[GFTextField class]])
            {
                GFTextField * gfTextField = (GFTextField *)view;
                if (gfTextField.tag == 100)
                {
                    realName = gfTextField;
                }
                else if (gfTextField.tag == 101)
                {
                    identifiyNum = gfTextField;
                }
                else if (gfTextField.tag == 104)
                {
                    cardID = gfTextField;
                }
            }
        }
        if (realName.text.length < 2 && ![GFStaticData getObjectForKey:kTagUserRealName])
        {
            [[CHNAlertView defaultAlertView] showContent:@"请输入正确的姓名，方便客服人员给您转账" cancelTitle:nil sureTitle:nil withDelegate:self withType:6];
            [cardID resignFirstResponder];
            return;
        }
        if ([self validateIdentityCard:identifiyNum.text] == NO)
        {
            [[CHNAlertView defaultAlertView] showContent:@"请填写与姓名一致的身份证号" cancelTitle:nil sureTitle:nil withDelegate:self withType:6];
            [cardID resignFirstResponder];
            return;
        }

    }
    else
    {
        for (UIView * view in bgView.subviews)
        {
            if ([view isKindOfClass:[GFTextField class]])
            {
                GFTextField * gfTextField = (GFTextField *)view;
                if (gfTextField.tag == 103)
                {
                    cardID = gfTextField;
                }
            }
        }
    }
    
    if (cardID.text.length<15||cardID.text.length>19 )
    {
        [[CHNAlertView defaultAlertView] showContent:@"请正确填写银行卡" cancelTitle:nil sureTitle:nil withDelegate:self withType:6];
        [cardID resignFirstResponder];
        return;
    }

    if (!bankName ||[bankName isEqualToString:@""]|| !branchName||[branchName isEqualToString:@""])
    {
        [[CHNAlertView defaultAlertView] showContent:@"请先选择银行卡及所属支行" cancelTitle:nil sureTitle:nil withDelegate:self withType:6];
        return;
    }
    
    [self createTip];
}

- (void)createTip
{
    if (!backgroundBtn)
    {
        backgroundBtn = [[UIButton alloc] init];
        backgroundBtn.frame = CGRectMake(0, 0, screenWidth, screenHeight);
        backgroundBtn.alpha = 0.4;
        backgroundBtn.backgroundColor = [UIColor blackColor];
        [backgroundBtn addTarget:self action:@selector(hideTipView) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:backgroundBtn];
    }
    backgroundBtn.hidden = NO;

    
    if(!tipView)
    {
        tipView = [[UIView alloc] init];
        tipView.frame = CGRectMake(15, 70, screenWidth -30, 350);
        tipView.backgroundColor = kFontColorA;
        tipView.layer.cornerRadius = 8;
        tipView.layer.masksToBounds = YES;
        tipView.alpha = 1;
        tipView.userInteractionEnabled = YES;
        [self.view addSubview:tipView];
    }
    tipView.hidden = NO;

    for (int i = 0; i < 2; i++)
    {
        UILabel * label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        if (i== 0)
        {
            label.textColor = KFontNewColorA;
            label.font = BoldFontWithSize(15);
            label.frame = CGRectMake(0, 0, CGRectGetWidth(tipView.frame), 40);
            label.text = @"信息确认";
        }
        if (i == 1)
        {
            label.textColor = kRedColor;
            label.font = NormalFontWithSize(12);
            label.frame = CGRectMake(15, 40, CGRectGetWidth(tipView.frame)-30, 50);
            label.numberOfLines = 0;
            label.textAlignment = NSTextAlignmentLeft;
            label.text = @"请仔细核对您所填写的信息，如有任何错误都将导致提现失败。";
        }
        [tipView addSubview:label];
    }
    
    NSArray * arr = @[@"持卡人姓名",@"选择银行卡",@"所属支行",@"银行卡号",@"验证手机"];
    for (int i =0; i < 5; i++)
    {
        UILabel * label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = KFontNewColorA;
        label.text = [arr objectAtIndex:i];
        label.font = NormalFontWithSize(12);
        label.frame = CGRectMake(15, 90+i*40, 65, 40);
        [tipView addSubview:label];
    }
    
    NSString * realName = nil;
    NSString * bank_account = nil;
    
    GFTextField * realNameTf = (GFTextField*)[self.view viewWithTag:100];
    if (isFirst)
    {
        realName = realNameTf.text;
        GFTextField * bankAccountTf = (GFTextField*)[self.view viewWithTag:104];
        bank_account = bankAccountTf.text;
    }
    else
    {
        realName = [transInfo objectForKey:@"real_name"];
        GFTextField * bankAccountTf = (GFTextField*)[self.view viewWithTag:103];
        bank_account = bankAccountTf.text;
    }
    NSArray * tempArr = @[realName,bankName,branchName,bank_account,[Utility departString:userInfo.mobile withType:4]];
    for (int i = 0; i<5; i++)
    {
        UILabel * label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = KFontNewColorA;
        label.numberOfLines = 3;
        label.text = [tempArr objectAtIndex:i];
        label.font = NormalFontWithSize(12);
        label.frame = CGRectMake(80, 90+i*40, CGRectGetWidth(tipView.frame)-30-65, 40);
        [tipView addSubview:label];
     }
    
    for (int i = 0; i<3; i++)
    {
        UILabel * lineLabel = [[UILabel alloc] init];
        lineLabel.backgroundColor = KFontNewColorM;
        if (i == 0)
        {
            lineLabel.frame = CGRectMake(0, 40, CGRectGetWidth(tipView.frame), 0.5);
        }
        else if (i == 1)
        {
            lineLabel.frame = CGRectMake(0, CGRectGetHeight(tipView.frame) - 45, CGRectGetWidth(tipView.frame), 0.5);
        }
        else if (i == 2)
        {
            lineLabel.frame = CGRectMake(CGRectGetWidth(tipView.frame)/2 -0.5, CGRectGetHeight(tipView.frame) - 45, 0.5, 44);
        }
        [tipView addSubview:lineLabel];
    }
    
    for (int i = 0; i< 6; i++)
    {
        UILabel * lineLabel = [[UILabel alloc] init];
        lineLabel.backgroundColor = KFontNewColorM;
        lineLabel.frame = CGRectMake(15, 90 + 40*i,CGRectGetWidth(tipView.frame)-30 , 0.5);
        [tipView addSubview:lineLabel];
    }
    
    for (int i = 0; i< 3; i++)
    {
        UILabel * lineLabel = [[UILabel alloc] init];
        lineLabel.backgroundColor = KFontNewColorM;
        if (i == 0)
        {
            lineLabel.frame = CGRectMake(15, 90, 0.5, 200);
        }
        else if (i == 1)
        {
            lineLabel.frame = CGRectMake(80, 90, 0.5, 200);
        }
        else if (i == 2)
        {
            lineLabel.frame = CGRectMake(CGRectGetWidth(tipView.frame)-15, 90, 0.5, 200);
        }
        [tipView addSubview:lineLabel];
    }
    
    UIButton * backBtn = [[UIButton alloc] init];
    backBtn.frame = CGRectMake(0, CGRectGetHeight(tipView.frame)-44, CGRectGetWidth(tipView.frame)/2-1, 44);
    backBtn.titleLabel.font = NormalFontWithSize(16);
    [backBtn setTitle:@"返回修改" forState:UIControlStateNormal];
    [backBtn setTitleColor:KFontNewColorB forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnOnClick) forControlEvents:UIControlEventTouchUpInside];
    [tipView addSubview:backBtn];
    
    UIButton * sureSubmitBtn = [[UIButton alloc] init];
    sureSubmitBtn.frame = CGRectMake(CGRectGetWidth(tipView.frame)/2+1, CGRectGetHeight(tipView.frame)-44, CGRectGetWidth(tipView.frame)/2, 44);
    sureSubmitBtn.titleLabel.font = NormalFontWithSize(16);
    [sureSubmitBtn setTitle:@"确认提交" forState:UIControlStateNormal];
    [sureSubmitBtn setTitleColor:@"#1c74d9".color forState:UIControlStateNormal];
    [sureSubmitBtn addTarget:self action:@selector(sureSubmitBtnOnClick) forControlEvents:UIControlEventTouchUpInside];
    [tipView addSubview:sureSubmitBtn];
}

- (void)backBtnOnClick
{
    [self hideTipView];
}

- (void)sureSubmitBtnOnClick
{
    GFTextField * realName = nil;
    GFTextField * identifiyNum = nil;
    GFTextField * cardID = nil;
    
    if (isFirst)
    {
        for (UIView * view in bgView.subviews)
        {
            if ([view isKindOfClass:[GFTextField class]])
            {
                GFTextField * gfTextField = (GFTextField *)view;
                if (gfTextField.tag == 100)
                {
                    realName = gfTextField;
                }
                else if (gfTextField.tag == 101)
                {
                    identifiyNum = gfTextField;
                }
                else if (gfTextField.tag == 104)
                {
                    cardID = gfTextField;
                }
            }
        }
        
        DrawCashViewController * dcvc = [[DrawCashViewController alloc] init];
        dcvc.real_name = [realName.text copy];
        dcvc.mobile = userInfo.mobile;
        dcvc.idcard = [identifiyNum.text copy];
        dcvc.card_no = [cardID.text copy];
        dcvc.branchBankID = [branchBankID copy];
        [self pushToViewController:dcvc];
    }
    else
    {
        [self requestSubmitCard];
    }
    [self hideTipView];
}

- (void)hideTipView
{
    if (tipView)
    {
        for (UIView * subView in tipView.subviews)
        {
            [subView removeFromSuperview];
        }
        tipView.hidden = YES;
    }
    if (backgroundBtn)
    {
        backgroundBtn.hidden = YES;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string  isEqualToString:@""])
    {
        return YES;
    }
    else
    {
        for (UIView * view in bgView.subviews)
        {
            if ([view isKindOfClass:[GFTextField class]])
            {
                GFTextField * gfTextField = (GFTextField *)view;
                if (!gfTextField.text.length)
                {
                    submitBtn.enabled = NO;
                    [submitBtn setBackgroundColor:KColorHeader];
                    [submitBtn setTintColor:kFontColorA];
                }
                else
                {
                    submitBtn.enabled = YES;
                    [submitBtn setBackgroundColor:kRedColor];
                    [submitBtn setTitleColor:kFontColorA forState:UIControlStateNormal];
                    [submitBtn setBackgroundImage:KBtnSelectNewColorA.image forState:UIControlStateHighlighted];
                    [submitBtn setBackgroundImage:KBtnSelectNewColorA.image forState:UIControlStateSelected];
                    [submitBtn addTarget:self action:@selector(submitBtnClicked:) forControlEvents:UIControlEventTouchUpInside];

                }
            }
        }
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    submitBtn.enabled = NO;
    [submitBtn setBackgroundColor:KColorHeader];
    [submitBtn setTintColor:kFontColorA];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (!isClose)
    {
        if (textField.tag == 100)
        {
            if (textField.text.length < 1 && ![GFStaticData getObjectForKey:kTagUserRealName])
            {
                if (textField.text.length)
                {
                    [self  textFieldResignFirstResponder];
                    
                    [[CHNAlertView defaultAlertView] showContent:@"请输入正确的姓名，方便客服人员给您转账" cancelTitle:nil sureTitle:nil withDelegate:self withType:6];
                }
            }
        }
        if (textField.tag == 101)
        {
            if ([self validateIdentityCard:textField.text]==NO)
            {
                if (textField.text.length)
                {
                    [self textFieldResignFirstResponder];
                    [[CHNAlertView defaultAlertView] showContent:@"请填写与姓名一致的身份证号" cancelTitle:nil sureTitle:nil withDelegate:self withType:6];
                }
            }
        }
        if (textField.tag == 104)
        {
            if (textField.text.length<15 || textField.text.length>19 )
            {
                if (textField.text.length)
                {
                    [self textFieldResignFirstResponder];
                    [[CHNAlertView defaultAlertView] showContent:@"请正确填写银行卡" cancelTitle:nil sureTitle:nil withDelegate:self withType:6];
                }
            }
        }
    }
    return YES;
}

// 判断身份证号的合法
- (BOOL)validateIdentityCard:(NSString *)identityCard
{
    BOOL flag;
    if (identityCard.length <= 0) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^((11|12|13|14|15|21|22|23|31|32|33|34|35|36|37|41|42|43|44|45|46|50|51|52|53|54|61|62|63|64|65|71|81|82|91)\\d{4})((((19|20)(([02468][048])|([13579][26]))0229))|((20[0-9][0-9])|(19[0-9][0-9]))((((0[1-9])|(1[0-2]))((0[1-9])|(1\\d)|(2[0-8])))|((((0[1,3-9])|(1[0-2]))(29|30))|(((0[13578])|(1[02]))31))))((\\d{3}(x|X))|(\\d{4}))$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [identityCardPredicate evaluateWithObject:identityCard];
}

- (void)textFieldResignFirstResponder
{
    for (UIView * view in bgView.subviews)
    {
        if ([view isKindOfClass:[GFTextField class]])
        {
            GFTextField * gfTextField = (GFTextField *)view;
            [gfTextField resignFirstResponder];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [GFStaticData saveObject:nil forKey:KTagBankCard forUser:userInfo.uid];
    [[CHNAlertView defaultAlertView] dismiss];
    
    [super viewWillDisappear:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
