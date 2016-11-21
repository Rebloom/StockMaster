//
//  WithDrawSellViewController.m
//  StockMaster
//
//  Created by Rebloom on 14/12/22.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "WithDrawSellViewController.h"
#import "HoldStockCell.h"

@interface WithDrawSellViewController () <HoldStockCellDelegate>
{
    NSArray *holdLongStockArray;
    NSArray *holdShortStockArray;
}

@end

@implementation WithDrawSellViewController

#pragma mark - View Load
- (void)viewDidLoad
{
    [super viewDidLoad];
    [headerView loadComponentsWithTitle:@"选择卖出股票"];
    headerView.backgroundColor = kFontColorA;
    [headerView setStatusBarColor:kFontColorA];
    [headerView backButton];
    [headerView createLine];
    
    [self requestSellStock];
    
    if (infoTable == nil)
    {
        infoTable = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, screenHeight-CGRectGetHeight(headerView.frame)) style:UITableViewStyleGrouped];
        infoTable.backgroundColor = [UIColor whiteColor];
        infoTable.delegate = self;
        infoTable.dataSource = self;
        infoTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:infoTable];
    }
    //下拉刷新
    if (!refreshview)
    {
        refreshview = [[EGORefreshTableHeaderView alloc] initWithFrame: CGRectMake(0, -65, screenWidth, 65)];
        refreshview.delegate = self;
        [infoTable addSubview:refreshview];
    }
}

#pragma mark - Control Action

#pragma mark - Private Method

#pragma mark - ASIHTTPRequestDelegate
// 获取卖出股票列表
- (void)requestSellStock
{
    UserInfoEntity *userInfo = [[UserInfoCoreDataStorage sharedInstance] getCurrentUserInfo];
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:userInfo.uid forKey:@"uid"];
    [GFRequestManager connectWithDelegate:self action:Get_sellable_stock_list param:paramDic];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    
    //结束下拉刷新
    isEgoRefresh = NO;
    
    ASIFormDataRequest * formDataRequest = (ASIFormDataRequest *)request;
    if ([formDataRequest.action isEqualToString:Get_sellable_stock_list])
    {
        NSArray *longArray = [[requestInfo objectForKey:@"data"] objectForKey:@"portfolio_long"];
        NSArray *shortArray = [[requestInfo objectForKey:@"data"] objectForKey:@"portfolio_short"];
        [[StockInfoCoreDataStorage sharedInstance] saveHoldStockWithLong:longArray andShort:shortArray];
        holdLongStockArray = [[StockInfoCoreDataStorage sharedInstance] getHoldStockWithType:StockHoldTypeLong];
        holdShortStockArray = [[StockInfoCoreDataStorage sharedInstance] getHoldStockWithType:StockHoldTypeShort];
        
        [infoTable reloadData];
        [refreshview egoRefreshScrollViewDataSourceDidFinishedLoading:infoTable];
    }
}

#pragma mark - HoldStockCellDelegate
- (void)holdStockSellBtnClickedAtIndexPath:(NSIndexPath *)indexPath
{
    HoldStockEntity * holdStock = nil;
    if (indexPath.section == 0) {
        holdStock = [holdLongStockArray objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == 1) {
        holdStock = [holdShortStockArray objectAtIndex:indexPath.row];
    }
    
    if (nil == holdStock) {
        return;
    }
    
    if (holdStock.isSellable)
    {
        SellStockViewController * SSVC = [[SellStockViewController alloc] init];
        SSVC.stockInfo = holdStock.stockInfo;
        SSVC.holdType = holdStock.holdType;
        [self pushToViewController:SSVC];
        
        // 诸葛统计
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"股票名"] = holdStock.stockInfo.name;
        if (holdStock.holdType == StockHoldTypeLong) {
            [[Zhuge sharedInstance] track:@"用户卖涨-提现卖出页" properties:dict];
        }
        else if (holdStock.holdType == StockHoldTypeShort) {
            [[Zhuge sharedInstance] track:@"用户卖跌-提现卖出页" properties:dict];
        }
    }
    else
    {
        [[CHNAlertView defaultAlertView] showContent:holdStock.sellMessage cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
    }
}

#pragma mark - TableView Delegate & DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (holdShortStockArray.count)
    {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return holdLongStockArray.count;
    }
    else if (section == 1) {
        return holdShortStockArray.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 46;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc] init];
    UILabel * buyLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 30, 150, 16)];
    buyLabel.backgroundColor = [UIColor clearColor];
    buyLabel.font = NormalFontWithSize(16);
    buyLabel.textColor = @"#929292".color;
    
    if (section == 0)
    {
        buyLabel.text = [NSString stringWithFormat:@"已买/持仓 (%d)", (int)holdLongStockArray.count];
    }
    else if (section == 1)
    {
        buyLabel.text = [NSString stringWithFormat:@"买跌/持仓 (%d)", (int)holdShortStockArray.count];
    }
    [view addSubview:buyLabel];
    
    
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, .5)];
    line.backgroundColor = @"#e2e2e2".color;
    [view addSubview:line];
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"HoldStockCell";
    
    HoldStockCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell) {
        cell = [[HoldStockCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.frame = CGRectMake(0, 0, screenWidth, 90);
    cell.delegate = self;
    cell.indexPath = indexPath;
    
    HoldStockEntity *holdStock = nil;
    if (indexPath.section == 0) {
        if (holdLongStockArray.count > indexPath.row)
        {
            UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, 61.5, screenWidth, .5)];
            line.backgroundColor = @"#e2e2e2".color;
            [cell addSubview:line];
        }
        holdStock = [holdLongStockArray objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == 1) {
        if (holdShortStockArray.count > indexPath.row)
        {
            UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, 61.5, screenWidth, .5)];
            line.backgroundColor = @"#e2e2e2".color;
            [cell addSubview:line];
        }
        holdStock = [holdShortStockArray objectAtIndex:indexPath.row];
    }
    
    cell.stockName.text = holdStock.stockInfo.name;
    cell.stockID.text = holdStock.stockInfo.code;
    cell.profitRate.text = holdStock.profitRate;
    cell.profit.text = holdStock.profitMoney;
    
    if (holdStock.status == 1)
    {
        cell.price.text = @"停牌";
    }
    else
    {
        cell.price.text = holdStock.currentPrice;
    }
    
    if ([holdStock.profitMoney componentsSeparatedByString:@"-"].count > 1)
    {
        cell.profit.textColor = kGreenColor;
        cell.profitRate.textColor = kGreenColor;
    }
    else
    {
        cell.profit.textColor = kRedColor;
        cell.profitRate.textColor = kRedColor;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.row < infoArr.count)
//    {
//        NSDictionary * dic = [infoArr objectAtIndex:indexPath.row];
//        StockInfoEntity * stockInfo = [[StockInfoCoreDataStorage sharedInstance] getStockInfoWithCode:CHECKDATA(@"stock_code") exchange:CHECKDATA(@"stock_exchange")];
//        SellStockViewController * SSVC = [[SellStockViewController alloc] init];
//        SSVC.stockInfo = stockInfo;
//        [self pushToViewController:SSVC];
//    }
}

#pragma mark - EGORefreshTableHeaderDelegate
//下拉刷新代理
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return isEgoRefresh;
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    isEgoRefresh = YES;
    [self requestSellStock];
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [NSDate date];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [refreshview egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [refreshview egoRefreshScrollViewDidScroll:scrollView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
