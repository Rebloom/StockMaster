//
//  EarnMoneyViewController.m
//  StockMaster
//
//  Created by 孤星之殇 on 15/4/2.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import "EarnMoneyViewController.h"
#import "UIImage+UIColor.h"
#import "NSString+UIColor.h"
#import "BuyHistoryViewController.h"
#import "DrawCashHistoryViewController.h"
#import "CardViewController.h"
#import "UIImageView+WebCache.h"
#import "Utility.h"
#import "AddCardViewController.h"
#import "GFWebViewController.h"

@interface EarnMoneyViewController ()

@end

@implementation EarnMoneyViewController
@synthesize flag;

- (void)dealloc
{
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}

-(void)requestGetWithDraw
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [GFRequestManager connectWithDelegate:self action:Get_invitation_withdraw  param:paramDic];
}

-(void)requestCash:(NSMutableDictionary*)dic
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:[dic objectForKey:@"bank_account"] forKey:@"bank_account"];
    [paramDic setObject:[dic objectForKey:@"real_name"] forKey:@"real_name"];
    [paramDic setObject:[dic objectForKey:@"bank_name" ] forKey:@"bank_name"];
    [paramDic setObject:moneyStr   forKey:@"withdraw_money"];
    [GFRequestManager connectWithDelegate:self action:Submit_invitation_withdraw param:paramDic];
}

-(void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    
    if ([[requestInfo objectForKey:@"err_code"] integerValue] == 10053)
    {
        AddCardViewController * ACVC = [[AddCardViewController alloc] init];
        if ([[requestInfo objectForKey:@"data"] objectForKey:@"idcard"]) {
            ACVC.isFirst = NO;
        }
        else
        {
            ACVC.isFirst = YES;
        }
        ACVC.modelType = 1; //进行添加
        [GFStaticData saveObject:@"2" forKey:KTagCardBack];
        [[CHNAlertView defaultAlertView] dismiss];
        [self pushToViewController:ACVC];
    }
    else if([[requestInfo objectForKey:@"err_code"] integerValue] == 0)
    {
        ASIFormDataRequest * formDataRequest = (ASIFormDataRequest *)request;
        NSDictionary * dic = [requestInfo objectForKey:@"data"];
        if ([formDataRequest.action isEqualToString:Get_invitation_withdraw])
        {
            [self updateUIWithDic:dic];
        }
        else if ([formDataRequest.action isEqualToString:Submit_invitation_withdraw])
        {
            [self pushToCardFinishViewControllerWithDic:dic];
        }
        else if ([formDataRequest.action isEqualToString:Get_bank_bind_info])
        {
            AddCardViewController * ACVC = [[AddCardViewController alloc] init];
            ACVC.transInfo = [requestInfo objectForKey:@"data"];
            if ([[requestInfo objectForKey:@"data"] objectForKey:@"idcard"])
            {
                ACVC.isFirst = NO;
            }
            else
            {
                ACVC.isFirst = YES;
            }
            ACVC.modelType = 1; //进行添加
            [GFStaticData saveObject:@"2" forKey:KTagCardBack];
            [self pushToViewController:ACVC];
        }
    }
}

- (void)popViewController
{
    [[CHNAlertView defaultAlertView] dismiss];
    if (self.navigationController && self.navigationController.viewControllers.count>1)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)buttonClickedAtIndex:(NSInteger)index
{
    if (index == 0)
    {
        [self popViewController];
    }
}

-(void)requestBankinfo
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [GFRequestManager connectWithDelegate:self action:Get_bank_bind_info param:paramDic];
}

- (void)updateUIWithDic:(NSDictionary *)back
{
    moneyStr = [[back objectForKey:@"withdraw_money"] copy];
    if (back.count > 0)
    {
        withDrawDescLabel.text = [NSString stringWithFormat:@"可提取金额￥%.2f",[[moneyStr description]floatValue]];
        
        bank_infoDic = [[back objectForKey:@"bank_info"] copy];
        if (bank_infoDic.count == 0)
        {
            [self createMiddleView];
        }
        else
        {
            [self createCardView];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //通过赚钱模块直接提现（区别卖股票提现）
    [headerView loadComponentsWithTitle:@"提现"];
    [headerView backButton];
    [headerView createLine];
    [headerView setStatusBarColor: kFontColorA];
    headerView.backgroundColor = kFontColorA;
    
    self.view.backgroundColor = KSelectNewColor;
    
    infoArr = [[NSMutableArray alloc] initWithCapacity:5];
    bank_infoDic = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    [self createTopView];
    
    if (bank_infoDic.count==0)
    {
        [self createMiddleView];
    }
    else
    {
        [self createCardView];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [GFStaticData saveObject:nil forKey:KTagCardInfo];
    
    [super viewWillDisappear:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    if ([GFStaticData getObjectForKey:KTagCardInfo])
    {
        bank_infoDic = [[GFStaticData getObjectForKey:KTagCardInfo] mutableCopy];
    }
    
    
    
    if (bank_infoDic.count>0)
    {
        [self createCardView];
    }
    else
    {
        [self requestGetWithDraw];
    }
    [cardTableView reloadData];
    [MBProgressHUD  hideHUDForView:self.view animated:YES];
}

- (void)createTopView
{
    if (!topView)
    {
        topView = [[UIImageView alloc] init ];
    }
    topView.frame = CGRectMake(0, CGRectGetMaxY(headerView.frame)+10, screenWidth, 105);
    topView.image = kFontColorA.image;
    [self.view addSubview:topView];
    
    if (!withDrawDescLabel)
    {
        withDrawDescLabel = [[UILabel alloc] initWithFrame:CGRectMake(22,10, 250, 85)];
    }
    withDrawDescLabel.backgroundColor = [UIColor clearColor];
    withDrawDescLabel.textColor = kRedColor;
    withDrawDescLabel.textAlignment = NSTextAlignmentLeft;
    withDrawDescLabel.font = NormalFontWithSize(17);
    [topView addSubview:withDrawDescLabel];
}

- (void)createMiddleView
{
    UILabel * cardLb = [[UILabel alloc] initWithFrame:CGRectMake(0,CGRectGetMaxY(topView.frame),  screenWidth, 88)];
    cardLb.backgroundColor = [UIColor clearColor];
    cardLb.textAlignment = NSTextAlignmentCenter;
    cardLb.textColor = kFontColorD;
    cardLb.text = @"尚无银行卡用于提现";
    cardLb.font =NormalFontWithSize(14);
    [self.view addSubview:cardLb];
    
    UIButton * nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(cardLb.frame), screenWidth-40, 44)];
    nextBtn.layer.cornerRadius = 4;
    nextBtn.layer.masksToBounds = YES;
    [nextBtn setTitle:@"添加银行卡" forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(nextBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [nextBtn setBackgroundImage:[KFontNewColorD image] forState:UIControlStateNormal];
    [nextBtn setBackgroundImage:[KBtnSelectNewColorA image ] forState:UIControlStateSelected];
    [nextBtn setBackgroundImage:[KBtnSelectNewColorA image] forState:UIControlStateHighlighted];
    nextBtn.titleLabel.font = NormalFontWithSize(17);
    [self.view addSubview:nextBtn];
}


- (void)createCardView
{
    if (!cardTableView)
    {
        cardTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topView.frame)+10, screenWidth, screenHeight-64) style:UITableViewStylePlain];
        cardTableView.backgroundColor = kBackgroundColor;
        cardTableView.delegate = self;
        cardTableView.dataSource = self;
        cardTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:cardTableView];
    }
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 0.1)];
    cardTableView.tableFooterView = footView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 80)];
    if (indexPath.row==0)
    {
        cell.backgroundColor = kFontColorA;
        UILabel * tempLabel = [[UILabel alloc] init];
        tempLabel.frame = CGRectMake(22, 0, 120, 58);
        tempLabel.font = NormalFontWithSize(17);
        tempLabel.textColor = kFontColorD;
        tempLabel.textAlignment =NSTextAlignmentLeft;
        tempLabel.text = @"提现到银行卡";
        [cell addSubview:tempLabel];
        
        UILabel * nameLb = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth-130, 9,100, 20)];
        
        if (bank_infoDic.count!=0)
        {
            nameLb.text =[bank_infoDic objectForKey:@"bank_name"] ;
        }
        nameLb.textAlignment = NSTextAlignmentRight;
        nameLb.textColor = kFontColorD;
        nameLb.font = NormalFontWithSize(14);
        nameLb.backgroundColor = [UIColor clearColor];
        [cell addSubview:nameLb];
        
        UILabel * cardNumLb = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth-130, CGRectGetMaxY(nameLb.frame), 100, 20)];
        if (bank_infoDic.count!=0)
        {
            NSString * str =[[bank_infoDic objectForKey:@"bank_account"] description];
            cardNumLb.text = [[str substringFromIndex:str.length - 4] copy];
        }
        cardNumLb.textAlignment = NSTextAlignmentRight;
        cardNumLb.textColor =kFontColorD;
        cardNumLb.font = NormalFontWithSize(14);
        cardNumLb.backgroundColor = [UIColor clearColor];
        [cell addSubview:cardNumLb];
        
        UIImageView * rightView = [[UIImageView alloc] initWithFrame:CGRectMake(295, 23, 7, 12)];
        rightView.image = [UIImage imageNamed:@"home_right"];
        rightView.backgroundColor = [UIColor clearColor];
        [cell addSubview:rightView];
    }
    else if (indexPath.row ==1)
    {
        cell.backgroundColor = kBackgroundColor;
        UIButton * cashBtn  = [[UIButton alloc] initWithFrame:CGRectMake(10, 18 ,screenWidth-20, 44)];
        cashBtn.backgroundColor = kBtnBgColor;
        cashBtn.layer.cornerRadius = 5;
        cashBtn.layer.masksToBounds = YES;
        [cashBtn setTitle:@"提 现" forState:UIControlStateNormal];
        [cashBtn addTarget:self action:@selector(cashBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cashBtn setBackgroundImage:[@"#b6494b".color  image]  forState:UIControlStateHighlighted];
        cashBtn.titleLabel.font = NormalFontWithSize(17);
        [cell addSubview:cashBtn];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    CardViewController * MCVC = [[CardViewController alloc] init];
    MCVC.deliverType = 2;
    MCVC.delegate = self;
    [self pushToViewController:MCVC];
}

- (void)sendInfo:(NSMutableDictionary *)dict
{
    bank_infoDic = [dict mutableCopy];
    [cardTableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58;
}

- (void)nextBtnClicked:(UIButton*)sender
{
    [self requestBankinfo];
}

- (void)cashBtnClicked:(UIButton*)sender
{
    if (bank_infoDic.count>0)
    {
        [self requestCash:[bank_infoDic mutableCopy]];
    }
}

- (void)pushToCardFinishViewControllerWithDic:(NSDictionary *)dic
{
    GFWebViewController * GWVC = [[GFWebViewController alloc] init];
    GWVC.title = @"提现";
    GWVC.pageType = WebViewTypePresent;
    GWVC.flag = 1;
    NSString * share_url = [NSString stringWithFormat:@"%@", [dic objectForKey:@"share_url"]];
    NSString * share_url_out = [NSString stringWithFormat:@"%@", [dic objectForKey:@"share_url_out"]];
    GWVC.requestUrl = [NSURL URLWithString:share_url];
    GWVC.task_url = [NSURL URLWithString:share_url_out];
    GWVC.desc = [dic objectForKey:@"share_desc"];
    [self  presentViewController:GWVC animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
