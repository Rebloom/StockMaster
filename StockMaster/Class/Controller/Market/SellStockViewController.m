//
//  SellStockViewController.m
//  StockMaster
//
//  Created by Rebloom on 14-10-13.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "SellStockViewController.h"


@interface SellStockViewController ()

@end

@implementation SellStockViewController
@synthesize stockInfo;

#pragma mark - View Load
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = KSelectNewColor;
    canChangeInput = YES;
    
    [headerView loadComponentsWithTitle:@"卖出"];
    [headerView setStatusBarColor:KColorHeader];
    [headerView refreshButton];
    headerView.backgroundColor = kFontColorA;
    [headerView backButton];
    headerView.refreshImage.image = [UIImage imageNamed:@"icon_shuaxin_default"];
    [headerView createLine];
    
    stockView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, 92)];
    stockView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:stockView];
    
    emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, 92)];
    emptyView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:emptyView];
    
    emptyTip = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, screenWidth-10, 30)];
    emptyTip.numberOfLines = 2;
    emptyTip.textAlignment = NSTextAlignmentCenter;
    emptyTip.backgroundColor = [UIColor clearColor];
    emptyTip.textColor = KFontNewColorB;
    emptyTip.font = NormalFontWithSize(13);
    [emptyView addSubview:emptyTip];
    
    UIView * line4 = [[UIView alloc] initWithFrame:CGRectMake(0, 20, screenWidth, .5)];
    line4.backgroundColor = KColorHeader;
    [stockView addSubview:line4];
    
    UIView * line5 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(line4.frame)+52, screenWidth, .5)];
    line5.backgroundColor = KColorHeader;
    [stockView addSubview:line5];
    
    UIView * mLine2 = [[UIView alloc] initWithFrame:CGRectMake(screenWidth/2-0.5, CGRectGetMaxY(line4.frame)+10, .5, 32)];
    mLine2.backgroundColor = KColorHeader;
    [stockView addSubview:mLine2];
    
    stockName = [[UILabel alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(line4.frame)+10, screenWidth/2-10, 15)];
    stockName.textAlignment = NSTextAlignmentCenter;
    stockName.backgroundColor = [UIColor clearColor];
    stockName.textColor = KFontNewColorA;
    stockName.font = NormalFontWithSize(15);
    stockName.text = stockInfo.name;
    [stockView addSubview:stockName];
    
    stockId = [[UILabel alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(stockName.frame)+5, screenWidth/2-10, 10)];
    stockId.textAlignment = NSTextAlignmentCenter;
    stockId.backgroundColor = [UIColor clearColor];
    stockId.textColor = KFontNewColorB;
    stockId.font = NormalFontWithSize(10);
    stockId.text = stockInfo.code;
    [stockView addSubview:stockId];
    
    price = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/2+5, CGRectGetMaxY(line4.frame)+10, screenWidth/2-10, 15)];
    price.textAlignment = NSTextAlignmentCenter;
    price.backgroundColor = [UIColor clearColor];
    price.textColor = KFontNewColorA;
    price.font = NormalFontWithSize(15);
    [stockView addSubview:price];
    
    UILabel * priceDesc = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/2+5, CGRectGetMaxY(stockName.frame)+5, screenWidth/2-10, 10)];
    priceDesc.textAlignment = NSTextAlignmentCenter;
    priceDesc.backgroundColor = [UIColor clearColor];
    priceDesc.textColor = KFontNewColorB;
    priceDesc.font = NormalFontWithSize(10);
    priceDesc.text = @"现价";
    [stockView addSubview:priceDesc];
    
    numberView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(stockView.frame), screenWidth, 98)];
    numberView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:numberView];
    
    UIView * line6 = [[UIView alloc] initWithFrame:CGRectMake(20, 0, screenWidth-40, .5)];
    line6.backgroundColor = KColorHeader;
    [numberView addSubview:line6];
    
    UIView * line7 = [[UIView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(line6.frame)+45, screenWidth-40, .5)];
    line7.backgroundColor = KColorHeader;
    [numberView addSubview:line7];
    
    minusBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(line6.frame), 57, 45)];
    [minusBtn setBackgroundImage:[UIImage imageNamed:@"icon_jian"] forState:UIControlStateNormal];
    [minusBtn setBackgroundImage:[UIImage imageNamed:@"icon_jian2"] forState:UIControlStateDisabled];
    [minusBtn addTarget:self action:@selector(minusBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [numberView addSubview:minusBtn];
    
    sellNum = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(minusBtn.frame), CGRectGetMaxY(line6.frame), screenWidth-154, 45)];
    sellNum.textAlignment = NSTextAlignmentCenter;
    sellNum.backgroundColor = KSelectNewColor;
    sellNum.textColor = KFontNewColorA;
    [numberView addSubview:sellNum];
    
    addBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(sellNum.frame), CGRectGetMaxY(line6.frame), 57, 45)];
    [addBtn setBackgroundImage:[UIImage imageNamed:@"icon_jia"] forState:UIControlStateNormal];
    [addBtn setBackgroundImage:[UIImage imageNamed:@"icon_jia2"] forState:UIControlStateDisabled];
    [addBtn addTarget:self action:@selector(addBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [numberView addSubview:addBtn];
    
    sellHalfNum = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(line7.frame)+20, screenWidth/2-40, 13)];
    sellHalfNum.textAlignment = NSTextAlignmentCenter;
    sellHalfNum.backgroundColor = [UIColor clearColor];
    sellHalfNum.textColor = KFontNewColorB;
    sellHalfNum.font = NormalFontWithSize(13);
    [numberView addSubview:sellHalfNum];
    
    UIButton * buyHalfBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(line7.frame), screenWidth/2-40, 53)];
    buyHalfBtn.tag = 1;
    [buyHalfBtn addTarget:self action:@selector(buySomeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [numberView addSubview:buyHalfBtn];
    
    UIView * mLine3 = [[UIView alloc] initWithFrame:CGRectMake(screenWidth/2-0.5, CGRectGetMaxY(line7.frame)+20, .5, 13)];
    mLine3.backgroundColor = KColorHeader;
    [numberView addSubview:mLine3];
    
    sellAllNum = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/2+20, CGRectGetMaxY(line7.frame)+20, screenWidth/2-40, 13)];
    sellAllNum.textAlignment = NSTextAlignmentCenter;
    sellAllNum.backgroundColor = [UIColor clearColor];
    sellAllNum.textColor = KFontNewColorB;
    sellAllNum.font = NormalFontWithSize(13);
    [numberView addSubview:sellAllNum];
    
    UIButton * buyAllBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth/2+20, CGRectGetMaxY(line7.frame), screenWidth/2-40, 53)];
    buyAllBtn.tag = 2;
    [buyAllBtn addTarget:self action:@selector(buySomeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [numberView addSubview:buyAllBtn];
    
    bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(numberView.frame), screenWidth, 220)];
    [self.view addSubview:bottomView];
    
    sellBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, screenWidth-40, 45)];
    [sellBtn setTitle:@"卖出" forState:UIControlStateNormal];
    [sellBtn setTitle:@"卖出" forState:UIControlStateSelected];
    sellBtn.layer.cornerRadius = 4;
    sellBtn.layer.masksToBounds = YES;
    [sellBtn addTarget:self action:@selector(sellBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [sellBtn setBackgroundImage:[kRedColor image] forState:UIControlStateNormal];
    [sellBtn setBackgroundImage:[@"#cdd1d6".color image] forState:UIControlStateSelected];
    [sellBtn setTitleColor:kFontColorA forState:UIControlStateNormal];
    [sellBtn setTitleColor:KFontNewColorB forState:UIControlStateSelected];
    [bottomView addSubview:sellBtn];
    
    inputNum = [[GFTextField alloc] initWithFrame:sellNum.frame];
    inputNum.keyboardType = UIKeyboardTypeNumberPad;
    inputNum.delegate = self;
    inputNum.textAlignment = NSTextAlignmentCenter;
    [numberView addSubview:inputNum];
    
    // 通行证提示标签
    expireLable = [[UILabel alloc] init];
    expireLable.frame = CGRectMake(0, CGRectGetMaxY(sellBtn.frame)+3, screenWidth, 20);
    expireLable.backgroundColor = [UIColor clearColor];
    expireLable.textColor = KFontNewColorB;
    expireLable.font = NormalFontWithSize(14);
    expireLable.textAlignment = NSTextAlignmentCenter;
    [bottomView addSubview:expireLable];
    if (self.holdType == StockHoldTypeLong) {
        expireLable.hidden = YES;
    }
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    [self startAutoRequestStockInfo];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [sellTimer invalidate];
    [super viewWillDisappear:YES];
}

//显示没有结果
- (void)showNoResult
{
    stockView.hidden = YES;
    emptyView.hidden = NO;
    emptyView.frame = CGRectMake(0, CGRectGetMaxY(headerView.frame)+20, screenWidth, 92);
    emptyTip.text = @"暂时搜索不到您输入的股票代码哟~";
    numberView.hidden = YES;
    bottomView.hidden = YES;
}

//显示提示信息
- (void)showTip
{
    stockView.hidden = NO;
    bottomView.hidden = YES;
    numberView.hidden = YES;
    emptyView.hidden = NO;
    emptyView.frame = CGRectMake(0, CGRectGetMaxY(stockView.frame)+20, screenWidth, 92);
}

//加载股票交易数据
- (void)reloadStockInfo:(NSDictionary *)dic
{
    if ([[dic objectForKey:@"is_tradable"] integerValue] == 0)
    {
        [sellTimer pauseTimer];
    }
    
    allNumber = [CHECKDATA(@"sellable_amount") integerValue];
    halfNumber = [CHECKDATA(@"half_sellable_amount") integerValue];
    sellAllNum.text = [NSString stringWithFormat:@"卖全部（%@）",CHECKDATA(@"sellable_amount")];
    sellHalfNum.text = [NSString stringWithFormat:@"卖一半（%@）",CHECKDATA(@"half_sellable_amount")];
    stockName.text = CHECKDATA(@"stock_name");
    stockId.text = CHECKDATA(@"stock_code");
    
    NSString * str1 = CHECKDATA(@"current_price");
    NSString * str2 = @" ";
    NSString * str3 = CHECKDATA(@"updown_range");
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@%@",str1,str2,str3]];
    
    [str addAttribute:NSForegroundColorAttributeName value:KFontNewColorA range:NSMakeRange(0,str1.length)];
    [str addAttribute:NSForegroundColorAttributeName value:KFontNewColorA range:NSMakeRange(str1.length,str2.length)];
    if ([CHECKDATA(@"updown_range") componentsSeparatedByString:@"-"].count > 1)
    {
        [str addAttribute:NSForegroundColorAttributeName value:kGreenColor range:NSMakeRange(str1.length+str2.length,str3.length)];
    }
    else
    {
        [str addAttribute:NSForegroundColorAttributeName value:kRedColor range:NSMakeRange(str1.length+str2.length,str3.length)];
    }
    
    price.attributedText = str;
    
    if (canChangeInput)
    {
        inputNum.text = CHECKDATA(@"sellable_amount");
        addBtn.enabled = NO;
    }
    
    if (inputNum.text.length)
    {
        sellBtn.selected = NO;
    }
    
    if (allNumber == 1)
    {
        sellHalfNum.hidden = YES;
        minusBtn.enabled = NO;
    }
    else if (allNumber == 0)
    {
        sellHalfNum.hidden = YES;
        sellAllNum.hidden = YES;
        minusBtn.enabled = NO;
        addBtn.enabled = NO;
        sellBtn.hidden = YES;
    }
    
    stockView.hidden = NO;
    numberView.hidden = NO;
    bottomView.hidden = NO;
    sellBtn.hidden = NO;
}

#pragma mark - Control Action
- (void)viewTapped:(id)sender
{
    [inputNum resignFirstResponder];
    if (inputNum.text.length)
    {
        sellBtn.selected = NO;
    }
    else
    {
        sellBtn.selected = YES;
    }
}

//买入股票
- (void)sellBtnClicked:(id)sender
{
    if (sellBtn.selected)
    {
        return;
    }
    if ([Utility isPureInt:inputNum.text])
    {
        NSMutableDictionary * param = [NSMutableDictionary dictionary];
        [param setObject:stockInfo.code forKey:@"stock_code"];
        [param setObject:stockInfo.exchange forKey:@"stock_exchange"];
        [param setObject:stockInfo.name forKey:@"stock_name"];
        [param setObject:inputNum.text forKey:@"sell_amount"];
        if (self.holdType == StockHoldTypeLong) {
            [GFRequestManager connectWithDelegate:self action:Submit_sell_stock_order param:param];
        }
        else if (self.holdType == StockHoldTypeShort) {
            [GFRequestManager connectWithDelegate:self action:Submit_short_sell_stock_order param:param];
        }
        
        // 诸葛统计
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"股票名"] = stockInfo.name;
        dict[@"卖出数量"] = inputNum.text;
        if (stockDict != nil) {
            dict[@"股票当前价"] = stockDict[@"current_price"];
            NSString *sellMoney = [NSString stringWithFormat:@"%0.2f", [stockDict[@"current_price"] floatValue] * [inputNum.text intValue]];
            dict[@"股票收入"] = sellMoney;
        }
        if (self.holdType == StockHoldTypeLong) {
            [[Zhuge sharedInstance] track:@"用户卖涨-交易页" properties:dict];
        }
        else if (self.holdType == StockHoldTypeShort) {
            [[Zhuge sharedInstance] track:@"用户卖跌-交易页" properties:dict];
        }
    }
    else
    {
        [[CHNAlertView defaultAlertView] showContent:@"请输入合法的股票数量" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
    }
}

//减买入数量
- (void)minusBtnClicked:(id)sender
{
    canChangeInput = NO;
    if ([inputNum.text integerValue]-100 >= 1)
    {
        inputNum.text = [NSString stringWithFormat:@"%d", [inputNum.text intValue]-100];
        minusBtn.enabled = YES;
    }
    else
    {
        inputNum.text = [NSString stringWithFormat:@"%d", 1];
        minusBtn.enabled = NO;
    }
    addBtn.enabled = YES;
}

//增加买入数量
- (void)addBtnClicked:(id)sender
{
    canChangeInput = NO;
    if ([inputNum.text integerValue]+100 <= allNumber)
    {
        inputNum.text = [NSString stringWithFormat:@"%d", [inputNum.text intValue]+100];
        addBtn.enabled = YES;
    }
    else
    {
        inputNum.text = [NSString stringWithFormat:@"%d", (int)allNumber];
        addBtn.enabled = NO;
    }
    minusBtn.enabled = YES;
}

//买入全部（一半）数量
- (void)buySomeBtnClicked:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    
    if (btn.tag == 1)
    {
        inputNum.text = [NSString stringWithFormat:@"%d", (int)halfNumber];
        addBtn.enabled = YES;
        minusBtn.enabled = YES;
    }
    else if (btn.tag == 2)
    {
        inputNum.text = [NSString stringWithFormat:@"%d", (int)allNumber];
        addBtn.enabled = NO;
        minusBtn.enabled = YES;
    }
}

//headerview 上 button点击事件
- (void)buttonClicked:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    if (btn.tag == 1)
    {
        [self back];
    }
    else if (btn.tag == 2)
    {
        headerView.refreshImage.hidden = YES;
        [headerView.actView startAnimating];
        [self requestSellableStockInfo];
    }
}

#pragma mark - Private Method
// 自动获取股票信息
- (void)startAutoRequestStockInfo
{
    sellTimer = [NSTimer scheduledTimerWithTimeInterval:12 target:self selector:@selector(requestSellableStockInfo) userInfo:nil repeats:YES];
    sellTimer.fireDate = [NSDate date];
}

// 返回交易
- (void)backToTrade
{
    [self.navigationController popViewControllerAnimated:YES];
}

// 停止加载
- (void)stopLoading
{
    [headerView.actView stopAnimating];
    headerView.refreshImage.hidden = NO;
}

#pragma mark - ASIHTTPRequestDelegate
//获取可卖股票信息
- (void)requestSellableStockInfo
{
    headerView.refreshImage.hidden = YES;
    [headerView.actView startAnimating];
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setObject:stockInfo.code forKey:@"stock_code"];
    [param setObject:stockInfo.exchange forKey:@"stock_exchange"];
    [param setObject:@"1" forKey:@"request_by"];
    
    if (self.holdType == StockHoldTypeLong) {
        [GFRequestManager connectWithDelegate:self action:Get_sellable_stock_info param:param];
    }
    else if (self.holdType == StockHoldTypeShort) {
        [GFRequestManager connectWithDelegate:self action:Get_short_sellable_stock_info param:param];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:2];
    
    ASIFormDataRequest * formDataRequest = (ASIFormDataRequest *)request;
    
    if ([formDataRequest.action isEqualToString:Get_sellable_stock_info] ||
        [formDataRequest.action isEqualToString:Get_short_sellable_stock_info])
    {
        stockDict = [requestInfo objectForKey:@"data"];
        [self reloadStockInfo:stockDict];
        
        // 设置买跌通行证过期提示
        NSString *expireMessage = [stockDict objectForKey:@"short_message"];
        expireLable.text = expireMessage;
    }
    else if ([formDataRequest.action isEqualToString:Submit_sell_stock_order] ||
             [formDataRequest.action isEqualToString:Submit_short_sell_stock_order])
    {
        if ([[requestInfo objectForKey:@"err_code"] integerValue] == 0)
        {
            [[TKAlertCenter defaultCenter] postAlertWithMessage:@"卖出成功" withType:ALERTTYPEERROR];
            [self performSelector:@selector(backToTrade) withObject:nil afterDelay:1];
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [super requestFailed:request];
    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:2];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    inputNum.text = @"";
    sellBtn.selected = YES;
    canChangeInput = NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.view.frame = CGRectMake(0, 0, screenWidth, screenHeight);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (inputNum.text.length == 0 && [string isEqualToString:@"0"])
    {
        return NO;
    }
    if (inputNum.text.length == 2)
    {
        NSString * finishString = [inputNum.text substringToIndex:1];
        if ([finishString isEqualToString:@"1"])
        {
            minusBtn.enabled = NO;
        }
    }
    if (inputNum.text.length == 1 && [string isEqualToString:@""])
    {
        inputNum.text = @"1";
        minusBtn.enabled = NO;
        addBtn.enabled = YES;
        sellBtn.selected = YES;
        
        return YES;
    }
    else
    {
        if (string.length)
        {
            sellBtn.selected = NO;
        }
        if (string.length)
        {
            if ([Utility isPureInt:inputNum.text] && [Utility isPureInt:string])
            {
                NSInteger inputValue = [inputNum.text integerValue]*10+[string integerValue];
                if (inputValue > allNumber || [inputNum.text integerValue] > allNumber)
                {
                    inputNum.text = [NSString stringWithFormat:@"%d", (int)allNumber];
                    addBtn.enabled = NO;
                    minusBtn.enabled = YES;
                    return NO;
                }
            }
            minusBtn.enabled = YES;
            addBtn.enabled = YES;
            return YES;
        }
    }
    
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
