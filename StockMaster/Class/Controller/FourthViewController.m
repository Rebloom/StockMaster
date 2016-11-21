//
//  FourthViewController.m
//  StockMaster
//
//  Created by Rebloom on 14-7-22.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "FourthViewController.h"
#import "AwardViewController.h"
#import "InviteViewController.h"
#import "AddCardViewController.h"
#import "GuessStockViewController.h"
#import "AnswerViewController.h"
#import "MineCenterViewController.h"
#import "SearchViewController.h"
#import "UserInfoCoreDataStorage.h"
#import "ShakeViewController.h"
#import "DownloadViewController.h"

@interface FourthViewController ()

@end

@implementation FourthViewController

- (void)dealloc
{
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
    self.view.backgroundColor = KSelectNewColor;
    
    headerView.alpha = 0;
    [headerView loadComponentsWithTitle:@"赚钱"];
    [headerView createLine];
    
    // 读取任务
    infoArr = [[UserInfoCoreDataStorage sharedInstance] getTaskInfo];
    
    infoTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    infoTable.delegate = self;
    infoTable.dataSource = self;
    infoTable.scrollsToTop = YES;
    infoTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    infoTable.backgroundColor = kBackgroundColor;
    [self.view addSubview:infoTable];
    
    
    tableHeader = [[EGORefreshTableHeaderView alloc] initWithFrame: CGRectMake(0, -65, screenWidth, 65)];
    tableHeader.delegate = self;
    [infoTable addSubview:tableHeader];
    
    [self createBannerCycleView];
    [self createPageControl];
    [self createFootView];
}

- (void)createPageControl
{
    if (!bannerPageControl) {
        bannerPageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, HeaderViewHeight-30, screenWidth, 30)];
        bannerPageControl.backgroundColor = [UIColor clearColor];
        bannerPageControl.currentPageIndicatorTintColor = kRedColor;
        bannerPageControl.pageIndicatorTintColor = KSelectNewColor;
    }
    bannerPageControl.numberOfPages = [bannerArr count];
    if ([bannerArr count] < 2)
    {
        bannerPageControl.hidden = YES;
    }
    else
    {
        bannerPageControl.hidden = NO;
    }
    bannerPageControl.enabled = NO;
    [bannerCycleView addSubview:bannerPageControl];
    
    UIPageControl *pageControl = bannerPageControl;
    bannerCycleView.TapScrollBlock = ^(NSInteger pageIndex)
    {
        pageControl.currentPage = pageIndex;
    };
}

- (void)createBannerCycleView
{
    if (bannerArr.count == 0) {
        UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, beginX+50, screenWidth, HeaderViewHeight)];
        imageView.image = [UIImage imageNamed:@"appstore_zhuanqian"];
        infoTable.tableHeaderView = imageView;
    }
    else {
        if (!bannerCycleView)
        {
            bannerCycleView = [[CycleScrollView alloc] initWithFrame:CGRectMake(0, beginX+50, screenWidth, HeaderViewHeight) animationDuration:5];
        }
        [self.view bringSubviewToFront:bannerCycleView];
        
        // 设置banner轮播图数据源
        __block NSArray *tempArr = bannerArr;
        bannerCycleView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex)
        {
            NSString * imageUrl= [[tempArr objectAtIndex:pageIndex] objectForKey:@"image_url"];
            UIImageView * bannerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, beginX+50, screenWidth, HeaderViewHeight)];
            bannerView.tag = pageIndex;
            [bannerView sd_setImageWithURL:[NSURL URLWithString:imageUrl]
                          placeholderImage:[UIImage imageNamed:@"appstore_zhuanqian"]
                                   options:SDWebImageRefreshCached];
            
            return bannerView;
        };
        
        // 设置banner轮播图个数（注意一定要先设置数据源再设置个数）
        bannerCycleView.totalPagesCount = ^NSInteger(void)
        {
            return [tempArr count];
        };
        
        // 设置banner轮播图点击事件
        __block FourthViewController *blockSelf = self;
        bannerCycleView.TapActionBlock = ^(NSInteger pageIndex)
        {
            [blockSelf bannerViewOnClick:pageIndex];
        };
        
        infoTable.tableHeaderView = bannerCycleView;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self performSelector:@selector(getMakeMoneyInfo) withObject:nil afterDelay:1];
    
    // 诸葛统计（查看赚钱页）
    [[Zhuge sharedInstance] track:@"查看赚钱页" properties:nil];
}

//创建底部视图
- (void)createFootView
{
    UIView * footView = [[UIView alloc] init];
    footView.frame = CGRectMake(0, 0, screenWidth, 156);
    footView.backgroundColor = [UIColor clearColor];
    
    UILabel * ideaLabel = [[UILabel alloc] init];
    ideaLabel.frame = CGRectMake(0,footView.frame.size.height-90, screenWidth, 12);
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

- (void)bannerViewTapAction:(UITapGestureRecognizer *)tap
{
    UIImageView *bannerView = (UIImageView *)tap.view;
    [self bannerViewOnClick:bannerView.tag];
}

- (void)bannerViewOnClick:(NSInteger)index
{
    NSDictionary * dict = [bannerArr objectAtIndex:index];
    if (![[dict objectForKey:@"href"] isEqualToString:@""]&&[dict objectForKey:@"href"])
    {
        if (![[UserInfoCoreDataStorage sharedInstance] isCurrentUserLogin]) {
            // 判断用户是否登录
            LoginViewController * SLVC = [[LoginViewController alloc] init];
            SLVC.flag = 1;
            SLVC.selectType = 4;
            [self pushToViewController:SLVC];
        }
        else {
            UserInfoEntity *userInfo = [[UserInfoCoreDataStorage sharedInstance] getCurrentUserInfo];
            GFWebViewController * GWVC = [[GFWebViewController alloc] init];
            GWVC.title = [dict objectForKey:@"href_title"];
            GWVC.pageType = WebViewTypePresent;
            NSString * h5Url = [NSString stringWithFormat:@"%@?uid=%@&token=%@&client_type=iOS", [dict objectForKey:@"href"], userInfo.uid, userInfo.token];
            NSString * h5Task = [NSString stringWithFormat:@"%@?uid=%@&token=%@&client_type=iOS", [dict objectForKey:@"href_task"], userInfo.uid, userInfo.token];
            GWVC.requestUrl = [NSURL URLWithString:h5Url];
            GWVC.task_url = [NSURL URLWithString:h5Task];
            GWVC.flag = 0;
            [self presentViewController:GWVC animated:YES completion:nil];
        }
    }
}

//获取赚钱首页信息
- (void)getMakeMoneyInfo
{
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [GFRequestManager connectWithDelegate:self action:Get_make_money param:param];
}

- (void)deliverArray:(NSDictionary*)dic
{
    bannerArr = [dic objectForKey:@"image_list"];
    
    if (bannerArr.count == 0) {
        return;
    }
    else if (bannerArr.count == 1)
    {
        NSString * imageUrl= [[bannerArr objectAtIndex:0] objectForKey:@"image_url"];
        UIImageView * bannerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, beginX+50, screenWidth, HeaderViewHeight)];
        bannerView.tag = 0;
        [bannerView sd_setImageWithURL:[NSURL URLWithString:imageUrl]
                      placeholderImage:[UIImage imageNamed:@"appstore_zhuanqian"]
                               options:SDWebImageRefreshCached];
        
        bannerView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bannerViewTapAction:)];
        [bannerView addGestureRecognizer:tapGesture];

        infoTable.tableHeaderView = bannerView;
    }
    else if (bannerArr.count > 1)
    {
        [self clearSubView];
        [self createBannerCycleView];
        [self createPageControl];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    isEgoRefresh = NO;
    [tableHeader egoRefreshScrollViewDataSourceDidFinishedLoading:infoTable];
    
    ASIFormDataRequest * formdataRequest = (ASIFormDataRequest *)request;
    if ([formdataRequest.action isEqualToString:Get_make_money])
    {
        NSArray * tempArr = [[requestInfo objectForKey:@"data"] objectForKey:@"task_list"];
        [[UserInfoCoreDataStorage sharedInstance] saveTaskInfo:tempArr];
        infoArr = [[UserInfoCoreDataStorage sharedInstance] getTaskInfo];
        
        [self deliverArray:[[requestInfo objectForKey:@"data"] copy]];
    }
    else if ([formdataRequest.action isEqualToString:Submit_user_award])
    {
        NSDictionary * dic = [requestInfo objectForKey:@"data"];
        [[CHNAlertView defaultAlertView] initWithAwardText:CHECKDATA(@"award_money") desc1:CHECKDATA(@"prompt1") desc2:CHECKDATA(@"prompt2") buttonDesc:@"知道了，退下~" delegate:self];
        [self getMakeMoneyInfo];
    }
    [infoTable reloadData];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [super requestFailed:request];
    isEgoRefresh = NO;
    [tableHeader egoRefreshScrollViewDataSourceDidFinishedLoading:infoTable];
}

- (void)clearSubView
{
    if (bannerCycleView)
    {
        for (UIView * view in bannerCycleView.subviews)
        {
            if ([view isKindOfClass:[UIPageControl class]])
            {
                [view removeFromSuperview];
            }
        }
    }
    if (bannerCycleView.scrollView)
    {
        for (UIView * view in bannerCycleView.scrollView.subviews)
        {
            [view removeFromSuperview];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return infoArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 80)];
    
    if (indexPath.row < infoArr.count)
    {
        TaskInfoEntity * taskInfo = [infoArr objectAtIndex:indexPath.row];
        
        NSInteger btn_status = taskInfo.status;
    
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 60, 60)];
        [imageView sd_setImageWithURL:[NSURL URLWithString:taskInfo.taskIcon]
                     placeholderImage:[UIImage imageNamed:@"task_default"]
                              options:SDWebImageRefreshCached];
        
        [cell addSubview:imageView];
        
        UIView * imageBack = [[UIView alloc] initWithFrame:imageView.frame];
        imageBack.layer.cornerRadius = 35;
        imageBack.layer.masksToBounds = YES;
        [cell addSubview:imageBack];
        
        UILabel * task = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame)+9, 20, screenWidth-110-84, 15)];
        task.backgroundColor = [UIColor clearColor];
        task.textColor = KFontNewColorA;
        task.font = NormalFontWithSize(15);
        task.text = taskInfo.name;
        [cell addSubview:task];
        
        UILabel * taskDesc = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame)+9, CGRectGetMaxY(task.frame)+11, screenWidth-110-84, 30)];
        taskDesc.numberOfLines = 2;
        taskDesc.backgroundColor = [UIColor clearColor];
        taskDesc.textColor = KFontNewColorB;
        taskDesc.font = NormalFontWithSize(13);
        taskDesc.text = taskInfo.describe;
        [taskDesc sizeToFit];
        [cell addSubview:taskDesc];
    
        UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, 89.5, screenWidth, .5)];
        line.backgroundColor = KColorHeader;
        [cell addSubview:line];
        
        UIButton * actionBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth-77, 28, 62, 34)];
        actionBtn.layer.cornerRadius = 4;
        actionBtn.layer.masksToBounds = YES;
        [actionBtn setTitle:taskInfo.buttonText forState:UIControlStateNormal];
        [actionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [actionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        actionBtn.titleLabel.font = NormalFontWithSize(13);
        actionBtn.tag = indexPath.row;
        [actionBtn addTarget:self action:@selector(actionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [actionBtn setBackgroundImage:[kRedColor image] forState:UIControlStateNormal];
        [actionBtn setBackgroundImage:[@"#e2e2e2".color image] forState:UIControlStateDisabled];
        [cell addSubview:actionBtn];
        
        if (btn_status == UNDONE||btn_status == UNFINISH)
        {
            actionBtn.hidden = YES;
            UIImageView * rightView = [[UIImageView alloc] init];
            rightView.image = [UIImage imageNamed:@"icon_discovery_right"];
            rightView.frame = CGRectMake(screenWidth-26, 37, 9, 16);
            [cell addSubview:rightView];
        }
        else if (btn_status == UNREWARD)
        {
            actionBtn.hidden = NO;
            actionBtn.enabled = YES;
        }
        else if (btn_status == REWARD)
        {
            actionBtn.hidden = NO;
            actionBtn.enabled = NO;
        }
    }
    
    return cell;
}

- (void)actionBtnClicked:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    
    [self tableView:infoTable didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:btn.tag inSection:0]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![[UserInfoCoreDataStorage sharedInstance] isCurrentUserLogin])
    {
        LoginViewController * SLVC = [[LoginViewController alloc] init];
        SLVC.flag = 1;
        SLVC.selectType = 4;
        [self pushToViewController:SLVC];
    }
    else
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        TaskInfoEntity * taskInfo = [infoArr objectAtIndex:indexPath.row];
        NSInteger taskStatus = taskInfo.status;
        NSInteger taskID = [taskInfo.taskID integerValue];
        
        switch (taskID) {
            case 1: // 去买股票
            {
                if (taskStatus == UNDONE) {
                    SearchViewController * SVC = [[SearchViewController alloc] init];
                    [self pushToViewController:SVC];
                }
                else if (taskStatus == UNREWARD) {
                    NSMutableDictionary * param = [NSMutableDictionary dictionary];
                    [param setObject:taskInfo.taskID forKey:@"task_id"];
                    [param setObject:taskInfo.logID  forKey:@"log_id"];
                    [GFRequestManager connectWithDelegate:self action:Submit_user_award param:param];
                }
            }
                break;
            case 2: // 去添加银行卡
            {
                if (taskStatus == UNDONE) {
                    AddCardViewController * ACVC = [[AddCardViewController alloc] init];
                    ACVC.isFirst = YES;
                    ACVC.modelType = 1;
                    [GFStaticData saveObject:@"1" forKey:KTagCardBack];
                    [self pushToViewController:ACVC];
                }
                else if (taskStatus == UNREWARD) {
                    NSMutableDictionary * param = [NSMutableDictionary dictionary];
                    [param setObject:taskInfo.taskID forKey:@"task_id"];
                    [param setObject:taskInfo.logID  forKey:@"log_id"];
                    [GFRequestManager connectWithDelegate:self action:Submit_user_award param:param];
                }
            }
                break;
            case 3: // 去个人中心
            {
                if (taskStatus == UNDONE) {
                    MineCenterViewController * MCVC = [[MineCenterViewController alloc] init];
                    MCVC.type = 1;
                    [self pushToViewController:MCVC];
                }
                else if (taskStatus == UNREWARD) {
                    NSMutableDictionary * param = [NSMutableDictionary dictionary];
                    [param setObject:taskInfo.taskID forKey:@"task_id"];
                    [param setObject:taskInfo.logID  forKey:@"log_id"];
                    [GFRequestManager connectWithDelegate:self action:Submit_user_award param:param];
                }
            }
                break;
            case 4: // 去摇一摇
            {
                if (taskStatus == UNDONE) {
                    ShakeViewController * SVC = [[ShakeViewController alloc] init];
                    [self pushToViewController:SVC];
                }
                else if (taskStatus == UNREWARD) {
                    NSMutableDictionary * param = [NSMutableDictionary dictionary];
                    [param setObject:taskInfo.taskID forKey:@"task_id"];
                    [param setObject:taskInfo.logID  forKey:@"log_id"];
                    [GFRequestManager connectWithDelegate:self action:Submit_user_award param:param];
                }
            }
                break;
            case 5: // 去猜大盘
            {
                if (taskStatus == UNDONE || taskStatus == UNREWARD || taskStatus == REWARD) {
                    GuessStockViewController * GSVC = [[GuessStockViewController alloc] init];
                    [self pushToViewController:GSVC];
                }
            }
                break;
            case 6: // 去回答问题
            {
                if (taskStatus == UNDONE || taskStatus == UNREWARD || taskStatus == REWARD) {
                    AnswerViewController * AVC = [[AnswerViewController alloc] init];
                    [self pushToViewController:AVC];
                }
                
            }
                break;
            case 111: // 去邀请好友
            {
                if (taskStatus == UNDONE || taskStatus == UNREWARD || taskStatus == REWARD) {
                    InviteViewController * IVC = [[InviteViewController alloc] init];
                    [self pushToViewController:IVC];
                }
            }
                break;
            case 112: // 去领奖中心
            {
                if (taskStatus == UNDONE || taskStatus == UNREWARD || taskStatus == REWARD) {
                    AwardViewController * AVC = [[AwardViewController alloc] init];
                    [self pushToViewController:AVC];
                }
            }
                break;
            case 9: // 去人人理财（合作）
            case 16: // 去联讯下载
            case 17: // 去联讯开户
            {
                
                if (taskStatus == UNDONE || taskStatus == REWARD) {
                    GFWebViewController * GWVC = [[GFWebViewController alloc] init];
                    GWVC.title = taskInfo.h5Title;
                    GWVC.pageType = WebViewTypePresent;
                    UserInfoEntity *userInfo = [[UserInfoCoreDataStorage sharedInstance] getCurrentUserInfo];
                    NSString * url_h5 = [NSString stringWithFormat:@"%@?uid=%@&token=%@&client_type=iOS", taskInfo.h5Url, userInfo.uid, userInfo.token];
                    NSString * url_h5_task = [NSString stringWithFormat:@"%@?uid=%@&token=%@&client_type=iOS", taskInfo.h5Task, userInfo.uid, userInfo.token];
                    GWVC.requestUrl = [NSURL URLWithString:url_h5];
                    GWVC.task_url = [NSURL URLWithString:url_h5_task];
                    GWVC.flag = 0;
                    [self  presentViewController:GWVC animated:YES completion:nil];
                }
                if (taskStatus == UNREWARD) {
                    NSMutableDictionary * param = [NSMutableDictionary dictionary];
                    [param setObject:taskInfo.taskID forKey:@"task_id"];
                    [param setObject:taskInfo.logID  forKey:@"log_id"];
                    [GFRequestManager connectWithDelegate:self action:Submit_user_award param:param];
                }
            }
                break;
            case 19:// 去应用商店下载
            {
                DownloadViewController * DVC = [[DownloadViewController alloc] init];
                [self pushToViewController:DVC];
            }
                break;
            default:
                break;
        }
    }
}


//下拉刷新代理
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return isEgoRefresh;
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    isEgoRefresh = YES;
    [self getMakeMoneyInfo];
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [NSDate date];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [tableHeader egoRefreshScrollViewDidEndDragging:scrollView];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [tableHeader egoRefreshScrollViewDidScroll:scrollView];
    
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
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
