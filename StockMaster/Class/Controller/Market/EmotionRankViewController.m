//
//  EmotionRankViewController.m
//  StockMaster
//
//  Created by 孤星之殇 on 15/5/2.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import "EmotionRankViewController.h"
#import "EmotionRankCell.h"

#import "EmotionViewController.h"

@interface EmotionRankViewController ()

@end

@implementation EmotionRankViewController

- (void)dealloc
{
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    infoDic = [[NSMutableDictionary alloc] initWithCapacity:10];
    userArr = [[NSMutableArray alloc] initWithCapacity:10];
    currentPage = @"1";

    
    [headerView loadComponentsWithTitle:@"感情排行"];
    [headerView createLine];
    [headerView backButton];
    
    [self createUI];
    [self createFootView];
    [self requestRankList:currentPage];
}

- (void)createUI
{
    topView = [[UIView alloc] init];
    topView.frame = CGRectMake(0, 0, screenWidth, 170);
    topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topView];
    
    UILabel * lineLabel = [[UILabel alloc] init];
    lineLabel.frame = CGRectMake(0,169.5, screenWidth, 0.5);
    lineLabel.backgroundColor = KLineNewBGColor1;
    [topView addSubview:lineLabel];

    
    for (int i = 0; i < 2; i++)
    {
        UILabel * nameLabel = [[UILabel alloc] init];
        nameLabel.frame = CGRectMake(screenWidth/2*i, 123, screenWidth/2, 15);
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.textColor = KFontNewColorB;
        nameLabel.font = NormalFontWithSize(13);
        if (i == 0)
        {
            nameLabel.text = @"股票数量";
        }
        else if (i == 1)
        {
            nameLabel.text = @"今日新增股票";
        }
        [topView addSubview:nameLabel];
        
    }
    stockNumLabel = [[UILabel alloc] init];
    stockNumLabel.textColor = kRedColor;
    stockNumLabel.textAlignment = NSTextAlignmentCenter;
    stockNumLabel.font = BoldFontWithSize(50);
    stockNumLabel.frame = CGRectMake(0,61, screenWidth/2, 50);
    stockNumLabel.text = @"--";
    [topView addSubview:stockNumLabel];
    
    newStockNumLabel = [[UILabel alloc] init];
    newStockNumLabel.textColor = kRedColor;
    newStockNumLabel.textAlignment = NSTextAlignmentCenter;
    newStockNumLabel.font = BoldFontWithSize(50);
    newStockNumLabel.frame = CGRectMake(screenWidth/2,61, screenWidth/2, 50);
    newStockNumLabel.text = @"--";
    [topView addSubview:newStockNumLabel];
    
    rankTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(headerView.frame), screenWidth, screenHeight - CGRectGetHeight(headerView.frame)) style:UITableViewStylePlain];
    rankTableView.delegate = self;
    rankTableView.dataSource = self;
    rankTableView.backgroundColor = kBackgroundColor;
    rankTableView.separatorStyle = NO;
    [self.view addSubview:rankTableView];
    
    rankTableView.tableHeaderView = topView;
}

- (void)createFootView
{
    if (!refreshView)
    {
        refreshView = [[UIView alloc] init];
    }
    refreshView.frame = CGRectMake(0, 0, screenWidth, 50);
    refreshView.backgroundColor = kFontColorA;
    
    if (!refreshLabel)
    {
        refreshLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 15, screenWidth, 30)];
    }
    refreshLabel.font = NormalFontWithSize(15);
    refreshLabel.backgroundColor = [UIColor clearColor] ;
    refreshLabel.textAlignment = NSTextAlignmentCenter;
    refreshLabel.textColor = KFontNewColorA;
    refreshLabel.text = @"上拉加载更多";
    [refreshView addSubview:refreshLabel];
    
    if (!aiView)
    {
        aiView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(80, 33, 6, 6)];
    }
    aiView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [refreshView addSubview:aiView];
    [refreshView bringSubviewToFront:aiView];
    
    
    if (!feetView)
    {
        feetView = [[UIView alloc] init];
    }
    feetView.frame = CGRectMake(0, 0, screenWidth, 150);
    feetView.backgroundColor = [UIColor clearColor];
    
    UILabel * lineLabel = [[UILabel alloc] init];
    lineLabel.frame = CGRectMake(0, 0, screenWidth, 0.5);
    lineLabel.backgroundColor = KFontNewColorJ;
    [feetView addSubview:lineLabel];
    
    UIImageView * iconImgView = [[UIImageView alloc] init];
    iconImgView.frame = CGRectMake(screenWidth/2-15, 52, 30, 23);
    iconImgView.image = [UIImage imageNamed:@"zhangzhang"];
    [feetView addSubview:iconImgView];
    
    UILabel * ideaLabel = [[UILabel alloc] init];
    ideaLabel.frame = CGRectMake(0,CGRectGetMaxY(iconImgView.frame)+10, screenWidth, 12);
    ideaLabel.text = @"免费炒股，大赚真钱";
    ideaLabel.textAlignment = NSTextAlignmentCenter;
    ideaLabel.textColor = KFontNewColorC;
    ideaLabel.font = NormalFontWithSize(12);
    [feetView addSubview:ideaLabel];
    
    rankTableView.tableFooterView = feetView;
}

- (void)requestRankList:(NSString*)page
{
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setObject:page forKey:@"page"];
    [GFRequestManager connectWithDelegate:self action:Get_stock_feeling_list param:param];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    
    refreshLabel.text=@"上拉刷新";
    [aiView stopAnimating];
    isRefresh=NO;
    
    ASIFormDataRequest * formDataRequest = (ASIFormDataRequest*)request;
    if ([formDataRequest.action isEqualToString:Get_stock_feeling_list])
    {
        infoDic = [[requestInfo objectForKey:@"data"] mutableCopy];
        [self deliverDic:infoDic];
        
        NSMutableArray * tempArr = [[requestInfo objectForKey:@"data"] objectForKey:@"feeling_stock_list"];
        if (tempArr.count > 0  )
        {
            for (int i = 0; i<tempArr.count; i++)
            {
                [userArr addObject:[tempArr objectAtIndex:i]];
            }
            if (tempArr.count >= 20)
            {
                rankTableView.tableFooterView = refreshView;
            }
            else
            {
                rankTableView.tableFooterView = feetView;
            }
        }
        else
        {
            rankTableView.tableFooterView = feetView;
        }
    }
    [rankTableView reloadData];
}

- (void)deliverDic:(NSMutableDictionary*)dict
{
    stockNumLabel.text = [[dict objectForKey:@"feeling_stock_num"] description];
    newStockNumLabel.text = [[dict objectForKey:@"today_add_num"] description];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [userArr count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId = @"cellID";
    
    EmotionRankCell * rankCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!rankCell)
    {
        rankCell = [[EmotionRankCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    rankCell.frame = CGRectMake(0, 0, screenWidth, 80);
    rankCell.backgroundColor = kFontColorA;
    rankCell.rankImageView.hidden = NO;
    rankCell.rankLabel.hidden = YES;
    
    if (indexPath.row == 0)
    {
        rankCell.rankImageView.image = [UIImage imageNamed:@"icon_diyi"];
    }
    else if(indexPath.row == 1)
    {
        rankCell.rankImageView.image = [UIImage imageNamed:@"icon_dier"];
    }
    else if (indexPath.row == 2)
    {
        rankCell.rankImageView.image = [UIImage imageNamed:@"icon_disan"];
    }
    else
    {
        rankCell.rankImageView.hidden = YES;
        rankCell.rankLabel.hidden = NO;
        rankCell.rankLabel.text = [NSString stringWithFormat:@"%d", (int)indexPath.row+1];
    }
    
    NSDictionary * tempDic = [userArr objectAtIndex:indexPath.row];
    if (tempDic.allKeys > 0)
    {
        rankCell.emotionNumLabel.text = [[tempDic objectForKey:@"feeling"] description];
        rankCell.buyNumLabel.text = [[tempDic objectForKey:@"buy_all_money"] description];
        rankCell.profitNumLabel.text = [[tempDic objectForKey:@"profit_all_money"] description];
        rankCell.stockNameLabel.text = [[tempDic objectForKey:@"stock_name"] description];
    }
    
    
    return rankCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    EmotionViewController * EVC = [[EmotionViewController alloc] init];
    StockInfoEntity * stockInfo = [[StockInfoCoreDataStorage sharedInstance] getStockInfoWithCode:[[userArr objectAtIndex:indexPath.row] objectForKey:@"stock_code"] exchange:[[userArr objectAtIndex:indexPath.row] objectForKey:@"stock_exchange"]];
    EVC.stockInfo = stockInfo;
    EVC.emotionType = 2;
    [self pushToViewController:EVC];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.f;
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(scrollView.contentOffset.y + (screenHeight-64-49)>scrollView.contentSize.height+40.0)
    {
        [aiView startAnimating];
        refreshLabel.text=@"正在刷新";
        isRefresh=YES;
        currentPage = [[NSString stringWithFormat:@"%d",([currentPage intValue] +1)] copy];
        [self requestRankList:currentPage];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(isRefresh==NO){
        if(scrollView.contentOffset.y+(screenHeight-64-49)>scrollView.contentSize.height+40.0)
        {
            refreshLabel.text=@"松开即刷新";
        }
        else
        {
            refreshLabel.text=@"上拉加载更多";
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
