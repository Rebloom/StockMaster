//
//  ShakeViewController.m
//  StockMaster
//
//  Created by dalikeji on 14-10-27.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "ShakeViewController.h"
#import "StockDetailViewController.h"

@implementation ShakeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    self.view.backgroundColor =kFontColorA;
    
    [headerView loadComponentsWithTitle:@"抖一抖"];
    [headerView backButton];
    [headerView createLine];
    headerView.backgroundColor = kFontColorA;
    [headerView setStatusBarColor: kFontColorA];
}

// 判断自选股本地列表中是否含有摇出的股票
- (void)judgeImageData
{
    NSArray * selectStockArr = [[StockInfoCoreDataStorage sharedInstance] getSelectStock];
    imgView.image = [UIImage imageNamed:@"icon_shake_add"];
    imgView.tag = 2;
    
    for (SelectStockEntity * selectStock in selectStockArr)
    {
        if ([selectStock.stockInfo.code isEqualToString:[[requestInfo objectForKey:@"data"] objectForKey:@"stock_code"]])
        {
            imgView.image = [UIImage imageNamed:@"icon_shake_minus"];
            imgView.tag = 1;
        }
    }
    if (imgView.tag == 1)
    {
        isSelect = YES;
    }
    else if(imgView.tag == 2)
    {
        isSelect = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    showView.frame = CGRectMake(20, screenHeight-200, screenWidth-40, 80);
    showView.hidden = NO;
    [self resignFirstResponder];
    [super viewWillDisappear:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setApplicationSupportsShakeToEdit:YES];
    [self becomeFirstResponder];
    isShake = YES;
    [self createUI];
    [self createImageView];
    self.view.backgroundColor = KFontColorE;
}

// 页面布局
- (void)createUI
{
    imgUp = [[UIImageView alloc] init];
    imgUp.userInteractionEnabled = YES;
    imgUp.frame = CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, screenHeight/2-100);
    imgUp.backgroundColor = KSelectNewColor;
    [self.view addSubview:imgUp];
    
    UIImageView * upView = [[UIImageView alloc] init];
    upView.frame = CGRectMake(screenWidth/2-75.5, CGRectGetHeight(imgUp.frame)-68.5, screenWidth/2-9, 68.5);
    upView.image = [UIImage imageNamed:@"Shake_01"];
    [imgUp addSubview:upView];
    [self.view sendSubviewToBack:imgUp];
    
    imgDown = [[UIImageView alloc] init];
    imgDown.userInteractionEnabled = YES;
    imgDown.frame = CGRectMake(0, CGRectGetMaxY(imgUp.frame), screenWidth, screenHeight/2+100);
    imgDown.backgroundColor = KSelectNewColor;
    [self.view addSubview:imgDown];
    
    UIImageView * downView = [[UIImageView alloc] init];
    downView.frame = CGRectMake(screenWidth/2-71.5, 0, screenWidth/2-13, 68.5);
    downView.image = [UIImage imageNamed:@"Shake_02"];
    [imgDown addSubview:downView];
    
    UIImageView * iconView = [[UIImageView alloc] init];
    iconView.image = [UIImage imageNamed:@"icon_logo"];
    iconView.frame = CGRectMake(screenWidth/2-25, screenHeight/2-52.5, 50, 32.5);
    [self.view addSubview:iconView];
    [self.view sendSubviewToBack:iconView];
    
}

// 初始化图片
- (void)createImageView
{
    showView = [[UIImageView alloc] init];
    showView.frame = CGRectMake(20, CGRectGetMinY(imgDown.frame), screenWidth-40, 80);
    showView.layer.borderWidth = 0.5;
    showView.layer.borderColor = kLineBGColor2.CGColor;
    showView.layer.cornerRadius = 10;
    showView.layer.masksToBounds = YES;
    showView.backgroundColor = [UIColor whiteColor];
    showView.userInteractionEnabled = YES;
    [self.view addSubview:showView];
    
    upLabel = [[UILabel alloc] init];
    upLabel.textAlignment = NSTextAlignmentLeft;
    upLabel.font = NormalFontWithSize(14);
    upLabel.frame = CGRectMake(20, 20, screenWidth-100, 20);
    upLabel.textColor = kFontColorD;
    [showView addSubview:upLabel];
    
    downLabel = [[UILabel alloc] init];
    downLabel.textAlignment = NSTextAlignmentLeft;
    downLabel.frame = CGRectMake(20, 40, screenWidth-100, 30);
    downLabel.textColor = KFontColorE;
    downLabel.numberOfLines = 0;
    downLabel.font = NormalFontWithSize(12);
    [showView addSubview:downLabel];
    
    UIButton * firstBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(showView.frame), CGRectGetHeight(showView.frame))];
    [firstBtn setBackgroundColor:[UIColor clearColor]];
    [firstBtn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    [showView addSubview:firstBtn];
    
    selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth-80, 0, 40, 80)];
    [selectBtn setBackgroundColor:[UIColor clearColor]];
    imgView = [[UIImageView alloc] init];
    imgView.frame = CGRectMake(0, 28.5, 23, 23);
    [selectBtn addSubview:imgView];
    [selectBtn addTarget:self action:@selector(selectOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [showView addSubview:selectBtn];
    
    showView.hidden = YES;
}

// 去股票详情页面
- (void)onClick:(UIButton*)sender
{
    if (stockData)
    {
        StockInfoEntity * stockInfo = [[StockInfoCoreDataStorage sharedInstance] getStockInfoWithCode:[stockData objectForKey:@"stock_code"] exchange:[stockData objectForKey:@"stock_exchange"]];
        if (stockInfo)
        {
            StockDetailViewController * SDVC = [[StockDetailViewController alloc] init];
            SDVC.stockInfo = stockInfo;
            [self pushToViewController:SDVC];
        }
    }
}

// 添加或删除自选
- (void)selectOnClick:(UIButton *)sender
{
    if (!isSelect) {
        [self requestAddSelect];
        isSelect = YES;
    }else{
        [self requestDeletSelect];
        isSelect = NO;
    }
}

// 摇一摇动画效果
- (void)addAnimations
{
    //让imgup上下移动
    CABasicAnimation *translation2 = [CABasicAnimation animationWithKeyPath:@"position"];
    translation2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    translation2.fromValue = [NSValue valueWithCGPoint:CGPointMake(screenWidth/2, 115)];
    translation2.toValue = [NSValue valueWithCGPoint:CGPointMake(screenWidth/2, 40)];
    translation2.duration = .4;
    translation2.repeatCount = 1;
    translation2.autoreverses = YES;
    
    //让imagdown上下移动
    CABasicAnimation *translation = [CABasicAnimation animationWithKeyPath:@"position"];
    translation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    translation.fromValue = [NSValue valueWithCGPoint:CGPointMake(screenWidth/2, screenHeight-100)];
    translation.toValue = [NSValue valueWithCGPoint:CGPointMake(screenWidth/2, screenHeight)];
    translation.duration = .4;
    translation.repeatCount = 1;
    translation.autoreverses = YES;
    
    [imgDown.layer addAnimation:translation forKey:@"translation"];
    [imgUp.layer addAnimation:translation2 forKey:@"translation2"];
}


#pragma mark 摇一摇
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (isShake)
    {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
        showView.hidden = YES;
        showView.frame = CGRectMake(20, CGRectGetMinY(imgDown.frame), screenWidth-40, 100);
        [self addAnimations];
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        [self performSelector:@selector(performLoading) withObject:nil afterDelay:.8];
        [self performSelector:@selector(requestShake) withObject:nil afterDelay:.8];
        isShake = NO;
        
        // 诸葛统计（摇一摇）
        [[Zhuge sharedInstance] track:@"摇一摇" properties:nil];
    }
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)performLoading
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

// 请求摇一摇的股票数据
- (void)requestShake
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [GFRequestManager connectWithDelegate:self action:Get_shake_shake param:paramDic];
}

// 添加自选的请求
- (void)requestAddSelect
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:[stockData objectForKey:@"stock_code"] forKey:@"stock_code"];
    [paramDic setObject:[stockData objectForKey:@"stock_exchange"] forKey:@"stock_exchange"];
    [GFRequestManager connectWithDelegate:self action:Submit_stock_watchlist param:paramDic];
}

// 删除自选的请求
- (void)requestDeletSelect
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:[stockData objectForKey:@"stock_code"] forKey:@"stock_code"];
    [paramDic setObject:[stockData objectForKey:@"stock_exchange"] forKey:@"stock_exchange"];
    [GFRequestManager connectWithDelegate:self action:Delete_stock_watchlist param:paramDic];
}

// 请求成功
- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    
    ASIFormDataRequest * formdateRequest = (ASIFormDataRequest *)request;
    if ([formdateRequest.action isEqualToString:Get_shake_shake])
    {
        isShake = YES;
        stockData = [[requestInfo objectForKey:@"data"] copy];
        [self deliverDic];
    }
    else if ([formdateRequest.action isEqualToString:Submit_stock_watchlist])
    {
        [[StockInfoCoreDataStorage sharedInstance] addSelectStockWithCode:[[stockData objectForKey:@"stock_code"] description] exchange:[[stockData objectForKey:@"stock_exchange"] description]];
        
        imgView.image = [UIImage imageNamed:@"icon_shake_minus"];
        [[TKAlertCenter defaultCenter] postAlertWithMessage:@"加入自选成功" withType:ALERTTYPEERROR];
    }
    else if ([formdateRequest.action isEqualToString:Delete_stock_watchlist])
    {
        [[StockInfoCoreDataStorage sharedInstance] delSelectStockWithCode:[stockData objectForKey:@"stock_code"] exchange:[stockData objectForKey:@"stock_exchange"]];
        imgView.image = [UIImage imageNamed:@"icon_shake_add"];
        [[TKAlertCenter defaultCenter] postAlertWithMessage:@"删除自选成功" withType:ALERTTYPEERROR];
    }
}

// 请求失败
- (void)requestFailed:(ASIHTTPRequest *)request
{
    [super requestFailed:request];
    isShake = YES;
}

// 处理返回数据 结束动画
- (void)deliverDic
{
    isShake = YES;
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    upLabel.text = [NSString stringWithFormat:@"%@(%@)",[stockData objectForKey:@"stock_name"],[stockData objectForKey:@"stock_code"]];
    downLabel.text = [stockData objectForKey:@"notice"];
    
    [self judgeImageData];
    
    showView.hidden = NO;
    
    CABasicAnimation *translation = [CABasicAnimation animationWithKeyPath:@"position"];
    translation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    translation.fromValue = [NSValue valueWithCGPoint:CGPointMake(screenWidth/2, screenHeight-250)];
    translation.toValue = [NSValue valueWithCGPoint:CGPointMake(screenWidth/2, screenHeight-150)];
    translation.duration = 1;
    translation.autoreverses = NO;
    translation.repeatCount = 1;
    showView.frame = CGRectMake(20, screenHeight-200, screenWidth-40, 80);
    [showView.layer addAnimation:translation forKey:@"translation"];
    AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
