//
//  MoreViewController.m
//  StockMaster
//
//  Created by dalikeji on 14-11-6.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "MoreViewController.h"
#import "LoginViewController.h"
#import "FeedbackViewController.h"
#import "CheckCodeViewController.h"
#import "AboutViewController.h"
#import "UIImage+UIColor.h"
#import "SecondLoginViewController.h"
#import "ShareManager.h"

@interface MoreViewController ()

@end

@implementation MoreViewController

-(void)deallocd
{
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [infoTableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor =KSelectNewColor;
    
    [headerView loadComponentsWithTitle:@"设置"];
    [headerView backButton];
    [headerView createLine];
    headerView.backgroundColor = kFontColorA;
    [headerView setStatusBarColor: kFontColorA];
    
    titleArr = [[NSMutableArray alloc] initWithCapacity:5];
    [titleArr addObject:@"意见反馈"];
    [titleArr addObject:@"修改密码"];
    [titleArr addObject:@"通知推送"];
    [titleArr addObject:@"关于（二维码）"];
    [titleArr addObject:@"分享"];
    
    [self createTabelView];
}

-(void)createTabelView
{
    if (!infoTableView)
    {
        infoTableView = [[UITableView alloc] init];
    }
    infoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    infoTableView.delegate = self;
    infoTableView.dataSource = self;
    infoTableView.backgroundColor = KSelectNewColor;
    infoTableView.frame = CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, screenHeight - CGRectGetHeight(headerView.frame));
    [self.view addSubview:infoTableView];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    
    ASIFormDataRequest * formDataRequest = (ASIFormDataRequest*)request;
    if ([formDataRequest.action isEqualToString:Submit_user_logout])
    {
        for (BasicViewController * bvc in self.navigationController.viewControllers)
        {
            if ([bvc isKindOfClass:[FifthViewController class]])
            {
                [[UserInfoCoreDataStorage sharedInstance] currentUserLogout];
                [GFStaticData saveObject:nil forKey:kTagSettingRefreshTime];
                [GFStaticData saveObject:nil forKey:kTagTopNoticeRefreshTime];
                
                if ([[UserInfoCoreDataStorage sharedInstance] getSettingInfoWithKey:kTagIsWeiXinLogin])
                {
                    HomeViewController * HVC = [[HomeViewController alloc] init];
                    [HVC setSelectedTab:TabSelectedFirst];
                    [HVC showTabbar];
                    [self presentViewController:HVC animated:NO completion:nil];
                }
                else
                {
                    SecondLoginViewController * HVC = [[SecondLoginViewController alloc] init];
                    [self pushToViewController:HVC];
                }
                
                return;
            }
        }
    }
    else if([formDataRequest.action isEqualToString:Get_retrieve_password_sms_code])
    {
        if ([[requestInfo objectForKey:@"message"] isEqualToString:@"Success"])
        {
            UserInfoEntity *userInfo = [[UserInfoCoreDataStorage sharedInstance] getCurrentUserInfo];
            CheckCodeViewController * CCVC = [[CheckCodeViewController alloc] init];
            CCVC.passPhone = userInfo.mobile;
            CCVC.flag = 2;
            [self pushToViewController:CCVC];
        }
    }
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return titleArr.count +1;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * mineCell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 60)];
    mineCell.backgroundColor = kFontColorA;
    mineCell.selectedBackgroundView = [[UIView alloc] initWithFrame:mineCell.frame];
    mineCell.selectedBackgroundView.backgroundColor = KSelectNewColor;
    
    
    if (indexPath.row<titleArr.count)
    {
        UILabel * title = [[UILabel alloc] init ];
        title.frame=CGRectMake(20, 0, 150, 58);
        title.backgroundColor = [UIColor clearColor];
        title.textColor = KFontNewColorA;
        title.font = NormalFontWithSize(15);
        title.text = [titleArr objectAtIndex:indexPath.row];
        [mineCell addSubview:title];
        
        UIImageView * rightView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth - 31, 20, 11, 20)];
        rightView.image = [UIImage imageNamed:@"jiantou-you"];
        rightView.backgroundColor = [UIColor clearColor];
        [mineCell addSubview:rightView];
        
        UILabel * lineLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 59, screenWidth, 0.5)];
        lineLb.backgroundColor = KLineNewBGColor1;
        lineLb.font = NormalFontWithSize(14);
        [mineCell addSubview:lineLb];
        
        if(indexPath.row == 4)
        {
            UILabel * lineLb2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 59.5, screenWidth, 0.5)];
            lineLb2.backgroundColor = KLineNewBGColor2;
            [mineCell addSubview:lineLb2];
        }
    }
    else
    {
        mineCell.backgroundColor = [UIColor clearColor];
        UIButton * logoutBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, screenWidth - 40, 44)];
        logoutBtn.tintColor = kFontColorA;
        logoutBtn.layer.cornerRadius = 5;
        logoutBtn.layer.masksToBounds = YES;
        logoutBtn.titleLabel.font = NormalFontWithSize(16);
        [logoutBtn setTitle:@"退出登录" forState:UIControlStateNormal];
        [logoutBtn setBackgroundImage:[KFontNewColorD image] forState:UIControlStateNormal];
        [logoutBtn setBackgroundImage:[KBtnSelectNewColorA image ] forState:UIControlStateSelected];
        [logoutBtn setBackgroundImage:[KBtnSelectNewColorA image] forState:UIControlStateHighlighted];
        [logoutBtn addTarget:self action:@selector(logoutBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [mineCell addSubview:logoutBtn];
    }
    
    return mineCell;
}

- (void)logoutBtnClicked:(id)sender
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [GFRequestManager connectWithDelegate:self action:Submit_user_logout param:paramDic];
    
    // 诸葛统计（用户注销）
    UserInfoEntity *userInfo = [[UserInfoCoreDataStorage sharedInstance] getCurrentUserInfo];
    NSMutableDictionary *user = [NSMutableDictionary dictionary];
    user[@"用户id"] = userInfo.uid;
    user[@"用户名"] = userInfo.nickname;
    user[@"手机"] = userInfo.mobile;
    [[Zhuge sharedInstance] track:@"用户注销" properties:user];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (indexPath.row == 0)
    {
        FeedbackViewController * FVC = [[FeedbackViewController alloc] init];
        [self pushToViewController:FVC];
    }
    else if (indexPath.row == 1)
    {
        NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
        UserInfoEntity *userInfo = [[UserInfoCoreDataStorage sharedInstance] getCurrentUserInfo];
        [paramDic setObject:userInfo.mobile forKey:@"mobile"];
        [GFRequestManager connectWithDelegate:self action:Get_retrieve_password_sms_code param:paramDic];
    }
    else if (indexPath.row == 2)
    {
        NoticeViewController * NVC = [[NoticeViewController alloc] init];
        [self pushToViewController:NVC];
    }
    else if (indexPath.row == 3)
    {
        AboutViewController * AVC = [[AboutViewController alloc] init];
        [self pushToViewController:AVC];
    }
    else if (indexPath.row == 4)
    {
        // number = 4 （qq、qq空间、微信、朋友圈）; = 5 （多一个新浪微博）
        ShareView *shareView = [[ShareView defaultShareView] initViewWtihNumber:4 Delegate:self WithViewController:self];
        [shareView showView];
    }
    [infoTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)shareAtIndex:(NSInteger)index
{
    UserInfoEntity *userInfo = [[UserInfoCoreDataStorage sharedInstance] getCurrentUserInfo];
    if (index == 0)
    {
        if ([TencentOAuth iphoneQQInstalled])
        {
            [[ShareManager defaultShareManager] sendTencentWithType:SHARETOQQ WithUid:userInfo.uid];
        }
        else
        {
            [[CHNAlertView defaultAlertView] showContent:@"还没有安装QQ哟~" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
        }
    }
    else if (index == 1)
    {
        if ([TencentOAuth iphoneQQInstalled])
        {
            [[ShareManager defaultShareManager] sendTencentWithType:SHARETOQZONE WithUid:userInfo.uid];
        }
        else
        {
            [[CHNAlertView defaultAlertView] showContent:@"还没有安装QQ哟~" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
        }
    }
    else if (index == 2)
    {
        if ([WXApi isWXAppInstalled])
        {
            [[ShareManager defaultShareManager] sendWXWithType:WXSceneTimeline WithUid:userInfo.uid];
        }
        else
        {
            [[CHNAlertView defaultAlertView] showContent:@"还没有安装微信哟~" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
        }
    }
    else if (index == 3)
    {
        if ([WXApi isWXAppInstalled])
        {
            [[ShareManager defaultShareManager] sendWXWithType:WXSceneSession WithUid:userInfo.uid];
        }
        else
        {
            [[CHNAlertView defaultAlertView] showContent:@"还没有安装微信哟~" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
        }
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)isDirectShareInIconActionSheet
{
    return YES;
}

@end
