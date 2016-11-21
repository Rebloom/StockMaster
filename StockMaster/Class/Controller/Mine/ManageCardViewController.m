//
//  ManageCardViewController.m
//  StockMaster
//
//  Created by dalikeji on 14-10-9.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "ManageCardViewController.h"
#import "UIImage+UIColor.h"
#import "CardViewController.h"
@interface ManageCardViewController ()

@end

@implementation ManageCardViewController
@synthesize deliverDic;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.backgroundColor = kBackgroundColor;
    }
    return self;
}

-(void)dealloc
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = KSelectNewColor;
    
    [headerView loadComponentsWithTitle:@"管理银行卡"];
    [headerView backButton];
    [headerView createLine];
    headerView.backgroundColor = kFontColorA;
    [headerView setStatusBarColor: kFontColorA];
    
    
    scrollView = [[UIScrollView alloc] init];
    scrollView.frame = CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, screenHeight);
    scrollView.delegate = self;
    scrollView.contentSize = CGSizeMake(screenWidth, 568);
    scrollView. backgroundColor = KSelectNewColor;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:scrollView];
}

- (void)setDeliverDic:(NSMutableDictionary *)_deliverDic
{
    deliverDic = _deliverDic;
    [self createTopUI];
    [self createFootUI];
}

-(void)createTopUI
{
    bgView = [[UIImageView alloc] init];
    bgView.backgroundColor = [UIColor clearColor];
    bgView.userInteractionEnabled = YES;
    [scrollView addSubview:bgView];
    
    
    NSArray * titleArr = @[@"持卡人姓名", @"银行卡号", @"银行卡", @"所属支行", @"身份证号", @"验证手机"];
    
    NSArray * descArr = @[[deliverDic objectForKey:@"real_name"],[Utility departString:[[deliverDic objectForKey:@"bank_account"] description] withType:2],[deliverDic objectForKey:@"bank_name"],[deliverDic objectForKey:@"branch_bank_name"],[Utility departString:[[deliverDic objectForKey:@"idcard"] description]withType:3],[Utility departString:[[deliverDic objectForKey:@"mobile"] description] withType:4]];
    bgView.frame = CGRectMake(0, 0, screenWidth, 60*titleArr.count);
    
    for (int i = 0; i < titleArr.count; i++)
    {
        UIImageView * imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(0, 60*i, screenWidth, 59.5);
        imageView.userInteractionEnabled = YES;
        imageView.backgroundColor = kFontColorA;
        [bgView addSubview:imageView];
        
        UILabel * tempLb = [[UILabel alloc] init];
        tempLb.frame = CGRectMake(20, 60*i+20, 70, 20);
        tempLb.text = [titleArr objectAtIndex:i];
        tempLb.textAlignment = NSTextAlignmentLeft;
        tempLb.textColor = KFontNewColorB;
        tempLb.font = NormalFontWithSize(14);
        [bgView addSubview:tempLb];
        
        GFTextField * textField = [[GFTextField alloc] init];
        textField.userInteractionEnabled = NO;
        textField.font = NormalFontWithSize(15);
        textField.textColor = KFontColorE;
        textField.delegate = self;
        textField.frame = CGRectMake(110, 60*i, screenWidth-150, 59.5);
        textField.placeHolderColor = 1;
        textField.text = [descArr objectAtIndex:i];
        [bgView addSubview:textField];
    }
    
    NSDictionary * dic = [GFStaticData getObjectForKey:kTagBindBankCardDefaultInfo];
    
    changeBtn = [[UIButton alloc] init];
    changeBtn.userInteractionEnabled = YES;
    changeBtn.frame = CGRectMake(screenWidth-80, 60*5, 60, 60);
    changeBtn.titleLabel.font = NormalFontWithSize(15);
    [changeBtn setTitleColor:KFontNewColorD forState:UIControlStateNormal];
    [changeBtn setTitle:dic?[dic objectForKey:@"tips_mobile_text"]:@"换一换" forState:UIControlStateNormal];
    [changeBtn setBackgroundColor:[UIColor clearColor]];
    [changeBtn addTarget:self action:@selector(changeBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:changeBtn];
    changeBtn.hidden = YES;
    if ([[dic objectForKey:@"tips_is_show"] integerValue])
    {
        changeBtn.hidden = NO;
    }
}

- (void)alertBtnClicked:(id)sender
{
    NSDictionary * dic = [GFStaticData getObjectForKey:kTagBindBankCardDefaultInfo];
    if (dic)
    {
        [[CHNAlertView defaultAlertView] showContent:[[dic objectForKey:@"tips_branch"] description] cancelTitle:nil sureTitle:nil withDelegate:self withType:6];
    }
}

-(void)createFootUI
{
    UILabel * contentLabel = [[UILabel alloc] init];
    contentLabel.textAlignment = NSTextAlignmentCenter;
    contentLabel.textColor = KFontNewColorB;
    contentLabel.font = NormalFontWithSize(13);
    [scrollView addSubview:contentLabel];
    
    submitBtn = [[UIButton alloc] init ];
    submitBtn.tintColor = kFontColorA;
    submitBtn.layer.cornerRadius = 5;
    submitBtn.layer.masksToBounds = YES;
    submitBtn.titleLabel.font = NormalFontWithSize(15);
    [submitBtn setTitle:@"删除银行卡" forState:UIControlStateNormal];
    [submitBtn setBackgroundImage:[KFontNewColorD image] forState:UIControlStateNormal];
    [submitBtn setBackgroundImage:[KBtnSelectNewColorA image ] forState:UIControlStateSelected];
    [submitBtn setBackgroundImage:[KBtnSelectNewColorA image] forState:UIControlStateHighlighted];
    [submitBtn addTarget:self action:@selector(submitBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:submitBtn];
    
    if ([[deliverDic objectForKey:@"bank_card_check_status"] integerValue] == 0)
    {
        contentLabel.frame = CGRectMake(20, CGRectGetMaxY(bgView.frame)+10, screenWidth-40, 20);
        contentLabel.text = [deliverDic objectForKey:@"bank_card_bind_tips"];
        
        UILabel * tip1 = [[UILabel alloc] init];
        tip1.textAlignment = NSTextAlignmentCenter;
        tip1.textColor = kRedColor;
        tip1.frame = CGRectMake(0, CGRectGetMaxY(contentLabel.frame), screenWidth, 20);
        tip1.text = [deliverDic objectForKey:@"bank_card_bind_error_tips"];
        tip1.font = NormalFontWithSize(13);
        [scrollView addSubview:tip1];
        
        submitBtn.frame = CGRectMake(20, CGRectGetMaxY(tip1.frame)+10, screenWidth-40, 44);
    }
    else
    {
        contentLabel.frame = CGRectMake(20, CGRectGetMaxY(bgView.frame), screenWidth-40, 53);
        contentLabel.text = [deliverDic objectForKey:@"bank_card_bind_tips"];
        submitBtn.frame = CGRectMake(20, CGRectGetMaxY(contentLabel.frame), screenWidth-40, 44);
    }
    
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
}


-(void)changeBtnOnClick:(UIButton *)sender
{
    NSDictionary * dic = [GFStaticData getObjectForKey:kTagBindBankCardDefaultInfo];
    if (dic)
    {
        if ([[dic objectForKey:@"tips_is_open_call"] integerValue])
        {
            NSString * contentString = [NSString stringWithFormat:@"%@,%@",dic?[dic objectForKey:@"tips_mobile_alert"]:@"为了您账户安全，修改验证手机号\n请联系客服",dic?[dic objectForKey:@"tips_telphone"]:@"400-666-5666"];
            [[CHNAlertView defaultAlertView] showContent:contentString cancelTitle:@"取消" sureTitle:@"呼叫" withDelegate:self withType:2];
        }
        else
        {
            [[CHNAlertView defaultAlertView] showContent:dic?[dic objectForKey:@"tips_mobile_alert"]:@"为了您账户安全，修改验证手机号\n请联系客服" cancelTitle:nil sureTitle:nil withDelegate:self withType:6];
        }
    }
}

- (void)buttonClickedAtIndex:(NSInteger)index
{
    if (index == 1)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://4006665666"]];
    }
}

-(void)submitBtnClicked:(UIButton *)sender
{
    [self requestDeleteCard];
}

-(void)requestDeleteCard
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:[deliverDic objectForKey:@"card_id"] forKey:@"card_id"];
    [GFRequestManager connectWithDelegate:self action:Delete_user_bank_card param:paramDic];
}

-(void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    
    ASIFormDataRequest * formDataRequest = (ASIFormDataRequest *)request;
    if([formDataRequest.action isEqualToString:Delete_user_bank_card])
    {
        for(BasicViewController * bvc in self.navigationController.viewControllers)
        {
            if ([bvc isKindOfClass:[CardViewController class]])
            {
                [self.navigationController popToViewController:bvc animated:YES];
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
