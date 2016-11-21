//
//  MasterViewController.m
//  StockMaster
//
//  Created by Rebloom on 14-8-6.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "MasterViewController.h"

@interface MasterViewController ()

@end

@implementation MasterViewController

- (void)dealloc
{
    for (ASIFormDataRequest * request in [RequestQueue instance].requestList)
    {
        if ([request.action isEqualToString:Get_rank_list_home])
        {
            [request cancel];
            request.delegate = nil;
        }
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [headerView loadComponentsWithTitle:@"股神榜"];
    [headerView backButton];
    [headerView createLine];
    headerView.backgroundColor = kFontColorA;
    [headerView setStatusBarColor: kFontColorA];
    
    self.view.backgroundColor =KSelectNewColor;
    
    firstArr  = [[NSMutableArray alloc] initWithCapacity:10];
    secondArr = [[NSMutableArray alloc] initWithCapacity:10];
    thirdArr = [[NSMutableArray alloc] initWithCapacity:10];
    
    infoTable = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, screenHeight-headerView.frame.size.height)];
    infoTable.backgroundColor =kBackgroundColor;
    infoTable.dataSource = self;
    infoTable.delegate = self;
    infoTable.separatorStyle = NO;
    [self.view addSubview:infoTable];
    
    // Do any additional setup after loading the view.
    [self createFootView];
    [self requestList];
}

// 统一底部控件
-(void)createFootView
{
    UIView * footView = [[UIView alloc] init];
    footView.frame = CGRectMake(0, 0, screenWidth, 156);
    footView.backgroundColor = [UIColor clearColor];
    
    UILabel * ideaLabel = [[UILabel alloc] init];
    ideaLabel.frame = CGRectMake(0,footView.frame.size.height-64, screenWidth, 12);
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

// 请求榜单分类列表
-(void)requestList
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [GFRequestManager connectWithDelegate:self action:Get_rank_list_home param:paramDic];
}

// 请求成功
- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    
    ASIFormDataRequest * formDataRequest = (ASIFormDataRequest *)request;
    if ([formDataRequest.action isEqualToString:Get_rank_list_home])
    {
        if (firstArr.count>0)
        {
            [firstArr removeAllObjects];
        }
        if (secondArr.count>0)
        {
            [secondArr removeAllObjects];
        }
        if (thirdArr.count>0)
        {
            [thirdArr removeAllObjects];
        }
        
        NSString * highest_total_profit_rate = [[[requestInfo objectForKey:@"data"] objectForKey:@"profit_rank"]objectForKey:@"highest_total_profit_rate"];
        NSString * highest_thirty_profit_rate = [[[requestInfo objectForKey:@"data"] objectForKey:@"profit_rank"]objectForKey:@"highest_thirty_profit_rate"];
        NSString * highest_seven_profit_rate = [[[requestInfo objectForKey:@"data"] objectForKey:@"profit_rank"]objectForKey:@"highest_seven_profit_rate"];
        NSString * highest_daily_profit_rate = [[[requestInfo objectForKey:@"data"] objectForKey:@"profit_rank"]objectForKey:@"highest_daily_profit_rate"];
        
        NSMutableArray * profit_rankArr = [[NSMutableArray alloc] initWithObjects:highest_total_profit_rate,highest_thirty_profit_rate,highest_seven_profit_rate ,highest_daily_profit_rate, nil];
        firstArr = [profit_rankArr copy];
        
        NSString * lowest_daily_profit_rate = [[[requestInfo objectForKey:@"data"] objectForKey:@"pathos_rank"] objectForKey:@"lowest_daily_profit_rate"];
        NSMutableArray * lowestArr = [[NSMutableArray alloc] initWithObjects:lowest_daily_profit_rate, nil];
        secondArr = [lowestArr copy];
    }
    [infoTable reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return firstArr.count;
    }
    else if (section == 1)
    {
        return secondArr.count;
    }
    //    else if (section == 2)
    //    {
    //        return thirdArr.count;
    //    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 52;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc] init];
    view.alpha = 0.8;
    view.frame = CGRectMake(0, 0, screenWidth, 52);
    view.backgroundColor = KSelectNewColor;
    
    UILabel * label = [[UILabel alloc] init];
    label.frame = CGRectMake(20, 0, screenWidth-120, 52);
    label.textColor = KFontNewColorA;
    label.textAlignment = NSTextAlignmentLeft;
    label.font = NormalFontWithSize(16);
    [view addSubview: label];
    
    if (section == 0)
    {
        label.text = @"收益榜";
    }
    else if (section == 1)
    {
        label.text = @"悲情榜";
    }
    //    else if ( section == 2)
    //    {
    //        label.text = @"逆袭榜";
    //    }
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 60)];
    cell.backgroundColor = kFontColorA;
    
    NSArray * nameArr1 = @[@"总收益榜",@"30日收益榜",@"7日收益榜",@"1日收益榜"];
    NSArray * imageArr1 = @[@"icon_zong",@"icon_30",@"icon_7",@"icon_22"];
    
    NSArray * nameArr2 = @[@"1日悲情榜"];
    NSArray * imageArr2 = @[@"icon_1"];
    
    //    NSArray * nameArr3 = @[@"逆袭榜"];
    //    NSArray * imageArr3 = @[@"icon_nixi"];
    
    UIImageView * icoImage = [[UIImageView alloc] init ];
    icoImage.frame=CGRectMake(20, 16.5, 27, 27);
    [icoImage setBackgroundColor:[UIColor clearColor]];
    [cell addSubview:icoImage];
    
    UILabel * titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(CGRectGetMaxX(icoImage.frame)+15, 10, 100, 20);
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = NormalFontWithSize(15);
    titleLabel.textColor =kTitleColorA;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [cell addSubview:titleLabel];
    
    UIImageView * rightView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-31, 20, 11, 20)];
    rightView.image = [UIImage imageNamed:@"home_right"];
    rightView.backgroundColor = [UIColor clearColor];
    [cell addSubview:rightView];
    
    UILabel * lineLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 59.5, screenWidth, 0.5)];
    lineLb.backgroundColor = kLineBGColor2;
    [cell addSubview:lineLb];
    
    UILabel * highLb = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(icoImage.frame)+15, 30, 235, 20)];
    highLb.backgroundColor = [UIColor clearColor];
    highLb.font = NormalFontWithSize(13);
    highLb.textColor =@"#979797".color;
    highLb.textAlignment = NSTextAlignmentLeft;
    [cell addSubview:highLb];
    
    if(indexPath.section == 0)
    {
        icoImage.image = [UIImage imageNamed:[imageArr1 objectAtIndex:indexPath.row]];
        
        titleLabel.text = [nameArr1 objectAtIndex:indexPath.row];
        if (firstArr.count>0)
        {
            highLb.text =[NSString stringWithFormat:@"最高收益率: %@" ,[firstArr objectAtIndex:indexPath.row]];
        }
        //        highLb.text =[NSString stringWithFormat:@"最高收益率: %.2f%%" ,32.23];
        
    }
    else if (indexPath.section == 1)
    {
        icoImage.image = [UIImage imageNamed:[imageArr2 objectAtIndex:indexPath.row]];
        
        titleLabel.text = [nameArr2 objectAtIndex:indexPath.row];
        
        if (secondArr.count>0)
        {
            highLb.text =[NSString stringWithFormat:@"最低一日收益率: %@" ,[secondArr objectAtIndex:indexPath.row]];
        }
        //        highLb.text =[NSString stringWithFormat:@"最低一日收益率: %.2f%%" ,32.23];
        
    }
    //    else if (indexPath.section == 2)
    //    {
    //        icoImage.image = [UIImage imageNamed:[imageArr3 objectAtIndex:indexPath.row]];
    //
    //        titleLabel.text = [nameArr3 objectAtIndex:indexPath.row];
    //
    //        if (thirdArr.count>0)
    //        {
    //            highLb.text =[NSString stringWithFormat:@"曾经赔至%@的神门" ,[thirdArr objectAtIndex:indexPath.row]];
    //        }
    //
    //    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    MasterListViewController * MLVC = [[MasterListViewController alloc] init];
    if (indexPath.section == 0)
    {
        MLVC.pageType =indexPath.row ;
    }
    else if (indexPath.section == 1)
    {
        MLVC.pageType = 4;
    }
    //    else if (indexPath.section == 2)
    //    {
    //        MLVC.pageType = 5;
    //    }
    [self pushToViewController:MLVC];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
