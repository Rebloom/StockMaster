//
//  WithDrawCashViewController.m
//  StockMaster
//
//  Created by Rebloom on 14-7-29.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "WithDrawCashViewController.h"
#import "UIImage+UIColor.h"
#import "NSString+UIColor.h"
#import "BuyHistoryViewController.h"
#import "DrawCashHistoryViewController.h"
#import "CardViewController.h"
#import "UIImageView+WebCache.h"
#import "Utility.h"
#import "AddCardViewController.h"
#import "GFWebViewController.h"

@interface WithDrawCashViewController ()

@end

@implementation WithDrawCashViewController
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
    [GFRequestManager connectWithDelegate:self action:Get_withdraw_home param:paramDic];
}

-(void)requestCash:(NSMutableDictionary*)dic
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:[dic objectForKey:@"bank_account"] forKey:@"bank_account"];
    [paramDic setObject:[dic objectForKey:@"real_name"] forKey:@"real_name"];
    [paramDic setObject:[dic objectForKey:@"bank_name" ] forKey:@"bank_name"];
    [paramDic setObject:moneyStr   forKey:@"withdraw_money"];
    [GFRequestManager connectWithDelegate:self action:Submit_withdraw_order param:paramDic];
    
    // 诸葛统计（用户提现）
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"收款户名"] = [dic objectForKey:@"real_name"];
    dict[@"银行名称"] = [dic objectForKey:@"bank_name"];
    dict[@"银行卡号"] = [dic objectForKey:@"bank_account"];
    dict[@"提现金额"] = moneyStr;
    [[Zhuge sharedInstance] track:@"用户提现" properties:dict];
}

-(void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    
    if ([[requestInfo objectForKey:@"data"] isKindOfClass:[NSDictionary class]])
    {
        if ([[[requestInfo objectForKey:@"data"] objectForKey:@"errno"] integerValue] == 10060)
        {
            NSDictionary * dic = [requestInfo objectForKey:@"data"];
            NSString * desc1 = [[dic objectForKey:@"balance"] description];
            [[CHNAlertView defaultAlertView] initWithTitle:desc1 withDelegate:self];
            return;
        }
    }
    
    if ([[requestInfo objectForKey:@"err_code"] integerValue] == 10053)
    {
        AddCardViewController * ACVC = [[AddCardViewController alloc] init];
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
    else
    {
        ASIFormDataRequest * formDataRequest = (ASIFormDataRequest *)request;
        NSDictionary * dic = [requestInfo objectForKey:@"data"];
        if ([formDataRequest.action isEqualToString:Get_withdraw_home])
        {
            [self updateUIWithDic:dic];
        }
        else if ([formDataRequest.action isEqualToString:Submit_withdraw_order])
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

- (void)buttonClickedAtIndex:(NSInteger)index
{
    if (index == 0)
    {
        [self back];
    }
    else if (index == 1)
    {
        WithDrawSellViewController * WDSVC = [[WithDrawSellViewController alloc] init];
        [self pushToViewController:WDSVC];
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
        withDrawDescLabel.text = [NSString stringWithFormat:@"可提取金额￥%.2f",[[[back objectForKey:@"withdraw_money"] description]floatValue]];
        ruleLb.text =[[back objectForKey:@"withdraw_hint"] description];
        bank_infoDic = [[back objectForKey:@"bank_info"] copy];
        if (bank_infoDic.count == 0) {
            [self createMiddleView];
        }else{
            [self createCardView];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //通过买卖股票提现（区别去做赚钱任务提现）
    [headerView loadComponentsWithTitle:@"提现"];
    [headerView backButton];
    [headerView createLine];
    [headerView setStatusBarColor: kFontColorA];
    headerView.backgroundColor = kFontColorA;
    
    self.view.backgroundColor = KSelectNewColor;
    
    infoArr = [[NSMutableArray alloc] initWithCapacity:5];
    bank_infoDic = [[NSMutableDictionary alloc] initWithCapacity:10];
    [self createTopView];
    if (bank_infoDic.count==0) {
        [self createMiddleView];
    }else{
        [self createCardView];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if (cardTableView)
    {
        [cardTableView reloadData];
    }
    if (bank_infoDic.count>0)
    {
        [cardTableView reloadData];
    }
    else
    {
        [self requestGetWithDraw];
    }
}

- (void)createTopView
{
    if (!topView) {
        topView = [[UIImageView alloc] init ];
    }
    topView.frame = CGRectMake(0, CGRectGetMaxY(headerView.frame)+10, screenWidth, 105);
    topView.image = kFontColorA.image;
    [self.view addSubview:topView];
    
    if (!withDrawDescLabel)
    {
        withDrawDescLabel = [[UILabel alloc] initWithFrame:CGRectMake(22,10, 200, 50)];
    }
    withDrawDescLabel.backgroundColor = [UIColor clearColor];
    withDrawDescLabel.textColor = kRedColor;
    withDrawDescLabel.textAlignment = NSTextAlignmentLeft;
    withDrawDescLabel.font = NormalFontWithSize(17);
    [topView addSubview:withDrawDescLabel];
    
    if (!ruleLb)
    {
        ruleLb = [[UILabel alloc] initWithFrame:CGRectMake(22, CGRectGetMaxY(withDrawDescLabel.frame)-10, screenWidth-36, 50)];
    }
    ruleLb.backgroundColor = [UIColor clearColor];
    ruleLb.textColor = KFontColorE;
    ruleLb.textAlignment = NSTextAlignmentLeft;
    ruleLb.font = NormalFontWithSize(14);
    ruleLb.numberOfLines = 0;
    [topView addSubview:ruleLb];
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
    }
    cardTableView.backgroundColor = kBackgroundColor;
    cardTableView.delegate = self;
    cardTableView.dataSource = self;
    cardTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:cardTableView];
    
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
    if (indexPath.row==0) {
        cell.backgroundColor = kFontColorA;
        UILabel * tempLabel = [[UILabel alloc] init];
        tempLabel.frame = CGRectMake(22, 0, 120, 58);
        tempLabel.font = NormalFontWithSize(17);
        tempLabel.textColor = kFontColorD;
        tempLabel.textAlignment =NSTextAlignmentLeft;
        tempLabel.text = @"提现到银行卡";
        [cell addSubview:tempLabel];
        
        UILabel * nameLb = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth-130, 9,100, 20)];
        if (bank_infoDic.count!=0) {
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
        
        UIImageView * rightView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-25, 23, 7, 12)];
        rightView.image = [UIImage imageNamed:@"home_right"];
        rightView.backgroundColor = [UIColor clearColor];
        [cell addSubview:rightView];
    }else if (indexPath.row ==1){
        cell.backgroundColor = kBackgroundColor;
        UIButton * cashBtn  = [[UIButton alloc] initWithFrame:CGRectMake(20, 18 ,screenWidth-40, 44)];
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
    NSString * share_url = [NSString stringWithFormat:@"%@", [dic objectForKey:@"share_url"]];
    NSString * share_url_out = [NSString stringWithFormat:@"%@", [dic objectForKey:@"share_url_out"]];
    GWVC.requestUrl = [NSURL URLWithString:share_url];
    GWVC.task_url = [NSURL URLWithString:share_url_out];
    GWVC.desc = [dic objectForKey:@"share_desc"];
    GWVC.flag = 1;
//    [self  presentViewController:GWVC animated:YES completion:nil];
    [self subPushToViewController:GWVC];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
