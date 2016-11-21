//
//  SubSectionViewController.m
//  StockMaster
//
//  Created by dalikeji on 14/11/26.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "SubSectionViewController.h"
#import "StockDetailViewController.h"

#define KTagUpDownImageView    9999
#define KTagUpdownBtn          8888

@interface SubSectionViewController ()

@end

@implementation SubSectionViewController
@synthesize plate_code;
@synthesize plate_name;

- (void)dealloc
{
    for (ASIFormDataRequest * request in [RequestQueue instance].requestList)
    {
        if ([request.action isEqualToString:Get_plate_stock_list])
        {
            [request cancel];
            request.delegate = nil;
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor =KSelectNewColor;
    
    [headerView loadComponentsWithTitle:self.plate_name];
    [headerView backButton];
    [headerView createLine];
    headerView.backgroundColor = kFontColorA;
    [headerView setStatusBarColor: kFontColorA];
    
    isFirst = NO;
    isSecond = NO;
    isThird = YES;
    
    is_tradable = YES;
    is_request_by = YES;
    
    // 排序的标识
    sort_key = @"04";
    flag = 0;
    
    infoArr = [[NSMutableArray alloc ]initWithCapacity:10];
    
    infoTabelView = [[UITableView alloc] initWithFrame:CGRectMake(0, 65, screenWidth, screenHeight - 65) style:UITableViewStylePlain];
    infoTabelView.delegate = self;
    infoTabelView.dataSource = self;
    infoTabelView.backgroundColor = KSelectNewColor;
    infoTabelView.separatorStyle = UITableViewCellAccessoryNone;
    [self.view addSubview:infoTabelView];
    
    [self createFootView];
    
    if (!refreshview)
    {
        refreshview = [[EGORefreshTableHeaderView alloc] initWithFrame: CGRectMake(0, -65, screenWidth, 65)];
        refreshview.delegate=self;
        [infoTabelView addSubview:refreshview];
    }
    
}

// 创建底部控件
- (void)createFootView
{
    UIView * view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, screenWidth, 150);
    view.backgroundColor = [UIColor clearColor];
    infoTabelView.tableFooterView = view;
    
    UIImageView * iconImgView = [[UIImageView alloc] init];
    iconImgView.frame = CGRectMake(screenWidth/2-15, 52, 30, 23);
    iconImgView.image = [UIImage imageNamed:@"zhangzhang"];
    [view addSubview:iconImgView];
    
    UILabel * ideaLabel = [[UILabel alloc] init];
    ideaLabel.frame = CGRectMake(0,CGRectGetMaxY(iconImgView.frame)+10, screenWidth, 12);
    ideaLabel.text = @"免费炒股，大赚真钱";
    ideaLabel.textAlignment = NSTextAlignmentCenter;
    ideaLabel.textColor = KFontNewColorC;
    ideaLabel.font = NormalFontWithSize(12);
    [view addSubview:ideaLabel];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return infoArr.count +1;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 52)];
    view.backgroundColor = KSelectNewColor;
    view.alpha = 0.8;
    view.userInteractionEnabled = YES;
    
    updownIv1 = [[UIImageView alloc] init];
    if(isFirst)
    {
        updownIv1.image = [UIImage imageNamed:@"icon_xiangxia"];
    }
    else
    {
        updownIv1.image = [UIImage imageNamed:@"icon_xiangshang"];
    }
    [view addSubview:updownIv1];
    
    updownIv2 = [[UIImageView alloc] init];
    if(isSecond)
    {
        updownIv2.image = [UIImage imageNamed:@"icon_xiangxia"];
    }
    else
    {
        updownIv2.image = [UIImage imageNamed:@"icon_xiangshang"];
    }
    [view addSubview:updownIv2];
    
    updownIv3 = [[UIImageView alloc] init];
    if(isThird)
    {
        updownIv3.image = [UIImage imageNamed:@"icon_xiangxia"];
    }
    else
    {
        updownIv3.image = [UIImage imageNamed:@"icon_xiangshang"];
    }
    [view addSubview:updownIv3];
    
    NSArray * arr = @[@"股票名称",@"当前价",@"涨跌价",@"涨跌幅"];
    for (int i = 0; i<arr.count; i++)
    {
        UILabel * label = [[UILabel alloc] init];
        label.frame = CGRectMake(i*(screenWidth)/4, 0, (screenWidth)/4, 52);
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = KFontNewColorB;
        label.text = [arr objectAtIndex:i];
        label.backgroundColor = [UIColor clearColor];
        label.font = NormalFontWithSize(13);
        [view addSubview:label];
        
        if (i == 1)
        {
            updownIv1.frame = CGRectMake(CGRectGetMaxX(label.frame) -15, 20, 6, 13);
        }
        else if (i == 2)
        {
            updownIv2.frame = CGRectMake(CGRectGetMaxX(label.frame) -15, 20, 6, 13);
        }
        else if (i == 3)
        {
            updownIv3.frame = CGRectMake(CGRectGetMaxX(label.frame) -15, 20, 6, 13);
        }
    }
    
    for (int i =1; i<=3; i++)
    {
        UIButton * upDownBtn = [[UIButton alloc] init];
        upDownBtn.frame = CGRectMake(i*(screenWidth)/4, 0, (screenWidth)/4, 52);
        upDownBtn.tag = i+KTagUpdownBtn;
        upDownBtn.backgroundColor = [UIColor clearColor];
        [upDownBtn addTarget:self action:@selector(upDownBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:upDownBtn];
        
        
    }
    
    if (flag == 0 || flag ==3 )
    {
        updownIv1.hidden =YES;
        updownIv2.hidden = YES;
        updownIv3.hidden = NO;
    }
    else if (flag == 1)
    {
        updownIv1.hidden = NO;
        updownIv2.hidden = YES;
        updownIv3.hidden = YES;
    }
    else if (flag == 2)
    {
        updownIv1.hidden = YES;
        updownIv2.hidden = NO;
        updownIv3.hidden = YES;
    }
    
    return view;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 60)];
    [cell setBackgroundColor:kFontColorA];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel * nameLabel = [[UILabel alloc] init];
    nameLabel.frame = CGRectMake(0, 30, screenWidth/4, 15);
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.textColor = KFontNewColorA;
    nameLabel.text = @"";
    nameLabel.font = NormalFontWithSize(15);
    [cell addSubview:nameLabel];
    
    UILabel * codeLabel = [[UILabel alloc] init];
    codeLabel.frame = CGRectMake(0, 45, screenWidth/4, 15);
    codeLabel.textAlignment = NSTextAlignmentCenter;
    codeLabel.textColor = KFontNewColorA;
    codeLabel.text = @"";
    codeLabel.font = NormalFontWithSize(13);
    [cell addSubview:codeLabel];
    
    UILabel * priceLabel = [[UILabel alloc] init];
    priceLabel.frame = CGRectMake(screenWidth/4, 35, screenWidth/4, 20);
    priceLabel.textAlignment = NSTextAlignmentCenter;
    priceLabel.text = @"";
    priceLabel.font = NormalFontWithSize(15);
    [cell addSubview:priceLabel];
    
    UILabel * upDownLabel = [[UILabel alloc] init];
    upDownLabel.frame = CGRectMake(screenWidth/4*2, 35, screenWidth/4, 20);
    upDownLabel.textAlignment = NSTextAlignmentCenter;
    upDownLabel.text = @"";
    upDownLabel.font = NormalFontWithSize(15);
    [cell addSubview:upDownLabel];
    
    UILabel * perLabel = [[UILabel alloc] init];
    perLabel.frame = CGRectMake(screenWidth/4*3, 35, screenWidth/4,20);
    perLabel.textAlignment = NSTextAlignmentCenter;
    perLabel.text = @"";
    perLabel.font = NormalFontWithSize(15);
    [cell addSubview:perLabel];
    
    if (infoArr.count > indexPath.row)
    {
        nameLabel.text = [[infoArr objectAtIndex:indexPath.row] objectForKey:@"stock_name"];
        codeLabel.text = [[infoArr objectAtIndex:indexPath.row] objectForKey:@"stock_code"];
        priceLabel.text = [[infoArr objectAtIndex:indexPath.row] objectForKey:@"current_price"];
        upDownLabel.text = [[infoArr objectAtIndex:indexPath.row] objectForKey:@"updown_price"];
        perLabel.text = [[infoArr objectAtIndex:indexPath.row] objectForKey:@"updown_range"];
        
        if ([perLabel.text floatValue]>=0)
        {
            perLabel.textColor = kRedColor;
            upDownLabel.textColor = kRedColor;
            priceLabel.textColor = kRedColor;
        }
        else
        {
            perLabel.textColor = kGreenColor;
            upDownLabel.textColor = kGreenColor;
            priceLabel.textColor = kGreenColor;
        }
    }
    else if(indexPath.row ==  infoArr.count && indexPath.row != 0 )
    {
        nameLabel.frame = CGRectZero;
        codeLabel.frame = CGRectZero;
        priceLabel.frame = CGRectZero;
        upDownLabel.frame = CGRectZero;
        perLabel.frame = CGRectZero;
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (infoArr.count > indexPath.row)
    {
        StockInfoEntity * stockInfo = [[StockInfoCoreDataStorage sharedInstance] getStockInfoWithCode:[[infoArr objectAtIndex:indexPath.row] objectForKey:@"stock_code"] exchange:[[infoArr objectAtIndex:indexPath.row] objectForKey:@"stock_exchange"]];
        StockDetailViewController * SDVC = [[StockDetailViewController alloc] init];
        SDVC.stockInfo = stockInfo;
        [self pushToViewController:SDVC];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (infoArr.count == indexPath.row && indexPath.row != 0 )
    {
        return 40;
    }
    return 60;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 52;
}

// 顶部选择排序listener
-(void)upDownBtnOnClick:(UIButton*)sender
{
    if (sender.tag == KTagUpdownBtn+1)
    {
        sort_key = @"03";
        updownIv1.hidden = NO;
        updownIv2.hidden = YES;
        updownIv3.hidden = YES;
        if(isFirst)
        {
            updownIv1.image = [UIImage imageNamed:@"icon_xiangshang"];
            isFirst = NO;
            [self requestPlateCode:self.plate_code WithOrder:@"1" WithKey:sort_key Withrequest_by:@"1"];
        }
        else
        {
            updownIv1.image = [UIImage imageNamed:@"icon_xiangxia"];
            isFirst = YES;
            [self requestPlateCode:self.plate_code WithOrder:@"0" WithKey:sort_key Withrequest_by:@"1"];
        }
        flag = 1;
        isSecond = NO;
        isThird = NO;
    }
    else if(sender.tag == KTagUpdownBtn+2)
    {
        sort_key = @"02";
        updownIv1.hidden = YES;
        updownIv2.hidden = NO;
        updownIv3.hidden = YES;
        if(isSecond)
        {
            updownIv2.image = [UIImage imageNamed:@"icon_xiangshang"];
            isSecond = NO;
            [self requestPlateCode:self.plate_code WithOrder:@"1" WithKey:sort_key Withrequest_by:@"1"];
        }
        else
        {
            updownIv2.image = [UIImage imageNamed:@"icon_xiangxia"];
            isSecond = YES;
            [self requestPlateCode:self.plate_code WithOrder:@"0" WithKey:sort_key Withrequest_by:@"1"];
        }
        flag = 2;
        isFirst = NO;
        isThird = NO;
    }
    else if(sender.tag == KTagUpdownBtn+3)
    {
        sort_key = @"01";
        updownIv1.hidden = YES;
        updownIv2.hidden = YES;
        updownIv3.hidden = NO;
        if(isThird)
        {
            updownIv3.image = [UIImage imageNamed:@"icon_xiangshang"];
            isThird = NO;
            [self requestPlateCode:self.plate_code WithOrder:@"1" WithKey:sort_key Withrequest_by:@"1"];
        }
        else
        {
            updownIv3.image = [UIImage imageNamed:@"icon_xiangxia"];
            isThird = YES;
            [self requestPlateCode:self.plate_code WithOrder:@"0" WithKey:sort_key Withrequest_by:@"1"];
        }
        flag =3;
        isFirst = YES;
        isSecond = NO;
    }
}

// 根据不同type不同排列顺序请求股票数据列表
- (void)requestPlateCode:(NSString *)code WithOrder:(NSString*)order WithKey:(NSString*)key Withrequest_by:(NSString*)request_by
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:code forKey:@"plate_code"];
    [paramDic setObject:order forKey:@"order"];
    [paramDic setObject:key forKey:@"sort_key"];
    [paramDic setObject:request_by forKey:@"request_by"];
    [GFRequestManager connectWithDelegate:self action:Get_plate_stock_list param:paramDic];
}

// 请求成功
- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    isEgoRefresh = NO;
    
    ASIFormDataRequest * formDataRequest = (ASIFormDataRequest *)request;
    if ([formDataRequest.action isEqualToString:Get_plate_stock_list])
    {
        NSString * tradable = [[[[requestInfo objectForKey:@"data"] objectAtIndex:0]objectForKey:@"is_tradable"] description];
        if ([tradable integerValue] == 0)
        {
            [subTimer pauseTimer];
        }
        
        if ([requestInfo objectForKey:@"data"])
        {
            infoArr = [[requestInfo objectForKey:@"data"] copy];
        }
        
        [infoTabelView reloadData];
        [refreshview egoRefreshScrollViewDataSourceDidFinishedLoading:infoTabelView];
    }
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return isEgoRefresh;
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    isEgoRefresh = YES;
    
    [self  requestData];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self requestData];
    
    subTimer = [NSTimer scheduledTimerWithTimeInterval:12 target:self selector:@selector(requestAutoRefresh) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [subTimer invalidate];
    [super viewWillDisappear:YES];
}

// 第一次默认请求配置
- (void)requestData
{
    NSString * first =@"";
    NSString * second = @"";
    NSString * third = @"";
    if (isFirst)
    {
        first = @"0";
    }
    else
    {
        first = @"1";
    }
    if (isSecond)
    {
        second = @"0";
    }
    else
    {
        second = @"1";
    }
    if (isThird)
    {
        third = @"0";
    }
    else
    {
        third = @"1";
    }
    
    if ([sort_key isEqualToString:@"01"])
    {
        [self requestPlateCode:self.plate_code WithOrder:third WithKey:sort_key Withrequest_by:@"1"];
    }
    else if ([sort_key isEqualToString:@"02"])
    {
        [self requestPlateCode:self.plate_code WithOrder:second WithKey:sort_key Withrequest_by:@"1"];
    }
    else if ([sort_key isEqualToString:@"03"])
    {
        [self requestPlateCode:self.plate_code WithOrder:first WithKey:sort_key Withrequest_by:@"1"];
    }
    else
    {
        [self requestPlateCode:self.plate_code WithOrder:@"0" WithKey:@"01" Withrequest_by:@"1"];
    }
}

//6s自动刷新
- (void)requestAutoRefresh
{
    
    NSString * first =@"";
    NSString * second = @"";
    NSString * third = @"";
    if (isFirst)
    {
        first = @"0";
    }
    else
    {
        first = @"1";
    }
    if (isSecond)
    {
        second = @"0";
    }
    else
    {
        second = @"1";
    }
    if (isThird)
    {
        third = @"0";
    }
    else
    {
        third = @"1";
    }
    
    if ([sort_key isEqualToString:@"01"])
    {
        [self requestPlateCode:self.plate_code WithOrder:third WithKey:sort_key Withrequest_by:@"2"];
    }
    else if ([sort_key isEqualToString:@"02"])
    {
        [self requestPlateCode:self.plate_code WithOrder:second WithKey:sort_key Withrequest_by:@"2"];
    }
    else if ([sort_key isEqualToString:@"03"])
    {
        [self requestPlateCode:self.plate_code WithOrder:first WithKey:sort_key Withrequest_by:@"2"];
    }
    else
    {
        [self requestPlateCode:self.plate_code WithOrder:@"0" WithKey:@"01" Withrequest_by:@"2"];
    }
}

@end
