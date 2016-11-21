//
//  InformationViewController.m
//  StockMaster
//
//  Created by dalikeji on 15/3/10.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import "InformationViewController.h"
#import "InformationDetailViewController.h"
#import "informationCell.h"

@interface InformationViewController ()

@end

@implementation InformationViewController
@synthesize stockInfo;

- (void)dealloc
{
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [infoTableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = KSelectNewColor;
    
    NSString * title = [NSString stringWithFormat:@"%@-资讯",stockInfo.name];
    [headerView loadComponentsWithTitle:title];
    
    [headerView createLine];
    [headerView backButton];
    headerView.backgroundColor = kFontColorA;
    [headerView setStatusBarColor:kFontColorA];
    
    infoArr = [[NSMutableArray alloc] initWithCapacity:10];
    readArr = [[NSMutableArray alloc] initWithCapacity:10];
    
    if ([GFStaticData getObjectForKey:KTagRead])
    {
        readArr = [[GFStaticData getObjectForKey:KTagRead] mutableCopy];
    }
    
    [self createTableView];
    [self createFootView];
    [self requestData];
}

- (void)createTableView
{
    if (!infoTableView)
    {
        infoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(headerView.frame), screenWidth, screenHeight - 65)];
    }
    infoTableView.backgroundColor = kBackgroundColor;
    infoTableView.dataSource = self;
    infoTableView.delegate = self;
    infoTableView.separatorStyle = NO;
    [self.view addSubview:infoTableView];
}

// 添加tableview底部数据
- (void)createFootView
{
    if (!footView)
    {
        footView = [[UIView alloc] init];
    }
    footView.frame = CGRectMake(0, 0, screenWidth, 156);
    footView.backgroundColor = [UIColor clearColor];
    
    infoTableView.tableFooterView = footView;
    
    UILabel * ideaLabel = [[UILabel alloc] init];
    ideaLabel.frame = CGRectMake(0,footView.frame.size.height-90, screenWidth, 12);
    ideaLabel.text = @"免费炒股，大赚真钱";
    ideaLabel.textAlignment = NSTextAlignmentCenter;
    ideaLabel.textColor = KFontNewColorC;
    ideaLabel.font = NormalFontWithSize(12);
    [footView addSubview:ideaLabel];
    
    UIImageView * iconImgView = [[UIImageView alloc] init];
    iconImgView.frame = CGRectMake(screenWidth, CGRectGetMinY(ideaLabel.frame) - 33, 30, 23);
    iconImgView.image = [UIImage imageNamed:@"zhangzhang"];
    [footView addSubview:iconImgView];
}

- (void)requestData
{
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setObject:stockInfo.code forKey:@"stock_code"];
    [param setObject:stockInfo.exchange forKey:@"stock_exchange"];
    [param setObject:@"1" forKey:@"page"];
    [GFRequestManager connectWithDelegate:self action:Get_stock_news_list param:param];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    
    ASIFormDataRequest * formDataRequest = (ASIFormDataRequest *)request;
    if ([formDataRequest.action isEqualToString:Get_stock_news_list])
    {
        NSMutableArray * tempArr = [[requestInfo objectForKey:@"data"] objectForKey:@"list"];
        if (tempArr.count > 0  )
        {
            for (int i = 0; i<tempArr.count; i++)
            {
                [infoArr addObject:[tempArr objectAtIndex:i]];
            }
            if (tempArr.count >= 10)
            {
                //                infoTableView.tableFooterView = refreshView;
            }
            else
            {
                infoTableView.tableFooterView = footView;
            }
        }
        else
        {
            infoTableView.tableFooterView = footView;
        }
        
    }
    [infoTableView reloadData];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [super requestFailed:request];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return infoArr.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * infomationID = @"infomationID";
    InformationCell * cell = [tableView dequeueReusableCellWithIdentifier:infomationID];
    if (!cell)
    {
        cell = [[InformationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:infomationID];
    }
    cell.frame = CGRectMake(0, 0, screenWidth, 101);
    
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = KSelectNewColor;
    cell.selectedBackgroundView = view;
    
    if (infoArr.count > 0)
    {
        cell.timeLabel.text = [[infoArr objectAtIndex:indexPath.row] objectForKey:@"news_time"];
        cell.contentLabel.text = [[infoArr objectAtIndex:indexPath.row] objectForKey:@"news_body"];
        cell.titleLabel.text = [[infoArr objectAtIndex:indexPath.row] objectForKey:@"news_title"];
    }
    
    cell.contentLabel.textColor = KFontNewColorA;
    cell.titleLabel.textColor = kRedColor;
    cell.redLabel.backgroundColor = kRedColor;
    cell.redLabel.frame =CGRectMake(15, 15, 6, 6);
    cell.timeLabel.frame = CGRectMake(CGRectGetMaxX(cell.redLabel.frame)+ 15, 12, 100, 12);
    
    if (readArr.count > 0)
    {
        
        NSString * news_id = [[infoArr objectAtIndex:indexPath.row] objectForKey:@"news_id"];
        for (int i = 0; i<readArr.count; i++)
        {
            NSString * read_id = [readArr objectAtIndex:i];
            if ([read_id isEqualToString:news_id])
            {
                cell.contentLabel.textColor = KFontNewColorB;
                cell.titleLabel.textColor = KFontNewColorB;
                cell.redLabel.backgroundColor = [UIColor clearColor];
                cell.redLabel.frame = CGRectZero;
                cell.timeLabel.frame = CGRectMake(CGRectGetMaxX(cell.redLabel.frame)+ 15, 12, 100, 12);
            }
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //存储不同的id
    NSString * read_id = [[infoArr objectAtIndex:indexPath.row] objectForKey:@"news_id"];
    NSString * news_url = [[infoArr objectAtIndex:indexPath.row] objectForKey:@"news_url"];
    
    [readArr addObject:read_id];
    
    NSArray * tempArr = [NSArray arrayWithArray:readArr];
    
    NSSet *set = [NSSet setWithArray:tempArr];
    
    [readArr removeAllObjects];
    
    for (NSString * str in set)
    {
        [readArr addObject:str];
    }
    
    [GFStaticData saveObject:readArr forKey:KTagRead];
    InformationDetailViewController * IDVC = [[InformationDetailViewController alloc]init];
    IDVC.news_url = news_url;
    IDVC.stock_name = self.stockInfo.name;
    [self pushToViewController:IDVC];
    
    [infoTableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 101;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
