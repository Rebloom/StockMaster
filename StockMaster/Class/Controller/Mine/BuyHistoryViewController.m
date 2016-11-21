//
//  BuyHistoryViewController.m
//  StockMaster
//
//  Created by Rebloom on 14-7-24.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BuyHistoryViewController.h"
#import "HistoryCell.h"
#import "NSString+UIColor.h"
#import "StockDetailViewController.h"

static CGFloat VIEWWIDTH = 395;

@interface BuyHistoryViewController ()

@end

@implementation BuyHistoryViewController

- (void)dealloc
{
    
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
    
    if (screenWidth == 414)
    {
        VIEWWIDTH = 414;
    }
    else
    {
        VIEWWIDTH = 395;
    }
    
    [headerView backButton];
    [headerView createLine];
    [headerView loadComponentsWithTitle:@"交割单"];
    headerView.backgroundColor = kFontColorA;
    [headerView setStatusBarColor: kFontColorA];
    
    self.view.backgroundColor = KSelectNewColor;
    
    isFirst = YES;
    showedSection = 0;
    tempArray = [[NSMutableArray alloc]initWithCapacity:10];
    
    listArr = [[NSMutableArray alloc] initWithCapacity:10];
    firstArr = [[NSMutableArray alloc] initWithCapacity:10];
    listDic = [[NSMutableDictionary alloc] initWithCapacity:10];
    tempDic = [[NSMutableDictionary alloc] initWithCapacity:10];
    selectedSection = [[NSMutableArray alloc] initWithCapacity:10];
    
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    [dic setValue:@"YES" forKey:@"0"];
    [selectedSection addObject:dic];
    
    [self createUI];
    [self requestHistoryList:@""];
}

// 初始化页面布局
- (void)createUI
{
    UIScrollView * scrollview = [[UIScrollView alloc] init];
    scrollview.frame = CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, screenHeight - CGRectGetMaxY(headerView.frame)+100);
    
    scrollview.contentSize = CGSizeMake(VIEWWIDTH,screenHeight-CGRectGetMaxY(headerView.frame));
    scrollview.delegate = self;
    [self.view addSubview:scrollview];
    
    UIView * view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, screenWidth, 150);
    view.backgroundColor = [UIColor clearColor];
    
    UILabel * ideaLabel = [[UILabel alloc] init];
    ideaLabel.frame = CGRectMake(0,150-64, screenWidth, 12);
    ideaLabel.text = @"免费炒股，大赚真钱";
    ideaLabel.textAlignment = NSTextAlignmentCenter;
    ideaLabel.textColor = KFontNewColorC;
    ideaLabel.font = NormalFontWithSize(12);
    [view addSubview:ideaLabel];
    
    UIImageView * iconImgView = [[UIImageView alloc] init];
    iconImgView.frame = CGRectMake(screenWidth/2-15, CGRectGetMinY(ideaLabel.frame) - 33, 30, 23);
    iconImgView.image = [UIImage imageNamed:@"zhangzhang"];
    [view addSubview:iconImgView];
    
    infoTable = [[UITableView alloc] init];
    infoTable.dataSource = self;
    infoTable.delegate = self;
    infoTable.frame = CGRectMake(0, 0, VIEWWIDTH, screenHeight-CGRectGetMaxY(headerView.frame));
    infoTable.backgroundColor = kBackgroundColor;
    infoTable.separatorStyle= NO;
    [scrollview addSubview:infoTable];
    infoTable.tableFooterView = view;
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSIndexPath * path = [[infoTable indexPathsForVisibleRows] firstObject];
    showedSection = path.section;
    [infoTable reloadData];
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc]init];
    view.alpha = 0.8;
    view.frame = CGRectMake(0, 0, VIEWWIDTH, 55);
    view.backgroundColor = kFontColorA;
    
    UILabel * monthLabel = [[UILabel alloc] init];
    monthLabel.textColor = KFontNewColorD;
    monthLabel.textAlignment = NSTextAlignmentCenter;
    monthLabel.font = NormalFontWithSize(20);
    monthLabel.backgroundColor = [UIColor clearColor];
    monthLabel.frame = CGRectMake(10, 0, 50, 54);
    [view addSubview:monthLabel];
    
    UILabel * yearLabel = [[UILabel alloc] init];
    yearLabel.textColor = KFontNewColorB;
    yearLabel.textAlignment = NSTextAlignmentLeft;
    yearLabel.font = NormalFontWithSize(15);
    yearLabel.backgroundColor = [UIColor clearColor];
    yearLabel.frame = CGRectMake(55, 0, 60, 54);
    [view addSubview:yearLabel];
    
    if (isFirst)
    {
        NSString * str = [[listDic objectForKey:@"year_month_list"] objectAtIndex:section];
        if(![str isEqualToString:@""])
        {
            NSArray *b = [str componentsSeparatedByString:@"-"];
            monthLabel.text = [b objectAtIndex:0];
            yearLabel.text = [NSString stringWithFormat:@" - %@",[b objectAtIndex:1]];
        }
    }
    else
    {
        NSString * str = [firstArr objectAtIndex:section];
        if(![str isEqualToString:@""])
        {
            NSArray *b = [str componentsSeparatedByString:@"-"];
            monthLabel.text = [b objectAtIndex:0];
            yearLabel.text = [NSString stringWithFormat:@" - %@",[b objectAtIndex:1]];
        }
    }
    
    
    if (section == showedSection)
    {
        NSArray * nameArr = @[@"股票",@"成交价",@"数量",@"手续费"];
        
        for (int i = 0; i < nameArr.count; i++)
        {
            UILabel * titleLabel = [[UILabel alloc] init];
            titleLabel.textAlignment = NSTextAlignmentLeft;
            if (i == 0)
            {
                titleLabel.frame = CGRectMake(130, 0, 70, 55);
            }
            else if (i == 1)
            {
                titleLabel.frame = CGRectMake(215, 0, 65, 55);
            }
            else if (i == 2)
            {
                titleLabel.frame = CGRectMake(280, 0, 50, 55);
            }
            else if (i == 3)
            {
                titleLabel.frame = CGRectMake(330, 0, 55, 55);
                titleLabel.textAlignment = NSTextAlignmentRight;
            }
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.textColor = KFontNewColorB;
            titleLabel.font = NormalFontWithSize(15);
            titleLabel.text = [nameArr objectAtIndex:i];
            [view addSubview:titleLabel];
        }
    }
    
    UIButton * timeBtn = [[UIButton alloc] init];
    timeBtn.frame = CGRectMake(0, 0, VIEWWIDTH, 54);
    timeBtn.tag = section;
    [timeBtn setBackgroundColor:[UIColor clearColor]];
    [timeBtn addTarget:self action:@selector(timeBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:timeBtn];
    
    UILabel * lineLb3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 54, VIEWWIDTH, 0.5)];
    lineLb3.backgroundColor = KLineNewBGColor1;
    [view addSubview:lineLb3];
    
    UILabel * lineLb4 = [[UILabel alloc] initWithFrame:CGRectMake(0, 54.5, VIEWWIDTH, 0.5)];
    lineLb4.backgroundColor = KLineNewBGColor2;
    [view addSubview:lineLb4];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (NSDictionary * dic in selectedSection)
    {
        if ([dic objectForKey:[NSString stringWithFormat:@"%d",(int)indexPath.section]])
        {
            if ([[dic objectForKey:[NSString stringWithFormat:@"%d",(int)indexPath.section]] isEqualToString:@"YES"])
            {
                NSArray * tempAr = [tempDic objectForKey:[NSString stringWithFormat:@"%d",(int)indexPath.section]];
                
                if (tempAr.count == indexPath.row && tempAr.count!=0 )
                {
                    return 40;
                }
                else if(tempAr.count > indexPath.row)
                {
                    return 60;
                }
                else if (tempAr.count == 0)
                {
                    return 95;
                }
            }
            else
            {
                return 0;
            }
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 55;
}

- (UITableViewCell * )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellStock = @"cellStock";
    HistoryCell * cell = [tableView dequeueReusableCellWithIdentifier:cellStock];
    cell.backgroundColor = kFontColorA;
    if (cell == nil)
    {
        cell = [[HistoryCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellStock];
    }
    
    
    for (NSDictionary * dic in selectedSection)
    {
        if ([dic objectForKey:[NSString stringWithFormat:@"%d",(int)indexPath.section]])
        {
            if ([[dic objectForKey:[NSString stringWithFormat:@"%d",(int)indexPath.section]] isEqualToString:@"YES"])
            {
                NSArray * moneyList = [tempDic objectForKey:[NSString stringWithFormat:@"%d",(int)indexPath.section]];
                
                if (indexPath.row < moneyList.count )
                {
                    NSDictionary * moneyDic = [moneyList objectAtIndex:indexPath.row];
                    NSString * imageStr = @"";
                    if ([[[moneyDic objectForKey:@"transaction_type"] description] isEqualToString:@"1"])
                    {
                        imageStr = @"mairu";
                        cell.firstLabel.textColor = kRedColor;
                        cell.secondLabel.textColor = kRedColor;
                        cell.thirdLabel.textColor = kRedColor;
                        cell.fourthLabel.textColor = kRedColor;
                        cell.fifthLabel.textColor = kRedColor;
                    }
                    else if ([[[moneyDic objectForKey:@"transaction_type"] description] isEqualToString:@"2"])
                    {
                        imageStr = @"maidiao";
                        cell.firstLabel.textColor = kGreenColor;
                        cell.secondLabel.textColor = kGreenColor;
                        cell.thirdLabel.textColor = kGreenColor;
                        cell.fourthLabel.textColor = kGreenColor;
                        cell.fifthLabel.textColor = kGreenColor;
                    }
                    else if ([[[moneyDic objectForKey:@"transaction_type"] description] isEqualToString:@"3"])
                    {
                        
                    }
                    NSString * str = [[moneyDic objectForKey:@"create_time"] description];
                    cell.firstLabel.text = [str copy];
                    cell.marketIv.image = [UIImage imageNamed:imageStr];
                    cell.secondLabel.text = [[moneyDic objectForKey:@"stock_name"] description];
                    cell.thirdLabel.text = [[moneyDic objectForKey:@"transaction_price"] description];
                    cell.fourthLabel.text = [[moneyDic objectForKey:@"transaction_amount"] description];
                    cell.fifthLabel.text = [[moneyDic objectForKey:@"brokerage_fee"] description];
                    
                    cell.marketIv.frame = CGRectMake(15, 40, 20, 20);
                    cell.firstLabel.frame = CGRectMake(40, 40,85, 20);
                    cell.secondLabel.frame = CGRectMake(130, 40, 70, 20);
                    cell.thirdLabel.frame = CGRectMake(215, 40, 65, 20);
                    cell.fourthLabel.frame = CGRectMake(280, 40, 50, 20);
                    cell.fifthLabel.frame = CGRectMake(330, 40, 65, 20);
                    cell.fourthLabel.textAlignment = NSTextAlignmentLeft;
                    cell.firstLabel.textAlignment = NSTextAlignmentLeft;
                }
                else if (indexPath.row !=0 && moneyList.count == indexPath.row)
                {
                    cell.marketIv.frame = CGRectZero;
                    cell.firstLabel.frame = CGRectZero;
                    cell.secondLabel.frame = CGRectZero;
                    cell.thirdLabel.frame = CGRectZero;
                    cell.fourthLabel.frame = CGRectZero;
                    cell.fifthLabel.frame = CGRectZero;
                    cell.secondLabel.textColor = kFontColorA;
                    cell.thirdLabel.textColor = kFontColorA;
                    cell.fourthLabel.textColor = kFontColorA;
                    cell.fifthLabel.textColor = kFontColorA;
                    cell.marketIv.image = kFontColorA.image;
                    cell.firstLabel.textColor =kFontColorA;
                }
                else
                {
                    cell.firstLabel.frame = CGRectMake(0, 0, VIEWWIDTH, 95);
                    cell.secondLabel.frame = CGRectZero;
                    cell.thirdLabel.frame = CGRectZero;
                    cell.fourthLabel.frame = CGRectZero;
                    cell.fifthLabel.frame = CGRectZero;
                    cell.marketIv.frame = CGRectZero;
                    cell.firstLabel.text  = @"暂无数据";
                    cell.firstLabel.textAlignment = NSTextAlignmentCenter;
                    cell.firstLabel.textColor = KFontNewColorB;
                    cell.secondLabel.textColor = kFontColorA;
                    cell.thirdLabel.textColor = kFontColorA;
                    cell.fourthLabel.textColor = kFontColorA;
                    cell.fifthLabel.textColor = kFontColorA;
                    cell.marketIv.image = kFontColorA.image;
                }
            }
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray * arr = [tempDic objectForKey:[NSString stringWithFormat:@"%d",(int)indexPath.section]];
    if (arr.count>0 && arr.count != indexPath.row)
    {
        StockInfoEntity * stockInfo = [[StockInfoCoreDataStorage sharedInstance] getStockInfoWithCode:[[arr objectAtIndex:indexPath.row] objectForKey:@"stock_code"] exchange:[[arr objectAtIndex:indexPath.row] objectForKey:@"stock_exchange"]];
        
        StockDetailViewController * SDVC = [[StockDetailViewController alloc] init];
        SDVC.stockInfo = stockInfo;
        [self pushToViewController:SDVC];
    }
    
}

// 请求用户交易历史数据
- (void)requestHistoryList:(NSString*)string
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:string forKey:@"year_month"];
    [paramDic setObject:@"" forKey:@"page_size"];
    [paramDic setObject:@"" forKey:@"start_id"];
    [GFRequestManager connectWithDelegate:self action:Get_transaction_record_list param:paramDic];
}

// 请求成功的回调
- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    
    ASIFormDataRequest * formDataRequest = (ASIFormDataRequest *)request;
    if([formDataRequest.action isEqualToString:Get_transaction_record_list])
    {
        if([[listDic allKeys] count]>0)
        {
            [listDic removeAllObjects];
        }
        listDic = [[requestInfo objectForKey:@"data"] mutableCopy];
        if ([[listDic objectForKey:@"year_month_list"] count]>0)
        {
            isFirst = YES;
        }
        else
        {
            isFirst = NO;
        }
        if (isFirst)
        {
            [tempDic setObject:[listDic objectForKey:@"transaction_record_list"] forKey:@"0"];
            firstArr = [[listDic objectForKey:@"year_month_list"] mutableCopy];
            isFirst = NO;
        }
        else
        {
            [tempDic setObject:[listDic objectForKey:@"transaction_record_list"] forKey:[NSString stringWithFormat:@"%d",(int)selectedIndex]];
        }
    }
    [infoTable reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [firstArr count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    for (NSDictionary * dic in selectedSection)
    {
        if ([dic objectForKey:[NSString stringWithFormat:@"%d",(int)section]])
        {
            if ([[dic objectForKey:[NSString stringWithFormat:@"%d",(int)section]] isEqualToString:@"YES"])
            {
                NSArray * tempAr = [tempDic objectForKey:[NSString stringWithFormat:@"%d",(int)section]];
                return tempAr.count?(tempAr.count+1):1;
            }
            else
            {
                return 0;
            }
        }
    }
    return 0;
}

// 分段请求历史数据，首先取消之前的请求
- (void)timeBtnOnClick:(UIButton *)sender
{
    selectedIndex = sender.tag;
    for (ASIFormDataRequest * request in [RequestQueue instance].requestList)
    {
        if ([request.action isEqualToString:Get_transaction_record_list])
        {
            [request cancel];
            request.delegate = nil;
        }
    }
    BOOL needAdd = YES;
    for (NSMutableDictionary * dic in selectedSection)
    {
        if ([dic objectForKey:[NSString stringWithFormat:@"%d", (int)selectedIndex]])
        {
            needAdd = NO;
            if ([[dic objectForKey:[NSString stringWithFormat:@"%d", (int)selectedIndex]] isEqualToString:@"YES"])
            {
                [dic setObject:@"NO" forKey:[NSString stringWithFormat:@"%d", (int)selectedIndex]];
            }
            else
            {
                [dic setObject:@"YES" forKey:[NSString stringWithFormat:@"%d", (int)selectedIndex]];
                [self requestHistoryList:[firstArr objectAtIndex:selectedIndex]];
            }
        }
    }
    
    if (needAdd)
    {
        NSMutableDictionary * addDic = [NSMutableDictionary dictionary];
        [addDic setObject:@"YES" forKey:[NSString stringWithFormat:@"%d", (int)selectedIndex]];
        [selectedSection addObject:addDic];
        [self requestHistoryList:[firstArr objectAtIndex:selectedIndex]];
    }
    [infoTable reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end