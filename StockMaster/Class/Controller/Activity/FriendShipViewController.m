//
//  FriendShipViewController.m
//  StockMaster
//
//  Created by dalikeji on 15/2/27.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import "FriendShipViewController.h"
#import "MasterDetailViewController.h"

@interface FriendShipViewController ()

@end

@implementation FriendShipViewController

- (void)dealloc
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor =KSelectNewColor;
    
    [headerView loadComponentsWithTitle:@"好友"];
    [headerView backButton];
    [headerView createLine];
    headerView.backgroundColor = kFontColorA;
    [headerView setStatusBarColor:kFontColorA];
    
    currentPage = @"1";
    userArr = [[NSMutableArray alloc] initWithCapacity:10];
    
    [self createTableView];
    [self requestFriendData:currentPage];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [infoTable reloadData];
}

- (void)createTableView
{
    if (!infoTable)
    {
        infoTable = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, screenHeight - 65)];
    }
    infoTable.backgroundColor = kBackgroundColor;
    infoTable.dataSource = self;
    infoTable.delegate = self;
    infoTable.separatorStyle = NO;
    [self.view addSubview:infoTable];
    
    [self createFootView];
}

// 添加tableview底部数据
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
        refreshLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, screenWidth, 30)];
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
}

- (void)requestFriendData:(NSString*)page
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:page forKey:@"page"];
    [GFRequestManager connectWithDelegate:self action:Get_invitation_friends_money param:paramDic];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    
    refreshLabel.text=@"上拉刷新";
    [aiView stopAnimating];
    isRefresh=NO;
    
    ASIFormDataRequest * formDataRequest = (ASIFormDataRequest *)request;
    if ([formDataRequest.action isEqualToString:Get_invitation_friends_money])
    {
        NSMutableArray * tempArr = [[requestInfo objectForKey:@"data"] objectForKey:@"list"];
        if (tempArr.count > 0  )
        {
            for (int i = 0; i<tempArr.count; i++)
            {
                [userArr addObject:[tempArr objectAtIndex:i]];
            }
            if (tempArr.count >= 10)
            {
                infoTable.tableFooterView = refreshView;
            }
            else
            {
                infoTable.tableFooterView = feetView;
            }
        }
        else
        {
            infoTable.tableFooterView = feetView;
        }
    }
    
    [infoTable reloadData];
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    [super requestFailed:request];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return userArr.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellStock = @"friendShipCell";
    
    FriendShipCell * cell = [tableView dequeueReusableCellWithIdentifier:cellStock];
    
    cell.backgroundColor = kFontColorA;
    
    if (cell == nil)
    {
        cell = [[FriendShipCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellStock];
    }
    
    NSDictionary * tempDic = [userArr objectAtIndex:indexPath.row];
    
    cell.nameLabel.text = [tempDic objectForKey:@"nickname"];
    cell.moneyLabel.text =[NSString stringWithFormat:@"ta帮你赚了%@本金",[[tempDic objectForKey:@"money"] description]];
    [cell.photoImg sd_setImageWithURL:[NSURL URLWithString:[[tempDic objectForKey:@"head"] description]]
                  placeholderImage:[UIImage imageNamed:@"icon_user_default"]
                              options:SDWebImageRefreshCached];
    cell.rankLabel.text =[NSString stringWithFormat:@"%d", (int)indexPath.row+1];
    if (indexPath.row == 0)
    {
        cell.rankImageView.image = [UIImage imageNamed:@"icon_one"];
    }
    else if (indexPath.row == 1)
    {
        cell.rankImageView.image = [UIImage imageNamed:@"icon_two"];
    }
    else if (indexPath.row == 2)
    {
        cell.rankImageView.image = [UIImage imageNamed:@"icon_three"];
    }
    else
    {
        cell.rankImageView.image = [UIImage imageNamed:@"icon_four"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dict = [userArr objectAtIndex:indexPath.row];
    
    MasterDetailViewController * MDVC = [[MasterDetailViewController alloc] init];
    MDVC.passDic = [userArr objectAtIndex:indexPath.row];
    MDVC.showUid = [[dict objectForKey:@"uid"] copy];
    [self pushToViewController:MDVC];
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
        [self requestFriendData:currentPage];
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
