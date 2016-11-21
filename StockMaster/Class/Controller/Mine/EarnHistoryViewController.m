//
//  EarnHistoryViewController.m
//  StockMaster
//
//  Created by dalikeji on 14-11-10.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "EarnHistoryViewController.h"
#import "ITTBaseDataSourceImp.h"
#import "NSString+UIColor.h"
#import "HistoryCell.h"
#define StockBeginDate      1990
#define StockYearSize       100
@interface EarnHistoryViewController ()

@end

@implementation EarnHistoryViewController

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
    
    [headerView loadComponentsWithTitle:@"赚钱记录"];
    [headerView backButton];
    [headerView createLine];
    headerView.backgroundColor = kFontColorA;
    [headerView setStatusBarColor: kFontColorA];
    
    self.view.backgroundColor = KSelectNewColor;
    
    isFirst = YES;
    
    
    listArr = [[NSMutableArray alloc] initWithCapacity:10];
    firstArr = [[NSMutableArray alloc] initWithCapacity:10];
    secondArr = [[NSMutableArray alloc] initWithCapacity:10];
    
    listDic = [[NSMutableDictionary alloc] initWithCapacity:10];
    tempDic = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    selectedSection = [[NSMutableArray alloc] initWithCapacity:10];
    
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    [dic setValue:@"YES" forKey:@"0"];
    [selectedSection addObject:dic];
    
    [self createUI];
    [self requestHistoryList:@""];
    
}

-(void)createUI
{
    
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
    infoTable.frame = CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, screenHeight-CGRectGetMaxY(headerView.frame));
    infoTable.backgroundColor = kBackgroundColor;
    infoTable.separatorStyle= NO;
    [self.view addSubview:infoTable];
    infoTable.tableFooterView = view;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (NSDictionary * dic in selectedSection)
    {
        if ([dic objectForKey:[NSString stringWithFormat:@"%d", (int)indexPath.section]])
        {
            if ([[dic objectForKey:[NSString stringWithFormat:@"%d", (int)indexPath.section]] isEqualToString:@"YES"])
            {
                NSArray * tempAr = [tempDic objectForKey:[NSString stringWithFormat:@"%d", (int)indexPath.section]];
                
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

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 55;
}


- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc]init];
    view.frame = CGRectMake(0, 0, screenWidth, 55);
    view.alpha = 0.8;
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
        NSArray * nameArr = @[@"类别",@"记录"];
        
        for (int i = 0; i < nameArr.count; i++)
        {
            UILabel * titleLabel = [[UILabel alloc] init ];
            titleLabel.textAlignment = NSTextAlignmentLeft;
            if (i == 0) {
                titleLabel.frame = CGRectMake(screenWidth/2-30, 0, 70, 55);
            }
            else if (i == 1)
            {
                titleLabel.frame = CGRectMake(screenWidth-100, 0, 80, 55);
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
    timeBtn.frame = CGRectMake(0, 0, screenWidth, 54);
    timeBtn.tag = section;
    [timeBtn setBackgroundColor:[UIColor clearColor]];
    [timeBtn addTarget:self action:@selector(timeBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:timeBtn];
    
    UILabel * lineLb3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 54, screenWidth, 0.5)];
    lineLb3.backgroundColor = KLineNewBGColor1;
    [view addSubview:lineLb3];
    
    UILabel * lineLb4 = [[UILabel alloc] initWithFrame:CGRectMake(0, 54.5, screenWidth, 0.5)];
    lineLb4.backgroundColor = KLineNewBGColor2;
    [view addSubview:lineLb4];
    
    return view;
    
}

- (UITableViewCell * )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellStock = @"cellStock";
    HistoryCell * cell = [tableView dequeueReusableCellWithIdentifier:cellStock];
    
    if (cell == nil)
    {
        cell = [[HistoryCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellStock];
    }
    
    cell.backgroundColor = kFontColorA;
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    
    for (NSDictionary * dic in selectedSection)
    {
        if ([dic objectForKey:[NSString stringWithFormat:@"%d", (int)indexPath.section]])
        {
            if ([[dic objectForKey:[NSString stringWithFormat:@"%d", (int)indexPath.section]] isEqualToString:@"YES"])
            {
                NSArray * moneyList = [tempDic objectForKey:[NSString stringWithFormat:@"%d", (int)indexPath.section]];
                if (indexPath.row < moneyList.count)
                {
                    NSDictionary * moneyDic = [moneyList objectAtIndex:indexPath.row];
                    NSString * dateStr = [[moneyDic objectForKey:@"create_time"] description];
                    cell.firstLabel.text = [dateStr substringFromIndex:3];
                    cell.secondLabel.text = [[moneyDic objectForKey:@"task_name"] description] ;
                    
                    NSString * symbol_mark = [moneyDic objectForKey:@"symbol_mark"];
                    NSString * tempStr = [NSString stringWithFormat:@"%@%@",symbol_mark,[[moneyDic objectForKey:@"money"] description]];
;
                    if ([symbol_mark isEqualToString:@"+"])
                    {
                        cell.thirdLabel.textColor = kRedColor;
                    }
                    else if ([symbol_mark isEqualToString:@"-"])
                    {
                        cell.thirdLabel.textColor = kGreenColor;
                    }
                    
                    if([tempStr rangeOfString:@"("].location !=NSNotFound)
                    {
                        NSString * str1 = [tempStr substringToIndex:7];
                        NSString * str2 = [tempStr substringFromIndex:7];
                        cell.thirdLabel.text = [NSString stringWithFormat:@"%@\n%@",str1,str2];
                    }
                    else
                    {
                        cell.thirdLabel.text = tempStr;
                    }
                    
                    
                    cell.firstLabel.frame = CGRectMake(20, 40, 60, 20);
                    cell.secondLabel.frame = CGRectMake(screenWidth/2-30, 40, 80, 20);
                    cell.thirdLabel.frame = CGRectMake(screenWidth - 155, 20, 135, 60);
                    cell.fourthLabel.frame = CGRectZero;
                    
                    cell.firstLabel.textAlignment = NSTextAlignmentLeft;
                    cell.firstLabel.textColor = KFontNewColorA;
                    cell.thirdLabel.textAlignment = NSTextAlignmentRight;
                }
                else if (indexPath.row !=0 && moneyList.count == indexPath.row)
                {
                    cell.marketIv.frame = CGRectZero;
                    cell.firstLabel.frame = CGRectZero;
                    cell.secondLabel.frame = CGRectZero;
                    cell.thirdLabel.frame = CGRectZero;
                    cell.fourthLabel.frame = CGRectZero;
                    cell.fifthLabel.frame = CGRectZero;
                }
                if([moneyList count] == 0)
                {
                    cell.firstLabel.text = @"无记录";
                    cell.firstLabel.frame = CGRectMake(0, 0, screenWidth, 95);
                    cell.secondLabel.frame = CGRectZero;
                    cell.thirdLabel.frame = CGRectZero;
                    cell.fourthLabel.frame = CGRectZero;
                    cell.fifthLabel.frame = CGRectZero;
                    cell.firstLabel.textAlignment = NSTextAlignmentCenter;
                    cell.firstLabel.textColor = KFontNewColorB;
                }
            }
        }
    }
    return cell ;
}

- (void)requestHistoryList:(NSString*)string
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:string forKey:@"year_month"];
    [paramDic setObject:@"10" forKey:@"page_size"];
    [paramDic setObject:@"0" forKey:@"start_id"];
    
    [GFRequestManager connectWithDelegate:self action:Get_user_make_money param:paramDic];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    
    ASIFormDataRequest * formdataRequest = (ASIFormDataRequest *)request;
    if ([formdataRequest.action isEqualToString:Get_user_make_money])
    {
        if([[listDic allKeys] count]>0)
        {
            [listDic removeAllObjects];
        }
        listDic = [[requestInfo objectForKey:@"data"] mutableCopy];
        if([[listDic allKeys]count]>0)
        {
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
                [tempDic setObject:[listDic objectForKey:@"make_money_list"] forKey:@"0"];
                firstArr = [[listDic objectForKey:@"year_month_list"] mutableCopy];
                isFirst = NO;
            }
            else
            {
                [tempDic setObject:[listDic objectForKey:@"make_money_list"] forKey:[NSString stringWithFormat:@"%d", (int)selectedIndex]];
            }
        }
    }
    [infoTable reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [firstArr count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    for (NSDictionary * dic in selectedSection)
    {
        if ([dic objectForKey:[NSString stringWithFormat:@"%d", (int)section]])
        {
            if ([[dic objectForKey:[NSString stringWithFormat:@"%d", (int)section]] isEqualToString:@"YES"])
            {
                NSArray * tempAr = [tempDic objectForKey:[NSString stringWithFormat:@"%d", (int)section]];
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSIndexPath * path = [[infoTable indexPathsForVisibleRows] firstObject];
    showedSection = path.section;
    [infoTable reloadData];
}

-(void)timeBtnOnClick:(UIButton *)sender
{
    selectedIndex = sender.tag;
    for (ASIFormDataRequest * request in [RequestQueue instance].requestList)
    {
        if ([request.action isEqualToString:Get_user_make_money])
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