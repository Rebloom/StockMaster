//
//  NoticeViewController.m
//  StockMaster
//
//  Created by Rebloom on 15/3/17.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import "NoticeViewController.h"

@implementation NoticeViewController

- (void)dealloc
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [headerView loadComponentsWithTitle:@"推送通知"];
    [headerView backButton];
    
    infoTable = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, screenHeight-CGRectGetHeight(headerView.frame))];
    infoTable.delegate = self;
    infoTable.dataSource = self;
    infoTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:infoTable];
    
    openStockSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(screenWidth -65, 20, 10, 10)];
    [openStockSwitch addTarget:self action:@selector(openSwitchChanged:) forControlEvents:UIControlEventTouchUpInside];
    openStockSwitch.on = YES;
    
    //    onListSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(255, 20, 10, 10)];
    //    onListSwitch.on = YES;
    //
    //    withdrawSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(255, 20, 10, 10)];
    //    withdrawSwitch.on = YES;
    
    noticedStock = [[NSMutableArray alloc] initWithCapacity:10];
    unnoticedStock = [[NSMutableArray alloc] initWithCapacity:10];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self requestPushInfo];
}

- (void)openSwitchChanged:(id)sender
{
    UISwitch * s = (UISwitch *)sender;
    
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    if (s.on)
    {
        [param setObject:@"1" forKey:@"is_start_trade_push"];
    }
    else
    {
        [param setObject:@"2" forKey:@"is_start_trade_push"];
    }
    [GFRequestManager connectWithDelegate:self action:Submit_user_push_set_info param:param];
}

- (void)requestPushInfo
{
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [GFRequestManager connectWithDelegate:self action:Get_user_push_set_info param:param];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    ASIFormDataRequest * formDataRequest = (ASIFormDataRequest *)request;
    if ([formDataRequest.action isEqualToString:Get_user_push_set_info])
    {
        NSDictionary * dic = [requestInfo objectForKey:@"data"];
        noticedStock = [[dic objectForKey:@"has_remind_stock"] mutableCopy];
        unnoticedStock = [[dic objectForKey:@"none_remind_stock"] mutableCopy];
        if ([[dic objectForKey:@"is_start_trade_push"] integerValue] == 1)
        {
            openStockSwitch.on = YES;
        }
        else
        {
            openStockSwitch.on = NO;
        }
        [infoTable reloadData];
    }
    else if ([formDataRequest.action isEqualToString:Submit_user_push_set_info])
    {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:@"设置成功" withType:ALERTTYPEERROR];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [super requestFailed:request];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    else if (section == 1)
    {
        return noticedStock.count?noticedStock.count:1;
    }
    else if (section == 2)
    {
        return unnoticedStock.count?unnoticedStock.count:1;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 0;
    }
    else if (section == 1)
    {
        return 52;
    }
    else if (section == 2)
    {
        return 52;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 52)];
    view.backgroundColor = @"#f5f5f5".color;
    
    if (section == 1)
    {
        UILabel * noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 300, 52)];
        noticeLabel.backgroundColor = [UIColor clearColor];
        noticeLabel.textColor = @"#494949".color;
        noticeLabel.font = NormalFontWithSize(16);
        noticeLabel.text = @"添加提醒的股票";
        [view addSubview:noticeLabel];
    }
    else if (section == 2)
    {
        UILabel * noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 300, 52)];
        noticeLabel.backgroundColor = [UIColor clearColor];
        noticeLabel.textColor = @"#494949".color;
        noticeLabel.font = NormalFontWithSize(16);
        noticeLabel.text = @"持仓与自选中未添加提醒的股票";
        [view addSubview:noticeLabel];
    }
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 60)];
    
    NSDictionary * dic = nil;
    if (indexPath.section == 0)
    {
        NSArray * title = @[@"开市提醒",@"上榜通知",@"提现通知"];
        
        UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 100, 20)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = @"#494949".color;
        titleLabel.font = NormalFontWithSize(15);
        titleLabel.text = [title objectAtIndex:indexPath.row];
        [cell addSubview:titleLabel];
        
        if (indexPath.row == 0)
        {
            [cell addSubview:openStockSwitch];
        }
        
        return cell;
    }
    
    else if (indexPath.section == 1)
    {
        if (noticedStock.count)
        {
            dic = [noticedStock objectAtIndex:indexPath.row];
        }
        else
        {
            UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 100, 20)];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.textColor = @"#494949".color;
            titleLabel.font = NormalFontWithSize(15);
            titleLabel.text = @"无";
            [cell addSubview:titleLabel];
            
            return cell;
        }
    }
    else if (indexPath.section == 2)
    {
        if (unnoticedStock.count)
        {
            dic = [unnoticedStock objectAtIndex:indexPath.row];
        }
        else
        {
            UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 100, 20)];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.textColor = @"#494949".color;
            titleLabel.font = NormalFontWithSize(15);
            titleLabel.text = @"无";
            [cell addSubview:titleLabel];
            
            return cell;
        }
    }
    
    UILabel * stockLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 60)];
    stockLabel.backgroundColor = [UIColor clearColor];
    stockLabel.textColor = @"#494949".color;
    stockLabel.font = NormalFontWithSize(15);
    stockLabel.text = [NSString stringWithFormat:@"%@(%@)",[dic objectForKey:@"stock_name"],[dic objectForKey:@"stock_code"]];
    [cell addSubview:stockLabel];
    
    UILabel * stockType = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth-80, 0, 60, 60)];
    stockType.backgroundColor = [UIColor clearColor];
    stockType.textColor = @"#929292".color;
    stockType.font = NormalFontWithSize(13);
    stockType.textAlignment = NSTextAlignmentRight;
    
    if ([[dic objectForKey:@"user_stock_status"] integerValue] == 1)
    {
        stockType.text = @"持仓";
    }
    else
    {
        stockType.text = @"自选";
    }
    [cell addSubview:stockType];
    
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, 59.5, screenWidth, .5)];
    line.backgroundColor = KColorHeader;
    [cell addSubview:line];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0)
    {
        return;
    }
    NSDictionary * dic = nil;
    if (indexPath.section == 1)
    {
        if (!noticedStock.count)
        {
            return;
        }
        dic = [noticedStock objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == 2)
    {
        if (!unnoticedStock.count)
        {
            return;
        }
        dic = [unnoticedStock objectAtIndex:indexPath.row];
    }
    
    StockInfoEntity * stockInfo = [[StockInfoCoreDataStorage sharedInstance] getStockInfoWithCode:[dic objectForKey:@"stock_code"] exchange: [dic objectForKey:@"stock_exchange"]];
    
    NoticeSettingViewController * NSVC = [[NoticeSettingViewController alloc] init];
    NSVC.stockInfo = stockInfo;
    [self pushToViewController:NSVC];
}

@end
