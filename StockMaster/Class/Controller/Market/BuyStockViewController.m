//
//  BuyStockViewController.m
//  StockMaster
//
//  Created by Rebloom on 14/12/15.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BuyStockViewController.h"
#import "RoyaDialView.h"
#import "SecondViewController.h"

@interface BuyStockViewController ()

@end

@implementation BuyStockViewController

@synthesize stockInfo;

#pragma mark - View Load
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    canChangeInput = YES;
    
    warned = YES;
    
    self.view.backgroundColor = KSelectNewColor;
    
    [headerView loadComponentsWithTitle:@"买入"];
    [headerView setStatusBarColor:kFontColorA];
    headerView.backgroundColor = kFontColorA;
    [headerView backButton];
    [headerView refreshButton];
    headerView.refreshImage.image = [UIImage imageNamed:@"icon_shuaxin_default"];
    [headerView createLine];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame)-beginX, screenWidth, screenHeight-headerView.frame.size.height)];
    [self.view insertSubview:scrollView belowSubview:headerView];
    
    topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 95)];
    topView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:topView];
    
    UILabel * inputStockNum = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, screenWidth, 20)];
    inputStockNum.textAlignment = NSTextAlignmentCenter;
    inputStockNum.backgroundColor = [UIColor clearColor];
    inputStockNum.textColor = KFontNewColorB;
    inputStockNum.font = NormalFontWithSize(12);
    inputStockNum.text = @"请输入6位股票代码";
    [topView addSubview:inputStockNum];
    
    UIView * line1 = [[UIView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(inputStockNum.frame)+10, screenWidth-40, .5)];
    line1.backgroundColor = KColorHeader;
    [topView addSubview:line1];
    
    UIView * line2 = [[UIView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(line1.frame)+45, screenWidth-40, .5)];
    line2.backgroundColor = KColorHeader;
    [topView addSubview:line2];
    
    for (int i = 0; i < 6; i++)
    {
        UILabel * inputLabel = [[UILabel alloc] initWithFrame:CGRectMake(20+screenWidth-40/6*i, CGRectGetMaxY(line1.frame), screenWidth-40/6, 45)];
        inputLabel.textAlignment = NSTextAlignmentCenter;
        inputLabel.tag = 1000+i;
        inputLabel.backgroundColor = [UIColor clearColor];
        inputLabel.textColor = [UIColor blackColor];
        inputLabel.font = NormalFontWithSize(18);
        inputLabel.text = [stockInfo.code substringWithRange:NSMakeRange(i , 1)];
        [topView addSubview:inputLabel];
        
        UIView * mLine = [[UIView alloc] initWithFrame:CGRectMake(20+46.5*i, CGRectGetMaxY(line1.frame), .5, 45.5)];
        mLine.backgroundColor = KColorHeader;
        [topView addSubview:mLine];
    }
    
    UIView * line3 = [[UIView alloc] initWithFrame:CGRectMake(screenWidth-20, CGRectGetMaxY(line1.frame), .5, 45)];
    line3.backgroundColor = KColorHeader;
    [topView addSubview:line3];
    
    stockView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topView.frame), screenWidth, 92)];
    stockView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:stockView];
    
    emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topView.frame), screenWidth, 92)];
    emptyView.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:emptyView];
    
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
    [scrollView addSubview:numberView];
    
    UIView * line6 = [[UIView alloc] initWithFrame:CGRectMake(75, 0, screenWidth/2+10, .5)];
    line6.backgroundColor = KColorHeader;
    [numberView addSubview:line6];
    
    UIView * line7 = [[UIView alloc] initWithFrame:CGRectMake(75, CGRectGetMaxY(line6.frame)+45, screenWidth/2+10, .5)];
    line7.backgroundColor = KColorHeader;
    [numberView addSubview:line7];
    
    minusBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(line6.frame), 57, 45)];
    [minusBtn setBackgroundImage:[UIImage imageNamed:@"icon_jian"] forState:UIControlStateNormal];
    [minusBtn setBackgroundImage:[UIImage imageNamed:@"icon_jian2"] forState:UIControlStateDisabled];
    [minusBtn addTarget:self action:@selector(minusBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [numberView addSubview:minusBtn];
    
    buyNum = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(minusBtn.frame), CGRectGetMaxY(line6.frame), screenWidth-154, 45)];
    buyNum.textAlignment = NSTextAlignmentCenter;
    buyNum.backgroundColor = KSelectNewColor;
    buyNum.textColor = KFontNewColorA;
    [numberView addSubview:buyNum];
    
    addBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(buyNum.frame), CGRectGetMaxY(line6.frame), 57, 45)];
    [addBtn setBackgroundImage:[UIImage imageNamed:@"icon_jia"] forState:UIControlStateNormal];
    [addBtn setBackgroundImage:[UIImage imageNamed:@"icon_jia2"] forState:UIControlStateDisabled];
    [addBtn addTarget:self action:@selector(addBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [numberView addSubview:addBtn];
    
    buyHalfNum = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(line7.frame)+20, screenWidth/2-40, 13)];
    buyHalfNum.textAlignment = NSTextAlignmentCenter;
    buyHalfNum.backgroundColor = [UIColor clearColor];
    buyHalfNum.textColor = KFontNewColorB;
    buyHalfNum.font = NormalFontWithSize(13);
    [numberView addSubview:buyHalfNum];
    
    UIButton * buyHalfBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(line7.frame), screenWidth/2-40, 53)];
    buyHalfBtn.tag = 1;
    [buyHalfBtn addTarget:self action:@selector(buySomeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [numberView addSubview:buyHalfBtn];
    
    mLine3 = [[UIView alloc] initWithFrame:CGRectMake(screenWidth/2-0.5, CGRectGetMaxY(line7.frame)+20, .5, 13)];
    mLine3.backgroundColor = KColorHeader;
    [numberView addSubview:mLine3];
    
    buyAllNum = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/2+20, CGRectGetMaxY(line7.frame)+20, screenWidth/2-40, 13)];
    buyAllNum.textAlignment = NSTextAlignmentCenter;
    buyAllNum.backgroundColor = [UIColor clearColor];
    buyAllNum.textColor = KFontNewColorB;
    buyAllNum.font = NormalFontWithSize(13);
    [numberView addSubview:buyAllNum];
    
    UIButton * buyAllBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth/2+20, CGRectGetMaxY(line7.frame), screenWidth/2-40, 53)];
    buyAllBtn.tag = 2;
    [buyAllBtn addTarget:self action:@selector(buySomeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [numberView addSubview:buyAllBtn];
    
    bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(numberView.frame), screenWidth, 220)];
    [scrollView addSubview:bottomView];
    
    buyBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, screenWidth-40, 45)];
    [buyBtn setTitle:@"买入" forState:UIControlStateNormal];
    [buyBtn setTitle:@"买入" forState:UIControlStateSelected];
    buyBtn.layer.cornerRadius = 4;
    buyBtn.layer.masksToBounds = YES;
    [buyBtn addTarget:self action:@selector(buyBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [buyBtn setBackgroundImage:[kRedColor image] forState:UIControlStateNormal];
    [buyBtn setBackgroundImage:[@"#cdd1d6".color image] forState:UIControlStateSelected];
    [buyBtn setTitleColor:kFontColorA forState:UIControlStateNormal];
    [buyBtn setTitleColor:KFontNewColorB forState:UIControlStateSelected];
    [bottomView addSubview:buyBtn];
    
    inputNum = [[GFTextField alloc] initWithFrame:buyNum.frame];
    inputNum.keyboardType = UIKeyboardTypeNumberPad;
    inputNum.delegate = self;
    inputNum.textAlignment = NSTextAlignmentCenter;
    [numberView addSubview:inputNum];
    
    expireLable = [[UILabel alloc] init];
    expireLable.frame = CGRectMake(0, CGRectGetMaxY(buyBtn.frame)+3, screenWidth, 20);
    expireLable.backgroundColor = [UIColor clearColor];
    expireLable.textColor = KFontNewColorB;
    expireLable.font = NormalFontWithSize(14);
    expireLable.textAlignment = NSTextAlignmentCenter;
    [bottomView addSubview:expireLable];
    
    if (self.holdType == StockHoldTypeLong) {
        expireLable.hidden = YES;
    }
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tap.delegate = self;
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    [self startAutoRequestStockInfo];
    
    if (!stockInfo)
    {
        stockView.hidden = YES;
        numberView.hidden = YES;
        bottomView.hidden = YES;
        buyBtn.hidden = YES;
    }
    else
    {
        topView.hidden = YES;
        stockView.frame = CGRectMake(0, 0, screenWidth, 92);
        numberView.frame = CGRectMake(0, CGRectGetMaxY(stockView.frame), screenWidth, 98);
        bottomView.frame = CGRectMake(0, CGRectGetMaxY(numberView.frame), screenWidth, 220);
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [buyTimer invalidate];
    [super viewWillDisappear:YES];
}

// 显示没有结果
- (void)showNoResult
{
    stockView.hidden = YES;
    emptyView.hidden = NO;
    topView.frame = CGRectMake(0, 0, screenWidth, 110);
    emptyView.frame = CGRectMake(0, CGRectGetMaxY(topView.frame)+20, screenWidth, 92);
    emptyTip.text = @"暂时搜索不到您输入的股票代码哟~";
    emptyTip.hidden = NO;
    numberView.hidden = YES;
    bottomView.hidden = YES;
}

// 显示提示信息
- (void)showTip
{
    stockView.hidden = NO;
    bottomView.hidden = YES;
    numberView.hidden = YES;
    emptyView.hidden = NO;
    topView.frame = CGRectMake(0, 0, screenWidth, 110);
    emptyView.frame = CGRectMake(0, CGRectGetMaxY(stockView.frame)+20, screenWidth, 92);
}

// 加载股票交易数据
- (void)reloadStockInfo:(NSDictionary *)dic
{
    if ([[dic objectForKey:@"is_tradable"] integerValue] == 0)
    {
        [buyTimer pauseTimer];
    }
    
    allNumber = [CHECKDATA(@"buyable_amount") integerValue];
    halfNumber = [CHECKDATA(@"half_buyable_amount") integerValue];
    buyAllNum.text = [NSString stringWithFormat:@"买全部（%@）",CHECKDATA(@"buyable_amount")];
    buyHalfNum.text = [NSString stringWithFormat:@"买一半（%@）",CHECKDATA(@"half_buyable_amount")];
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
        if (halfNumber == 0)
        {
            inputNum.text = CHECKDATA(@"buyable_amount");
        }
        else
        {
            inputNum.text = CHECKDATA(@"half_buyable_amount");
        }
    }
    
    if (inputNum.text.length)
    {
        buyBtn.selected = NO;
    }
    
    if (allNumber == 1)
    {
        buyHalfNum.hidden = YES;
        minusBtn.enabled = NO;
    }
    else if (allNumber == 0)
    {
        buyHalfNum.hidden = YES;
        buyAllNum.hidden = YES;
        minusBtn.enabled = NO;
        addBtn.enabled = NO;
        buyBtn.selected = YES;
        mLine3.hidden = YES;
        
        if (warned)
        {
            UILabel * tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(numberView.frame)-32, screenWidth, 13)];
            tipLabel.text = [[dic objectForKey:@"buyable_message"] description];
            tipLabel.textAlignment = NSTextAlignmentCenter;
            tipLabel.backgroundColor = [UIColor clearColor];
            tipLabel.textColor = KFontNewColorB;
            tipLabel.font = NormalFontWithSize(13);
            [scrollView addSubview:tipLabel];
            
            inputNum.enabled = NO;
            
            warned = NO;
        }
    }
    
    stockView.hidden = NO;
    numberView.hidden = NO;
    bottomView.hidden = NO;
    buyBtn.hidden = NO;
}

#pragma mark - Control Action
- (void)viewTapped:(id)sender
{
    [inputNum resignFirstResponder];
    [self buttonSelected];
}

// 买入股票
- (void)buyBtnClicked:(id)sender
{
    if (buyBtn.selected) {
        return;
    }
    
    if ([Utility isPureInt:inputNum.text]) {
        NSMutableDictionary * param = [NSMutableDictionary dictionary];
        [param setObject:stockInfo.code forKey:@"stock_code"];
        [param setObject:stockInfo.exchange forKey:@"stock_exchange"];
        [param setObject:stockInfo.name forKey:@"stock_name"];
        [param setObject:inputNum.text forKey:@"buy_amount"];
        if (self.holdType == StockHoldTypeLong) {
            [GFRequestManager connectWithDelegate:self action:Submit_buy_stock_order param:param];
        }
        else if (self.holdType == StockHoldTypeShort) {
            [GFRequestManager connectWithDelegate:self action:Submit_short_buy_stock_order param:param];
        }
        
        
        // 诸葛统计
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"股票名"] = stockInfo.name;
        dict[@"买入数量"] = inputNum.text;
        if (stockDict != nil) {
            dict[@"股票当前价"] = stockDict[@"current_price"];
            NSString *buyMoney = [NSString stringWithFormat:@"%0.2f", [stockDict[@"current_price"] floatValue] * [inputNum.text intValue]];
            dict[@"股票花费"] = buyMoney;
        }
        if (self.holdType == StockHoldTypeLong) {
            [[Zhuge sharedInstance] track:@"用户买涨-交易页" properties:dict];
        }
        else if (self.holdType == StockHoldTypeShort) {
            [[Zhuge sharedInstance] track:@"用户买跌-交易页" properties:dict];
        }
    }
    else {
        [[CHNAlertView defaultAlertView] showContent:@"请输入合法的股票数量" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
        canBack = NO;
    }
}

// 减买入的数量
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
        inputNum.text = [NSString stringWithFormat:@"%d",1];
        minusBtn.enabled = NO;
    }
    addBtn.enabled = YES;
}

// 增加买入数量
- (void)addBtnClicked:(id)sender
{
    canChangeInput = NO;
    if ([inputNum.text integerValue]+100 < allNumber)
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

// 买入全部（一半）数量
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
    buyBtn.enabled = YES;
}

// headerview 上 button点击事件
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
        [self requestBuyableStockInfo];
    }
}

#pragma mark - Private Method
// 自动获取股票信息
- (void)startAutoRequestStockInfo
{
    buyTimer = [NSTimer scheduledTimerWithTimeInterval:12 target:self selector:@selector(requestBuyableStockInfo) userInfo:nil repeats:YES];
    buyTimer.fireDate = [NSDate date];
}

- (void)buttonSelected
{
    if (inputNum.text.length && allNumber)
    {
        buyBtn.selected = NO;
    }
    else
    {
        buyBtn.selected = YES;
    }
}

// 返回交易
- (void)backToTrade
{
    for (BasicViewController * bvc in self.navigationController.viewControllers)
    {
        if ([bvc isKindOfClass:[SecondViewController class]])
        {
            [self.navigationController popToViewController:bvc animated:YES];
            return;
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

// 停止加载
- (void)stopLoading
{
    [headerView.actView stopAnimating];
    headerView.refreshImage.hidden = NO;
}

#pragma mark - ASIHTTPRequestDelegate
// 获取可买股票信息
- (void)requestBuyableStockInfo
{
    headerView.refreshImage.hidden = YES;
    [headerView.actView startAnimating];
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setObject:stockInfo.code forKey:@"stock_code"];
    [param setObject:stockInfo.exchange forKey:@"stock_exchange"];
    [param setObject:@"1" forKey:@"request_by"];
    
    if (self.holdType == StockHoldTypeLong) {
        [GFRequestManager connectWithDelegate:self action:Get_buyable_stock_info param:param];
    }
    else if (self.holdType == StockHoldTypeShort) {
        [GFRequestManager connectWithDelegate:self action:Get_short_buyable_stock_info param:param];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:2];
    
    
    ASIFormDataRequest * formdataRequest = (ASIFormDataRequest *)request;
    
    if([[requestInfo objectForKey:@"err_code"] integerValue])
    {
        [[CHNAlertView defaultAlertView] showContent:[[requestInfo objectForKey:@"message"] description] cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
        canBack = YES;
        return;
    }
    
    if ([formdataRequest.action isEqualToString:Get_buyable_stock_info] ||
        [formdataRequest.action isEqualToString:Get_short_buyable_stock_info])
    {
        stockDict = [requestInfo objectForKey:@"data"];
        
        NSInteger classStatus = [[stockDict objectForKey:@"stock_class"] integerValue];
        buyBtn.selected = YES;
        
        if (classStatus == 1)
        {
            [self reloadStockInfo:stockDict];
        }
        else if (classStatus == 2)
        {
            // 停牌
            [self reloadStockInfo:stockDict];
            price.text = @"停牌";
            emptyTip.text = [[stockDict objectForKey:@"return_msg"] description];
            [self showTip];
        }
        else if (classStatus == 3)
        {
            // 涨停
            [self reloadStockInfo:stockDict];
            emptyTip.text = [[stockDict objectForKey:@"return_msg"] description];
            [self showTip];
        }
        else if (classStatus == 4)
        {
            // 新股
            [self reloadStockInfo:stockDict];
            emptyTip.text = [[stockDict objectForKey:@"return_msg"] description];
            [self showTip];
        }
        
        // 设置买跌通行证过期提示
        NSString *expireMessage = [stockDict objectForKey:@"short_message"];
        expireLable.text = expireMessage;
    }
    else if ([formdataRequest.action isEqualToString:Submit_buy_stock_order] ||
             [formdataRequest.action isEqualToString:Submit_short_buy_stock_order])
    {
        if ([[requestInfo objectForKey:@"err_code"] integerValue] == 0)
        {
            [[TKAlertCenter defaultCenter] postAlertWithMessage:@"买入成功" withType:ALERTTYPEERROR];
            [self performSelector:@selector(backToTrade) withObject:nil afterDelay:1];
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [super requestFailed:request];
    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:2];
}

#pragma mark - UIGestureRecognizerDelegate
// 判断响应的控件
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    NSString * touchObject = NSStringFromClass([touch.view class]);
    
    if ([touchObject isKindOfClass:[UIButton class]])
    {
        return NO;
    }
    
    return YES;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    canChangeInput = NO;
    
    emptyTip.hidden = YES;
    addBtn.enabled = YES;
    minusBtn.enabled = YES;
    
    if ([inputNum isEqual:textField])
    {
        inputNum.text = @"";
        buyBtn.selected = YES;
    }
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
        buyBtn.selected = YES;
        
        return YES;
    }
    else
    {
        if (string.length)
        {
            buyBtn.selected = NO;
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

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self buttonSelected];
}

#pragma mark - CHNAlertViewDelegate
- (void)buttonClickedAtIndex:(NSInteger)index
{
    if (canBack)
    {
        [self performSelector:@selector(back) withObject:nil afterDelay:1];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
