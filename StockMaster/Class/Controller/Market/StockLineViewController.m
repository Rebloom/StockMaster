//
//  StockLineViewController.m
//  StockMaster
//
//  Created by dalikeji on 15/3/12.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import "StockLineViewController.h"


@interface StockLineViewController ()
{
    RealtimeDataEntity *realtimeData;
}

@end

@implementation StockLineViewController
@synthesize stockInfo;
- (void)dealloc
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = KSelectNewColor;
    
    realtimeData = [[StockInfoCoreDataStorage sharedInstance] getStockRealtimeDataWithCode:stockInfo.code exchange:stockInfo.exchange];
    
    //旋转屏幕，但是只旋转当前的View
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];
    self.view.transform = CGAffineTransformMakeRotation(M_PI/2);
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    self.view.bounds = CGRectMake(0, 0, frame.size.height, frame.size.width);
    
    ViewHeight = screenWidth;
    ViewWidth  = screenHeight;
    everyWidth = ViewWidth/4;
    
    [self createHeadView];
    [self createBannerView];
    [self createLineView];
    
    [self reloadHeadView];
    
    [self requestData];
}

//创建头部视图
- (void)createHeadView
{
    if (!topView)
    {
        topView = [[UIView alloc] init];
    }
    topView.frame = CGRectMake(0, 0, ViewWidth, 83);
    topView.backgroundColor = kFontColorA;
    [self.view addSubview:topView];
    
    if (!nameLabel)
    {
        nameLabel = [[UILabel alloc] init];
    }
    nameLabel.frame = CGRectMake(15, 17, 60, 15);
    nameLabel.font = BoldFontWithSize(15);
    nameLabel.textColor = KFontNewColorA;
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.text = stockInfo.name;
    [topView addSubview:nameLabel];
    
    if (!priceLabel)
    {
        priceLabel = [[UILabel alloc] init];
    }
    priceLabel.frame = CGRectMake(CGRectGetMaxX(nameLabel.frame)+10, CGRectGetMinY(nameLabel.frame), 60, CGRectGetHeight(nameLabel.frame));
    priceLabel.font = BoldFontWithSize(15);
    priceLabel.textColor = kRedColor;
    priceLabel.textAlignment = NSTextAlignmentLeft;
    priceLabel.text = @"00.00";
    [topView addSubview:priceLabel];
    
    if (!highLabel)
    {
        highLabel = [[UILabel alloc] init];
    }
    highLabel.frame = CGRectMake(everyWidth +10, CGRectGetMinY(nameLabel.frame), 100, CGRectGetHeight(nameLabel.frame));
    highLabel.font = NormalFontWithSize(13);
    highLabel.textColor = KFontNewColorA;
    highLabel.textAlignment = NSTextAlignmentLeft;
    highLabel.text = @"最高:00.00";
    [topView addSubview:highLabel];
    
    if (!lowLabel)
    {
        lowLabel = [[UILabel alloc] init];
    }
    lowLabel.frame = CGRectMake(everyWidth*5/3+10, CGRectGetMinY(nameLabel.frame), 100, CGRectGetHeight(nameLabel.frame));
    lowLabel.font = NormalFontWithSize(13);
    lowLabel.backgroundColor = [UIColor clearColor];
    lowLabel.textColor = KFontNewColorA;
    lowLabel.textAlignment = NSTextAlignmentLeft;
    lowLabel.text = @"最低:00.00";
    [topView addSubview:lowLabel];
    
    if (!openLabel)
    {
        openLabel = [[UILabel alloc] init];
    }
    openLabel.frame = CGRectMake(everyWidth*7/3+10, CGRectGetMinY(nameLabel.frame), 100, CGRectGetHeight(nameLabel.frame));
    openLabel.font = NormalFontWithSize(13);
    openLabel.backgroundColor = [UIColor clearColor];
    openLabel.textColor = KFontNewColorA;
    openLabel.textAlignment = NSTextAlignmentLeft;
    openLabel.text = @"今开:00.00";
    [topView addSubview:openLabel];
    
    if (!closeLable)
    {
        closeLable = [[UILabel alloc] init];
    }
    closeLable.frame = CGRectMake(everyWidth *3+10, CGRectGetMinY(nameLabel.frame), 100, CGRectGetHeight(nameLabel.frame));
    closeLable.font = NormalFontWithSize(13);
    closeLable.backgroundColor = [UIColor clearColor];
    closeLable.textColor = KFontNewColorA;
    closeLable.textAlignment = NSTextAlignmentLeft;
    closeLable.text = @"昨收:00.00";
    [topView addSubview:closeLable];
    
    UIButton * backBtn = [[UIButton alloc] init];
    backBtn.backgroundColor = [UIColor clearColor];
    backBtn.frame = CGRectMake(ViewWidth - 65, 0, 65, CGRectGetHeight(topView.frame));
    
    UIImageView * backImageView = [[UIImageView alloc] init];
    backImageView.image = [UIImage imageNamed:@"iconguanbi"];
    backImageView.frame = CGRectMake(50-19, 14.5, 19, 19);
    [backBtn addSubview:backImageView];
    
    [backBtn addTarget:self action:@selector(backBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backBtn];
}

//创建选择视图
- (void)createBannerView
{
    if (!bannerView)
    {
        bannerView = [[UIView alloc] initWithFrame:CGRectMake(0, 48, CGRectGetWidth(topView.frame), 35)];
    }
    bannerView.backgroundColor = [UIColor whiteColor];
    [topView addSubview:bannerView];
    
    for(int i = 0;i < 2; i++)
    {
        UILabel * lineLabel = [[UILabel alloc] init];
        lineLabel.backgroundColor = KFontNewColorJ;
        lineLabel.frame = CGRectMake(0, (34.5*i), ViewWidth, 0.5);
        [bannerView addSubview:lineLabel];
    }
    
    NSArray * btnArr = @[@"分时",@"日线",@"周线",@"月线"];
    for (int i = 0; i < btnArr.count; i++)
    {
        UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(everyWidth*i +0.5, 1, everyWidth-1, 33)];
        btn.tag = i+1;
        if (i == 0)
        {
            [btn setTitleColor:kFontColorA forState:UIControlStateNormal];
            [btn setBackgroundImage:[kRedColor image] forState:UIControlStateNormal];
            [btn setBackgroundImage:[kRedColor image] forState:UIControlStateHighlighted];
        }
        else
        {
            [btn setTitleColor:KFontNewColorB forState:UIControlStateNormal];
            [btn setBackgroundImage:[kFontColorA image] forState:UIControlStateNormal];
            [btn setBackgroundImage:[kFontColorA image] forState:UIControlStateHighlighted];
        }
        
        [btn setTitle:[btnArr objectAtIndex:i] forState:UIControlStateNormal];
        btn.titleLabel.font = NormalFontWithSize(14);
        [btn addTarget:self action:@selector(bannerBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [bannerView addSubview:btn];
        
        UILabel * lineLabel = [[UILabel alloc] init];
        lineLabel.backgroundColor = KFontNewColorJ;
        lineLabel.frame = CGRectMake(everyWidth * (i+1), 0, 0.5, 33);
        [bannerView addSubview:lineLabel];
    }
}

- (void)createLineView
{
    if (!lineView)
    {
        lineView = [[CHNLineView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(bannerView.frame), ViewWidth, ViewHeight - 83)];
    }
    lineView.backgroundColor = kLineBgColor3;
    [self.view addSubview:lineView];
    lineView.stockInfo = self.stockInfo;
    lineView.type = Get_time_share;
    [lineView start];
    lineView.userInteractionEnabled = NO;
}

//切换K线（分时、日K、周K、月K）
- (void)bannerBtnClicked:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    
    UIButton * btn1 = (UIButton*)[bannerView viewWithTag:1];
    UIButton * btn2 = (UIButton*)[bannerView viewWithTag:2];
    UIButton * btn3 = (UIButton*)[bannerView viewWithTag:3];
    UIButton * btn4 = (UIButton*)[bannerView viewWithTag:4];
    
    switch (btn.tag)
    {
        case 1:
            [lineView requestKLineWithType:Get_time_share];
            [btn1 setTitleColor:kFontColorA forState:UIControlStateNormal];
            [btn1 setBackgroundImage:[kRedColor image] forState:UIControlStateNormal];
            [btn1 setBackgroundImage:[kRedColor image] forState:UIControlStateHighlighted];
            
            [btn2 setTitleColor:KFontNewColorB forState:UIControlStateNormal];
            [btn2 setBackgroundImage:[kFontColorA image] forState:UIControlStateNormal];
            [btn2 setBackgroundImage:[kFontColorA image] forState:UIControlStateHighlighted];
            
            [btn3 setTitleColor:KFontNewColorB forState:UIControlStateNormal];
            [btn3 setBackgroundImage:[kFontColorA image] forState:UIControlStateNormal];
            [btn3 setBackgroundImage:[kFontColorA image] forState:UIControlStateHighlighted];
            
            [btn4 setTitleColor:KFontNewColorB forState:UIControlStateNormal];
            [btn4 setBackgroundImage:[kFontColorA image] forState:UIControlStateNormal];
            [btn4 setBackgroundImage:[kFontColorA image] forState:UIControlStateHighlighted];
            
            break;
        case 2:
            [lineView requestKLineWithType:@"day"];
            [btn1 setTitleColor:KFontNewColorB forState:UIControlStateNormal];
            [btn1 setBackgroundImage:[kFontColorA image] forState:UIControlStateNormal];
            [btn1 setBackgroundImage:[kFontColorA image] forState:UIControlStateHighlighted];
            
            [btn2 setTitleColor:kFontColorA forState:UIControlStateNormal];
            [btn2 setBackgroundImage:[kRedColor image] forState:UIControlStateNormal];
            [btn2 setBackgroundImage:[kRedColor image] forState:UIControlStateHighlighted];
            
            [btn3 setTitleColor:KFontNewColorB forState:UIControlStateNormal];
            [btn3 setBackgroundImage:[kFontColorA image] forState:UIControlStateNormal];
            [btn3 setBackgroundImage:[kFontColorA image] forState:UIControlStateHighlighted];
            
            [btn4 setTitleColor:KFontNewColorB forState:UIControlStateNormal];
            [btn4 setBackgroundImage:[kFontColorA image] forState:UIControlStateNormal];
            [btn4 setBackgroundImage:[kFontColorA image] forState:UIControlStateHighlighted];
            
            break;
        case 3:
            [lineView requestKLineWithType:@"week"];
            [btn1 setTitleColor:KFontNewColorB forState:UIControlStateNormal];
            [btn1 setBackgroundImage:[kFontColorA image] forState:UIControlStateNormal];
            [btn1 setBackgroundImage:[kFontColorA image] forState:UIControlStateHighlighted];
            
            [btn2 setTitleColor:KFontNewColorB forState:UIControlStateNormal];
            [btn2 setBackgroundImage:[kFontColorA image] forState:UIControlStateNormal];
            [btn2 setBackgroundImage:[kFontColorA image] forState:UIControlStateHighlighted];
            
            [btn3 setTitleColor:kFontColorA forState:UIControlStateNormal];
            [btn3 setBackgroundImage:[kRedColor image] forState:UIControlStateNormal];
            [btn3 setBackgroundImage:[kRedColor image] forState:UIControlStateHighlighted];
            
            [btn4 setTitleColor:KFontNewColorB forState:UIControlStateNormal];
            [btn4 setBackgroundImage:[kFontColorA image] forState:UIControlStateNormal];
            [btn4 setBackgroundImage:[kFontColorA image] forState:UIControlStateHighlighted];
            
            break;
        case 4:
            [lineView requestKLineWithType:@"month"];
            [btn1 setTitleColor:KFontNewColorB forState:UIControlStateNormal];
            [btn1 setBackgroundImage:[kFontColorA image] forState:UIControlStateNormal];
            [btn1 setBackgroundImage:[kFontColorA image] forState:UIControlStateHighlighted];
            
            [btn2 setTitleColor:KFontNewColorB forState:UIControlStateNormal];
            [btn2 setBackgroundImage:[kFontColorA image] forState:UIControlStateNormal];
            [btn2 setBackgroundImage:[kFontColorA image] forState:UIControlStateHighlighted];
            
            [btn3 setTitleColor:KFontNewColorB forState:UIControlStateNormal];
            [btn3 setBackgroundImage:[kFontColorA image] forState:UIControlStateNormal];
            [btn3 setBackgroundImage:[kFontColorA image] forState:UIControlStateHighlighted];
            
            [btn4 setTitleColor:kFontColorA forState:UIControlStateNormal];
            [btn4 setBackgroundImage:[kRedColor image] forState:UIControlStateNormal];
            [btn4 setBackgroundImage:[kRedColor image] forState:UIControlStateHighlighted];
            
            break;
        default:
            break;
    }
}

//返回上一页
- (void)backBtnOnClick:(UIButton*)sender
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

- (void)requestData
{
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setObject:stockInfo.code forKey:@"stock_code"];
    [param setObject:stockInfo.exchange forKey:@"stock_exchange"];
    [GFRequestManager connectWithDelegate:self action:Get_realtime_data param:param];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    
    ASIFormDataRequest * formDataRequest = (ASIFormDataRequest *)request;
    
    if ([formDataRequest.action isEqualToString:Get_realtime_data])
    {
        NSDictionary *dataDict = [requestInfo objectForKey:@"data"];
        realtimeData = [[StockInfoCoreDataStorage sharedInstance] saveStockRealtimeData:dataDict];
        [self reloadHeadView];
    }
}

- (void)reloadHeadView
{
    if (nil == realtimeData) {
        return;
    }
    
    priceLabel.text = realtimeData.currentPrice;
    highLabel.text = [NSString stringWithFormat:@"最高: %@", realtimeData.todayMax];
    lowLabel.text = [NSString stringWithFormat:@"最低: %@", realtimeData.todayMin];
    openLabel.text = [NSString stringWithFormat:@"今开: %@", realtimeData.todayOpen];
    closeLable.text = [NSString stringWithFormat:@"昨收: %@", realtimeData.yesterdayEndPrice];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [super requestFailed:request];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [super viewWillDisappear:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
