//
//  SecondViewController.m
//  StockMaster
//
//  Created by Rebloom on 14-7-22.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "SecondViewController.h"
#import "NSString+UIColor.h"
#import "UIImage+UIColor.h"
#import "LoginViewController.h"
#import "StockDetailViewController.h"
#import "StockLineViewController.h"
#import "BuySearchViewController.h"
#import "BuyStockViewController.h"
#import "SellStockViewController.h"

#define TableSectionNumber 4

enum TableSection
{
    TableSectionAsset = 0,
    TableSectionHoldLong = 1,
    TableSectionHoldShort = 2,
    TableSectionSelected = 3
};

@interface SecondViewController ()
{
    UserAssetEntity *userAsset;
}

@end

@implementation SecondViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}

#pragma mark - View Load
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [headerView loadComponentsWithTitle:@"买卖"];
    [headerView createLine];
    
    headerView.backgroundColor = kFontColorA;;
    headerView.alpha = 0;
    
    if ([self judgeCanShow])
    {
        holdLongStockArr = [[StockInfoCoreDataStorage sharedInstance] getHoldStockWithType:StockHoldTypeLong];
        selectedStockArr = [[StockInfoCoreDataStorage sharedInstance] getSelectStock];
        userAsset = [[UserInfoCoreDataStorage sharedInstance] getUserAsset];
        
        infoTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
        infoTable.backgroundColor = kBackgroundColor;
        infoTable.tableHeaderView = publicTop;
        //infoTable.showsHorizontalScrollIndicator = NO;
        infoTable.showsVerticalScrollIndicator = NO;
        infoTable.delegate = self;
        infoTable.dataSource = self;
        infoTable.editing = NO;
        infoTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:infoTable];
        
        publicTop = [[PublicTopView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, HeaderViewHeight)];
        publicTop.delegate = self;
        
        statusBarView.backgroundColor = [UIColor clearColor];
        
        infoTable.tableHeaderView = publicTop;
        
        NSDictionary * userFinanceInfo = (NSDictionary *)[[UserInfoCoreDataStorage sharedInstance] getSettingInfoWithKey:kTagUserFinanceInfo];
        if (userFinanceInfo)
        {
            [publicTop transInfo:userFinanceInfo];
            [publicTop clearsContextBeforeDrawing];
            [publicTop setNeedsDisplay];
            [infoTable.tableHeaderView bringSubviewToFront:publicTop];
        }
        
        if (!refreshview)
        {
            refreshview = [[EGORefreshTableHeaderView alloc] initWithFrame: CGRectMake(0, -65, screenWidth, 65)];
            refreshview.delegate = self;
            [infoTable addSubview:refreshview];
        }
        
        [self createFootView];
    }
    [self.view bringSubviewToFront:headerView];
}

//创建底部视图
-(void)createFootView
{
    UIView * footView = [[UIView alloc] init];
    footView.frame = CGRectMake(0, 0, screenWidth, 156);
    footView.backgroundColor = [UIColor clearColor];
    
    UILabel * ideaLabel = [[UILabel alloc] init];
    ideaLabel.frame = CGRectMake(0,footView.frame.size.height-100, screenWidth, 12);
    ideaLabel.text = @"免费炒股，大赚真钱";
    ideaLabel.textAlignment = NSTextAlignmentCenter;
    ideaLabel.textColor = KFontNewColorC;
    ideaLabel.font = NormalFontWithSize(12);
    [footView addSubview:ideaLabel];
    
    UIImageView * iconImgView = [[UIImageView alloc] init];
    iconImgView.frame = CGRectMake(screenWidth/2-15, CGRectGetMinY(ideaLabel.frame) - 33, 30, 23);
    iconImgView.image = [UIImage imageNamed:@"zhangzhang"];
    [footView addSubview:iconImgView];
    
    infoTable.tableFooterView = footView;
}

// 重新加载资产信息
- (void)reloadAssetView
{
    if (nil == userAsset) {
        return;
    }
    
    originMoney.text = userAsset.initbaseMoney;
    holdStockMoney.text = userAsset.positionMoney;
    canUseMoney.text = userAsset.usableMoney;
    NSString * profit = userAsset.profitMoney;
    
    if ([profit componentsSeparatedByString:@"-"].count > 1)
    {
        profitMoney.textColor = kGreenColor;
    }
    else
    {
        profitMoney.textColor = kRedColor;
    }
    profitMoney.text = profit;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    if ([self judgeCanShow])
    {
        [self requestStockTimeData];
        [self requestUserHistory];
        
        secondTimer = [NSTimer scheduledTimerWithTimeInterval:12 target:self selector:@selector(autoRequestStockInfo) userInfo:nil repeats:YES];
    }
    //    [infoTable scrollRectToVisible:CGRectMake(0, 0, screenWidth, infoTable.frame.size.height) animated:YES];
    
    // 诸葛统计（查看交易页）
    [[Zhuge sharedInstance] track:@"查看交易页" properties:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [secondTimer invalidate];
    
    [super viewWillDisappear:YES];
}

// 顶部统一头部代理方法
- (void)setStatusBarColor:(UIColor *)color
{
    //[headerView setStatusBarColor:color];
}

#pragma mark - Control Action
- (void)ruleBtnClicked:(id)sender
{
    if ([GFStaticData getObjectForKey:kTagAppStoreClose])
    {
        UserInfoEntity *userInfo = [[UserInfoCoreDataStorage sharedInstance] getCurrentUserInfo];
        NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@uid=%@&token=%@&t=%@",HostWithDrawAddress, userInfo.uid, userInfo.token, [Utility dateTimeToStringLF:[NSDate date]]]];
        
        GFWebViewController * GWVC = [[GFWebViewController alloc] init];
        GWVC.pageType = WebViewTypePush;
        GWVC.requestUrl = url;
        GWVC.title = @"提现";
        GWVC.flag = 0;
        [self pushToViewController:GWVC];
    }
}

//没有自选去发现页面
- (void)emptyViewClicked:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KTAGVCSWITCH object:@"2"];
}

//持仓的股票进入股票详情页
- (void)holdCellClicked:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    if (btn.tag < holdLongStockArr.count)
    {
        HoldStockEntity * holdStock = [holdLongStockArr objectAtIndex:btn.tag];
        
        StockDetailViewController * SDVC = [[StockDetailViewController alloc] init];
        SDVC.stockInfo = holdStock.stockInfo;
        [self pushToViewController:SDVC];
        
        [infoTable reloadData];
    }
}

- (void)setTableViewEditable:(UIButton *)sender
{
    tableViewEditing = !tableViewEditing;
    editBtn.selected = tableViewEditing;
    deleteImage.hidden = tableViewEditing;
    [infoTable reloadData];
}

//买股票
- (void)buyStock
{
    if (portfolioDic == nil) {
        return;
    }
    
    if ([canUseMoney.text integerValue] > 0)
    {
        BOOL is_tradable = [[portfolioDic objectForKey:@"is_tradable"] boolValue];
        if (is_tradable)
        {
            BuySearchViewController * BSVC = [[BuySearchViewController alloc] init];
            [self pushToViewController:BSVC];
        }
        else
        {
            [[CHNAlertView defaultAlertView] showContent:[[portfolioDic objectForKey:@"is_tradable_message"] description] cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
        }
    }
    else
    {
        [[CHNAlertView defaultAlertView] showContent:@"可用余额不足" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
    }
}

#pragma mark - Private Method
//判断是否需要登录
- (BOOL)judgeCanShow
{
    if (![[UserInfoCoreDataStorage sharedInstance] isCurrentUserLogin])
    {
        LoginViewController * SLVC = [[LoginViewController alloc] init];
        SLVC.flag = 1;
        SLVC.selectType = 2;
        [self pushToViewController:SLVC];
        return NO;
    }
    return YES;
}

#pragma mark - TableView DataSource & Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return TableSectionNumber;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == TableSectionHoldLong)
    {
        return holdLongStockArr.count?holdLongStockArr.count:1;
    }
    else if (section == TableSectionHoldShort) {
        return holdShortStockArr.count?holdShortStockArr.count:1;
    }
    else if (section == TableSectionSelected)
    {
        return selectedStockArr.count?selectedStockArr.count:1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * holdCellIDT = @"HOLDCELL";
    static NSString * selectedCellIDT = @"SELECTEDCELL";
    
    if (indexPath.section == TableSectionHoldLong)
    {
        HoldStockCell * cell = [tableView dequeueReusableCellWithIdentifier:holdCellIDT];
        if (nil == cell) {
            cell = [[HoldStockCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:holdCellIDT];
        }
        
        cell.frame = CGRectMake(0, 0, screenWidth, 90);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        cell.indexPath = indexPath;
        
        if (holdLongStockArr.count)
        {
            HoldStockEntity * holdStock = [holdLongStockArr objectAtIndex:indexPath.row];
            
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
        }
        else
        {
            UITableViewCell * emptyView = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 90)];
            emptyView.backgroundColor = [UIColor whiteColor];
            
            UIButton * toShake = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 90)];
            [toShake addTarget:self action:@selector(emptyViewClicked:) forControlEvents:UIControlEventTouchUpInside];
            [emptyView addSubview:toShake];
            
            UILabel * lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 90)];
            lbl.textAlignment = NSTextAlignmentCenter;
            lbl.backgroundColor = [UIColor clearColor];
            lbl.textColor = @"#949494".color;
            lbl.text = @"空空如也~去发现看看呗";
            lbl.font = NormalFontWithSize(15);
            [emptyView addSubview:lbl];
            
            return emptyView;
        }
        return cell;
    }
    else if (indexPath.section == TableSectionHoldShort)
    {
        HoldStockCell * cell = [tableView dequeueReusableCellWithIdentifier:holdCellIDT];
        if (nil == cell) {
            cell = [[HoldStockCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:holdCellIDT];
            cell = [[HoldStockCell alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 90)];
        }
        
        cell.frame = CGRectMake(0, 0, screenWidth, 90);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        cell.indexPath = indexPath;
        
        if (holdShortStockArr.count)
        {
            HoldStockEntity * holdStock = [holdShortStockArr objectAtIndex:indexPath.row];
            
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
        }
        else
        {
            UITableViewCell * emptyView = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 90)];
            emptyView.backgroundColor = [UIColor whiteColor];
            
            UIButton * toShake = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 90)];
            [toShake addTarget:self action:@selector(emptyViewClicked:) forControlEvents:UIControlEventTouchUpInside];
            [emptyView addSubview:toShake];
            
            UILabel * lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 90)];
            lbl.textAlignment = NSTextAlignmentCenter;
            lbl.backgroundColor = [UIColor clearColor];
            lbl.textColor = @"#949494".color;
            lbl.text = @"空空如也~去发现看看呗";
            lbl.font = NormalFontWithSize(15);
            [emptyView addSubview:lbl];
            
            return emptyView;
        }
        return cell;
    }
    else if (indexPath.section == TableSectionSelected)
    {
        SelectedStockCell * cell = [tableView dequeueReusableCellWithIdentifier:selectedCellIDT];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (!cell)
        {
            cell = [[SelectedStockCell alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 90)];
            cell.delegate = self;
            cell.tag = indexPath.row;
        }
        
        if (selectedStockArr.count)
        {
            SelectStockEntity * selectStock = [selectedStockArr objectAtIndex:indexPath.row];
            
            cell.stockName.text = selectStock.stockInfo.name;
            cell.stockID.text = selectStock.stockInfo.code;
            cell.profit.text = selectStock.profitRate;
            
            cell.buyButton.selected = tableViewEditing;
            
            if ([selectStock.profitRate componentsSeparatedByString:@"-"].count > 1)
            {
                cell.profit.textColor = kGreenColor;
            }
            else
            {
                cell.profit.textColor = kRedColor;
            }
            
            if (selectStock.status == 1)
            {
                cell.price.text = @"停牌";
            }
            else
            {
                cell.price.text = selectStock.currentPrice;
            }
            
            cell.updownRange.text = selectStock.profitRate;
            
            if ([selectStock.profitRate componentsSeparatedByString:@"-"].count > 1)
            {
                cell.updownRange.backgroundColor = kGreenColor;
            }
            else
            {
                cell.updownRange.backgroundColor = kRedColor;
            }
            
            if (selectedStockArr.count == indexPath.row)
            {
                UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, 89.5, screenWidth, .5)];
                line.backgroundColor = @"#e2e2e2".color;
                [cell addSubview:line];
            }
        }
        else
        {
            UITableViewCell * emptyView = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 90)];
            emptyView.backgroundColor = [UIColor whiteColor];
            
            UIButton * toShake = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 90)];
            [toShake addTarget:self action:@selector(emptyViewClicked:) forControlEvents:UIControlEventTouchUpInside];
            [emptyView addSubview:toShake];
            
            UILabel * lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 90)];
            lbl.textAlignment = NSTextAlignmentCenter;
            lbl.backgroundColor = [UIColor clearColor];
            lbl.textColor = @"#949494".color;
            lbl.text = @"空空如也~去发现看看呗";
            lbl.font = NormalFontWithSize(15);
            [emptyView addSubview:lbl];
            
            return emptyView;
        }
        
        return cell;
    }
    
    return [[UITableViewCell alloc] initWithFrame:CGRectZero];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == TableSectionAsset)
    {
        return 80;
    }
    return 46;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 60)];
    view.backgroundColor = [UIColor whiteColor];
    
    if (section == TableSectionAsset)
    {
        view.backgroundColor = @"#f5f5f5".color;
        if (!originMoney)
        {
            originMoney = [[UILabel alloc] initWithFrame:CGRectMake(90, 0, 60, 40)];
            originMoney.backgroundColor = [UIColor clearColor];
            originMoney.textColor = KFontNewColorA;
            originMoney.font = BoldFontWithSize(13);
            originMoney.textAlignment = NSTextAlignmentCenter;
        }
        [view addSubview:originMoney];
        
        if (!originMoenyDesc)
        {
            originMoenyDesc = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 60, 40)];
            originMoenyDesc.backgroundColor = [UIColor clearColor];
            originMoenyDesc.textColor = KFontNewColorB;
            originMoenyDesc.font = NormalFontWithSize(13);
            originMoenyDesc.textAlignment = NSTextAlignmentCenter;
        }
        [view addSubview:originMoenyDesc];
        originMoenyDesc.text = @"炒股本金";
        
        if (!holdStockMoney)
        {
            holdStockMoney = [[UILabel alloc] initWithFrame:CGRectMake(90, 40, 60, 40)];
            holdStockMoney.backgroundColor = [UIColor clearColor];
            holdStockMoney.textColor = KFontNewColorA;
            holdStockMoney.font = BoldFontWithSize(13);
            holdStockMoney.textAlignment = NSTextAlignmentCenter;
        }
        [view addSubview:holdStockMoney];
        
        if (!holdStockDesc)
        {
            holdStockDesc = [[UILabel alloc] initWithFrame:CGRectMake(30, 40, 60, 40)];
            holdStockDesc.backgroundColor = [UIColor clearColor];
            holdStockDesc.textColor = KFontNewColorB;
            holdStockDesc.font = NormalFontWithSize(13);
            holdStockDesc.textAlignment = NSTextAlignmentCenter;
        }
        [view addSubview:holdStockDesc];
        holdStockDesc.text = @"持股市值";
        
        UIView * line1 = [[UIView alloc] initWithFrame:CGRectMake(15, 40, screenWidth-30, .5)];
        line1.backgroundColor = @"#e2e2e2".color;
        [view addSubview:line1];
        
        UIView * line2 = [[UIView alloc] initWithFrame:CGRectMake(screenWidth/2, 15, .5, 50)];
        line2.backgroundColor = @"#e2e2e2".color;
        [view addSubview:line2];
        
        UIView * line3 = [[UIView alloc] initWithFrame:CGRectMake(0, 79.5, screenWidth, .5)];
        line3.backgroundColor = @"#e2e2e2".color;
        [view addSubview:line3];
        
        if (!canUseMoney)
        {
            canUseMoney = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/2+90, 0, 60, 40)];
            canUseMoney.backgroundColor = [UIColor clearColor];
            canUseMoney.textColor = KFontNewColorA;
            canUseMoney.font = BoldFontWithSize(13);
            canUseMoney.textAlignment = NSTextAlignmentCenter;
        }
        [view addSubview:canUseMoney];
        
        if (!canUserDesc)
        {
            canUserDesc = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/2+30, 0, 60, 40)];
            canUserDesc.backgroundColor = [UIColor clearColor];
            canUserDesc.textColor = KFontNewColorB;
            canUserDesc.font = NormalFontWithSize(13);
            canUserDesc.textAlignment = NSTextAlignmentCenter;
        }
        [view addSubview:canUserDesc];
        canUserDesc.text = @"可用余额";
        
        UIImageView * redImage = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-26, 14, 23, 23)];
        redImage.image = [UIImage imageNamed:@"icon_red_buy"];
        [view addSubview:redImage];
        
        UILabel * buyLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth-26, 25, 21, 10)];
        buyLabel.textAlignment = NSTextAlignmentRight;
        buyLabel.font = NormalFontWithSize(10);
        buyLabel.textColor = [UIColor whiteColor];
        buyLabel.text = @"买";
        [view addSubview:buyLabel];
        
        UIButton * buyStockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [buyStockBtn addTarget:self action:@selector(buyStock) forControlEvents:UIControlEventTouchUpInside];
        buyStockBtn.frame = CGRectMake(screenWidth/2, 0, screenWidth/2, 40);
        [view addSubview:buyStockBtn];
        
        if (!profitMoney)
        {
            profitMoney = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/2+90, 40, 60, 40)];
            profitMoney.backgroundColor = [UIColor clearColor];
            profitMoney.font = BoldFontWithSize(13);
            profitMoney.textAlignment = NSTextAlignmentCenter;
        }
        [view addSubview:profitMoney];
        
        if (!profitDesc)
        {
            profitDesc = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/2+30, 40, 60, 40)];
            profitDesc.backgroundColor = [UIColor clearColor];
            profitDesc.textColor = KFontNewColorB;
            profitDesc.font = NormalFontWithSize(13);
            profitDesc.textAlignment = NSTextAlignmentCenter;
        }
        [view addSubview:profitDesc];
        profitDesc.text = @"持仓盈亏";
        
        [self reloadAssetView];
    }
    else if (section == TableSectionHoldLong ||
             section == TableSectionHoldShort ||
             section == TableSectionSelected)
    {
        UILabel * buyLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 30, 150, 16)];
        buyLabel.backgroundColor = [UIColor clearColor];
        buyLabel.font = NormalFontWithSize(16);
        buyLabel.textColor = @"#929292".color;
        
        if (section == TableSectionHoldLong)
        {
            buyLabel.text = [NSString stringWithFormat:@"已买/持仓 (%d)", (int)holdLongStockArr.count];
        }
        else if (section == TableSectionHoldShort)
        {
            buyLabel.text = [NSString stringWithFormat:@"买跌/持仓 (%d)", (int)holdShortStockArr.count];
        }
        else
        {
            buyLabel.text = [NSString stringWithFormat:@"购物车/自选 (%d)", (int)selectedStockArr.count];
            
            if (!deleteImage)
            {
                deleteImage = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-55, 29, 16, 16)];
            }
            deleteImage.image = [UIImage imageNamed:@"icon_select_delete"];
            [view addSubview:deleteImage];
            
            
            if (!editBtn)
            {
                editBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth-73, 9, 48, 56)];
            }
            [editBtn addTarget:self action:@selector(setTableViewEditable:) forControlEvents:UIControlEventTouchUpInside];
            [editBtn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
            [editBtn setTitle:@"完成" forState:UIControlStateSelected];
            editBtn.titleLabel.font = NormalFontWithSize(13);
            [editBtn setTitle:@"" forState:UIControlStateNormal];
            [view addSubview:editBtn];
        }
        [view addSubview:buyLabel];
        
        if (selectedStockArr.count > 0)
        {
            if (tableViewEditing)
            {
                deleteImage.hidden = YES;
                [editBtn setTitle:@"完成" forState:UIControlStateSelected];
            }
            else
            {
                deleteImage.hidden = NO;
                [editBtn setTitle:@"" forState:UIControlStateSelected];
            }
        }
        else
        {
            deleteImage.hidden = YES;
            [editBtn setTitle:@"" forState:UIControlStateSelected];
            tableViewEditing = NO;
        }
        
        UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, .5)];
        line.backgroundColor = @"#e2e2e2".color;
        [view addSubview:line];
    }
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == TableSectionAsset)
    {
        // do nothing
    }
    else if (indexPath.section == TableSectionHoldLong)
    {
        HoldStockEntity * holdStock = [holdLongStockArr objectAtIndex:indexPath.row];
        
        StockDetailViewController * SDVC = [[StockDetailViewController alloc] init];
        SDVC.stockInfo = holdStock.stockInfo;
        [self pushToViewController:SDVC];
    }
    else if (indexPath.section == TableSectionHoldShort)
    {
        HoldStockEntity * holdStock = [holdShortStockArr objectAtIndex:indexPath.row];
        
        StockDetailViewController * SDVC = [[StockDetailViewController alloc] init];
        SDVC.stockInfo = holdStock.stockInfo;
        [self pushToViewController:SDVC];
    }
    
    else if (indexPath.section == TableSectionSelected)
    {
        SelectStockEntity * selectStock = [selectedStockArr objectAtIndex:indexPath.row];
        
        StockDetailViewController * SDVC = [[StockDetailViewController alloc] init];
        SDVC.stockInfo = selectStock.stockInfo;
        [self pushToViewController:SDVC];
    }
}

//持仓cell的代理方法
#pragma mark - HoldStockCellDelegate
- (void)holdStockSellBtnClickedAtIndexPath:(NSIndexPath *)indexPath
{
    HoldStockEntity * holdStock = nil;
    if (indexPath.section == TableSectionHoldLong) {
        holdStock = [holdLongStockArr objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == TableSectionHoldShort) {
        holdStock = [holdShortStockArr objectAtIndex:indexPath.row];
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
            [[Zhuge sharedInstance] track:@"用户卖涨-买卖页" properties:dict];
        }
        else if (holdStock.holdType == StockHoldTypeShort) {
            [[Zhuge sharedInstance] track:@"用户卖跌-买卖页" properties:dict];
        }
    }
    else
    {
        [[CHNAlertView defaultAlertView] showContent:holdStock.sellMessage cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
    }
}

//自选cell的代理方法
#pragma mark - SelectedStockCellDelegate
- (void)SelectedStockCellClickedAtIndex:(NSInteger)index withTag:(NSInteger)tag
{
    SelectStockEntity * selectStock = [selectedStockArr objectAtIndex:tag];
    if (tableViewEditing)
    {
        selectedIndex = tag;
        // 删自选
        NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
        [paramDic setObject:selectStock.stockInfo.code forKey:@"stock_code"];
        [paramDic setObject:selectStock.stockInfo.exchange forKey:@"stock_exchange"];
        [GFRequestManager connectWithDelegate:self action:Delete_stock_watchlist param:paramDic];
    }
    else
    {
        StockDetailViewController * SDVC = [[StockDetailViewController alloc] init];
        SDVC.stockInfo = selectStock.stockInfo;
        [self pushToViewController:SDVC];
    }
}

#pragma mark - ASIHTTPRequestDelegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    isEgoRefresh = NO;
    [refreshview egoRefreshScrollViewDataSourceDidFinishedLoading:infoTable];
    
    ASIFormDataRequest * formdataRequest = (ASIFormDataRequest *)request;
    if ([[requestInfo objectForKey:@"err_code"] integerValue])
    {
        [[CHNAlertView defaultAlertView] showContent:[[requestInfo objectForKey:@"message"] description] cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
        return;
    }
    
    if ([formdataRequest.action isEqualToString:Get_portfolio_home])
    {
        NSArray *longArray = [[requestInfo objectForKey:@"data"] objectForKey:@"portfolio_long"];
        NSArray *shortArray = [[requestInfo objectForKey:@"data"] objectForKey:@"portfolio_short"];
        [[StockInfoCoreDataStorage sharedInstance] saveHoldStockWithLong:longArray andShort:shortArray];
        holdLongStockArr = [[StockInfoCoreDataStorage sharedInstance] getHoldStockWithType:StockHoldTypeLong];
        holdShortStockArr = [[StockInfoCoreDataStorage sharedInstance] getHoldStockWithType:StockHoldTypeShort];
        
        NSDictionary *assetDict = [requestInfo objectForKey:@"data"];
        userAsset = [[UserInfoCoreDataStorage sharedInstance] saveUserAsset:assetDict];
        
        // 不在交易时间，暂停定时加载
        if ([[assetDict objectForKey:@"is_tradable"] integerValue] == 0)
        {
            [secondTimer pauseTimer];
        }
        
        [self reloadAssetView];
        
        portfolioDic = [[requestInfo objectForKey:@"data"] mutableCopy];
    }
    else if ([formdataRequest.action isEqualToString:Get_stock_watchlist])
    {
        NSArray *stockArray = [requestInfo objectForKey:@"data"];
        [[StockInfoCoreDataStorage sharedInstance] saveSelectStock:stockArray];
        
        selectedStockArr = [[[StockInfoCoreDataStorage sharedInstance] getSelectStock] copy];
    }
    else if ([formdataRequest.action isEqualToString:Delete_stock_watchlist])
    {
        SelectStockEntity * selectStock = [selectedStockArr objectAtIndex:selectedIndex];
        [[StockInfoCoreDataStorage sharedInstance] delSelectStockWithCode:selectStock.stockInfo.code exchange:selectStock.stockInfo.exchange];
        selectedStockArr = [[[StockInfoCoreDataStorage sharedInstance] getSelectStock] copy];
        
        [[TKAlertCenter defaultCenter] postAlertWithMessage:@"删除自选成功" withType:ALERTTYPEERROR];
    }
    else if ([formdataRequest.action isEqualToString:Get_user_history_assets])
    {
        [publicTop transInfo:[requestInfo objectForKey:@"data"]];
        [publicTop clearsContextBeforeDrawing];
        [publicTop setNeedsDisplay];
        [infoTable.tableHeaderView bringSubviewToFront:publicTop];
    }
    [infoTable reloadData];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [super requestFailed:request];
    isEgoRefresh = NO;
}

//请求用户历史本金记录
-(void)requestUserHistory
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [GFRequestManager connectWithDelegate:self action:Get_user_history_assets param:paramDic];
}

// 获取用户持仓股票列表数据
- (void)requestHoldingInfo
{
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setObject:@"1" forKey:@"request_by"];
    [GFRequestManager connectWithDelegate:self action:Get_portfolio_home param:param];
}

// 获取用户自选股票列表数据
- (void)requestWatchListInfo
{
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setObject:@"1" forKey:@"request_by"];
    [GFRequestManager connectWithDelegate:self action:Get_stock_watchlist param:param];
}

//请求数据
- (void)requestStockTimeData
{
    [self requestHoldingInfo];
    [self requestWatchListInfo];
}

- (void)autoRequestStockInfo
{
    NSMutableDictionary * param1 = [NSMutableDictionary dictionary];
    [param1 setObject:@"2" forKey:@"request_by"];
    [GFRequestManager connectWithDelegate:self action:Get_portfolio_home param:param1];
    
    NSMutableDictionary * param2 = [NSMutableDictionary dictionary];
    [param2 setObject:@"2" forKey:@"request_by"];
    [GFRequestManager connectWithDelegate:self action:Get_stock_watchlist param:param2];
}

#pragma mark - CHNAlertViewDelegate
- (void)buttonClickedAtIndex:(NSInteger)index
{
    if (index == 0)
    {
        // 取消了，啥也不用干
    }
    else if (index == 1)
    {
        WithDrawSellViewController * WDSVC = [[WithDrawSellViewController alloc] init];
        [self pushToViewController:WDSVC];
    }
    else if (index == 3)
    {
        [GFStaticData saveObject:@"YES" forKey:kTagNeedToAlert];
        // 查看提现规则
        GFWebViewController * GWVC = [[GFWebViewController alloc] init];
        GWVC.requestUrl = [NSURL URLWithString:@"http://m.aizhangzhang.com/html5/withdraw_rate.html"];
        GWVC.title = @"提现规则";
        GWVC.flag = 0;
        [self presentViewController:GWVC];
    }
}

#pragma mark - EGORefreshTableHeaderDelegate
//下拉刷新代理方法
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return isEgoRefresh;
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    isEgoRefresh = YES;
    [self requestUserHistory];
    [self requestHoldingInfo];
    [self requestWatchListInfo];
    
    // 诸葛统计（下拉刷新交易页）
    [[Zhuge sharedInstance] track:@"下拉刷新交易页" properties:nil];
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
    
    if ([scrollView isEqual:infoTable])
    {
        if (scrollView.contentOffset.y < 30)
        {
            headerView.alpha = 0;
            
            [self.view bringSubviewToFront:infoTable];
        }
        else if (scrollView.contentOffset.y > 150)
        {
            headerView.alpha = 1;
            [self.view bringSubviewToFront:headerView];
            [self.view sendSubviewToBack:infoTable];
        }
        else
        {
            headerView.alpha = (scrollView.contentOffset.y/120);
            
            [self.view sendSubviewToBack:infoTable];
            [self.view bringSubviewToFront:headerView];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
