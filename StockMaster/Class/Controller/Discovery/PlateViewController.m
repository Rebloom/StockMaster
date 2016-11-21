//
//  PlateViewController.m
//  StockMaster
//
//  Created by dalikeji on 14/11/25.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "PlateViewController.h"
#import "SubSectionViewController.h"

#define KTagImageView  1123

@interface PlateViewController ()

@end

@implementation PlateViewController

- (void)dealloc
{
    for (ASIFormDataRequest * request in [RequestQueue instance].requestList)
    {
        if ([request.action isEqualToString:Get_plate_list])
        {
            [request cancel];
            request.delegate = nil;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self requestData];
    
    plateTimer = [NSTimer scheduledTimerWithTimeInterval:12 target:self selector:@selector(requestAutoRefresh)userInfo:nil repeats:YES];
    
    isUpDown = YES;                         // yes  箭头向下    no  箭头向上
    imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(screenWidth/2+40, 40, 8, 4);
    imageView.image = [UIImage imageNamed:@"icon_xiasanjiao"];
    [headerView addSubview:imageView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [plateTimer invalidate];
    [super viewWillDisappear:YES];
}

// 请求数据
- (void)requestData
{
    [self requestPlate:deliverType withOrder:@"0" Withrequest_by:@"1"];
}

//6s自动刷新
- (void)requestAutoRefresh
{
    [self requestPlate:deliverType withOrder:@"0" Withrequest_by:@"2"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor =KSelectNewColor;
    
    [headerView backButton];
    [headerView createLine];
    headerView.backgroundColor = kFontColorA;
    [headerView setStatusBarColor: kFontColorA];
    [headerView loadComponentsWithTitle:@"全部板块"];
    
    [self createHeaderView];
    
    infoArr = [[NSMutableArray alloc] initWithCapacity:10];
    mArr = [[NSMutableArray alloc] initWithCapacity:10];
    // 默认全部板块
    deliverType = @"00";
    index = 0;
    
    infoTabelView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, screenHeight - 65) style:UITableViewStylePlain];
    infoTabelView.delegate = self;
    infoTabelView.dataSource = self;
    infoTabelView.backgroundColor = KSelectNewColor;
    infoTabelView.separatorStyle = UITableViewCellAccessoryNone;
    [self.view addSubview:infoTabelView];
    [self createFootView];
    
    //下拉刷新
    if (!refreshview)
    {
        refreshview = [[EGORefreshTableHeaderView alloc] initWithFrame: CGRectMake(0, -65, screenWidth, 65)];
        refreshview.delegate=self;
        [infoTabelView addSubview:refreshview];
    }
}

// 顶部加上listener
- (void)createHeaderView
{
    UIButton * selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(65, 20, screenWidth-100, 44)];
    selectBtn.tag = 3500;
    [selectBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [selectBtn setBackgroundColor:[UIColor clearColor]];
    [selectBtn addTarget:self action:@selector(selectBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:selectBtn];
}

// 点击了就下拉或者隐藏
- (void)selectBtnOnClick:(UIButton *)sender
{
    NSArray * arr = @[@"全部板块",@"行业板块",@"概念板块",@"地域板块"];
    // 因为动画是initshow的所以显示消失由控件置空判断
    if(dropDown == nil)
    {
        CGFloat f = 106;
        dropDown = [[NIDropDown alloc] initWithShowDropDownBtn:sender andHeight:&f andArray:arr];
        dropDown.alpha = 0.8;
        dropDown.delegate = self;
        dropDown.backgroundColor = KColorHeader;
        [self.view insertSubview:dropDown aboveSubview:infoTabelView];
    }
    else
    {
        [dropDown hideDropDown:sender];
        [self rel];
    }
    
    if (isUpDown)
    {
        isUpDown = NO;
        imageView.image = [UIImage imageNamed:@"icon_shangsanjiao"];
    }
    else
    {
        isUpDown = YES;
        imageView.image = [UIImage imageNamed:@"icon_xiasanjiao"];
    }
}

// 控件的代理方法
- (void)niDropDownDelegateMethod:(NSString * )type
{
    [self rel];
    UIButton * selectBtn = (UIButton*)[headerView viewWithTag:3500];
    [selectBtn setBackgroundColor:kFontColorA];
    type = [NSString stringWithFormat:@"0%d", [type intValue]];
    deliverType = [type copy];
    [self requestPlate:deliverType withOrder:@"0" Withrequest_by:@"1"];
    imageView.image = [UIImage imageNamed:@"icon_xiasanjiao"];
    isUpDown = YES;
}

// 置空控件
- (void)rel
{
    dropDown = nil;
}

// 初始化底部
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

// 根据选择请求不同数据
- (void)requestPlate:(NSString*)type withOrder:(NSString*)order Withrequest_by:(NSString*)request_by
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    if (!type)
    {
        type = @"04";
    }
    [paramDic setObject:type forKey:@"plate_type"];
    [paramDic setObject:order forKey:@"order"];
    [paramDic setObject:request_by forKey:@"request_by"];
    [GFRequestManager connectWithDelegate:self action:Get_plate_list param:paramDic];
}

// 请求成功回调
- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    isEgoRefresh = NO;
    
    ASIFormDataRequest * formDataRequest = (ASIFormDataRequest *)request;
    if ([formDataRequest.action isEqualToString:Get_plate_list])
    {
        NSArray *plateArray = [requestInfo objectForKey:@"data"];
        [[StockInfoCoreDataStorage sharedInstance] savePlateInfo:plateArray];
        
        if ([requestInfo objectForKey:@"data"])
        {
            infoArr = [[requestInfo objectForKey:@"data"] copy];
        }
        if (mArr.count>0)
        {
            [mArr removeAllObjects];
        }
        
        NSString * tradable = [[[[requestInfo objectForKey:@"data"] objectAtIndex:0]objectForKey:@"is_tradable"] description];
        if ([tradable integerValue] == 0)
        {
            [plateTimer pauseTimer];
        }
        
        NSMutableArray * arr = [[NSMutableArray alloc] initWithCapacity:10];
        for(int i = 0; i < infoArr.count; i += 3)
        {
            if (arr.count>0)
            {
                [arr removeAllObjects];
            }
            if (i<infoArr.count)
            {
                [arr addObject:[infoArr objectAtIndex:i]];
            }
            if ((i+1)<infoArr.count)
            {
                [arr addObject:[infoArr objectAtIndex:i+1]];
            }
            if ((i+2)<infoArr.count)
            {
                [arr addObject:[infoArr objectAtIndex:i+2]];
            }
            [mArr addObject:[arr mutableCopy]];
        }
        
        [infoTabelView reloadData];
        [refreshview egoRefreshScrollViewDataSourceDidFinishedLoading:infoTabelView];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return mArr.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 100)];
    [cell setBackgroundColor:kFontColorA];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (mArr.count>indexPath.row)
    {
        if (mArr.count>indexPath.row)
        {
            for(int i = 0;i<3;i++)
            {
                UILabel * nameLabel = [[UILabel alloc]init];
                nameLabel.frame = CGRectMake(screenWidth/3*i, 30, screenWidth/3, 20);
                nameLabel.backgroundColor = [UIColor clearColor];
                nameLabel.textColor = KFontNewColorA;
                nameLabel.textAlignment = NSTextAlignmentCenter;
                nameLabel.font = NormalFontWithSize(13);
                [cell addSubview:nameLabel];
                
                UILabel * profitLabel = [[UILabel alloc] init];
                profitLabel.backgroundColor = [UIColor clearColor];
                profitLabel.frame = CGRectMake(screenWidth/3*i, 50, screenWidth/3, 20);
                profitLabel.textColor = kRedColor;
                profitLabel.textAlignment = NSTextAlignmentCenter;
                profitLabel.font = NormalFontWithSize(15);
                [cell addSubview:profitLabel];
                
                UIButton * plateBtn = [[UIButton alloc] init];
                [plateBtn setBackgroundColor: [UIColor clearColor]];
                plateBtn.frame = CGRectMake(screenWidth/3*i, 0, screenWidth/3, 100);
                plateBtn.tag = indexPath.row * 3 +i;
                [plateBtn addTarget:self action:@selector(plateBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:plateBtn];
                
                if (i < [[mArr objectAtIndex:indexPath.row] count])
                {
                    NSString * profit = [[[mArr objectAtIndex:indexPath.row] objectAtIndex:i]objectForKey:@"updown_range"];
                    nameLabel.text = [[[mArr objectAtIndex:indexPath.row] objectAtIndex:i]objectForKey:@"plate_name"];
                    profitLabel.text = [profit copy];
                    if ([profit floatValue]>=0)
                    {
                        profitLabel.textColor = kRedColor;
                    }
                    else
                    {
                        profitLabel.textColor = kGreenColor;
                    }
                }
                else
                {
                    nameLabel.text = @"";
                    profitLabel.text = @"";
                }
                
            }
            for (int i=1; i<3; i++)
            {
                UILabel * lineLabel1 = [[UILabel alloc] init];
                lineLabel1.backgroundColor = KColorHeader;
                lineLabel1.frame = CGRectMake(screenWidth/3*i, 30, 1, 40);
                [cell addSubview:lineLabel1];
            }
            UILabel * lineLabel2 = [[UILabel alloc] init];
            lineLabel2.backgroundColor = KLineNewBGColor1;
            lineLabel2.frame = CGRectMake(0, 99, screenWidth, 0.5);
            [cell addSubview:lineLabel2];
            
            UILabel * lineLabel3 = [[UILabel alloc] init];
            lineLabel3.backgroundColor = KLineNewBGColor2;
            lineLabel3.frame = CGRectMake(0, 99.5, screenWidth, 0.5);
            [cell addSubview:lineLabel3];
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (void)plateBtnOnClick:(UIButton*)sender
{
    SubSectionViewController * SSVC = [[SubSectionViewController alloc] init];
    if (sender.tag <infoArr.count)
    {
        SSVC.plate_code = [[[infoArr objectAtIndex:sender.tag ]objectForKey:@"plate_code"] copy];
        SSVC.plate_name = [[[infoArr objectAtIndex:sender.tag] objectForKey:@"plate_name"] copy];
        [self pushToViewController:SSVC];
    }
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return isEgoRefresh;
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    isEgoRefresh = YES;
    
    [self requestData];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
