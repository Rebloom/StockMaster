//
//  StockMarketViewController.m
//  StockMaster
//
//  Created by dalikeji on 14/11/24.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "StockMarketViewController.h"

#import "NSString+UIColor.h"
#import "UIImage+UIColor.h"
#import "StockDetailViewController.h"

#define  LABLE_FONT  14
#define  NUMBER_FONT 12

#define kUpLabelTag             1000
#define kDownLabelTag           2000
#define KUpdownPriceTag         3000
#define KUpdownRangeTag         4000
#define KTagUpDownImageView     5000
#define KTagUpdownBtn           6000

@interface StockMarketViewController ()

@end

@implementation StockMarketViewController

-(void)dealloc
{
    for (ASIFormDataRequest * request in [RequestQueue instance].requestList)
    {
        if ([request.action isEqualToString:Get_stock_rank_list])
        {
            [request cancel];
            request.delegate = nil;
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor =KSelectNewColor;
    
    [headerView loadComponentsWithTitle:@"股票榜"];
    [headerView backButton];
    [headerView createLine];
    headerView.backgroundColor = kFontColorA;
    [headerView setStatusBarColor: kFontColorA];
    
    
    isFirst = NO;
    isSecond = YES;
    isThird = NO;
    
    sort_key = @"11";
    page = @"1";
    flag = 0;
    
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
    [self CreateCancelBtn];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [stockMarketTimer invalidate];
    [super viewWillDisappear:YES];
}

- (void)CreateCancelBtn
{
    cancelBtn = [[UIButton alloc] init];
    cancelBtn.frame = CGRectMake(screenWidth -80, 20, 80, 44);
    cancelBtn.titleLabel.font = NormalFontWithSize(13);
    cancelBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    [cancelBtn setBackgroundColor:[UIColor clearColor]];
    [cancelBtn setTitle:@"取消排序" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:KFontNewColorA forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelBtnOnClick) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:cancelBtn];
    cancelBtn.hidden = YES;
}

-(void)createFootView
{
    UIView * view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, screenWidth, 50);
    view.backgroundColor = kFontColorA;
    
    refreshLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, screenWidth, 30)];
    refreshLabel.font = NormalFontWithSize(15);
    refreshLabel.backgroundColor = [UIColor clearColor] ;
    refreshLabel.textAlignment = NSTextAlignmentCenter;
    refreshLabel.textColor = KFontNewColorA;
    refreshLabel.text = @"上拉加载更多";
    [view addSubview:refreshLabel];
    
    aiView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(80, 33, 6, 6)];
    aiView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [view addSubview:aiView];
    [view bringSubviewToFront:aiView];
    
    infoTabelView.tableFooterView=view;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return totalArr.count;
}


-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 52)];
    view.alpha = 0.8;
    view.backgroundColor = KSelectNewColor;
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
    
    NSArray * arr = @[@"股票名称",@"当前价",@"涨跌幅",@"评级"];
    for (int i = 0; i<arr.count; i++) {
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
        else if (i ==3)
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
    
    if ( flag ==3 )
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
    else if (flag == 0 ||flag == 2)
    {
        updownIv1.hidden = YES;
        updownIv2.hidden = NO;
        updownIv3.hidden = YES;
    }
    
    return view;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
    upDownLabel.frame = CGRectMake(screenWidth/4*2, 30, screenWidth/4, 15);
    upDownLabel.textAlignment = NSTextAlignmentCenter;
    upDownLabel.text = @"";
    upDownLabel.font = NormalFontWithSize(15);
    [cell addSubview:upDownLabel];
    
    UILabel * perLabel = [[UILabel alloc] init];
    perLabel.frame = CGRectMake(screenWidth/4*2+5, 45, screenWidth/4,15);
    perLabel.textAlignment = NSTextAlignmentCenter;
    perLabel.text = @"";
    perLabel.font = NormalFontWithSize(15);
    [cell addSubview:perLabel];
    
    UIImageView * gradeImageView = [[UIImageView alloc] init];
    gradeImageView.frame = CGRectMake(screenWidth/4*3 + screenWidth/8 -15, 30, 30,30);
    [cell addSubview:gradeImageView];
    
    if (totalArr.count > indexPath.row)
    {
        nameLabel.text = [[totalArr objectAtIndex:indexPath.row] objectForKey:@"stock_name"];
        codeLabel.text = [[totalArr objectAtIndex:indexPath.row] objectForKey:@"stock_code"];
        priceLabel.text = [[totalArr objectAtIndex:indexPath.row] objectForKey:@"current_price"];
        upDownLabel.text = [[totalArr objectAtIndex:indexPath.row] objectForKey:@"updown_price"];
        perLabel.text = [[totalArr objectAtIndex:indexPath.row] objectForKey:@"updown_range"];
        gradeImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",[[totalArr objectAtIndex:indexPath.row] objectForKey:@"stock_grade"]]];
        
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (totalArr.count > indexPath.row)
    {
        NSDictionary *stockDict = [totalArr objectAtIndex:indexPath.row];
        StockInfoEntity * stockInfo = [[StockInfoCoreDataStorage sharedInstance] getStockInfoWithCode:[stockDict objectForKey:@"stock_code"] exchange:[stockDict objectForKey:@"stock_exchange"]];
        StockDetailViewController * SDVC = [[StockDetailViewController alloc] init];
        SDVC.stockInfo = stockInfo;
        [self pushToViewController:SDVC];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (totalArr.count == indexPath.row && indexPath.row != 0 )
    {
        return 40;
    }
    return 60;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 52;
}

- (void)cancelBtnOnClick
{
    isFirst = NO;
    isSecond = YES;
    isThird = NO;
    
    sort_key = @"11";
    page = @"1";
    flag = 0;
    
    cancelBtn.hidden = YES;
    [self requestData];
}

-(void)upDownBtnOnClick:(UIButton*)sender
{
    cancelBtn.hidden = NO;
    page = @"1";
    
    if (sender.tag==KTagUpdownBtn+1)
    {
        sort_key = @"03";
        updownIv1.hidden = NO;
        updownIv2.hidden = YES;
        updownIv3.hidden = YES;
        if(isFirst)
        {
            updownIv1.image = [UIImage imageNamed:@"icon_xiangshang"];
            isFirst = NO;
            [self requestPlateCode:page WithOrder:@"1" WithKey:sort_key Withrequest_by:@"1"];
        }
        else
        {
            updownIv1.image = [UIImage imageNamed:@"icon_xiangxia"];
            isFirst = YES;
            [self requestPlateCode:page WithOrder:@"0" WithKey:sort_key Withrequest_by:@"1"];
        }
        flag = 1;
        isSecond = NO;
        isThird = NO;
    }
    else   if (sender.tag==KTagUpdownBtn+2)
    {
        sort_key = @"01";
        updownIv1.hidden = YES;
        updownIv2.hidden = NO;
        updownIv3.hidden = YES;
        if(isSecond)
        {
            updownIv2.image = [UIImage imageNamed:@"icon_xiangshang"];
            isSecond = NO;
            [self requestPlateCode:page WithOrder:@"1" WithKey:sort_key Withrequest_by:@"1"];
        }
        else
        {
            updownIv2.image = [UIImage imageNamed:@"icon_xiangxia"];
            isSecond = YES;
            [self requestPlateCode:page WithOrder:@"0" WithKey:sort_key Withrequest_by:@"1"];
        }
        flag = 2;
        isFirst = NO;
        isThird = NO;
    }
    else if (sender.tag==KTagUpdownBtn+3)
    {
        sort_key = @"04";
        updownIv1.hidden = YES;
        updownIv2.hidden = YES;
        updownIv3.hidden = NO;
        if(isThird)
        {
            updownIv3.image = [UIImage imageNamed:@"icon_xiangshang"];
            isThird = NO;
            [self requestPlateCode:page WithOrder:@"1" WithKey:sort_key Withrequest_by:@"1"];
        }
        else
        {
            updownIv3.image = [UIImage imageNamed:@"icon_xiangxia"];
            isThird = YES;
            [self requestPlateCode:page WithOrder:@"0" WithKey:sort_key Withrequest_by: @"1"];
        }
        flag = 3;
        isSecond = NO;
        isFirst =NO;
    }
    
    refreshFlag = 0;
}

-(void) requestPlateCode:(NSString *)pages WithOrder:(NSString*)order WithKey:(NSString*)key Withrequest_by:(NSString*)request_by
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:pages forKey:@"page"];
    [paramDic setObject:order forKey:@"order"];
    [paramDic setObject:key forKey:@"sort_key"];
    [paramDic setObject:request_by forKey:@"request_by"];
    [GFRequestManager connectWithDelegate:self action:Get_stock_rank_list param:paramDic];
}

-(void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    isEgoRefresh = NO;
    
    refreshLabel.text = @"上拉刷新";
    [aiView stopAnimating];
    isRefresh = NO;
    
    ASIFormDataRequest * formDataRequest = (ASIFormDataRequest *)request;
    
    if ([formDataRequest.action isEqualToString:Get_stock_rank_list])
    {
        if ([requestInfo objectForKey:@"data"])
        {
            NSString * tradable = [[[[requestInfo objectForKey:@"data"] objectAtIndex:0]objectForKey:@"is_tradable"] description];
            if ([tradable integerValue] == 0)
            {
                [stockMarketTimer pauseTimer];
            }
            
            infoArr = [[requestInfo objectForKey:@"data"] mutableCopy];
            // 如果有新股，股票数据中没有，这里临时保存下
            [[StockInfoCoreDataStorage sharedInstance] saveStockInfo:infoArr];
            if (refreshFlag == 0)
            {
                if (totalArr.count > 0)
                {
                    [totalArr removeAllObjects];
                }
                if (![[[infoArr lastObject] objectForKey:@"stock_code"] isEqualToString:[[totalArr lastObject] objectForKey:@"stock_code"]])
                {
                    totalArr = [infoArr mutableCopy];
                }
                [infoTabelView scrollRectToVisible:CGRectMake(0, 0, screenWidth, infoTabelView.frame.size.height) animated:NO];
            }
            else if(refreshFlag == 1)
            {
                if (infoArr.count > 0  )
                {
                    for (int i = 0; i<infoArr.count; i++)
                    {
                        if (![[[infoArr lastObject] objectForKey:@"stock_code"] isEqualToString:[[totalArr lastObject] objectForKey:@"stock_code"]])
                        {
                            [totalArr addObject:[infoArr objectAtIndex:i]];
                        }
                    }
                }
            }
        }
        [infoTabelView reloadData];
        [refreshview egoRefreshScrollViewDataSourceDidFinishedLoading:infoTabelView];
    }
}

-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return isEgoRefresh;
}

-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    isEgoRefresh = YES;
    page = @"1";
    refreshFlag = 0;
    [self cancelBtnOnClick];
//    [self requestData];
}

-(NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [NSDate date];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [refreshview egoRefreshScrollViewDidEndDragging:scrollView];
    
    if(scrollView.contentOffset.y + (screenHeight-64-49)>scrollView.contentSize.height+40.0)
    {
        [aiView startAnimating];
        refreshLabel.text=@"正在刷新";
        isRefresh=YES;
        page = [[NSString stringWithFormat:@"%ld",((long)[page integerValue] +1)] copy];
        [self requestData];
    }
   
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [refreshview egoRefreshScrollViewDidScroll:scrollView];
    if(isRefresh==NO)
    {
        if(scrollView.contentOffset.y+(screenHeight-64-49)>scrollView.contentSize.height+40.0)
        {
            refreshLabel.text=@"松开即刷新";
        }
        else
        {
            refreshLabel.text=@"上拉加载更多";
        }
    }
    if (scrollView.contentOffset.y > 0)
    {
        //上啦刷新
        refreshFlag = 1;
    }
    else if(scrollView.contentOffset.y < 0)
    {
        //下拉刷新
        refreshFlag = 0;
        if (scrollView.contentOffset.y <= -50)
        {
            sort_key = @"11";
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self requestData];
    
    stockMarketTimer = [NSTimer scheduledTimerWithTimeInterval:12 target:self selector:@selector(requestAutoRefresh)userInfo:nil repeats:YES];
}

-(void)requestData
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
        [self requestPlateCode:page WithOrder:second WithKey:sort_key Withrequest_by:@"1"];
    }
    else if ([sort_key isEqualToString:@"03"])
    {
        [self requestPlateCode:page WithOrder:first WithKey:sort_key Withrequest_by:@"1"];
    }
    else if ([sort_key isEqualToString:@"04"])
    {
        [self requestPlateCode:page WithOrder:third WithKey:sort_key Withrequest_by:@"1"];
    }
    else
    {
        [self requestPlateCode:page WithOrder:@"0" WithKey:@"01" Withrequest_by:@"1"];
    }
}

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
        [self requestPlateCode:page WithOrder:second WithKey:sort_key Withrequest_by:@"2"];
    }
    else if ([sort_key isEqualToString:@"03"])
    {
        [self requestPlateCode:page WithOrder:first WithKey:sort_key Withrequest_by:@"2"];
    }
    else if ([sort_key isEqualToString:@"04"])
    {
        [self requestPlateCode:page WithOrder:third WithKey:sort_key Withrequest_by:@"2"];
    }
    else
    {
        [self requestPlateCode:page WithOrder:@"0" WithKey:@"01" Withrequest_by:@"2"];
    }
}

@end
