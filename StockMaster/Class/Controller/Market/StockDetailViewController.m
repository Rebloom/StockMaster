//
//  StockDetailViewController.m
//  StockMaster
//
//  Created by dalikeji on 15/3/10.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import "StockDetailViewController.h"
#import "InformationViewController.h"
#import "InformationDetailViewController.h"
#import "SubSectionViewController.h"
#import "StockLineViewController.h"
#import "BuyStockViewController.h"
#import "NoticeSettingViewController.h"
#import "SellStockViewController.h"
#import "EmotionViewController.h"

#define KTagPriceNum    100
#define KTagPercentNum  101
#define KTagProfitNum   102
#define KTagHoldNum     103

#define KTagLongPriceNum    100
#define KTagLongProfitNum   101
#define KTagLongHoldNum     102
#define KTagLongPercentNum  103
#define KTagShortPriceNum   104
#define KTagShortProfitNum  105
#define KTagShortHoldNum    106
#define KTagShortPercentNum 107

@interface StockDetailViewController ()
{
    RealtimeDataEntity *realtimeData;
    StockGradeEntity *stockGrade;
    NSArray * plateArr;
    NSArray * newsArr;
    
    NSInteger sectionNumber;
    NSInteger sectionIndexHold;
    NSInteger sectionIndexGrade;
    NSInteger sectionIndexLongShort;
    NSInteger sectionIndexPlate;
    NSInteger sectionIndexNews;
    
    CGFloat cellHoldHeight;
    NSInteger holdPageCount;
    NSInteger holdShowType;
}

@end

@implementation StockDetailViewController

@synthesize stockInfo;
@synthesize title;

#pragma mark - View Load

// 底部按钮尺寸
#define ButtonViewHeight        50

// 操作弹窗及按钮尺寸
#define OperateButtonNum        4
#define OperateButtonHeight     45

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTagHideTabbarNoti object:nil];
    
    self.view.backgroundColor = KSelectNewColor;
    
    headerView.backgroundColor = kFontColorA;
    [headerView refreshButton];
    
    isMoreOpen = NO;
    
    // 加载数据
    [self loadCacheData];
    [self reloadTableData];
    
    // 创建界面
    [self createHeader];
    [self createBackButton];
    [self createTableView];
    [self createHeadView];
    [self createLineView];
    [self createFootView];
    [self createButtonView];
    [self createOperateView];
    
    if (stockInfo.type)
    {
        [self createHeart];
    }
    
    //下拉刷新
    if (!refreshview)
    {
        refreshview = [[EGORefreshTableHeaderView alloc] initWithFrame: CGRectMake(0, -64, screenWidth, 64)];
        refreshview.delegate = self;
        [infoTableView addSubview:refreshview];
    }
    
    [headerView loadStockTitle:stockInfo];
    
    if (realtimeData != nil) {
        [self reloadHeaderView];
    }
    
    // 诸葛统计（查看股票详情）
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"股票代码"] = stockInfo.code;
    dict[@"股票名称"] = stockInfo.name;
    [[Zhuge sharedInstance] track:@"查看股票详情" properties:dict];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self delayMessageSync];
    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:0.5];
    [self requestData];
    [infoTableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [marketTimer invalidate];
    [heartTimer invalidate];
    [super viewWillDisappear:YES];
}

- (void)createBackButton
{
    UIButton * backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, beginX, 60, kTagHeaderHeight)];
    backButton.tag = 1;
    UIImageView * backImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, beginX+13, 11, 20)];
    [backImage setBackgroundColor:[UIColor clearColor]];
    backImage.image = [UIImage imageNamed:@"jiantoubai"];
    [headerView addSubview:backImage];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:backButton];
}

- (void)createHeader
{
    if (!timeLabel)
    {
        timeLabel = [[UILabel alloc] init];
        timeLabel.textColor = kFontColorA;
        timeLabel.textAlignment = NSTextAlignmentCenter;
        timeLabel.text = @"";
        timeLabel.font = NormalFontWithSize(10);
        timeLabel.alpha = 0.8;
        timeLabel.frame = CGRectMake(0, beginX+30, screenWidth, 10);
        [headerView addSubview:timeLabel];
    }
}

//创建底部视图
- (void)createButtonView
{
    if (!stockInfo.type)
    {
        return;
    }
    if (!buttonView)
    {
        buttonView = [[UIView alloc] init];
    }
    buttonView.frame = CGRectMake(0, screenHeight - 50, screenWidth, 50);
    buttonView.userInteractionEnabled = YES;
    buttonView.backgroundColor = kFontColorA;
    [self.view addSubview:buttonView];
    [self.view bringSubviewToFront:buttonView];
    
    UILabel * lineLabel = [[UILabel alloc] init];
    lineLabel.frame = CGRectMake(0, 0, screenWidth, 1);
    lineLabel.backgroundColor = KLineNewBGColor7;
    [buttonView addSubview:lineLabel];
    
    if (!buyLongButton)
    {
        buyLongButton = [[UIButton alloc] init];
    }
    buyLongButton.titleLabel.font = NormalFontWithSize(16);
    buyLongButton.frame = CGRectMake(0, 0, screenWidth/3, 50);
    [buyLongButton setTitle:@"买涨" forState:UIControlStateNormal];
    [buyLongButton setTitleColor:KFontNewColorB forState:UIControlStateNormal];
    [buyLongButton addTarget:self action:@selector(buyLongBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:buyLongButton];
    
    if (!buyShortButton)
    {
        buyShortButton = [[UIButton alloc] init];
    }
    buyShortButton.titleLabel.font = NormalFontWithSize(16);
    buyShortButton.frame = CGRectMake(screenWidth/3, 0, screenWidth/3, 50);
    [buyShortButton setTitle:@"买跌" forState:UIControlStateNormal];
    [buyShortButton setTitleColor:KFontNewColorB forState:UIControlStateNormal];
    [buyShortButton addTarget:self action:@selector(buyShortBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:buyShortButton];
    
    buyTipPoint = [[UILabel alloc] init];
    buyTipPoint.frame = CGRectMake(10, 21, 8, 8);
    buyTipPoint.backgroundColor = kRedColor;
    buyTipPoint.layer.cornerRadius = 4;
    buyTipPoint.layer.masksToBounds = YES;
    [buyShortButton addSubview:buyTipPoint];
    NSString *buyShortTip = [[UserInfoCoreDataStorage sharedInstance] getSettingInfoWithKey:kTagBuyShortTip];
    if (buyShortTip != nil) {
        buyTipPoint.hidden = YES;
    }
    
    if (!moreOperateButton)
    {
        moreOperateButton = [[UIButton alloc] init];
    }
    moreOperateButton.titleLabel.font = NormalFontWithSize(16);
    moreOperateButton.frame = CGRectMake(screenWidth*2/3, 0, screenWidth/3, 50);
    [moreOperateButton setTitle:@"更多操作" forState:UIControlStateNormal];
    [moreOperateButton addTarget:self action:@selector(moreOperateBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [moreOperateButton setTitleColor:KFontNewColorA forState:UIControlStateNormal];
    [buttonView addSubview:moreOperateButton];
    
    moreTipPoint = [[UILabel alloc] init];
    moreTipPoint.frame = CGRectMake(10, 21, 8, 8);
    moreTipPoint.backgroundColor = kRedColor;
    moreTipPoint.layer.cornerRadius = 4;
    moreTipPoint.layer.masksToBounds = YES;
    [moreOperateButton addSubview:moreTipPoint];
    NSString *sellShortTip = [[UserInfoCoreDataStorage sharedInstance] getSettingInfoWithKey:kTagSellShortTip];
    if (sellShortTip != nil) {
        moreTipPoint.hidden = YES;
    }
    
    for (int i = 0; i<2; i++ )
    {
        UILabel * lineLab = [[UILabel alloc] init];
        lineLab.frame = CGRectMake(screenWidth/3*(i+1), 10, 0.5, 30 );
        lineLab.backgroundColor = KColorHeader;
        [buttonView addSubview:lineLab];
    }
}

//创建心
- (void)createHeart
{
    UIButton * heartBtn = [[UIButton alloc] init];
    heartBtn.backgroundColor = [UIColor clearColor];
    heartBtn.frame = CGRectMake(0, screenHeight - 110, 80, 50);
    [heartBtn addTarget:self action:@selector(heartBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:heartBtn];
    
    if (!bottomImageView)
    {
        bottomImageView = [[UIImageView alloc] init];
    }
    bottomImageView.image = [UIImage imageNamed:@"icon_hongxin_bj"];
    bottomImageView.frame = CGRectMake(15, 10, 40, 40);
    [heartBtn addSubview:bottomImageView];
    
    if (!smallImageView)
    {
        smallImageView = [[UIImageView alloc] init];
    }
    smallImageView.frame = CGRectMake(23.5/2, 12.5, 16.5, 15);
    smallImageView.image = [UIImage imageNamed:@"icon_small"];
    [bottomImageView addSubview:smallImageView];
    
    if (!bigImageView)
    {
        bigImageView = [[UIImageView alloc] init];
    }
    bigImageView.frame = CGRectMake(9.25, 10.25, 21.5, 19.5);
    bigImageView.image = [UIImage imageNamed:@"icon_big"];
    [bottomImageView addSubview:bigImageView];
    
    if (!smallNumLabel)
    {
        smallNumLabel = [[UILabel alloc]init];
    }
    smallNumLabel.backgroundColor = [UIColor clearColor];
    smallNumLabel.text = @"0";
    smallNumLabel.textAlignment = NSTextAlignmentCenter;
    smallNumLabel.textColor = kFontColorA;
    smallNumLabel.font = NormalFontWithSize(17);
    smallNumLabel.frame = CGRectMake(0, 0, 40, 40);
    smallNumLabel.layer.cornerRadius = 20;
    smallNumLabel.layer.masksToBounds = YES;
    [bottomImageView addSubview:smallNumLabel];
}

//创建更多弹窗
- (void)createOperateView
{
    if (!operateView)
    {
        operateView = [[UIView alloc] init];
    }
    operateView.frame = CGRectMake(screenWidth*2/3, screenHeight-60 ,screenWidth/3-3, 4*OperateButtonHeight);
    operateView.backgroundColor = kFontColorA;
    operateView.hidden = YES;
    [self.view addSubview:operateView];
    [self.view insertSubview:operateView belowSubview:buttonView];
    
    // 画四周及中间的线
    UILabel * horlineLabel1 = [[UILabel alloc] init];
    horlineLabel1.frame = CGRectMake(0, 0, screenWidth/3, 1);
    horlineLabel1.backgroundColor = KSelectNewColor;
    [operateView addSubview:horlineLabel1];
    
    UILabel * horlineLabel2 = [[UILabel alloc] init];
    horlineLabel2.frame = CGRectMake(10, 45, screenWidth/3-20, 1);
    horlineLabel2.backgroundColor = KSelectNewColor;
    [operateView addSubview:horlineLabel2];
    
    UILabel * horlineLabel3 = [[UILabel alloc] init];
    horlineLabel3.frame = CGRectMake(10, 45*2, screenWidth/3-20, 1);
    horlineLabel3.backgroundColor = KSelectNewColor;
    [operateView addSubview:horlineLabel3];
    
    UILabel * horlineLabel4 = [[UILabel alloc] init];
    horlineLabel4.frame = CGRectMake(10, 45*3, screenWidth/3 -20, 1);
    horlineLabel4.backgroundColor = KSelectNewColor;
    [operateView addSubview:horlineLabel4];
    
    UILabel * horlineLabel5 = [[UILabel alloc] init];
    horlineLabel5.frame = CGRectMake(0, 45*4-1, screenWidth/3, 1);
    horlineLabel5.backgroundColor = KSelectNewColor;
    [operateView addSubview:horlineLabel5];
    
    UILabel * verlineLabel1 = [[UILabel alloc] init];
    verlineLabel1.frame = CGRectMake(0, 0, 1, 4*45);
    verlineLabel1.backgroundColor = KSelectNewColor;
    [operateView addSubview:verlineLabel1];
    
    UILabel * verlineLabel2 = [[UILabel alloc] init];
    verlineLabel2.frame = CGRectMake(screenWidth/3-2, 0, 1, 4*45);
    verlineLabel2.backgroundColor = KSelectNewColor;
    [operateView addSubview:verlineLabel2];
    
    
    // 卖涨按钮
    if (nil == sellLongButton) {
        sellLongButton = [[UIButton alloc] init];
    }
    sellLongButton.backgroundColor = [UIColor clearColor];
    sellLongButton.frame = CGRectMake(0, 0, CGRectGetWidth(operateView.frame), CGRectGetHeight(operateView.frame)/4);
    sellLongButton.titleLabel.font = NormalFontWithSize(14);
    [sellLongButton setTitleColor:KFontNewColorA forState:UIControlStateNormal];
    [sellLongButton setTitle:@"卖涨" forState:UIControlStateNormal];
    [sellLongButton addTarget:self action:@selector(sellLongBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [operateView addSubview:sellLongButton];
    
    
    // 卖跌按钮
    if (nil == sellShortButton) {
        sellShortButton = [[UIButton alloc] init];
    }
    sellShortButton.backgroundColor = [UIColor clearColor];
    sellShortButton.frame = CGRectMake(0, CGRectGetMaxY(sellLongButton.frame), CGRectGetWidth(operateView.frame), CGRectGetHeight(operateView.frame)/4);
    sellShortButton.titleLabel.font = NormalFontWithSize(14);
    [sellShortButton setTitleColor:KFontNewColorA forState:UIControlStateNormal];
    [sellShortButton setTitle:@"卖跌" forState:UIControlStateNormal];
    [sellShortButton addTarget:self action:@selector(sellShortBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [operateView addSubview:sellShortButton];
    
    
    // 提醒按钮
    if (!remindButton) {
        remindButton = [[UIButton alloc] init];
    }
    remindButton.backgroundColor = [UIColor clearColor];
    remindButton.frame = CGRectMake(0, CGRectGetMaxY(sellShortButton.frame), CGRectGetWidth(operateView.frame), CGRectGetHeight(operateView.frame)/4);
    remindButton.titleLabel.font = NormalFontWithSize(14);
    [remindButton setTitleColor:KFontNewColorA forState:UIControlStateNormal];
    [remindButton setTitle:@"添加提醒" forState:UIControlStateNormal];
    [remindButton addTarget:self action:@selector(remindBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [operateView addSubview:remindButton];
    
    
    // 自选按钮
    if (!selectButton) {
        selectButton = [[UIButton alloc] init];
    }
    selectButton.backgroundColor = [UIColor clearColor];
    selectButton.frame = CGRectMake(0, CGRectGetMaxY(remindButton.frame), CGRectGetWidth(operateView.frame), CGRectGetHeight(operateView.frame)/4);
    selectButton.titleLabel.font = NormalFontWithSize(14);
    [selectButton setTitleColor:KFontNewColorA forState:UIControlStateNormal];
    [selectButton setTitle:@"添加购物车/自选" forState:UIControlStateNormal];
    [selectButton addTarget:self action:@selector(selectBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [operateView addSubview:selectButton];
}

- (void)delayHidden
{
    operateView.hidden = YES;
}

- (void)reloadButtonView
{
    if (!stockInfo.type)
    {
        return;
    }
    isMoreOpen = YES;
    
    // 买涨按钮是否可用
    if (realtimeData.buyStatus == 0) {
        [buyLongButton setTitleColor:KFontNewColorB forState:UIControlStateNormal];
    }
    else if (realtimeData.buyStatus == 1) {
        [buyLongButton setTitleColor:KFontNewColorA forState:UIControlStateNormal];
    }
    
    // 买跌按钮是否可用
    if (realtimeData.shortBuyStatus == 0) {
        [buyShortButton setTitleColor:KFontNewColorB forState:UIControlStateNormal];
    }
    else if (realtimeData.shortBuyStatus == 1) {
        [buyShortButton setTitleColor:KFontNewColorA forState:UIControlStateNormal];
    }
    
    // 卖涨按钮是否可用
    if (realtimeData.sellStatus == 0){
        [sellLongButton setTitleColor:KFontNewColorB forState:UIControlStateNormal];
    }
    else if (realtimeData.sellStatus == 1) {
        [sellLongButton setTitleColor:KFontNewColorA forState:UIControlStateNormal];
    }
    
    // 卖跌按钮是否可用
    if (realtimeData.shortSellStatus == 0) {
        [sellShortButton setTitleColor:KFontNewColorB forState:UIControlStateNormal];
    }
    else if (realtimeData.shortSellStatus == 1) {
        [sellShortButton setTitleColor:KFontNewColorA forState:UIControlStateNormal];
    }
    
    // 提醒按钮文案
    if (realtimeData.isSetRemind == 1) {
        [remindButton setTitle:@"编辑提醒" forState:UIControlStateNormal];
    }
    else if(realtimeData.isSetRemind == 2) {
        [remindButton setTitle:@"添加提醒" forState:UIControlStateNormal];
    }
    
    // 自选按钮文案
    if (realtimeData.isSelected == 0) {
        [selectButton setTitle:@"添加购物车/自选" forState:UIControlStateNormal];
    }
    else if(realtimeData.isSelected == 1) {
        [selectButton setTitle:@"取消购物车/自选" forState:UIControlStateNormal];
    }
}

//创建tableview
- (void)createTableView
{
    if (!infoTableView)
    {
        infoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,CGRectGetMaxY(headerView.frame), screenWidth, screenHeight-64 - 50) style:UITableViewStyleGrouped];
        if (!stockInfo.type)
        {
            infoTableView.frame = CGRectMake(0,CGRectGetMaxY(headerView.frame), screenWidth, screenHeight-64);
        }
    }
    infoTableView.backgroundView = [[UIView alloc]init];
    infoTableView.backgroundColor = [UIColor clearColor];
    infoTableView.dataSource = self;
    infoTableView.delegate = self;
    infoTableView.separatorStyle = NO;
    infoTableView.showsVerticalScrollIndicator = NO;
    
    [self.view addSubview:infoTableView];
}

- (void)createFootView
{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 40)];
    view.backgroundColor = KSelectNewColor;
    infoTableView.tableFooterView = view;
}

- (void)heartAnimate
{
    showOrHide = !showOrHide;
    if (showOrHide)
    {
        if (nil == realtimeData || [realtimeData.stockFeeling isEqualToString:@"0"])
        {
            smallImageView.hidden = NO;
            bigImageView.hidden = YES;
            smallNumLabel.hidden = YES;
        }
        else
        {
            smallImageView.hidden = YES;
            bigImageView.hidden = YES;
            smallNumLabel.hidden = NO;
            smallNumLabel.text = realtimeData.stockFeeling;
        }
    }
    else
    {
        smallImageView.hidden = YES;
        bigImageView.hidden = NO;
        smallNumLabel.hidden = YES;
    }
}

//创建头部视图
- (void)createHeadView
{
    if (!tableHead)
    {
        tableHead = [[UIView alloc] init];
    }

    tableHead.frame = CGRectMake(0, 0, screenWidth, 165);
    tableHead.backgroundColor = KSelectNewColor;
    
    if (!priceLabel)
    {
        priceLabel = [[UILabel alloc] init ];
        priceLabel.frame = CGRectMake(20, 10, 200, 30);
        priceLabel.textColor = kFontColorA;
        priceLabel.font = NormalFontWithSize(30);
        priceLabel.textAlignment = NSTextAlignmentLeft;
        priceLabel.backgroundColor = [UIColor clearColor];
        priceLabel.text = @"00.00";
        [priceLabel sizeToFit];
        [tableHead addSubview:priceLabel];
    }
    
    if (!profitLabel)
    {
        profitLabel = [[UILabel alloc] init ];
        profitLabel.frame = CGRectMake(CGRectGetMaxX(priceLabel.frame)+10,CGRectGetMinY(priceLabel.frame)+3, 100, 15);
        profitLabel.textColor = kFontColorA;
        profitLabel.font = NormalFontWithSize(10);
        profitLabel.textAlignment = NSTextAlignmentLeft;
        profitLabel.backgroundColor = [UIColor clearColor];
        profitLabel.text = @"--";
        [tableHead addSubview:profitLabel];
    }
    
    if (!percentLabel)
    {
        percentLabel = [[UILabel alloc] init];
        percentLabel.frame = CGRectMake(CGRectGetMaxX(priceLabel.frame)+10,CGRectGetMaxY(profitLabel.frame), 100, 15);
        percentLabel.textColor = kFontColorA;
        percentLabel.font = NormalFontWithSize(10);
        percentLabel.textAlignment = NSTextAlignmentLeft;
        percentLabel.backgroundColor = [UIColor clearColor];
        percentLabel.text = @"--";
        [tableHead addSubview:percentLabel];
    }
    
    if (!compareLabel)
    {
        compareLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(priceLabel.frame),CGRectGetMaxY(priceLabel.frame), screenWidth - 20, 15)];
        compareLabel.textColor = kFontColorA;
        compareLabel.font = NormalFontWithSize(10);
        compareLabel.textAlignment = NSTextAlignmentLeft;
        compareLabel.backgroundColor = [UIColor clearColor];
        compareLabel.text = @"";
        [tableHead addSubview:compareLabel];
        compareLabel.hidden = YES;
    }
    
    if (!statusLabel)
    {
        statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth - 110, 12, 90, 30)];
        statusLabel.textColor = kFontColorA;
        statusLabel.font = NormalFontWithSize(23);
        statusLabel.text = @"";
        statusLabel.textAlignment = NSTextAlignmentRight;
        statusLabel.backgroundColor = [UIColor clearColor];
        [tableHead addSubview:statusLabel];
    }
    
    infoTableView.tableHeaderView = tableHead;
}

//创建分时图
- (void)createLineView
{
    lineView = [[TimeLineView alloc] initWithFrame:CGRectMake(0,165 -100 , screenWidth -20, 100)];
    lineView.backgroundColor = [UIColor clearColor];
    [tableHead addSubview:lineView];
    lineView.stockInfo = self.stockInfo;
    lineView.type = Get_time_share;
    lineView.userInteractionEnabled = NO;
    [lineView start];
    
    UIButton * KLineButton = [[UIButton alloc] init];
    KLineButton.backgroundColor = [UIColor clearColor];
    KLineButton.frame = CGRectMake(0, 0, screenWidth, 165);
    [KLineButton addTarget:self action:@selector(KLineBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [tableHead addSubview:KLineButton];
    [tableHead bringSubviewToFront:KLineButton];
}

//停止加载
- (void)stopLoading
{
    [headerView.actView stopAnimating];
    headerView.refreshImage.hidden = NO;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    // 结束下拉刷新
    isEgoRefresh = NO;
    [refreshview egoRefreshScrollViewDataSourceDidFinishedLoading:infoTableView];
}

//加载头部详情数据
- (void)reloadHeaderView
{
    profitLabel.text = realtimeData.updownPrice;
    percentLabel.text = realtimeData.updownRange;
    priceLabel.text = realtimeData.currentPrice;
    compareLabel.text = realtimeData.priceCompare;
    if ([priceLabel.text floatValue] >=100)
    {
        priceLabel.frame = CGRectMake(20, 10, 200, 30);
        [priceLabel sizeToFit];
        profitLabel.frame = CGRectMake(CGRectGetMaxX(priceLabel.frame) +10,CGRectGetMinY(priceLabel.frame)+3, 100, 15);
        percentLabel.frame = CGRectMake(CGRectGetMaxX(priceLabel.frame) +10,CGRectGetMaxY(profitLabel.frame), 100, 15);
    }
    if (realtimeData.stockStatus == 1)
    {
        statusLabel.text = @"停牌";
    }
    else
    {
        statusLabel.text = @"";
    }
    // 不在交易时间暂停定时拉取实时数据
    if (realtimeData.isTradable == 0) {
        [marketTimer pauseTimer];
    }
    
    NSString * updown = realtimeData.updown;
    if ([updown isEqualToString:@"down"])
    {
        headerView.backgroundColor = kGreenColor;
        tableHead.backgroundColor = kGreenColor;
    }
    else
    {
        headerView.backgroundColor = kRedColor;
        tableHead.backgroundColor = kRedColor;
    }
    
    // 重新载入市场状态与日期时间
    [self reloadTimeLabel];
}

- (void)reloadTimeLabel
{
    if (nil == realtimeData) {
        return;
    }
    
    NSString *marketStatus = nil;
    if (realtimeData.marketStatus == 0) {
        marketStatus = @"交易中";
    }
    else if (realtimeData.marketStatus == 1) {
        marketStatus = @"已休市";
    }
    else if (realtimeData.marketStatus == 2) {
        marketStatus = @"已收盘";
    }
    
    NSString *statusAndTime = [NSString stringWithFormat:@"%@  %@", marketStatus, realtimeData.dateTime];
    timeLabel.text = statusAndTime;
}

- (UITableViewCell *)createHoldCellWithIdentifier:(NSString *)identifier
{
    CGFloat holdHeight = 77.5;
    CGFloat pageHeight = 22.5;
    
    UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = kFontColorA;
    
    // 持仓cell高度为cellHoldHeight，其它值都根据些值算出
    cell.frame = CGRectMake(0, 0, screenWidth, cellHoldHeight);
    
    holdScrollView = [[UIScrollView alloc] init];
    holdScrollView.frame = CGRectMake(0, 0, screenWidth, cellHoldHeight);
    holdScrollView.contentSize = CGSizeMake(holdPageCount * CGRectGetWidth(holdScrollView.frame), CGRectGetHeight(holdScrollView.frame));
    holdScrollView.contentMode = UIViewContentModeCenter;
    holdScrollView.pagingEnabled = YES;
    holdScrollView.scrollsToTop = NO;
    holdScrollView.showsHorizontalScrollIndicator = NO;
    holdScrollView.delegate = self;
    
    [cell addSubview:holdScrollView];
    
    NSArray *labelArray = [[NSArray alloc]initWithObjects:@"成本价格", @"盈亏金额", @"持股数量", @"盈亏比例", nil];
    
    //////////////////////////////////////////////////////////////
    // 创建买涨持仓页
    
    holdLongView = [[UIView alloc] init];
    holdLongView.frame = CGRectMake(0, 0, CGRectGetMaxX(holdScrollView.frame), holdHeight);
    holdLongView.backgroundColor = [UIColor clearColor];
    UIImageView *holdLongImageView = [[UIImageView alloc] init];
    holdLongImageView.frame = CGRectMake(0, 0, 35, 35);
    holdLongImageView.image = [UIImage imageNamed:@"hold_long"];
    [holdLongView addSubview:holdLongImageView];
    
    // 横线
    UIView *holdLongHorLine = [[UIView alloc] init];
    holdLongHorLine.frame = CGRectMake(15, holdHeight/2, screenWidth-15*2, 1);
    holdLongHorLine.backgroundColor = KLineNewBGColor7;
    [holdLongView addSubview:holdLongHorLine];
    
    // 竖线
    UIView *holdLongVerLine = [[UIView alloc] init];
    holdLongVerLine.frame = CGRectMake(screenWidth/2, 10, 1, holdHeight-10*2);
    holdLongVerLine.backgroundColor = KLineNewBGColor7;
    [holdLongView addSubview:holdLongVerLine];
    
    // 显示标签
    for (int labelIndex = 0; labelIndex < 4; labelIndex++) {
        int row = labelIndex % 2;
        int column = labelIndex / 2;
        
        UILabel *textLabel = [[UILabel alloc] init];
        textLabel.frame = CGRectMake(25 + (screenWidth/2*row), 12.5 + holdHeight/2*column, 70, 15);
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.textColor = KFontNewColorA;
        textLabel.font = NormalFontWithSize(14);
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.text = [labelArray objectAtIndex:labelIndex];
        
        [holdLongView addSubview:textLabel];
        
        
        UILabel *numLabel = [[UILabel alloc] init];
        numLabel.frame = CGRectMake(90 + (screenWidth/2*row), 12.5 + holdHeight/2*column, 70, 15);
        numLabel.textAlignment = NSTextAlignmentRight;
        numLabel.textColor = KFontNewColorB;
        numLabel.font = NormalFontWithSize(14);
        numLabel.backgroundColor = [UIColor clearColor];
        numLabel.text = @"--";
        numLabel.tag = KTagLongPriceNum + labelIndex;
        
        [holdLongView addSubview:numLabel];
    }
    
    
    //////////////////////////////////////////////////////////////
    // 创建买跌持仓页
    
    holdShortView = [[UIView alloc] init];
    holdShortView.frame = CGRectMake(0, 0, CGRectGetMaxX(holdScrollView.frame), holdHeight);
    holdShortView.backgroundColor = [UIColor clearColor];
    UIImageView *holdShortImageView = [[UIImageView alloc] init];
    holdShortImageView.frame = CGRectMake(0, 0, 35, 35);
    holdShortImageView.image = [UIImage imageNamed:@"hold_short"];
    [holdShortView addSubview:holdShortImageView];
    
    // 横线
    UIView *holdShortHorLine = [[UIView alloc] init];
    holdShortHorLine.frame = CGRectMake(15, holdHeight/2, screenWidth-15*2, 1);
    holdShortHorLine.backgroundColor = KLineNewBGColor7;
    [holdShortView addSubview:holdShortHorLine];
    
    // 竖线
    UIView *holdShortVerLine = [[UIView alloc] init];
    holdShortVerLine.frame = CGRectMake(screenWidth/2, 10, 1, holdHeight-10*2);
    holdShortVerLine.backgroundColor = KLineNewBGColor7;
    [holdShortView addSubview:holdShortVerLine];
    
    // 显示标签
    for (int labelIndex = 0; labelIndex < 4; labelIndex++) {
        int row = labelIndex % 2;
        int column = labelIndex / 2;
        
        UILabel *textLabel = [[UILabel alloc] init];
        textLabel.frame = CGRectMake(25 + (screenWidth/2*row), 12.5 + holdHeight/2*column, 70, 15);
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.textColor = KFontNewColorA;
        textLabel.font = NormalFontWithSize(14);
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.text = [labelArray objectAtIndex:labelIndex];
        
        [holdShortView addSubview:textLabel];
        
        UILabel *numLabel = [[UILabel alloc] init];
        numLabel.frame = CGRectMake(90 + (screenWidth/2*row), 12.5 + holdHeight/2*column, 70, 15);
        numLabel.textAlignment = NSTextAlignmentRight;
        numLabel.textColor = KFontNewColorB;
        numLabel.font = NormalFontWithSize(14);
        numLabel.backgroundColor = [UIColor clearColor];
        numLabel.text = @"--";
        numLabel.tag = KTagShortPriceNum + labelIndex;
        
        [holdShortView addSubview:numLabel];
    }
    
    pageControl = [[UIPageControl alloc] init];
    pageControl.frame = CGRectMake((screenWidth-50)/2, holdHeight, 50, pageHeight);
    pageControl.backgroundColor = [UIColor clearColor];
    pageControl.currentPageIndicatorTintColor = KFontNewColorB;
    pageControl.pageIndicatorTintColor = KSelectNewColor;
    pageControl.numberOfPages = 2;
    pageControl.enabled = NO;
    [cell addSubview:pageControl];
    
    if (holdPageCount < 2) {
        pageControl.hidden = YES;
    }
    
    if (holdShowType == 1) {
        [holdScrollView addSubview:holdLongView];
    }
    else if (holdShowType == 2) {
        [holdScrollView addSubview:holdShortView];
    }
    else if (holdShowType == 3) {
        [holdScrollView addSubview:holdLongView];
        CGRect holdRect = holdLongView.frame;
        holdRect.origin = CGPointMake(CGRectGetMaxX(holdLongView.frame), 0);
        holdShortView.frame = holdRect;
        [holdScrollView addSubview:holdShortView];
    }

    return cell;
}

#pragma mark - Control Action
- (void)back:(UIButton*)sender
{
    [self back];
}

//headerview 上 button 点击事件
- (void)buttonClicked:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    if (btn.tag == 2)
    {
        [self requestData];
    }
    else
    {
        [self back];
    }
}

- (void)heartBtnOnClick:(UIButton*)sender
{
    EmotionViewController * EVC = [[EmotionViewController alloc] init];
    EVC.stockInfo = stockInfo;
    [self pushToViewController:EVC];
}

- (void)buyLongBtnClicked:(id)sender
{
    if (nil == realtimeData) {
        return;
    }
    
    if (realtimeData.buyStatus == 0)
    {
        //不可买
        [[CHNAlertView defaultAlertView] showContent:realtimeData.buyMessage cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
    }
    else if (realtimeData.buyStatus == 1)
    {
         
        //可买
        BuyStockViewController * BSVC = [[BuyStockViewController alloc] init];
        BSVC.stockInfo = self.stockInfo;
        BSVC.holdType = StockHoldTypeLong;
        [self pushToViewController:BSVC];
        
        // 诸葛统计（用户买涨-股票详情页）
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"股票名"] = self.stockInfo.name;
        [[Zhuge sharedInstance] track:@"用户买涨-股票详情页" properties:dict];
    }
}

- (void)buyShortBtnClicked:(id)sender
{
    // 隐藏提示红点
    buyTipPoint.hidden = YES;
    [[UserInfoCoreDataStorage sharedInstance] saveSettingInfoWithKey:kTagBuyShortTip value:@"1"];
    
    if (nil == realtimeData) {
        return;
    }
    
    if (realtimeData.shortBuyStatus == 0)
    {
        //不可买
        [[CHNAlertView defaultAlertView] showContent:realtimeData.shortBuyMessage cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
    }
    else if (realtimeData.shortBuyStatus == 1)
    {
        if (realtimeData.shortCardStatus == ShortCardStatusNoCardNoUse)
        {
            [self requestCardBuyInfo:PropCardCardIDMakeShort withNum:@"1"];
        }
        else if (realtimeData.shortCardStatus == ShortCardStatusHasCardNoUse)
        {
            [self requestCardInfo:PropCardCardIDMakeShort];
        }
        else if (realtimeData.shortCardStatus == ShortCardStatusHasCardHasUse)
        {
            [self toBuyVC];
        }
    }
}

- (void)toBuyVC
{
    //可买
    BuyStockViewController * BSVC = [[BuyStockViewController alloc] init];
    BSVC.stockInfo = self.stockInfo;
    BSVC.holdType = StockHoldTypeShort;
    [self pushToViewController:BSVC];
    
    // 诸葛统计（用户买跌-股票详情页）
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"股票名"] = self.stockInfo.name;
    [[Zhuge sharedInstance] track:@"用户买跌-股票详情页" properties:dict];
}

- (void)sellLongBtnClicked:(id)sender
{
    if (realtimeData.sellStatus == 0)
    {
        //不可卖
        [[CHNAlertView defaultAlertView] showContent:realtimeData.sellMessage cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
    }
    else if (realtimeData.sellStatus == 1)
    {
        //可卖
        SellStockViewController * SSVC = [[SellStockViewController alloc] init];
        SSVC.stockInfo = self.stockInfo;
        SSVC.holdType = StockHoldTypeLong;
        [self pushToViewController:SSVC];
        
        // 诸葛统计（用户卖涨-股票详情页）
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"股票名"] = self.stockInfo.name;
        [[Zhuge sharedInstance] track:@"用户卖涨-股票详情页" properties:dict];
    }
}

- (void)sellShortBtnClicked:(id)sender
{
    if (realtimeData.shortSellStatus == 0)
    {
        //不可卖
        [[CHNAlertView defaultAlertView] showContent:realtimeData.shortSellMessage cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
    }
    else if (realtimeData.shortSellStatus == 1)
    {
        //可卖
        SellStockViewController * SSVC = [[SellStockViewController alloc] init];
        SSVC.stockInfo = self.stockInfo;
        SSVC.holdType = StockHoldTypeShort;
        [self pushToViewController:SSVC];
        
        // 诸葛统计（用户卖跌-股票详情页）
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"股票名"] = self.stockInfo.name;
        [[Zhuge sharedInstance] track:@"用户卖跌-股票详情页" properties:dict];
    }
}

//更多操作
- (void)moreOperateBtnOnClick:(UIButton *)sender
{
    // 隐藏提示红点
    moreTipPoint.hidden = YES;
    [[UserInfoCoreDataStorage sharedInstance] saveSettingInfoWithKey:kTagSellShortTip value:@"1"];
    
    CGRect soureRect = operateView.frame;
    CGRect destRect = operateView.frame;
    if (isMoreOpen)
    {
        operateView.hidden = NO;
        soureRect.origin = CGPointMake(CGRectGetMinX(moreOperateButton.frame), screenHeight-ButtonViewHeight);
        destRect.origin = CGPointMake(CGRectGetMinX(moreOperateButton.frame), screenHeight-45*4-ButtonViewHeight-3);
        
        operateView.frame = soureRect;
        [UIView beginAnimations:@"Animation" context:nil];
        [UIView setAnimationDuration:0.5];
        operateView.frame = destRect;
        [UIView commitAnimations];
        isMoreOpen = NO;
    }
    else
    {
        soureRect.origin = CGPointMake(CGRectGetMinX(moreOperateButton.frame), screenHeight-45*4-ButtonViewHeight-3);
        destRect.origin = CGPointMake(CGRectGetMinX(moreOperateButton.frame), screenHeight-ButtonViewHeight);
        operateView.frame = soureRect;
        [UIView beginAnimations:@"Animation" context:nil];
        [UIView setAnimationDuration:0.5];
        operateView.frame = destRect;
        [UIView commitAnimations];
        [self performSelector:@selector(delayHidden) withObject:self afterDelay:0.5];
        isMoreOpen = YES;
    }
}

// 添加自选按钮
- (void)selectBtnOnClick:(UIButton *)sender
{
    operateView.hidden = YES;
    if (realtimeData.isSelected == 0)
    {
        NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
        [paramDic setObject:stockInfo.code forKey:@"stock_code"];
        [paramDic setObject:stockInfo.exchange forKey:@"stock_exchange"];
        [GFRequestManager connectWithDelegate:self action:Submit_stock_watchlist param:paramDic];
        
        [selectButton setTitle:@"取消购物车/自选" forState:UIControlStateNormal];
        
        // 诸葛统计（添加自选-股票详情页）
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"股票名"] = stockInfo.name;
        [[Zhuge sharedInstance] track:@"添加自选-股票详情页" properties:dict];
    }
    else if (realtimeData.isSelected == 1)
    {
        NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
        [paramDic setObject:stockInfo.code forKey:@"stock_code"];
        [paramDic setObject:stockInfo.exchange forKey:@"stock_exchange"];
        [GFRequestManager connectWithDelegate:self action:Delete_stock_watchlist param:paramDic];
        
        [selectButton setTitle:@"添加购物车/自选" forState:UIControlStateNormal];
        
        // 诸葛统计（取消自选-股票详情页）
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"股票名"] = stockInfo.name;
        [[Zhuge sharedInstance] track:@"取消自选-股票详情页" properties:dict];
    }
}

// 添加提醒
- (void)remindBtnOnClick:(UIButton*)sender
{
    operateView.hidden = YES;
    NoticeSettingViewController * NSVC = [[NoticeSettingViewController alloc] init];
    NSVC.stockInfo = self.stockInfo;
    [self pushToViewController:NSVC];
}

// 点击进入K线图
- (void)KLineBtnOnClick:(UIButton*)sender
{
    StockLineViewController * SLVC = [[StockLineViewController alloc] init];
    
    SLVC.stockInfo = stockInfo;
    [self pushToViewController:SLVC];
}

//点击更多资讯
- (void)moreNewsBtnOnClick:(UIButton*)sender
{
    InformationViewController * IVC = [[InformationViewController alloc]init];
    IVC.stockInfo = self.stockInfo;
    [self pushToViewController:IVC];
}

//点击进入板块
- (void)indexBtnClicked:(UIButton*)sender
{
    StockPlateEntity *stockPlate = [plateArr objectAtIndex:sender.tag];
    
    SubSectionViewController * SSVC = [[SubSectionViewController alloc] init];
    SSVC.plate_code = stockPlate.plateInfo.code;
    SSVC.plate_name = stockPlate.plateInfo.name;
    [self pushToViewController:SSVC];
}

#pragma mark - Private Method
- (void)loadCacheData
{
    // 读取股票实时数据
    realtimeData = [[StockInfoCoreDataStorage sharedInstance] getStockRealtimeDataWithCode:stockInfo.code exchange:stockInfo.exchange];
    
    if (stockInfo.type) {
        // 读取股票评级数据
        stockGrade = [[StockInfoCoreDataStorage sharedInstance] getStockGradeWithCode:stockInfo.code exchange:stockInfo.exchange];
        // 读取所属板块数据
        plateArr = [[StockInfoCoreDataStorage sharedInstance] getStockPlateWithCode:stockInfo.code exchange:stockInfo.exchange];
    }
}

- (void)reloadTableData
{
    realtimeData = [[StockInfoCoreDataStorage sharedInstance] getStockRealtimeDataWithCode:stockInfo.code exchange:stockInfo.exchange];
    
    if (nil == realtimeData) {
        sectionNumber = 0;
        return;
    }
    
    if (stockInfo.type == 0) {
        // 指数详情，只有资讯项
        sectionNumber = 1;
        
        sectionIndexHold = -1;
        sectionIndexGrade = -1;
        sectionIndexLongShort = -1;
        sectionIndexPlate = -1;
        sectionIndexNews = 0;
    }
    else if (stockInfo.type == 1) {
        // 股票详情
        if (realtimeData != nil && (realtimeData.isHoldings == 1 ||
                                    realtimeData.shortIsHoldings == 1)) {
            // 有持仓，增加持仓项
            sectionNumber = 5;
            
            sectionIndexHold = 0;
            sectionIndexGrade = 1;
            sectionIndexLongShort = 2;
            sectionIndexPlate = 3;
            sectionIndexNews = 4;
        }
        else {
            // 没持仓，去掉持仓项
            sectionNumber = 4;
            
            sectionIndexHold = -1;
            sectionIndexGrade = 0;
            sectionIndexLongShort = 1;
            sectionIndexPlate = 2;
            sectionIndexNews = 3;
        }
    }
    
    [self reloadCellHoldData];
}

- (void)reloadCellHoldData
{
    if (nil == realtimeData) {
        return;
    }
    
    if (realtimeData.isHoldings == 1 && realtimeData.shortIsHoldings == 0) {
        cellHoldHeight = 77.5;
        holdPageCount = 1;
        
        holdShowType = 1;
    }
    else if (realtimeData.isHoldings == 0 && realtimeData.shortIsHoldings == 1) {
        cellHoldHeight = 77.5;
        holdPageCount = 1;
        
        holdShowType = 2;
    }
    
    else if (realtimeData.isHoldings == 1 && realtimeData.shortIsHoldings == 1) {
        cellHoldHeight = 100;
        holdPageCount = 2;
        
        holdShowType = 3;
    }
}

- (void)delayMessageSync
{
    marketTimer = [NSTimer scheduledTimerWithTimeInterval:12 target:self selector:@selector(requestStockInfo) userInfo:nil repeats:YES];
    if (stockInfo.type)
    {
        heartTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(heartAnimate) userInfo:nil repeats:YES];
    }
}

- (void)configHoldData
{
    if (realtimeData == nil) {
        return;
    }
    
    // 设置买涨持仓数据
    UILabel *longPriceNumLabel = (UILabel *)[holdScrollView viewWithTag:KTagLongPriceNum];
    UILabel *longProfitNumLabel = (UILabel *)[holdScrollView viewWithTag:KTagLongProfitNum];
    UILabel *longHoldNumLabel = (UILabel *)[holdScrollView viewWithTag:KTagLongHoldNum];
    UILabel *longPercentNumLabel = (UILabel *)[holdScrollView viewWithTag:KTagLongPercentNum];
    
    longPriceNumLabel.text = realtimeData.userTradePrice;
    longProfitNumLabel.text = realtimeData.userProfitMoney;
    longHoldNumLabel.text = realtimeData.userTradeAmount;
    longPercentNumLabel.text = realtimeData.userProfitRate;
    
    if ([longPercentNumLabel.text floatValue] < 0) {
        longProfitNumLabel.textColor = kGreenColor;
        longPercentNumLabel.textColor = kGreenColor;
    }
    else {
        longProfitNumLabel.textColor = kRedColor;
        longPercentNumLabel.textColor = kRedColor;
    }
    
    
    // 设置买跌持仓数据
    UILabel *shortPriceNumLabel = (UILabel *)[holdScrollView viewWithTag:KTagShortPriceNum];
    UILabel *shortProfitNumLabel = (UILabel *)[holdScrollView viewWithTag:KTagShortProfitNum];
    UILabel *shortHoldNumLabel = (UILabel *)[holdScrollView viewWithTag:KTagShortHoldNum];
    UILabel *shortPercentNumLabel = (UILabel *)[holdScrollView viewWithTag:KTagShortPercentNum];
    
    shortPriceNumLabel.text = realtimeData.shortUserTradePrice;
    shortProfitNumLabel.text = realtimeData.shortUserProfitMoney;
    shortHoldNumLabel.text = realtimeData.shortUserTradeAmount;
    shortPercentNumLabel.text = realtimeData.shortUserProfitRate;

    if ([shortPercentNumLabel.text floatValue] < 0) {
        shortProfitNumLabel.textColor = kGreenColor;
        shortPercentNumLabel.textColor = kGreenColor;
    }
    else {
        shortProfitNumLabel.textColor = kRedColor;
        shortPercentNumLabel.textColor = kRedColor;
    }
}

- (void)propCardInfo:(NSDictionary *)dic
{
    NSInteger type;
    NSInteger propFlag = [CHECKDATA(@"status") integerValue];
    if (propFlag == 1 || propFlag == 10)
    {
        type = 1;
    }
    else
    {
        type = 2;
    }
    
    prop =  [[PropView defaultShareView] initViewWithName:CHECKDATA(@"card_name") WithDescription:CHECKDATA(@"desc") WithType:type Delegate:self WithImageURL:CHECKDATA(@"img") WithDirect:[CHECKDATA(@"link_to") integerValue]?@"查看感情度":@""  WithPrompt:CHECKDATA(@"button_desc") isBuy:NO cardPrice:@"" usable:@"" ExpireTime:@""];
    prop.delegate = self;
    [prop showView];
}

- (void)propCardBuyInfo:(NSDictionary *)dic
{
    if (prop.isShow)
    {
        int numValue;
        if (prop.isAdd)
        {
            numValue = [prop.numLabel.text intValue]+1;
        }
        else
        {
            numValue = [prop.numLabel.text intValue]-1;
        }
        prop.numLabel.text = [NSString stringWithFormat:@"%d",numValue];
        [prop.buyBtn setTitle:CHECKDATA(@"button_buy") forState:UIControlStateNormal];
    }
    else
    {
        prop =  [[PropView defaultShareView] initViewWithName:CHECKDATA(@"card_name") WithDescription:CHECKDATA(@"desc") WithType:1 Delegate:self WithImageURL:CHECKDATA(@"img") WithDirect:@"" WithPrompt:CHECKDATA(@"button_buy")  isBuy:YES cardPrice:CHECKDATA(@"button_buy") usable:[NSString stringWithFormat:@"可用盈利%@",CHECKDATA(@"usable_buy_money")] ExpireTime:@""];
        prop.delegate = self;
        [prop showView];
    }
}

- (void)buyCardFinished:(NSDictionary *)dic
{
    [[TKAlertCenter defaultCenter] postAlertWithMessage:CHECKDATA(@"prompt1") withType:ALERTTYPEERROR];
    [prop hideView];
}

- (void)addBtnClicked:(id)sender
{
    prop.leftImage.enabled = YES;
    UIButton * btn = (UIButton *)sender;
    int numValue = [prop.numLabel.text intValue];
    
    [self requestCardBuyInfo:[NSString stringWithFormat:@"%ld",btn.tag] withNum:[NSString stringWithFormat:@"%d",numValue+1]];
}

- (void)minusBtnClicked:(id)sender
{
    prop.leftImage.enabled = YES;
    if ([prop.numLabel.text integerValue] > 1)
    {
        UIButton * btn = (UIButton *)sender;
        int numValue = [prop.numLabel.text intValue]-1;
        
        if (numValue == 1)
        {
            prop.leftImage.enabled = NO;
        }
        
        [self requestCardBuyInfo:[NSString stringWithFormat:@"%ld",btn.tag] withNum:[NSString stringWithFormat:@"%d",numValue]];
    }
    else
    {
        prop.leftImage.enabled = NO;
    }
}

- (void)buyBtnClicked:(id)sender
{
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setObject:PropCardCardIDMakeShort forKey:@"card_id"];
    [param setObject:prop.numLabel.text forKey:@"buy_num"];
    [GFRequestManager connectWithDelegate:self action:Submit_buy_card param:param];
}

- (void)cardToUse:(NSInteger)index
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:PropCardCardIDMakeShort forKey:@"card_id"];
    [paramDic setObject:@"1" forKey:@"card_num"];
    [GFRequestManager connectWithDelegate:self action:Submit_use_card param:paramDic];
}


#pragma mark - ASIHTTPRequestDelegate
- (void)requestData
{
    [self requestGrade];
    [self requestStockInfo];
    [self requestPlate];
    [self requestNews];
}

//请求板块
- (void)requestPlate
{
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setObject:stockInfo.code forKey:@"stock_code"];
    [param setObject:stockInfo.exchange forKey:@"stock_exchange"];
    [GFRequestManager connectWithDelegate:self action:Get_stock_hot_plate param:param];
}

//请求新闻
- (void)requestNews
{
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setObject:stockInfo.code forKey:@"stock_code"];
    [param setObject:stockInfo.exchange forKey:@"stock_exchange"];
    [GFRequestManager connectWithDelegate:self action:Get_stock_news_top param:param];
}

//获取股票数据
- (void)requestStockInfo
{
    headerView.refreshImage.hidden = YES;
    [headerView.actView startAnimating];
    
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setObject:stockInfo.code forKey:@"stock_code"];
    [param setObject:stockInfo.exchange forKey:@"stock_exchange"];
    [GFRequestManager connectWithDelegate:self action:Get_realtime_data param:param];
    
    [lineView requestKLineWithType:Get_time_share];
}

//请求评级
- (void)requestGrade
{
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setObject:stockInfo.code forKey:@"stock_code"];
    [param setObject:stockInfo.exchange forKey:@"stock_exchange"];
    [GFRequestManager connectWithDelegate:self action:Get_stock_grade param:param];
}

//请求购买道具卡信息
- (void)requestCardBuyInfo:(NSString *)card_id withNum:(NSString *)num
{
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setObject:card_id forKey:@"card_id"];
    [param setObject:num forKey:@"buy_num"];
    [GFRequestManager connectWithDelegate:self action:Get_card_buy_info param:param];
}

//获取卡片详情
- (void)requestCardInfo:(NSString *)card_id
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:card_id forKey:@"card_id"];
    [GFRequestManager connectWithDelegate:self action:Get_card_info param:paramDic];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:0.5];
    
    isEgoRefresh = NO;
    [refreshview egoRefreshScrollViewDataSourceDidFinishedLoading:infoTableView];
    
    ASIFormDataRequest * formDataRequest = (ASIFormDataRequest*)request;
    if ([formDataRequest.action isEqualToString:Get_stock_grade])
    {
        NSDictionary *gradeDict = [requestInfo objectForKey:@"data"];
        stockGrade = [[StockInfoCoreDataStorage sharedInstance] saveStockGrade:gradeDict];
    }
    else if ([formDataRequest.action isEqualToString:Get_stock_hot_plate])
    {
        NSArray *dataArr = [[requestInfo objectForKey:@"data"] objectForKey:@"list"];
        [[StockInfoCoreDataStorage sharedInstance] saveStockPlate:dataArr code:stockInfo.code exchange:stockInfo.exchange];
        plateArr = [[StockInfoCoreDataStorage sharedInstance] getStockPlateWithCode:stockInfo.code exchange:stockInfo.exchange];
    }
    else if ([formDataRequest.action isEqualToString:Get_stock_news_top])
    {
        newsArr = [[[requestInfo objectForKey:@"data"] objectForKey:@"list"] mutableCopy];
    }
    else if ([formDataRequest.action isEqualToString:Submit_stock_watchlist])
    {
        [[StockInfoCoreDataStorage sharedInstance] addSelectStockWithCode:stockInfo.code exchange:stockInfo.exchange];
        [[StockInfoCoreDataStorage sharedInstance] addStockRealtimeDataSelectedWithCode:stockInfo.code exchange:stockInfo.exchange];
        realtimeData = [[StockInfoCoreDataStorage sharedInstance] getStockRealtimeDataWithCode:stockInfo.code exchange:stockInfo.exchange];
        
        headerView.addSelectImage.image = [UIImage imageNamed:@"icon_minus"];
        headerView.buttonSelected = YES;
        [headerView reloadInputViews];
        [[TKAlertCenter defaultCenter] postAlertWithMessage:@"加入自选成功" withType:ALERTTYPEERROR];
    }
    else if ([formDataRequest.action isEqualToString:Delete_stock_watchlist])
    {
        [[StockInfoCoreDataStorage sharedInstance] delSelectStockWithCode:stockInfo.code exchange:stockInfo.exchange];
        [[StockInfoCoreDataStorage sharedInstance] delStockRealtimeDataSelectedWithCode:stockInfo.code exchange:stockInfo.exchange];
        realtimeData = [[StockInfoCoreDataStorage sharedInstance] getStockRealtimeDataWithCode:stockInfo.code exchange:stockInfo.exchange];
        
        headerView.addSelectImage.image = [UIImage imageNamed:@"icon_add"];
        headerView.buttonSelected = NO;
        [headerView reloadInputViews];
        [[TKAlertCenter defaultCenter] postAlertWithMessage:@"删除自选成功" withType:ALERTTYPEERROR];
    }
    else if ([formDataRequest.action isEqualToString:Get_realtime_data])
    {
        NSDictionary * dic = [requestInfo objectForKey:@"data"];
        if (dic != nil)
        {
            realtimeData = [[StockInfoCoreDataStorage sharedInstance] saveStockRealtimeData:dic];
            
            [self reloadTableData];
            
            // 重新加载底部操作按钮状态
            [self reloadButtonView];
            //重新加载顶部视图
            [self reloadHeaderView];
        }
    }
    else if ([formDataRequest.action isEqualToString:Get_card_info])
    {
        [self propCardInfo:[requestInfo objectForKey:@"data"]];
    }
    else if ([formDataRequest.action isEqualToString:Submit_use_card])
    {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:@"使用成功" withType:ALERTTYPEERROR];
    }
    else if ([formDataRequest.action isEqualToString:Get_card_buy_info])
    {
        [self propCardBuyInfo:[requestInfo objectForKey:@"data"]];
    }
    else if ([formDataRequest.action isEqualToString:Submit_buy_card])
    {
        [self buyCardFinished:[requestInfo objectForKey:@"data"]];
    }
    
    [infoTableView reloadData];
}

//请求失败
- (void)requestFailed:(ASIHTTPRequest *)request
{
    [super requestFailed:request];
    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:0.5];
}

#pragma mark - TableView Delegate & DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sectionNumber;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == sectionIndexHold) {
        return 1;
    }
    else if (section == sectionIndexGrade) {
        return 1;
    }
    else if (section == sectionIndexLongShort) {
        return 1;
    }
    else if (section == sectionIndexPlate) {
        return 1;
    }
    else if (section == sectionIndexNews) {
        return newsArr.count + 1;
    }
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [[UITableViewCell alloc] init];
    cell.backgroundColor = kFontColorA;
    
    if (indexPath.section == sectionIndexHold) {
        NSString *holdCellIdentifier = @"holdCell";
        cell = [tableView dequeueReusableCellWithIdentifier:holdCellIdentifier];
        if (nil == cell) {
            cell = [self createHoldCellWithIdentifier:holdCellIdentifier];
        }
        [self configHoldData];
    }
    else if (indexPath.section == sectionIndexGrade) {
        cell.frame = CGRectMake(0, 0, screenWidth, 100);
        cell.userInteractionEnabled = NO;
        
        UIImageView * gradeImageView = [[UIImageView alloc] init];
        gradeImageView.frame = CGRectMake(20.5, 20, 60, 60);
        
        [cell addSubview:gradeImageView];
        
        
        UILabel * trendLabel = [[UILabel alloc] init];
        trendLabel.frame = CGRectMake(CGRectGetMaxX(gradeImageView.frame)+16, 20, 100, 15);
        trendLabel.textAlignment = NSTextAlignmentLeft;
        
        if (stockGrade != nil)
        {
            NSString * str1 = @"股票走势: ";
            NSString * str2 = stockGrade.tendency;
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",str1,str2]];
            [str addAttribute:NSForegroundColorAttributeName value:KFontNewColorB range:NSMakeRange(0,str1.length)];
            [str addAttribute:NSForegroundColorAttributeName value:KFontNewColorA range:NSMakeRange(str1.length,str2.length)];
            [str addAttribute:NSFontAttributeName value:NormalFontWithSize(12) range:NSMakeRange(0,str1.length)];
            [str addAttribute:NSFontAttributeName value:BoldFontWithSize(14) range:NSMakeRange(str1.length,str2.length)];
            
            trendLabel.attributedText = str;
        }
        [cell addSubview:trendLabel];
        
        
        UILabel * qualityLabel = [[UILabel alloc] init];
        qualityLabel.frame = CGRectMake(screenWidth - 120, 20, 100, 15);
        qualityLabel.textAlignment = NSTextAlignmentLeft;
        
        if (stockGrade != nil)
        {
            NSString * str3 = @"股票质地: ";
            NSString * str4 = stockGrade.quality;
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",str3,str4]];
            [string addAttribute:NSForegroundColorAttributeName value:KFontNewColorB range:NSMakeRange(0,str3.length)];
            [string addAttribute:NSForegroundColorAttributeName value:KFontNewColorA range:NSMakeRange(str3.length,str4.length)];
            [string addAttribute:NSFontAttributeName value:NormalFontWithSize(12) range:NSMakeRange(0,str3.length)];
            [string addAttribute:NSFontAttributeName value:BoldFontWithSize(14) range:NSMakeRange(str3.length,str4.length)];
            
            qualityLabel.attributedText = string;
        }
        
        [cell addSubview:qualityLabel];
        
        UILabel * detailLabel = [[UILabel alloc] init];
        detailLabel.frame = CGRectMake(CGRectGetMaxX(gradeImageView.frame)+16, CGRectGetMaxY(trendLabel.frame)+14, screenWidth - 116,31);
        detailLabel.font = NormalFontWithSize(12);
        detailLabel.numberOfLines = 0;
        detailLabel.textAlignment = NSTextAlignmentLeft;
        detailLabel.textColor = KFontNewColorB;
        if (stockGrade != nil)
        {
            detailLabel.text = stockGrade.suggest;
            gradeImageView.image = [UIImage imageNamed:stockGrade.grade];
        }
        [cell addSubview:detailLabel];
    }
    else if (indexPath.section == sectionIndexLongShort) {
        cell.frame = CGRectMake(0, 0, screenWidth, 100);
        cell.userInteractionEnabled = NO;
        
        CGFloat rateSize = 70;
        
        UIView *rateView = [[UIView alloc] init];
        rateView.frame = CGRectMake(20, (100-rateSize)/2, rateSize, rateSize);
        
        // 做多视图
        float longRate = [realtimeData.makingLongRate floatValue];
        UIView *longView = [[UIView alloc] init];
        longView.frame = CGRectMake(0, 0, rateSize, rateSize * longRate);
        longView.backgroundColor = kRedColor;
        [rateView addSubview:longView];
        
        UILabel *longLabel = [[UILabel alloc] init];
        longLabel.frame = CGRectMake(0, 0, rateSize, 12);
        longLabel.center = CGPointMake(longView.frame.size.width/2, longView.frame.size.height/2);
        longLabel.font = BoldFontWithSize(12);
        longLabel.textColor = [UIColor whiteColor];
        longLabel.textAlignment = NSTextAlignmentCenter;
        longLabel.text = @"多";
        [longView addSubview:longLabel];
        
        // 做空视图
        float shortRate = [realtimeData.makingShortRate floatValue];
        UIView *shortView = [[UIView alloc] init];
        shortView.frame = CGRectMake(0, CGRectGetMaxY(longView.frame), rateSize, rateSize * shortRate);
        shortView.backgroundColor = kGreenColor;
        [rateView addSubview:shortView];
        
        UILabel *shortLabel = [[UILabel alloc] init];
        shortLabel.frame = CGRectMake(0, 0, rateSize, 12);
        shortLabel.center = CGPointMake(shortView.frame.size.width/2, shortView.frame.size.height/2);
        shortLabel.font = BoldFontWithSize(12);
        shortLabel.backgroundColor = [UIColor clearColor];
        shortLabel.textColor = [UIColor whiteColor];
        shortLabel.textAlignment = NSTextAlignmentCenter;
        shortLabel.text = @"空";
        [shortView addSubview:shortLabel];
        
        [cell addSubview:rateView];
        
        UILabel * detailLabel = [[UILabel alloc] init];
        detailLabel.frame = CGRectMake(CGRectGetMaxX(rateView.frame)+16, 17, screenWidth - 116,31);
        detailLabel.font = NormalFontWithSize(12);
        detailLabel.numberOfLines = 0;
        detailLabel.textAlignment = NSTextAlignmentLeft;
        detailLabel.textColor = KFontNewColorB;
        detailLabel.text = realtimeData.shortLongText;
        [cell addSubview:detailLabel];
    }
    else if (indexPath.section == sectionIndexPlate) {
        cell.frame = CGRectMake(0, 0, screenWidth, 74);
        
        for (int i = 0; i<2; i++ ) {
            UILabel * lineLabel = [[UILabel alloc] init];
            lineLabel.frame = CGRectMake(screenWidth/3*(i+1), 20, 0.5, 34);
            lineLabel.backgroundColor = KColorHeader;
            [cell addSubview:lineLabel];
        }
        for (int i = 0; i < plateArr.count; i++)
        {
            StockPlateEntity *stockPlate = [plateArr objectAtIndex:i];
            
            UILabel * nameLable = [[UILabel alloc] init];
            nameLable.frame = CGRectMake(screenWidth/3*i, 20, screenWidth/3, 20);
            nameLable.backgroundColor = [UIColor clearColor];
            nameLable.textColor =KFontNewColorA;
            nameLable.text = stockPlate.plateInfo.name;
            nameLable.font = NormalFontWithSize(13);
            nameLable.textAlignment = NSTextAlignmentCenter;
            [cell addSubview:nameLable];
            
            UILabel * numLabel = [[UILabel alloc] init];
            numLabel.frame = CGRectMake(screenWidth/3*i, 40, screenWidth/3, 20);
            numLabel.backgroundColor = [UIColor clearColor];
            numLabel.textAlignment = NSTextAlignmentCenter;
            numLabel.text = stockPlate.plateInfo.updownRange;
            
            if ([numLabel.text floatValue] < 0)
            {
                numLabel.textColor = kGreenColor;
            }
            else
            {
                numLabel.textColor = kRedColor;
            }
            
            numLabel.font = NormalFontWithSize(16);
            [cell addSubview:numLabel];
            
            UIButton * headerBtn = [[UIButton alloc] initWithFrame:CGRectMake(i*screenWidth/3, 0, screenWidth/3, 130)];
            [headerBtn addTarget:self action:@selector(indexBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            headerBtn.tag = i;
            [cell addSubview:headerBtn];
        }
    }
    else if (indexPath.section == sectionIndexNews) {
        if (indexPath.row < 5)
        {
            UILabel * lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, screenWidth, 0.5)];
            lineLabel.backgroundColor = KLineNewBGColor1;
            [cell addSubview:lineLabel];
            
            UILabel * noticeLabel = [[UILabel alloc] init];
            noticeLabel.frame = CGRectMake(20, 0, screenWidth - 70, 65);
            noticeLabel.font = NormalFontWithSize(14);
            noticeLabel.textAlignment = NSTextAlignmentLeft;
            if (newsArr.count > 0)
            {
                NSString * news_title = [[newsArr objectAtIndex:indexPath.row] objectForKey:@"news_title"];
                noticeLabel.text = news_title;
            }
            noticeLabel.textColor = KFontNewColorA;
            noticeLabel.backgroundColor = [UIColor clearColor];
            noticeLabel.numberOfLines = 0;
            [cell addSubview:noticeLabel];
            
            
            UILabel * newsTimeLabel = [[UILabel alloc] init];
            newsTimeLabel.frame = CGRectMake(screenWidth - 70, 50, 50, 10);
            if (newsArr.count > 0)
            {
                NSString * newsTime = [[newsArr objectAtIndex:indexPath.row] objectForKey:@"news_time"];
                newsTimeLabel.text = newsTime;
            }
            newsTimeLabel.textAlignment = NSTextAlignmentRight;
            newsTimeLabel.font = NormalFontWithSize(10);
            newsTimeLabel.textColor = KFontNewColorB;
            [cell addSubview:newsTimeLabel];
        }
        else if (indexPath.row == 5)
        {
            UILabel * moreLabel = [[UILabel alloc] init];
            moreLabel.frame = CGRectMake(0, 0, screenWidth, 40);
            moreLabel.backgroundColor = [UIColor clearColor];
            moreLabel.font = NormalFontWithSize(12);
            moreLabel.textAlignment = NSTextAlignmentCenter;
            moreLabel.textColor = KFontNewColorB;
            moreLabel.text = @"点击查看更多";
            [cell addSubview:moreLabel];
            
            UIView * view = [[UIView alloc] init];
            view.backgroundColor = kFontColorA;
            cell.selectedBackgroundView = view;
        }
    }
    
    return cell;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = KSelectNewColor;
    
    UILabel * nameLabel = [[UILabel alloc] init];
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textColor = KFontNewColorA;
    nameLabel.font = NormalFontWithSize(16);
    [view addSubview:nameLabel];
    
    UIButton * moreNewsBtn = [[UIButton alloc] init];
    moreNewsBtn.titleLabel.font = NormalFontWithSize(15);
    [moreNewsBtn setTitleColor:KFontNewColorB forState:UIControlStateNormal];
    [moreNewsBtn addTarget:self action:@selector(moreNewsBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:moreNewsBtn];
    
    if (section == 0)
    {
        view.frame= CGRectMake(0, 0, screenWidth, 55);
        nameLabel.frame = CGRectMake(20, 0, 100, view.frame.size.height);
        moreNewsBtn.frame = CGRectMake(0, 0, screenWidth, view.frame.size.height);
    }
    else
    {
        view.frame= CGRectMake(0, 0, screenWidth, 35);
        nameLabel.frame = CGRectMake(20, -8, 100, view.frame.size.height);
        moreNewsBtn.frame = CGRectMake(0, -8, screenWidth, view.frame.size.height);
    }
    
    UIImageView * rightView = [[UIImageView alloc] init];
    rightView.image = [UIImage imageNamed:@"home_right"];
    rightView.frame = CGRectMake(screenWidth-20-11.5, -0.5, 11.5, 21);
    [view addSubview:rightView];
    
    
    if (section == sectionIndexHold) {
        nameLabel.text = @"持仓";
        moreNewsBtn.hidden = YES;
        rightView.hidden = YES;
    }
    else if (section == sectionIndexGrade) {
        nameLabel.text = @"股票评级";
        moreNewsBtn.hidden = YES;
        rightView.hidden = YES;
    }
    else if (section == sectionIndexLongShort) {
        nameLabel.text = @"多空对比";
        moreNewsBtn.hidden = YES;
        rightView.hidden = YES;
    }
    else if (section == sectionIndexPlate) {
        nameLabel.text = @"所属板块";
        moreNewsBtn.hidden = YES;
        rightView.hidden = YES;
    }
    else if (section == sectionIndexNews) {

        nameLabel.text = @"资讯";
        moreNewsBtn.hidden = NO;
        rightView.hidden = NO;
        if (section == 0) {
            rightView.frame = CGRectMake(screenWidth-20-11.5, 17, 11.5, 21);
        }
    }
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (stockInfo.type)
    {
        if (indexPath.section == 1)
        {
            UITableViewCell * cell = (UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
            UIView * view = [[UIView alloc] init];
            view.backgroundColor = kFontColorA;
            cell.backgroundView = view;
        }
        
        if (indexPath.section == 2)
        {
            if (indexPath.row < 5)
            {
                InformationDetailViewController * IDVC = [[InformationDetailViewController alloc] init];
                IDVC.news_url = [[newsArr objectAtIndex:indexPath.row] objectForKey:@"news_url"];
                IDVC.stock_name = stockInfo.name;
                [self pushToViewController:IDVC];
            }
            else if (indexPath.row == 5)
            {
                InformationViewController * IVC = [[InformationViewController alloc] init];
                IVC.stockInfo = self.stockInfo;
                [self pushToViewController:IVC];
            }
        }
    }
    else
    {
        if (indexPath.row < 5)
        {
            InformationDetailViewController * IDVC = [[InformationDetailViewController alloc] init];
            IDVC.news_url = [[newsArr objectAtIndex:indexPath.row] objectForKey:@"news_url"];
            IDVC.stock_name = stockInfo.name;
            [self pushToViewController:IDVC];
        }
        else if (indexPath.row == 5)
        {
            InformationViewController * IVC = [[InformationViewController alloc] init];
            IVC.stockInfo = self.stockInfo;
            [self pushToViewController:IVC];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == sectionIndexHold) {
        return cellHoldHeight;
    }
    else if (indexPath.section == sectionIndexGrade) {
        return 100;
    }
    else if (indexPath.section == sectionIndexLongShort) {
        return 100;
    }
    else if (indexPath.section == sectionIndexPlate) {
        return 74;
    }
    else if (indexPath.section == sectionIndexNews) {
        if (indexPath.row < 5) {
            return 65;
        }
        else if (indexPath.row == 5) {
            return 40;
        }
    }
    
    
    
    
//    if (stockInfo.type == 1)
//    {
//        if (indexPath.section == 0)
//        {
//            return 100;
//        }
//        else if (indexPath.section == 1)
//        {
//            return 74;
//        }
//        else if (indexPath.section == 2)
//        {
//            if (indexPath.row < 5)
//            {
//                return 65;
//            }
//            else if (indexPath.row == 5)
//            {
//                return 40;
//            }
//        }
//    }
//    else
//    {
//        if (indexPath.row < 5)
//        {
//            return 65;
//        }
//        else if (indexPath.row == 5)
//        {
//            return 40;
//        }
//    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (stockInfo.type)
    {
        if (section == 0)
        {
            return 55;
        }
        return 35;
    }
    return 55;
}

#pragma mark - EGORefreshTableHeaderDelegate
-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return isEgoRefresh;
}

-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    isEgoRefresh = YES;
    [self requestData];
}

-(NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [NSDate date];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == holdScrollView) {
        int contentOffsetX = holdScrollView.contentOffset.x;
        if(contentOffsetX < CGRectGetWidth(holdScrollView.frame)) {
            pageControl.currentPage = 0;
        }
        else if(contentOffsetX >= CGRectGetWidth(holdScrollView.frame)) {
            pageControl.currentPage = 1;
        }
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == infoTableView) {
        [refreshview egoRefreshScrollViewDidEndDragging:scrollView];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == infoTableView) {
        [refreshview egoRefreshScrollViewDidScroll:scrollView];
        operateView.hidden = YES;
        
        if (scrollView.contentOffset.y < 30)
        {
            [self reloadTimeLabel];
        }
        else
        {
            timeLabel.text = [NSString stringWithFormat:@"%@  %@  %@", priceLabel.text, profitLabel.text, percentLabel.text];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end