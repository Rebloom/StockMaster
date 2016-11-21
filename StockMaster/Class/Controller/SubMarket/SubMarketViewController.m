//
//  SubMarketViewController.m
//  StockMaster
//
//  Created by dalikeji on 14-9-22.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "SubMarketViewController.h"
#import "UIImage+UIColor.h"
#import "NSString+UIColor.h"
#import "FirstViewController.h"
@interface SubMarketViewController ()

@end

@implementation SubMarketViewController

@synthesize flag;
@synthesize stock;
@synthesize fromFirst;

-(void)dealloc
{
    RELEASE_OBJ(containerView);
    RELEASE_OBJ(nameLabel);
    RELEASE_OBJ(priceDetailLabel);
    RELEASE_OBJ(numDetailLabel);
    RELEASE_OBJ(stockIv);
    RELEASE_OBJ(priceLabel);
    RELEASE_OBJ(buyLabel) ;
    RELEASE_OBJ(sellLabel);
    RELEASE_OBJ(sellNumLabel) ;
    RELEASE_OBJ(contentTv);
    RELEASE_OBJ(downView) ;
    RELEASE_OBJ(commitBtn) ;
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createMarket];
    if (flag == 1)
    {
        [headerView loadComponentsWithTitle:@"买入"];
    }
    else if (flag == 2)
    {
        [headerView loadComponentsWithTitle:@"卖出"];
    }
    [headerView backButton];
    [headerView refreshButton];

    //添加手势，用于回收textfield键盘
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView = NO;
    
    [self.view addGestureRecognizer:tapGr];
    
    if (flag == 1)
    {
        [self requestBuyStock];
    }
    else if(flag == 2)
    {
        [self requestSellDetail];
    }
}

- (void)buttonClicked:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    if (btn.tag == 2)
    {
        [headerView.actView startAnimating];
        headerView.refreshImage.hidden = YES;
        if (flag == 1)
        {
            [self requestBuyStock];
        }
        else if (flag == 2)
        {
            [self requestSellDetail];
        }
    }
    [super buttonClicked:sender];
}

#pragma mark 买入（卖出）数据请求
-(void)requestMarketData
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:stock.ID forKey:@"stock_code"];
    [paramDic setObject:stock.stock_exchange forKey:@"stock_exchange"];
    [paramDic setObject:nameLabel.text forKey:@"stock_name"];
    [paramDic setObject:tradePrice forKey:@"trade_price"];
    [paramDic setObject:markeyStr forKey:@"amount"];
    if (flag==1)
    {
        [GFRequestManager connectWithDelegate:self action:Submit_buy_stock_info param:paramDic];
    }
    else if (flag==2)
    {
        [GFRequestManager connectWithDelegate:self action:Submit_sell_stock_info param:paramDic];
    }
}


#pragma mark 请求买入数据
-(void)requestBuyStock
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:stock.ID forKey:@"stock_code"];
    [paramDic setObject:stock.stock_exchange forKey:@"stock_exchange"];
    [GFRequestManager connectWithDelegate:self action:Get_buy_stock_info param:paramDic];
}

#pragma mark 请求卖出详请数据
-(void)requestSellDetail
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:stock.ID forKey:@"stock_code"];
    [paramDic setObject:stock.stock_exchange forKey:@"stock_exchange"];
    [GFRequestManager connectWithDelegate:self action:Get_sell_stock_info param:paramDic];
}

-(void)requestFinished:(ASIHTTPRequest *)request
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [headerView.actView stopAnimating];
    headerView.refreshImage.hidden = NO;
    
    NSDictionary * back = [request.responseString objectFromJSONString];
    NSInteger errCode = [[back objectForKey:@"err_code"] integerValue];
    
    if (errCode == 534)
    {
        for (BasicViewController * bvc in self.navigationController.viewControllers)
        {
            if ([bvc isKindOfClass:[WithDrawListViewController class]] && [GFStaticData getObjectForKey:kTagFromWithDraw])
            {
                [GFStaticData saveObject:@"YES" forKey:kTagNeedToAlert];
                double delayInSeconds = 1.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                               {
                                   [self.navigationController popToViewController:bvc animated:YES];
                               });
            }
            else if ([bvc isKindOfClass:[FirstViewController class]])
            {
                [GFStaticData saveObject:@"YES" forKey:kTagNeedToAlert];
                double delayInSeconds = 1.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                               {
                                   [self.navigationController popToViewController:bvc animated:YES];
                               });
            }
        }
        return;
    }
    
    if ([super judgeBackInfo:back])
    {
        commitBtn.userInteractionEnabled = YES;
        ASIFormDataRequest * formDataRequest = (ASIFormDataRequest *)request;
        if ([formDataRequest.action isEqualToString:Get_sell_stock_info]||[formDataRequest.action isEqualToString:Get_buy_stock_info])
        {
            if ([back objectForKey:@"data"])
            {
                NSDictionary * dic = [back objectForKey:@"data"];
                commitBtn.enabled = YES;
                nameLabel.text = [dic objectForKey:@"stock_name"];
                numDetailLabel.text = [NSString stringWithFormat:@"股票代码: %@" ,[dic objectForKey:@"stock_code"]];
                priceLabel.text = [NSString stringWithFormat:@"可用资金: %.2f",[[dic objectForKey:@"usable_money"] floatValue]];
                sellNumLabel.text = [NSString stringWithFormat:@"当前价格: %.2f",[[dic objectForKey:@"current_price"] floatValue]];
                NSString * str = [dic objectForKey:@"current_price"];
                tradePrice = [str copy];
                
                if (flag == 1)
                {
                    buyLabel.hidden = NO;
                    sellLabel.hidden = YES;
                }
                else if (flag == 2)
                {
                    buyLabel.hidden = YES;
                    sellLabel.hidden = NO;
                }
                
                priceDetailLabel.text =[[dic objectForKey:@"usable_amount"]description] ;
                priceDetailLabel.frame = CGRectMake(74, 107, 64,17);
            }
        }
        else if ([formDataRequest.action isEqualToString:Submit_sell_stock_info]||[formDataRequest.action isEqualToString:Submit_buy_stock_info])
        {
            if ([[back objectForKey:@"message"] isEqualToString:@"Success"])
            {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                if (flag == 1)
                {
                    [[TKAlertCenter defaultCenter] postAlertWithMessage:@"购买成功" withType:ALERTTYPEERROR];
                }
                else if(flag == 2)
                {
                    [[TKAlertCenter defaultCenter] postAlertWithMessage:@"卖出成功" withType:ALERTTYPEERROR];
                }
                double delayInSeconds = 1.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                               {
                                   if (fromFirst)
                                   {
                                       [self requestGetWithDraw];
                                   }
                                   else
                                   {
                                       [self back];
                                   }
                               });
            }
        }
        else if ([formDataRequest.action isEqualToString:Get_withdraw_home])
        {
            if ([self judgeBackInfo:back])
            {
                WithDrawCashViewController * WDCVC = [[WithDrawCashViewController alloc] init];
                [self pushToViewController:WDCVC];
                [WDCVC release];
            }
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [headerView.actView stopAnimating];
    headerView.refreshImage.hidden = NO;
    [[TKAlertCenter defaultCenter] postAlertWithMessage:@"网络请求超时" withType:ALERTTYPEERROR];
}

-(void)requestGetWithDraw
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [GFRequestManager connectWithDelegate:self action:Get_withdraw_home param:paramDic];
}


#pragma mark 买入和卖出详情页
-(void)createMarket{
    
    if (!containerView) {
        containerView =[[UIView alloc]init];
    }
    containerView.frame=CGRectMake(0, CGRectGetMaxY(headerView.frame), 320, 600);
    containerView.userInteractionEnabled =YES;
    containerView.backgroundColor =kBackgroundColor;
    containerView.hidden = NO;
    [self.view addSubview:containerView];
    
    if (!stockIv) {
        stockIv = [[UIImageView alloc] init];
    }
    stockIv.frame = CGRectMake(0, 0, 320, 67);
    stockIv.userInteractionEnabled = YES;
    [stockIv setImage:[UIImage imageNamed:@"bj_gupiao.png"]];
    [containerView addSubview:stockIv];
    
    //股票名称
    if (!nameLabel) {
        nameLabel = [[UILabel alloc] init];
    }
    nameLabel.frame = CGRectMake(10, 10, 90, 20);
    nameLabel.numberOfLines =0;
    nameLabel.font=BoldFontWithSize(17);
    nameLabel.textAlignment=NSTextAlignmentLeft;
    nameLabel.textColor =kFontColorA;
    [nameLabel setBackgroundColor:[UIColor clearColor]];
    [stockIv addSubview:nameLabel];
    
    //600234
    if (!numDetailLabel) {
        numDetailLabel = [[UILabel alloc] init];
    }
    numDetailLabel.frame = CGRectMake(10, 25, 230, 30);
    numDetailLabel.numberOfLines =0;
    numDetailLabel.textAlignment=NSTextAlignmentLeft;
    numDetailLabel.font=BoldFontWithSize(12);
    numDetailLabel.textColor = @"#ffca08".color;
    [numDetailLabel setBackgroundColor:[UIColor clearColor]];
    [stockIv addSubview:numDetailLabel];
    
    //可用资金
    if (!priceLabel) {
        priceLabel = [[UILabel alloc] init];
    }
    priceLabel.frame = CGRectMake(10, CGRectGetMaxY(stockIv.frame), 180, 40);
    priceLabel.numberOfLines =0;
    priceLabel.font=NormalFontWithSize(14);
    priceLabel.textAlignment=NSTextAlignmentLeft;
    priceLabel.textColor = @"#717171".color;
    [priceLabel setBackgroundColor:[UIColor clearColor]];
    [containerView addSubview:priceLabel];
    
    if (!buyLabel)
    {
        buyLabel = [[UILabel alloc] init];
        buyLabel.hidden = YES;
    }
    buyLabel.frame = CGRectMake(10, 107, 180, 40);
    buyLabel.text = @"可买数量: ";
    buyLabel.font = NormalFontWithSize(14);
    buyLabel.textColor = @"#717171".color;
    [buyLabel sizeToFit];
    
    [containerView addSubview:buyLabel];
    
    if (!sellLabel)
    {
        sellLabel = [[UILabel alloc] init];
        sellLabel.hidden = YES;
    }
    sellLabel.frame = CGRectMake(10, 107, 180, 40);
    sellLabel.text = @"可卖数量: ";
    sellLabel.font = NormalFontWithSize(14);
    sellLabel.textColor = @"#717171".color;
    [sellLabel sizeToFit];
    
    [containerView addSubview:sellLabel];
    
    //可（买）卖数量
    if(!priceDetailLabel){
        priceDetailLabel = [[UILabel alloc] init];
    }
    priceDetailLabel.frame = CGRectMake(74, 107, 64,17);
    priceDetailLabel.numberOfLines = 1;
    priceDetailLabel.font = NormalFontWithSize(14);
    priceDetailLabel.textAlignment = NSTextAlignmentLeft;
    priceDetailLabel.textColor = @"#717171".color;
    [priceDetailLabel setBackgroundColor:[UIColor clearColor]];
    [containerView addSubview:priceDetailLabel];
    
    //当前价格
    if (!sellNumLabel) {
        sellNumLabel = [[UILabel alloc] init];
    }
    sellNumLabel.frame = CGRectMake(10, CGRectGetMaxY(priceDetailLabel.frame), 180, 40);
    sellNumLabel.numberOfLines =0;
    sellNumLabel.font=NormalFontWithSize(14);
    
    sellNumLabel.textAlignment=NSTextAlignmentLeft;
    sellNumLabel.textColor =@"#717171".color;
    [sellNumLabel setBackgroundColor:[UIColor clearColor]];
    [containerView addSubview:sellNumLabel];
    
    //数量
    if (!contentTv) {
        contentTv = [[GFTextField alloc] init];
    }
    contentTv.frame = CGRectMake(15, CGRectGetMaxY(sellNumLabel.frame), 290, 37);
    contentTv.placeHolderColor = 1;
    contentTv.delegate = self;
    contentTv.placeholder = @"请输入交易数量";
    contentTv.font = NormalFontWithSize(14);
    contentTv.keyboardType = UIKeyboardTypeNumberPad;
    contentTv.textColor = kTitleColorA;
    contentTv.delegate = self;
    [containerView addSubview:contentTv];
    
    if (!downView) {
        downView = [[UIImageView alloc] init];
    }
    downView.frame = CGRectMake(10, CGRectGetMaxY(contentTv.frame), 300, 3);
    downView.image = [UIImage imageNamed:@"input_shuru.png"];
    [containerView addSubview:downView];
    
    //卖出（买入）按钮
    commitBtn = [[UIButton alloc] init];
    commitBtn.frame = CGRectMake(10, CGRectGetMaxY(downView.frame)+20, 300, 44);
    commitBtn.hidden = NO;
    commitBtn.enabled = NO;
    [commitBtn addTarget:self action:@selector(commitOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [commitBtn setBackgroundImage:[@"#d3d3d3".color image] forState:UIControlStateDisabled];
    [commitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    commitBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [commitBtn setBackgroundColor:kBtnBgColor];
    [containerView addSubview:commitBtn];
    
    if (flag==1) {
        [commitBtn setTitle:@"买入" forState:UIControlStateNormal];
        [commitBtn setBackgroundImage:[@"#b6494b".color  image]  forState:UIControlStateHighlighted];
        
    }else if (flag==2){
        [commitBtn setTitle:@"卖出" forState:UIControlStateNormal];
        [commitBtn setBackgroundImage:[@"#b6494b".color  image]  forState:UIControlStateHighlighted];
    }
}

#pragma mark  买入（卖出）提交
-(void)commitOnClick:(UIButton*)sender
{
    if (contentTv.text.length)
    {
        if([contentTv.text intValue]>0)
        {
            
            markeyStr=contentTv.text ;
            [self requestMarketData];
            contentTv.text =@"";
        }
        else
        {
            [[TKAlertCenter defaultCenter] postAlertWithMessage:@"请输入非0的正整数" withType:ALERTTYPEERROR];
        }
    }
    else
    {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:@"请输入买卖股票的数量" withType:ALERTTYPEERROR];
    }
}

#pragma mark ---TextField 收键盘

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (!iPhone5)
    {
        self.view.frame = CGRectMake(0, -60, 320, self.view.frame.size.height);
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (!iPhone5)
    {
        self.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField==contentTv){
        [contentTv resignFirstResponder];
    }
    return YES;
}

#pragma mark --- 点击空白处收键盘
-(void)viewTapped:(UITapGestureRecognizer*)tapGr
{
    [contentTv resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
