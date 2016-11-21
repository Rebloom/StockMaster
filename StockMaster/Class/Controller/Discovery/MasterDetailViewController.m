//
//  MasterDetailViewController.m
//  StockMaster
//
//  Created by Rebloom on 14-8-6.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "MasterDetailViewController.h"
#import "NSString+UIColor.h"
#import "UIImage+UIColor.h"
#import "StockDetailViewController.h"
#import "StockDetailViewController.h"

static CGFloat  VIEWWIDTH = 340;

@interface MasterDetailViewController ()

@end

@implementation MasterDetailViewController

@synthesize passDic;
@synthesize showUid;

- (void)dealloc
{
    for (ASIFormDataRequest * request in [RequestQueue instance].requestList)
    {
        if ([request.action isEqualToString:Get_user_home])
        {
            [request cancel];
            request.delegate = nil;
        }
    }
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
    
    if (screenWidth == 320)
    {
        VIEWWIDTH = 340;
    }
    else
    {
        VIEWWIDTH = screenWidth;
    }
    
    [headerView backButton];
    [headerView createLine];
    headerView.backgroundColor = kFontColorA;
    [headerView setStatusBarColor:kFontColorA];
    self.view.backgroundColor = KSelectNewColor;
    
    selectedBtnIndex = 1;
    recoverIndex = 0;
    
    // 持仓数据
    holdArray = [[NSMutableArray alloc] initWithCapacity:10];
    // 历史数据
    historyArray = [[NSMutableArray alloc] initWithCapacity:10];
    // 股票数据，去详情页面用
    tempArray = [[NSMutableArray alloc] initWithCapacity:10];
    // 复活后交易历史数据
    recoverArr = [[NSMutableArray alloc] initWithCapacity:10];
    // 复活前交易历史数据
    dieArr = [[NSMutableArray alloc] initWithCapacity:10];
    sendDieArr = [[NSMutableArray alloc] initWithCapacity:10];
    sendRecoverArr = [[NSMutableArray alloc] initWithCapacity:10];
    
    [self createUI];
    [self requestUserData];
}

// 请求用户数据
-(void)requestUserData
{
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setObject:self.showUid forKey:@"show_uid"];
    [GFRequestManager connectWithDelegate:self action:Get_user_home param:param];
}

// 请求成功
- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    ASIFormDataRequest * formDataRequest = (ASIFormDataRequest *)request;
    if ([formDataRequest.action isEqualToString:Get_user_home])
    {
        NSMutableDictionary * dic = [requestInfo objectForKey:@"data"];
        NSString * nameString = [[[dic objectForKey:@"user_profit"] objectForKey:@"nickname"] description];
        
        // 判断显示头部名称
        if ([Utility lenghtWithString:nameString] > 14)
        {
            for (int i = 0; i < nameString.length; i++)
            {
                NSString * apartStr = [nameString substringToIndex:i];
                // 汉字字符集
                NSString * pattern  = @"[\u4e00-\u9fa5]";
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
                // 计算中文字符的个数
                NSInteger numMatch = [regex numberOfMatchesInString:apartStr options:NSMatchingReportProgress range:NSMakeRange(0, apartStr.length)];
                if (apartStr.length+numMatch == 14)
                {
                    nameString = [NSString stringWithFormat:@"%@...",apartStr];
                    break;
                }
            }
        }
        
        [headerView loadComponentsWithTitle:nameString];
        headerView.backgroundColor = kFontColorA;
        [headerView setStatusBarColor: kFontColorA];
        
        NSDictionary * dict = [dic objectForKey:@"user_profit"];
        accuracy.text = [[dict objectForKey:@"seven_profit"] description];
        totalProfit.text = [[dict objectForKey:@"total_profit"] description];
        [photoView sd_setImageWithURL:[NSURL URLWithString:[[dict objectForKey:@"head"] description]]
                     placeholderImage:[UIImage imageNamed:@"icon_user_default"]
                              options:SDWebImageRefreshCached];
        if ([[dict objectForKey:@"total_profit_updown"] isEqualToString:@"up"])
        {
            totalIv.image = [UIImage imageNamed:@"icon_xiangshang2"];
        }
        else
        {
            totalIv.image = [UIImage imageNamed:@"icon_xiangxia2"];
        }
        if ([[dict objectForKey:@"seven_profit_updown"] isEqualToString:@"up"])
        {
            profitIv.image = [UIImage imageNamed:@"icon_xiangshang2"];
        }
        else
        {
            profitIv.image = [UIImage imageNamed:@"icon_xiangxia2"];
        }
        [self sendData:dic];
    }
    
    [infoTable reloadData];
}

// 转化数据，股票数据到详情页面
-(void)sendData:(NSMutableDictionary*)dict
{
    holdArray = [[dict objectForKey:@"user_portfolio"] mutableCopy];
    NSMutableArray * array = [[NSMutableArray alloc] init];
    for (int i=0; i < holdArray.count; i++) {
        StockInfoEntity * stockInfo = [[StockInfoCoreDataStorage sharedInstance] getStockInfoWithCode:[[holdArray objectAtIndex:i] objectForKey:@"stock_code"] exchange:[[holdArray objectAtIndex:i] objectForKey:@"stock_exchange"]];
        [array  addObject:stockInfo];
    }
    if (tempArray.count>0)
    {
        [tempArray removeAllObjects];
    }
    tempArray = [array  mutableCopy];
    
    historyArray = [[dict objectForKey:@"user_transaction_history"] mutableCopy];
    if (recoverArr.count>0)
    {
        [recoverArr removeAllObjects];
    }
    if (dieArr.count>0)
    {
        [dieArr count];
    }
    NSMutableArray * arr1 = [NSMutableArray array];
    NSMutableArray * arr2 = [NSMutableArray array];
    for (NSDictionary * dictionary in historyArray)
    {
        if ([[[dictionary objectForKey:@"is_resurrection"] description] isEqualToString:@"0"])
        {
            [arr1 addObject:dictionary];
        }
        else if ([[[dictionary objectForKey:@"is_resurrection"] description] isEqualToString:@"1"])
        {
            [arr2 addObject:dictionary];
        }
    }
    
    sendRecoverArr = [arr1 mutableCopy];
    sendDieArr = [arr2 mutableCopy];
    
    if (arr1.count>0)
    {
        NSMutableArray * arr3 = [[NSMutableArray alloc] init];
        for (int i=0; i<arr1.count; i++)
        {
            StockInfoEntity * stockInfo = [[StockInfoCoreDataStorage sharedInstance] getStockInfoWithCode:[[arr1 objectAtIndex:i] objectForKey:@"stock_code"] exchange:[[arr1 objectAtIndex:i] objectForKey:@"stock_exchange"]];
            [arr3 addObject:stockInfo];
        }
        recoverArr = [arr3  copy];
    }
    
    if (arr2.count>0)
    {
        NSMutableArray * arr4 = [[NSMutableArray alloc] init];
        for (int i=0; i<arr2.count; i++)
        {
            StockInfoEntity * stockInfo = [[StockInfoCoreDataStorage sharedInstance] getStockInfoWithCode:[[historyArray objectAtIndex:i] objectForKey:@"stock_code"] exchange:[[historyArray objectAtIndex:i] objectForKey:@"stock_exchange"]];
            [arr4 addObject:stockInfo];
        }
        dieArr = [arr4  copy];
    }
    if (recoverArr.count>0 && dieArr.count<=0)
    {
        recoverIndex = 1;
    }
    else if (recoverArr.count>0&&dieArr.count>0) {
        recoverIndex = 2;
    }
    else if (recoverArr.count<=0 && dieArr.count<=0)
    {
        recoverIndex = 0;
    }
}

// 初始化界面布局
-(void)createUI
{
    CGFloat temp = 0;
    if (screenWidth == 320)
    {
        temp = 0;
    }
    else if (screenWidth == 375)
    {
        temp = 10;
    }
    else if (screenWidth == 414)
    {
        temp = 20;
    }
    
    scrollview = [[UIScrollView alloc] init];
    scrollview.frame = CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, screenHeight - CGRectGetMaxY(headerView.frame)+100);
    scrollview.delegate = self;
    [self.view addSubview:scrollview];
    
    bgView = [[UIImageView alloc] init ];
    bgView.frame = CGRectMake(0,0 , VIEWWIDTH, 160);
    bgView.backgroundColor = kFontColorA;
    bgView.userInteractionEnabled = YES;
    [scrollview addSubview:bgView];
    
    photoView = [[UIImageView alloc]init];
    photoView.frame = CGRectMake(20, 40, 80, 80);
    photoView.layer.cornerRadius = 40 ;
    photoView.layer.masksToBounds = YES;
    photoView.image = [UIImage imageNamed:@"icon_user_default"];
    [bgView addSubview:photoView];
    
    totalProfit = [[UILabel alloc] init];
    totalProfit.frame = CGRectMake(CGRectGetMaxX(photoView.frame)+20+temp, 60, 100, 20);
    totalProfit.backgroundColor = [UIColor clearColor];
    totalProfit.font = NormalFontWithSize(20);
    totalProfit.textColor = KFontNewColorA;
    totalProfit.textAlignment = NSTextAlignmentLeft;
    totalProfit.text = @"加载中...";
    [bgView addSubview:totalProfit];
    
    UILabel * total = [[UILabel alloc] init];
    total.frame = CGRectMake(CGRectGetMinX(totalProfit.frame), CGRectGetMaxY(totalProfit.frame)+10, 200, 20);
    total.backgroundColor = [UIColor clearColor];
    total.font = NormalFontWithSize(13);
    total.textColor = KFontNewColorB;
    total.textAlignment = NSTextAlignmentLeft;
    total.text = @"总收益率";
    [total sizeToFit];
    [bgView addSubview:total];
    
    totalIv = [[UIImageView alloc] init];
    totalIv.frame = CGRectMake(CGRectGetMaxX(total.frame) +10, 92, 6, 10);
    [bgView addSubview:totalIv];
    
    
    accuracy = [[UILabel alloc] init];
    accuracy.frame = CGRectMake(CGRectGetMaxX(totalProfit.frame)+temp, CGRectGetMinY(totalProfit.frame), 200, 20);
    accuracy.backgroundColor = [UIColor clearColor];
    accuracy.font = NormalFontWithSize(20);
    accuracy.textAlignment = NSTextAlignmentLeft;
    accuracy.textColor = KFontNewColorA;
    accuracy.text = @"加载中...";
    [bgView addSubview:accuracy];
    
    
    UILabel * acurate = [[UILabel alloc] init];
    acurate.frame = CGRectMake(CGRectGetMinX(accuracy.frame), CGRectGetMaxY(accuracy.frame)+10, 200, 20);
    acurate.backgroundColor = [UIColor clearColor];
    acurate.textAlignment = NSTextAlignmentLeft;
    acurate.font = NormalFontWithSize(13);
    acurate.textColor = KFontNewColorB;
    acurate.text = @"7日收益率";
    [acurate sizeToFit];
    [bgView addSubview:acurate];
    
    profitIv = [[UIImageView alloc] init];
    profitIv.frame = CGRectMake(CGRectGetMaxX(acurate.frame) +10, 92, 6, 10);
    [bgView addSubview:profitIv];
    
    holdBtn = [[UIButton alloc] init];
    holdBtn.frame = CGRectMake(0, CGRectGetMaxY(bgView.frame), screenWidth/2, 44);
    holdBtn.tag = 2000;
    [holdBtn setBackgroundColor:KSelectNewColor];
    [holdBtn setTitle:@"持仓" forState:UIControlStateNormal];
    holdBtn.titleLabel.font = NormalFontWithSize(14);
    [holdBtn setTitleColor:KFontNewColorA forState:UIControlStateNormal];
    [holdBtn addTarget:self action:@selector(headerBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [scrollview addSubview:holdBtn];
    
    historyBtn = [[UIButton alloc] init];
    historyBtn.frame = CGRectMake(screenWidth/2, CGRectGetMaxY(bgView.frame), screenWidth/2, 44);
    historyBtn.tag = 2001;
    historyBtn.titleLabel.font = NormalFontWithSize(14);
    [historyBtn setBackgroundColor:KSelectNewColor];
    [historyBtn setTitle:@"历史" forState:UIControlStateNormal];
    [historyBtn setTitleColor:KFontNewColorB forState:UIControlStateNormal];
    [historyBtn addTarget:self action:@selector(headerBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [scrollview addSubview:historyBtn];
    [self headerBtnClicked:holdBtn];
    
    infoTable = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(historyBtn.frame), screenWidth, screenHeight-headerView.frame.size.height-101-49)];
    infoTable.backgroundColor = kBackgroundColor;
    infoTable.dataSource = self;
    infoTable.delegate = self;
    infoTable.separatorStyle = NO;
    [scrollview addSubview:infoTable];
    
    [self createFootView];
}

// 底部的统一布局
-(void)createFootView
{
    UIView * footView = [[UIView alloc] init];
    footView.frame = CGRectMake(0, 0, screenWidth, 156);
    footView.backgroundColor = [UIColor clearColor];
    infoTable.tableFooterView = footView;
    
    UILabel * ideaLabel = [[UILabel alloc] init];
    ideaLabel.frame = CGRectMake(0,footView.frame.size.height-64, screenWidth, 12);
    ideaLabel.text = @"免费炒股，大赚真钱";
    ideaLabel.textAlignment = NSTextAlignmentCenter;
    ideaLabel.textColor = KFontNewColorC;
    ideaLabel.font = NormalFontWithSize(12);
    [footView addSubview:ideaLabel];
    
    UIImageView * iconImgView = [[UIImageView alloc] init];
    iconImgView.frame = CGRectMake(screenWidth/2-15, CGRectGetMinY(ideaLabel.frame) - 33, 30, 23);
    iconImgView.image = [UIImage imageNamed:@"zhangzhang"];
    [footView addSubview:iconImgView];
}

// 点击了持仓或者历史数据，切换数据
- (void)headerBtnClicked:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    [btn setBackgroundColor:KSelectNewColor];
    
    if ([btn isEqual:holdBtn])
    {
        [holdBtn setTitleColor:KFontNewColorB forState:UIControlStateNormal];
        [historyBtn setTitleColor:KFontNewColorA forState:UIControlStateNormal];
        selectedBtnIndex = 1;
        scrollview.contentSize = CGSizeMake(screenWidth,screenHeight-CGRectGetMaxY(headerView.frame));
        infoTable.frame = CGRectMake(0, CGRectGetMaxY(historyBtn.frame), screenWidth, screenHeight-headerView.frame.size.height-101-49);
    }
    else
    {
        [holdBtn setTitleColor:KFontNewColorA forState:UIControlStateNormal];
        [historyBtn setTitleColor:KFontNewColorB forState:UIControlStateNormal];
        selectedBtnIndex = 2;
        scrollview.contentSize = CGSizeMake(VIEWWIDTH,screenHeight-CGRectGetMaxY(headerView.frame));
        infoTable.frame = CGRectMake(0, CGRectGetMaxY(historyBtn.frame), VIEWWIDTH, screenHeight-headerView.frame.size.height-101-49);
    }
    [infoTable reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (recoverIndex == 0)
    {
        return 1;
    }
    else  if (recoverIndex == 1)
    {
        return 1;
    }
    else if (recoverIndex == 2)
    {
        if (selectedBtnIndex == 1)
        {
            return 1;
        }
        else if (selectedBtnIndex ==2)
        {
            return 2;
        }
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (selectedBtnIndex == 1)
    {
        return holdArray.count;
    }
    else if (selectedBtnIndex == 2)
    {
        if (recoverIndex == 0)
        {
            return 0;
        }
        else if (recoverIndex == 1)
        {
            return recoverArr.count;
        }
        else if (recoverIndex == 2)
        {
            if (section == 0)
            {
                return recoverArr.count;
            }
            else if (section == 1)
            {
                return dieArr.count;
            }
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 52;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc] init ];
    view.backgroundColor = kFontColorA;
    
    if (selectedBtnIndex == 1)
    {
        view.frame = CGRectMake(0, 0, screenWidth, 52);
        NSArray * nameArr = @[@"代号",@"股票",@"成本",@"盈亏"];
        for (int i = 0; i < nameArr.count; i++)
        {
            UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/4*i, 0, screenWidth/4, 51.5)];
            title.textAlignment = NSTextAlignmentCenter;
            title.backgroundColor = [UIColor clearColor];
            title.font = NormalFontWithSize(12);
            title.textColor = KFontNewColorB;
            title.text = [nameArr objectAtIndex:i];
            [view addSubview:title];
        }
    }
    else if(selectedBtnIndex == 2)
    {
        if (recoverIndex == 0||recoverIndex == 1)
        {
            if (screenWidth == 320)
            {
                view.frame = CGRectMake(0, 0, 360, 52);
            }
            else
            {
                view.frame = CGRectMake(0, 0, screenWidth, 52);
            }
            NSArray * nameArr = @[@"买/卖",@"代号",@"股票",@"成本",@"盈亏"];
            for (int i = 0; i < nameArr.count; i++)
            {
                UILabel * title = [[UILabel alloc] init];
                if (screenWidth == 320)
                {
                    title.frame = CGRectMake(68*(i), 0, 68,51.5);
                }
                else
                {
                    title.frame = CGRectMake(screenWidth/5*(i), 0, screenWidth/5,51.5);
                }
                title.textAlignment = NSTextAlignmentCenter;
                title.backgroundColor = [UIColor clearColor];
                title.font = NormalFontWithSize(12);
                title.textColor = KFontNewColorB;
                title.text = [nameArr objectAtIndex:i];
                [view addSubview:title];
            }
        }
        else if (recoverIndex == 2)
        {
            if (screenWidth == 320)
            {
                view.frame = CGRectMake(0, 0, 360, 52);
            }
            else
            {
                view.frame = CGRectMake(0, 0, screenWidth, 52);
            }            if (section == 0)
            {
                NSArray * nameArr = @[@"买/卖",@"代号",@"股票",@"成本",@"盈亏"];
                for (int i = 0; i < nameArr.count; i++)
                {
                    UILabel * title = [[UILabel alloc] init];
                    if (screenWidth == 320)
                    {
                        title.frame = CGRectMake(68*(i), 0, 68,51.5);
                    }
                    else
                    {
                        title.frame = CGRectMake(screenWidth/5*(i), 0, screenWidth/5,51.5);
                    }                    title.textAlignment = NSTextAlignmentCenter;
                    title.backgroundColor = [UIColor clearColor];
                    title.font = NormalFontWithSize(12);
                    title.textColor = KFontNewColorB;
                    title.text = [nameArr objectAtIndex:i];
                    [view addSubview:title];
                }
            }
            else if (section == 1)
            {
                UILabel * label = [[UILabel alloc] init];
                label.frame = CGRectMake(0, 0, screenWidth, 52);
                label.backgroundColor = kRedColor;
                label.text = @"复活";
                label.textAlignment = NSTextAlignmentCenter;
                label.textColor = kFontColorA;
                [view addSubview:label];
            }
        }
    }
    
    UILabel * lintLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 51.5, VIEWWIDTH, 0.5)];
    lintLb.backgroundColor = kLineBGColor2;
    [view addSubview:lintLb];
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [[UITableViewCell alloc] init];
    if (selectedBtnIndex == 1)
    {
        cell.frame =CGRectMake(0, 0, screenWidth, 100);
    }
    else if (selectedBtnIndex == 2)
    {
        cell.frame =CGRectMake(0, 0, VIEWWIDTH, 100);
    }
    cell.backgroundColor = kFontColorA;
    
    UIImageView * marketView = [[UIImageView alloc] init];
    [cell addSubview:marketView];
    
    if (selectedBtnIndex == 1)
    {
        NSDictionary * dic = [holdArray objectAtIndex:indexPath.row];
        NSString * stockID = [[dic objectForKey:@"stock_code"] description];
        NSString * stockName = [[dic objectForKey:@"stock_name"] description];
        NSString * tradePrice = [[dic objectForKey:@"transaction_price"] description];
        NSString * profitNum = [[dic objectForKey:@"profit_rate"] description];
        
        
        NSArray * nameArr = @[stockID, stockName, tradePrice, profitNum];
        
        
        for (int i = 0; i < nameArr.count; i++)
        {
            UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/4*i, 0, screenWidth/4, 100)];
            title.textAlignment = NSTextAlignmentCenter;
            title.backgroundColor = [UIColor clearColor];
            title.font = NormalFontWithSize(12);
            
            
            if ([profitNum componentsSeparatedByString:@"-"].count > 1)
            {
                title.textColor = kGreenColor;
            }
            else
            {
                title.textColor = kRedColor;
            }
            if (i == 2) {
                title.text =[NSString stringWithFormat:@"%.2f",[[nameArr objectAtIndex:i] floatValue]] ;
            }else{
                title.text = [nameArr objectAtIndex:i];
            }
            [cell addSubview:title];
        }
    }
    else if (selectedBtnIndex == 2)
    {
        if (recoverIndex == 0)
        {
            return cell;
        }
        else if (recoverIndex == 1)
        {
            NSDictionary * dic = [sendRecoverArr objectAtIndex:indexPath.row];
            NSString * market = [[dic objectForKey:@"transaction_type"] description];
            NSString * stockID = [[dic objectForKey:@"stock_code"] description];
            NSString * stockName = [[dic objectForKey:@"stock_name"] description];
            NSString * tradePrice = [[dic objectForKey:@"transaction_price"] description];
            NSString * profitNum = [[dic objectForKey:@"profit_rate"] description];
            NSString * direction = @"";
            
            NSArray * nameArr = @[direction,stockID, stockName, tradePrice, profitNum];
            
            for (int i = 0; i < nameArr.count; i++)
            {
                UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(VIEWWIDTH/5*i, 0, VIEWWIDTH/5, 100)];
                title.textAlignment = NSTextAlignmentCenter;
                title.backgroundColor = [UIColor clearColor];
                title.font = NormalFontWithSize(12);
                if ([market isEqualToString:@"2"])
                {
                    title.textColor = kGreenColor;
                }
                else
                {
                    title.textColor = kRedColor;
                }
                if (i == 0)
                {
                    marketView.frame = CGRectMake(25, 40, 20, 20);
                    if ([market isEqualToString:@"1"]) {
                        marketView.image = [UIImage imageNamed:@"faxian_mai.png"];
                    }else if([market isEqualToString:@"2"]){
                        marketView.image = [UIImage imageNamed:@"faxian_mai2.png"];
                    }
                }
                if (i == 3) {
                    title.text =[NSString stringWithFormat:@"%.2f",[[nameArr objectAtIndex:i] floatValue]] ;
                }else{
                    title.text = [nameArr objectAtIndex:i];
                }
                [cell addSubview:title];
            }
        }
        else if (recoverIndex == 2)
        {
            if (indexPath.section == 0)
            {
                NSDictionary * dic = [sendRecoverArr objectAtIndex:indexPath.row];
                
                NSString * market = [[dic objectForKey:@"transaction_type"] description];
                NSString * stockID = [[dic objectForKey:@"stock_code"] description];
                NSString * stockName = [[dic objectForKey:@"stock_name"] description];
                NSString * tradePrice = [[dic objectForKey:@"transaction_price"] description];
                NSString * profitNum = [[dic objectForKey:@"profit_rate"] description];
                
                NSString * direction = @"";
                
                
                NSArray * nameArr = @[direction,stockID, stockName, tradePrice, profitNum];
                
                for (int i = 0; i < nameArr.count; i++)
                {
                    UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(VIEWWIDTH/5*i, 0, VIEWWIDTH/5, 100)];
                    title.textAlignment = NSTextAlignmentCenter;
                    title.backgroundColor = [UIColor clearColor];
                    title.font = NormalFontWithSize(12);
                    if ([market isEqualToString:@"2"])
                    {
                        title.textColor = kGreenColor;
                    }
                    else
                    {
                        title.textColor = kRedColor;
                    }
                    if (i == 0)
                    {
                        marketView.frame = CGRectMake(25, 40, 20, 20);
                        if ([market isEqualToString:@"1"]) {
                            marketView.image = [UIImage imageNamed:@"faxian_mai.png"];
                        }else if([market isEqualToString:@"2"]){
                            marketView.image = [UIImage imageNamed:@"faxian_mai2.png"];
                        }
                    }
                    if (i == 3) {
                        title.text =[NSString stringWithFormat:@"%.2f",[[nameArr objectAtIndex:i] floatValue]] ;
                    }else{
                        title.text = [nameArr objectAtIndex:i];
                    }
                    [cell addSubview:title];
                }
            }
            else if (indexPath.section == 1)
            {
                NSDictionary * dic = [sendDieArr objectAtIndex:indexPath.row];
                NSString * market = [[dic objectForKey:@"transaction_type"] description];
                NSString * stockID = [[dic objectForKey:@"stock_code"] description];
                NSString * stockName = [[dic objectForKey:@"stock_name"] description];
                NSString * tradePrice = [[dic objectForKey:@"transaction_price"] description];
                NSString * profitNum = [[dic objectForKey:@"profit_rate"] description];
                
                NSString * direction = @"";
                
                
                NSArray * nameArr = @[direction,stockID, stockName, tradePrice, profitNum];
                
                for (int i = 0; i < nameArr.count; i++)
                {
                    UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(68*i, 0, 68, 100)];
                    title.textAlignment = NSTextAlignmentCenter;
                    title.backgroundColor = [UIColor clearColor];
                    title.font = NormalFontWithSize(12);
                    if ([market isEqualToString:@"2"])
                    {
                        title.textColor = kGreenColor;
                    }
                    else
                    {
                        title.textColor = kRedColor;
                    }
                    if (i == 0)
                    {
                        marketView.frame = CGRectMake(25, 40, 20, 20);
                        if ([market isEqualToString:@"1"]) {
                            marketView.image = [UIImage imageNamed:@"faxian_mai.png"];
                        }else if([market isEqualToString:@"2"]){
                            marketView.image = [UIImage imageNamed:@"faxian_mai2.png"];
                        }
                    }
                    if (i == 3) {
                        title.text =[NSString stringWithFormat:@"%.2f",[[nameArr objectAtIndex:i] floatValue]] ;
                    }else{
                        title.text = [nameArr objectAtIndex:i];
                    }
                    [cell addSubview:title];
                }
            }
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    StockDetailViewController * SDVC = [[StockDetailViewController alloc] init];
    
    StockInfoEntity * stockInfo = nil;
    if (selectedBtnIndex == 1)
    {
        stockInfo = [tempArray objectAtIndex:indexPath.row];
    }
    else if (selectedBtnIndex == 2)
    {
        if (recoverIndex == 1)
        {
            stockInfo = [recoverArr objectAtIndex:indexPath.row];
        }
        else if (recoverIndex ==2 )
        {
            if (indexPath.section == 0)
            {
                stockInfo = [recoverArr objectAtIndex:indexPath.row];
            }
            else if (indexPath.section == 1)
            {
                stockInfo = [dieArr objectAtIndex:indexPath.row];
            }
        }
    }
    SDVC.stockInfo = stockInfo;
    [self pushToViewController:SDVC];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
