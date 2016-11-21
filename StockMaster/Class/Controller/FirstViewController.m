//
//  FirstViewController.m
//  StockMaster
//
//  Created by Rebloom on 14-7-22.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "FirstViewController.h"
#import "CHNMacro.h"
#import "NSString+UIColor.h"
#import "UIImage+UIColor.h"
#import "GFWebViewController.h"
#import "ShakeViewController.h"
#import "RegisterViewController.h"
#import "LoginViewController.h"
#import "StockDetailViewController.h"
#import "StockMarketViewController.h"
#import "EmotionViewController.h"
#import "EmotionRankViewController.h"
#import "InformationDetailViewController.h"
#import "MessageBoxViewController.h"
#import "PropBagViewController.h"
#import "PropView.h"

#define FirstCellHeight         175

@interface FirstViewController ()
{
    UserInfoEntity *userInfo;
}

@end

@implementation FirstViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    userInfo = [[UserInfoCoreDataStorage sharedInstance] getCurrentUserInfo];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WXLoginFinished:) name:kTagWXShareFinished object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFinishedNoti:) name:kTagWXLoginRefresh object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFinishedNoti:) name:kTagLoginFinishedNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedRemoteNoti:) name:kTagReceivedRemoteNoti object:nil];
    infoArr = [[NSArray alloc] init];
    notifiDic = [[NSDictionary alloc] init];
    cardArr = [[[UserInfoCoreDataStorage sharedInstance] getPropCard] mutableCopy];
    if (cardArr.count > 0)
    {
        [cardArr insertObject:@"进入道具包（占位用，没实际作用）" atIndex:0];
        
        [cardArr addObject:@"敬请期待（占位用，没实际作用）"];
    }
    
    cardDic = [[NSMutableDictionary alloc] initWithCapacity:10];
    emotionNumArr = [[NSMutableArray alloc] initWithCapacity:10];
    
    needLoad1 = YES;
    needLoad2 = YES;
    needLoad3 = YES;
    currentTab = 1;
    // 此变量标识页面出现需不需要刷新 当进入二级页面之后或下拉到第二页 页面回来不再请求刷新
    needRefresh = YES;
    
    self.view.backgroundColor = KSelectNewColor;
    
    [headerView loadComponentsWithTitle:@"涨涨"];
    [headerView createLine];
    headerView.backgroundColor = kFontColorA;
    headerView.alpha = 0;
    
    statusBarView.backgroundColor = [UIColor clearColor];
    
    homeHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, HeaderViewHeight+133)];

    if ([UserInfoCoreDataStorage sharedInstance].isCurrentUserLogin)
    {
         infoTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight) style:UITableViewStylePlain];
    }
    else
    {
         infoTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 240, screenWidth, screenHeight) style:UITableViewStylePlain];
    }
   
    infoTable.backgroundColor = kBackgroundColor;
    infoTable.delegate = self;
    infoTable.dataSource = self;
    infoTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    infoTable.showsVerticalScrollIndicator = NO;
    [self.view addSubview:infoTable];
    
    publicTop = [[PublicTopView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, HeaderViewHeight)];
    publicTop.delegate = self;
    [homeHeaderView addSubview:publicTop];
    
    NSDictionary * userFinanceInfo = (NSDictionary *)[[UserInfoCoreDataStorage sharedInstance] getSettingInfoWithKey:kTagUserFinanceInfo];
    if (userFinanceInfo)
    {
        infoDic = [userFinanceInfo mutableCopy];
        
        [publicTop transInfo:userFinanceInfo];
        [publicTop clearsContextBeforeDrawing];
        [publicTop setNeedsDisplay];
    }
    
    [self createPropBag];
    
    [self createFootView];
    
    if (!refreshview)
    {
        refreshview = [[EGORefreshTableHeaderView alloc] initWithFrame: CGRectMake(0, -65, screenWidth, 65)];
        refreshview.delegate = self;
        [infoTable addSubview:refreshview];
    }
    
    infoTable.tableHeaderView = homeHeaderView;
    [infoTable.tableHeaderView bringSubviewToFront:homeHeaderView];
    
    // 判断用户是否登录，加载不同的UI
    if ([[UserInfoCoreDataStorage sharedInstance] isCurrentUserLogin])
    {
        [self updateLoginDate];
        // 诸葛统计（用户身份）
        NSMutableDictionary *user = [NSMutableDictionary dictionary];
        user[@"name"] = userInfo.nickname;
        user[@"mobile"] = userInfo.mobile;
        user[@"avatar"] = userInfo.head;
        [[Zhuge sharedInstance] identify:userInfo.uid properties:user];
    }
    else
    {
        [self addNoLoginUI];
        infoTable.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
        
        // 诸葛统计（用户身份）
        NSMutableDictionary *user = [NSMutableDictionary dictionary];
        user[@"name"] = @"未登录";
        NSString *uid = [[Zhuge sharedInstance] getDeviceId];
        [[Zhuge sharedInstance] identify:uid properties:user];
        
    }
    
    [self updateStockList];
    
    [self.view bringSubviewToFront:headerView];
}

//道具包
- (void)createPropBag
{
    if (!propView)
    {
        propView = [[UIView alloc] init];
    }
    propView.frame = CGRectMake(0, CGRectGetHeight(homeHeaderView.frame)-133, screenWidth, 90);
    propView.backgroundColor = kFontColorA;
    [homeHeaderView addSubview:propView];
    
    [self createScrollView];
    
    UIView * buyWhatView = [[UIView alloc] init];
    buyWhatView.frame = CGRectMake(0, CGRectGetMaxY(propView.frame), screenWidth, 43);
    buyWhatView.backgroundColor = KSelectNewColor;
    [homeHeaderView addSubview:buyWhatView];
    
    UILabel * buyWhatLabel = [[UILabel alloc] init];
    buyWhatLabel.frame = CGRectMake(15, 0, 200, 42.5);
    buyWhatLabel.textAlignment = NSTextAlignmentLeft;
    buyWhatLabel.text = @"买什么股票?";
    buyWhatLabel.textColor = KFontNewColorB;
    buyWhatLabel.font = NormalFontWithSize(13);
    [buyWhatView addSubview:buyWhatLabel];
    
    for (int i = 0; i <2; i++)
    {
        UILabel * xianLabel = [[UILabel alloc] init];
        xianLabel.backgroundColor = KFontNewColorM;
        if (i == 0)
        {
            xianLabel.frame = CGRectMake(0, 0, screenWidth, 0.5);
        }
        else if (i == 1)
        {
            xianLabel.frame = CGRectMake(0, CGRectGetMaxY(buyWhatLabel.frame), screenWidth, 0.5);
        }
        [buyWhatView addSubview:xianLabel];
    }
    
}

- (void)clearScrollView
{
    if (cardSV)
    {
        for (UIView * view in cardSV.subviews)
        {
            [view removeFromSuperview];
        }
    }
}

- (void)createScrollView
{
    [self clearScrollView];
    
    if (!cardSV)
    {
        cardSV = [[UIScrollView alloc]init];
    }
    cardSV.frame = CGRectMake(0, 0, screenWidth, 90);
    cardSV.showsHorizontalScrollIndicator = NO;
    cardSV.scrollsToTop = NO;
    if (cardArr.count>0)
    {
        NSInteger  number =  cardArr.count;
        
        PropCardEntity * propCard = nil;
        cardSV.contentSize = CGSizeMake(90*number, 90);
        for (int i = 0; i< number; i++)
        {
            propCard = [cardArr objectAtIndex:i];
            UIView * view = [[UIView alloc] init];
            view.frame = CGRectMake(i*90 , 0, 90, 90);
            if (i == 0)
            {
                view.backgroundColor = @"#e2e2e2".color;
            }
            else
            {
                view.backgroundColor = kFontColorA;
            }
            [cardSV addSubview:view];
            
            UIImageView * imageView = [[UIImageView alloc] init];
            imageView.frame = CGRectMake(33.5, 20, 23, 23);
            imageView.hidden = NO;
            
            if (i == 0)
            {
                imageView.image = [UIImage imageNamed:@"bag.png"];
            }
            else if (i == number-1)
            {
                imageView.hidden = YES;
            }
            else
            {
                imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_card%d",i]];
                NSLog(@"!!!!%@",[NSString stringWithFormat:@"icon_card%d",i]);
            }
            
            [view addSubview:imageView];
            
            UILabel * nameLabel = [[UILabel alloc] init];
            nameLabel.frame = CGRectMake(0, CGRectGetMaxY(imageView.frame)+15, 90, 15);
            nameLabel.font = NormalFontWithSize(13);
            nameLabel.numberOfLines = 0;
            nameLabel.textAlignment = NSTextAlignmentCenter;
            nameLabel.backgroundColor = [UIColor clearColor];
            nameLabel.textColor = KFontNewColorA;
            if (i == 0)
            {
                nameLabel.textColor = KFontNewColorA;
                nameLabel.text = @"进入道具包";
            }
            else if(i == number-2)
            {
                nameLabel.text = propCard.name;
                nameLabel.textColor = KFontNewColorM;
            }
            else if(i == number-1)
            {
                nameLabel.text = @"敬请\n期待";
                nameLabel.frame = CGRectMake(0,0, 90, 90);
                nameLabel.textColor = KFontNewColorM;
            }
            else
            {
                nameLabel.text = propCard.name;
            }
            
            [view addSubview:nameLabel];
            
            
            UILabel * numberLabel = [[UILabel alloc] init];
            numberLabel.frame = CGRectMake(0, 5, 85, 11);
            numberLabel.font = NormalFontWithSize(10);
            numberLabel.numberOfLines = 0;
            numberLabel.textAlignment = NSTextAlignmentRight;
            numberLabel.backgroundColor = [UIColor clearColor];
            numberLabel.textColor = KFontNewColorA;
            
            if (i == 0||i == number-1||i== number -2)
            {
                numberLabel.hidden = YES;
            }
            else
            {
                numberLabel.hidden = NO;
                numberLabel.text = [NSString stringWithFormat:@"x %@",propCard.num];
            }
            
            //判断90%复活卡是否为1  如果是就请求接口在送一张
            if (i == 1)
            {
                if ([propCard.num integerValue] == 0)
                {
                    [self requestReceive_90_card];
                }
            }
            
            [view addSubview:numberLabel];
            
            UIButton * cardBtn = [[UIButton alloc] init];
            cardBtn.frame = CGRectMake(0, 0, 90, 90);
            cardBtn.backgroundColor = [UIColor clearColor];
            cardBtn.tag = i;
            if (i == number -1)
            {
                cardBtn.enabled = NO;
            }
            else
            {
                cardBtn.enabled = YES;
            }
            [cardBtn addTarget:self action:@selector(cardBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:cardBtn];
            
            UILabel * lineLabel = [[UILabel alloc] init];
            lineLabel.backgroundColor = KFontNewColorM;
            lineLabel.frame =  CGRectMake(89.5, 0, 0.5, 90);
            [view addSubview:lineLabel];
        }
    }
    [propView addSubview:cardSV];
}

- (void)cardBtnOnClick:(UIButton*)sender
{
    PropCardEntity * propCard = nil;
    propCard = [cardArr objectAtIndex:sender.tag];
    if (sender.tag == 0)
    {
        PropBagViewController * PBVC = [[PropBagViewController alloc] init];
        [self pushToViewController:PBVC];
    }
    else
    {
        
        [self requestCardInfo:propCard.cardID];
    }
}

- (void)updateLoginDate
{
    // 更新登录的时间戳,记录最近两次登录的时间 按年月日
    NSString * date1 = [[UserInfoCoreDataStorage sharedInstance] getSettingInfoWithKey:kTagLoginDate1];
    
    if (date1)
    {
        [[UserInfoCoreDataStorage sharedInstance] saveSettingInfoWithKey:kTagLoginDate1 value:[Utility dateTimeToStringYMD:[NSDate date]]];
        [[UserInfoCoreDataStorage sharedInstance] saveSettingInfoWithKey:kTagLoginDate2 value:date1];
    }
    else
    {
        [[UserInfoCoreDataStorage sharedInstance] saveSettingInfoWithKey:kTagLoginDate1 value:[Utility dateTimeToStringYMD:[NSDate date]]];
    }
    NSString * date2 = [[UserInfoCoreDataStorage sharedInstance] getSettingInfoWithKey:kTagLoginDate2];
    if ([date1 isEqualToString:date2])
    {
        [[UserInfoCoreDataStorage sharedInstance] saveSettingInfoWithKey:kTagLoginDate2 value:nil];
    }
}

- (void)receivedRemoteNoti:(NSNotification *)noti
{
    if ([[UserInfoCoreDataStorage sharedInstance] isCurrentUserLogin])
    {
        if ([noti object])
        {
            BOOL canPush = YES;
            for (BasicViewController * bvc in super.navigationController.viewControllers)
            {
                if ([bvc isKindOfClass:[StockDetailViewController class]])
                {
                    canPush = NO;
                }
            }
            
            if (canPush)
            {
                StockInfoEntity * stockInfo = (StockInfoEntity *)[noti object];
                
                StockDetailViewController * SDVC = [[StockDetailViewController alloc] init];
                SDVC.stockInfo = stockInfo;
                [self pushToViewController:SDVC];
            }
        }
        else
        {
            MessageBoxViewController * MBVC = [[MessageBoxViewController alloc] init];
            [self pushToViewController:MBVC];
        }
    }
}

- (void)loginFinishedNoti:(NSNotification *)noti
{
    infoArr = nil;
    infoDic = nil;
    
    for (UIView * view in headerView.subviews)
    {
        [view removeFromSuperview];
    }
    headerView.hidden = YES;
    headerView.frame = CGRectMake(0, 0, screenWidth, beginX+45);
    [headerView loadComponentsWithTitle:@"涨涨"];
    [headerView createLine];
    
    
    infoTable.tableHeaderView = homeHeaderView;
    infoTable.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    [self performSelector:@selector(delayRequest) withObject:nil afterDelay:.5];
}

- (void)delayRequest
{
    [self getFirstPageData:1];
    [self requestUserHistory];
}

//请求更新股票数据
- (void)updateStockList
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    // 得到最后更新股票数据时间戳，如果为0请求所有股票数据
    NSString *updateTime = [[StockInfoCoreDataStorage sharedInstance] getStockInfoUpdateTime];
    [paramDic setObject:updateTime forKey:@"last_updated"];
    [GFRequestManager connectWithDelegate:self action:Get_stock_data param:paramDic];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    userInfo = [[UserInfoCoreDataStorage sharedInstance] getCurrentUserInfo];
    
    if ([[UserInfoCoreDataStorage sharedInstance] isCurrentUserLogin])
    {
        if (!infoArr.count)
        {
            [self reloadTabData];
            
            if (needRefresh)
            {
                [self getFirstPageData:currentTab];
            }
        }
        else
        {
            [infoTable reloadData];
        }
        
        
        [self requestUserHistory];
        
        [self requestFeeling];
        [self requestCardBag];
        
        // 诸葛统计（查看首页）
        [[Zhuge sharedInstance] track:@"查看首页" properties:nil];
    }
    else
    {
        [self requestTop10];
    }
}

- (void)reloadTabData
{
    if (currentTab == 1)
    {
        infoArr = [[UserInfoCoreDataStorage sharedInstance] getSettingInfoWithKey:kTagZhangZhang1];
    }
    else if (currentTab == 2)
    {
        infoArr = [[UserInfoCoreDataStorage sharedInstance] getSettingInfoWithKey:kTagZhangZhang2];
    }
    else if (currentTab == 3)
    {
        infoArr = [[UserInfoCoreDataStorage sharedInstance] getSettingInfoWithKey:kTagZhangZhang3];
    }
    [infoTable reloadData];
}

//没有登录的UI界面
- (void)addNoLoginUI
{
    headerView.alpha = 1;
    headerView.frame = CGRectMake(0, 0, screenWidth, 240);
    
    for(UIView * view in headerView.subviews)
    {
        [view removeFromSuperview];
    }
    headerView.backgroundColor = kRedColor;
    UILabel * desc1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 55, screenWidth, 25)];
    desc1.backgroundColor = [UIColor clearColor];
    desc1.textAlignment= NSTextAlignmentCenter;
    desc1.textColor = [UIColor whiteColor];
    
    NSString * str1 = @"注册送虚拟炒股资金";
    NSString * str2 = @"5000.00";
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",str1,str2]];
    
    [str addAttribute:NSForegroundColorAttributeName value:kFontColorA range:NSMakeRange(0,str1.length)];
    [str addAttribute:NSForegroundColorAttributeName value:kFontColorA range:NSMakeRange(str1.length,str2.length)];
    
    [str addAttribute:NSFontAttributeName value:NormalFontWithSize(15) range:NSMakeRange(0,str1.length)];
    [str addAttribute:NSFontAttributeName value:NormalFontWithSize(25) range:NSMakeRange(str1.length,str2.length)];
    
    desc1.attributedText = str;
    
    [headerView addSubview:desc1];
    
    desc3 = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(desc1.frame)+10, screenWidth, 16)];
    desc3.backgroundColor = [UIColor clearColor];
    desc3.textAlignment = NSTextAlignmentCenter;
    desc3.font = NormalFontWithSize(16);
    desc3.textColor = [UIColor whiteColor];
    desc3.text = @"赚钱按比例提现";
    [headerView addSubview:desc3];
    desc3.hidden = YES;
    
    UIButton * loginBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(desc3.frame)+20, 120, 45)];
    loginBtn.layer.cornerRadius = 4;
    loginBtn.layer.masksToBounds = YES;
    [loginBtn setBackgroundImage:[KNewColorRed2 image] forState:UIControlStateNormal];
    [loginBtn setBackgroundImage:[@"#e98e89".color image] forState:UIControlStateHighlighted];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn setTitleColor:kRedColor forState:UIControlStateNormal];
    loginBtn.titleLabel.font = NormalFontWithSize(16);
    [loginBtn addTarget:self action:@selector(toLoginViewController) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:loginBtn];
    
    UIButton * registerBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth-140, CGRectGetMaxY(desc3.frame)+20, 120, 45)];
    registerBtn.layer.cornerRadius = 4;
    registerBtn.layer.masksToBounds = YES;
    [registerBtn setBackgroundImage:[kFontColorA image] forState:UIControlStateNormal];
    [registerBtn setBackgroundImage:[@"#f2bebc".color image] forState:UIControlStateHighlighted];
    [registerBtn setTitle:@"注册" forState:UIControlStateNormal];
    [registerBtn setTitleColor:kRedColor forState:UIControlStateNormal];
    registerBtn.titleLabel.font = NormalFontWithSize(16);
    [registerBtn addTarget:self action:@selector(toRegisterViewController) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:registerBtn];
    
    UIButton * WXLoginBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(registerBtn.frame)+20, screenWidth, 60)];
    WXLoginBtn.backgroundColor = @"#f5f5f5".color;
    [WXLoginBtn addTarget:self action:@selector(WXLogin) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:WXLoginBtn];
    
    UIImageView * WXIcon = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth/2-60, 16, 29, 27.5)];
    WXIcon.image = [UIImage imageNamed:@"icon_weixin"];
    WXIcon.userInteractionEnabled = NO;
    [WXLoginBtn addSubview:WXIcon];
    
    UILabel * WXLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(WXIcon.frame)+9, 0, 100, 60)];
    WXLabel.text = @"微信登录";
    WXLabel.userInteractionEnabled = NO;
    WXLabel.backgroundColor = [UIColor clearColor];
    WXLabel.font = NormalFontWithSize(15);
    WXLabel.textColor = @"#494949".color;
    WXLabel.textAlignment = NSTextAlignmentLeft;
    [WXLoginBtn addSubview:WXLabel];
}

- (void)WXLogin
{
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        [[CHNAlertView defaultAlertView] showContent:@"网络连接失败" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
    }
    else
    {
        // 判断是不是从首页登录，如果是标识YES 从微信登录返回后直接push到register页面，如果不是标识nil，发通知让FirstViewController来push到register页面
        [[UserInfoCoreDataStorage sharedInstance] saveSettingInfoWithKey:kTagWXLoginFromHome value:@"YES"];
        SendAuthReq * req = [[SendAuthReq alloc] init];
        req.openID = kWeiXinAppKey;
        req.scope = @"snsapi_userinfo";
        req.state = @"weixin_login";
        [WXApi sendReq:req];
    }
}

- (void)WXLoginFinished:(NSNotification *)noti
{
    BaseResp * resp = [noti object];
    if (resp.errCode == 0)
    {
        if ([resp isKindOfClass:[SendAuthResp class]])
        {
            SendAuthResp * sendAuthResp = (SendAuthResp *)resp;
            if (sendAuthResp.code)
            {
                [self getAccessTokenWithCode:sendAuthResp.code];
            }
        }
    }
}

- (void)getAccessTokenWithCode:(NSString *)code
{
    UserInfoCoreDataStorage *coreDataStorage = [UserInfoCoreDataStorage sharedInstance];
    if (![coreDataStorage getSettingInfoWithKey:kTagRequestAccessToken])
    {
        [coreDataStorage saveSettingInfoWithKey:kTagRequestAccessToken value:@"YES"];
        NSString * path = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",kWeiXinAppKey,kWeiXinAppSecret,code];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:path]];
        [request setRequestMethod:@"GET"];
        [request setCachePolicy:ASIDoNotReadFromCacheCachePolicy];
        request.delegate = self;
        request.action = @"WXLOGIN";
        [[RequestQueue instance].requestList addObject:request];
        [request startAsynchronous];
    }
}

//进入登陆界面
- (void)toLoginViewController
{
    LoginViewController * LVC = [[LoginViewController alloc] init];
    LVC.flag = 2;
    [self pushToViewController:LVC];
}

//进入注册界面
- (void)toRegisterViewController
{
    RegisterViewController * RVC = [[RegisterViewController alloc] init];
    [self pushToViewController:RVC];
}

//请求用户历史本金记录
-(void)requestUserHistory
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [GFRequestManager connectWithDelegate:self action:Get_user_history_assets param:paramDic];
}

//请求首页可领奖个数
- (void)requestFeeling
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [GFRequestManager connectWithDelegate:self action:Get_stock_feeling_reward_num param:paramDic];
}

//道具包
- (void)requestCardBag
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [GFRequestManager connectWithDelegate:self action:Get_card_list param:paramDic];
}

//道具卡信息
- (void)requestCardInfo:(NSString *)card_id
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:card_id forKey:@"card_id"];
    [GFRequestManager connectWithDelegate:self action:Get_card_info param:paramDic];
}

//请求提现前10名数据
- (void)requestTop10
{
    if ([GFStaticData getObjectForKey:kTagAppStoreClose])
    {
        NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
        [GFRequestManager connectWithDelegate:self action:Get_top_withdraw_money param:paramDic];
    }
    else
    {
        NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
        [GFRequestManager connectWithDelegate:self action:Get_total_profit_rank param:paramDic];
    }
}

//请求热门股票数据
- (void)getHotStock
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:@"50" forKey:@"page_size"];
    [paramDic setObject:@"0" forKey:@"stard_id"];
    [GFRequestManager connectWithDelegate:self action:Get_hot_stock param:paramDic];
}

- (void)orderBtnClicked:(id)sender
{
    btn1.selected = NO;
    btn2.selected = NO;
    btn3.selected = NO;
    
    UIButton * btn = (UIButton *)sender;
    if (btn == btn1)
    {
        currentTab = 1;
        btn1.selected = YES;
        
        // 诸葛统计（首页-最多人买）
        [[Zhuge sharedInstance] track:@"首页-跟你最亲" properties:nil];
    }
    else if (btn == btn2)
    {
        currentTab = 2;
        btn2.selected = YES;
        
        // 诸葛统计（首页-最新资讯）
        [[Zhuge sharedInstance] track:@"首页-最多人买" properties:nil];
    }
    else if (btn == btn3)
    {
        currentTab = 3;
        btn3.selected = YES;
        
        // 诸葛统计（首页-跟你最亲）
        [[Zhuge sharedInstance] track:@"首页-最新资讯" properties:nil];
    }
    [self getFirstPageData:currentTab];
    [infoTable reloadData];
}

- (void)getFirstPageData:(NSInteger)type
{
    if (currentTab == 1)
    {
        infoArr = [[UserInfoCoreDataStorage sharedInstance] getSettingInfoWithKey:kTagZhangZhang1];
    }
    else if (currentTab == 2)
    {
        infoArr = [[UserInfoCoreDataStorage sharedInstance] getSettingInfoWithKey:kTagZhangZhang2];
    }
    else if (currentTab == 3)
    {
        infoArr = [[UserInfoCoreDataStorage sharedInstance] getSettingInfoWithKey:kTagZhangZhang3];
    }
    
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setObject:@"10" forKey:@"page_size"];
    if (type == 1)
    {
        needLoad1 = NO;
        [param setObject:@"feeling" forKey:@"sort_key"];
    }
    else if (type == 2)
    {
        needLoad2 = NO;
        [param setObject:@"sales" forKey:@"sort_key"];
    }
    else if (type == 3)
    {
        needLoad3 = NO;
        [param setObject:@"news" forKey:@"sort_key"];
    }
    
    refreshLoading = YES;
    [param setObject:@"1" forKey:@"page"];
    
    [GFRequestManager connectWithDelegate:self action:Get_index_stock param:param];
}

- (void)requestReceive_90_card
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [GFRequestManager connectWithDelegate:self action:Submit_receive_90_card param:paramDic];
}

- (void)getIndexStockWithSortType:(NSInteger)type
{
    needRefresh = NO;
    if (!infoArr.count)
    {
        return;
    }
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setObject:@"10" forKey:@"page_size"];
    if (type == 1)
    {
        needLoad1 = NO;
        [param setObject:@"feeling" forKey:@"sort_key"];
    }
    else if (type == 2)
    {
        needLoad2 = NO;
        [param setObject:@"sales" forKey:@"sort_key"];
    }
    else if (type == 3)
    {
        needLoad3 = NO;
        [param setObject:@"news" forKey:@"sort_key"];
    }
    refreshLoading = NO;
    [param setObject:[NSString stringWithFormat:@"%d", (int)infoArr.count/10+1] forKey:@"page"];
    
    [GFRequestManager connectWithDelegate:self action:Get_index_stock param:param];
}

// 获取首页股票信息，数据处理
- (void)transStockInfo
{
    needLoad1 = YES;
    needLoad2 = YES;
    needLoad3 = YES;
    
    NSArray * listArr = [[requestInfo objectForKey:@"data"] objectForKey:@"list"];
    
    if (listArr.count)
    {
        if (refreshLoading)
        {
            infoArr = [listArr copy];
            if (currentTab == 1)
            {
                [[UserInfoCoreDataStorage sharedInstance] saveSettingInfoWithKey:kTagZhangZhang1 value:infoArr];
            }
            else if (currentTab == 2)
            {
                [[UserInfoCoreDataStorage sharedInstance] saveSettingInfoWithKey:kTagZhangZhang2 value:infoArr];
            }
            else if (currentTab == 3)
            {
                [[UserInfoCoreDataStorage sharedInstance] saveSettingInfoWithKey:kTagZhangZhang3 value:infoArr];
            }
        }
        else
        {
            if (infoArr.count)
            {
                infoArr = [infoArr arrayByAddingObjectsFromArray:listArr];
            }
            else
            {
                infoArr = [listArr copy];
            }
        }
    }
    else
    {
        if (currentTab == 1)
        {
            needLoad1 = NO;
        }
        else if (currentTab == 2)
        {
            needLoad2 = NO;
        }
        else if (currentTab == 3)
        {
            needLoad3 = NO;
        }
    }
    
    [[StockInfoCoreDataStorage sharedInstance] saveStockInfo:infoArr];
    for (NSDictionary * dic in infoArr)
    {
        if ([[dic objectForKey:@"is_optional"] integerValue] == 1)
        {
            StockInfoEntity * stockInfo = [[StockInfoCoreDataStorage sharedInstance] getStockInfoWithCode:[[dic objectForKey:@"stock_code"] description] exchange:[[dic objectForKey:@"stock_exchange"] description]];
            [[StockInfoCoreDataStorage sharedInstance] addSelectStockWithCode:stockInfo.code exchange:stockInfo.exchange];
        }
    }
}

// 加入自选请求结束
- (void)finishSubmitStockInfo
{
    NSDictionary * dic = [infoArr objectAtIndex:selectedIndex];
    StockInfoEntity * stockInfo = [[StockInfoCoreDataStorage sharedInstance] getStockInfoWithCode:[[dic objectForKey:@"stock_code"] description] exchange:[[dic objectForKey:@"stock_exchange"] description]];
    [[StockInfoCoreDataStorage sharedInstance] addSelectStockWithCode:stockInfo.code exchange:stockInfo.exchange];
    [[TKAlertCenter defaultCenter] postAlertWithMessage:@"加入自选成功" withType:ALERTTYPEERROR];
}

// 删除自选请求结束
- (void)finishDeleteStockInfo
{
    NSDictionary * dic = [infoArr objectAtIndex:selectedIndex];
    StockInfoEntity * stockInfo = [[StockInfoCoreDataStorage sharedInstance] getStockInfoWithCode:[[dic objectForKey:@"stock_code"] description] exchange:[[dic objectForKey:@"stock_exchange"] description]];
    [[StockInfoCoreDataStorage sharedInstance] delSelectStockWithCode:stockInfo.code exchange:stockInfo.exchange];
    [[TKAlertCenter defaultCenter] postAlertWithMessage:@"删除自选成功" withType:ALERTTYPEERROR];
}

// 获取用户财务信息
- (void)transUserFinanceInfo
{
    [[UserInfoCoreDataStorage sharedInstance] saveSettingInfoWithKey:kTagUserFinanceInfo value:[requestInfo objectForKey:@"data"]];
    infoDic = [[requestInfo objectForKey:@"data"] mutableCopy];
    
    [publicTop transInfo:[requestInfo objectForKey:@"data"]];
    [publicTop clearsContextBeforeDrawing];
    [publicTop setNeedsDisplay];
    [infoTable.tableHeaderView bringSubviewToFront:homeHeaderView];
    
    NSString * name = [infoDic objectForKey:@"gs_stock_name"];
    NSString * amount = [infoDic objectForKey:@"gs_stock_count"];
    NSString * price = [infoDic objectForKey:@"gs_stock_total_price"];
    NSString * message = [infoDic objectForKey:@"gs_message"];
    
    if ([[infoDic objectForKey:@"gs_id"] integerValue] > 0)
    {
        [[CHNAlertView defaultAlertView] initWithAwardStockName:name amount:amount price:price message:message delegate:self];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    isEgoRefresh = NO;
    [refreshview egoRefreshScrollViewDataSourceDidFinishedLoading:infoTable];
    
    ASIFormDataRequest * formdataRequest = (ASIFormDataRequest *)request;
    
    if ([formdataRequest.action isEqualToString:Get_top_withdraw_money])
    {
        // 获取提现榜单列表
        infoArr = [[requestInfo objectForKey:@"data"] copy];
    }
    else if ([formdataRequest.action isEqualToString:Get_total_profit_rank])
    {
        // 获取盈利榜单列表
        infoArr = [[[requestInfo objectForKey:@"data"] objectForKey:@"rank_list"] copy];
    }
    else if ([formdataRequest.action isEqualToString:Get_index_stock])
    {
        [self transStockInfo];
    }
    else if ([formdataRequest.action isEqualToString:Submit_stock_watchlist])
    {
        [self finishSubmitStockInfo];
    }
    else if ([formdataRequest.action isEqualToString:Delete_stock_watchlist])
    {
        [self finishDeleteStockInfo];
    }
    else if ([formdataRequest.action isEqualToString:Get_stock_data])
    {
        // 获取股票信息总表，存储数据库
        NSArray *stockArray = [requestInfo objectForKey:@"data"];
        [[StockInfoCoreDataStorage sharedInstance] saveStockInfo:stockArray];
    }
    else if ([formdataRequest.action isEqualToString:Get_user_history_assets])
    {
        [self transUserFinanceInfo];
    }
    else if ([formdataRequest.action isEqualToString:Get_stock_feeling_reward_num])
    {
        // 获取用户感情度奖励信息，改变下方tabbar显示
        notifiDic = [requestInfo objectForKey:@"data"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:KTAGBADGE object:[[notifiDic objectForKey:@"feeling_reward_num"] description]];
    }
    else if ([formdataRequest.action isEqualToString:Submit_receive_gift_stock])
    {
        // 获取新用户奖励股票信息
        if (getStock)
        {
            [self performSelector:@selector(afterShow:) withObject:requestInfo afterDelay:.3];
        }
    }
    else if ([formdataRequest.action isEqualToString:Submit_index_red_package_reward])
    {
        // 领取红包请求
        NSDictionary * dic = [requestInfo objectForKey:@"data"];
        if ([[dic objectForKey:@"status"] integerValue] == 1)
        {
            [[CHNAlertView defaultAlertView] showContent:[dic objectForKey:@"prompt1"] cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
        }
    }
    else if ([formdataRequest.action isEqualToString:Get_card_list])
    {
        // 获取道具包信息列表
        NSMutableArray * tempArr = [[requestInfo objectForKey:@"data"] objectForKey:@"list"];
        
        cardArr = [[[UserInfoCoreDataStorage sharedInstance] savePropCard:tempArr] mutableCopy];
        
        [cardArr insertObject:@"进入道具包（占位用，没实际作用）" atIndex:0];
        
        [cardArr addObject:@"敬请期待（占位用，没实际作用）"];
        
        [self createScrollView];
    }
    else if ([formdataRequest.action isEqualToString:Get_card_info])
    {
        // 获取单个道具弹出信息
        cardDic = [[requestInfo objectForKey:@"data"] copy];
        [self propCardInfo:cardDic];
    }
    else if ([formdataRequest.action isEqualToString:Submit_use_card])
    {
        // 使用卡片请求
        [[TKAlertCenter defaultCenter] postAlertWithMessage:@"使用成功" withType:ALERTTYPEERROR];
        [self requestCardBag];
        [self requestUserHistory];
        
        if ([cardName isEqualToString:@"2"])
        {
            [self requestReceive_90_card];
        }
    }
    else if ([formdataRequest.action isEqualToString:Submit_receive_90_card])
    {
        // 免费领取复活卡
        [self requestCardBag];
        
        NSDictionary * dict = [requestInfo objectForKey:@"data"];
        if ([[dict objectForKey:@"add_card_num"] integerValue] != 0)
        {
            [self propCardInfo:dict];
        }
    }
    [infoTable reloadData];
}

- (void)propCardInfo:(NSDictionary *)dic
{
    NSInteger type;
    propFlag = [CHECKDATA(@"status") integerValue];
    if (propFlag == 1 || propFlag == 10)
    {
        type = 1;
    }
    else
    {
        type = 2;
    }
    
    prop =  [[PropView defaultShareView] initViewWithName:CHECKDATA(@"card_name") WithDescription:CHECKDATA(@"desc") WithType:type Delegate:self WithImageURL:CHECKDATA(@"img") WithDirect:[CHECKDATA(@"link_to") integerValue]?@"查看感情度":@""  WithPrompt:CHECKDATA(@"button_desc") isBuy:NO cardPrice:@"" usable:@"" ExpireTime:@""];
    prop.delegate = self;
    [prop showView];
}

//道具包代理方法 --- 使用卡片
- (void)cardToUse:(NSInteger)index
{
    [prop hideView];
    
    if (propFlag == 1)
    {
        cardName = [cardDic objectForKey:@"card_id"];
        [self requestUseCard:cardName];
    }
    else if (propFlag == 10)
    {
        PropBagViewController * PBVC = [[PropBagViewController alloc] init];
        [self pushToViewController:PBVC];
    }
}

- (void)requestUseCard:(NSString*)card_id
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:card_id forKey:@"card_id"];
    [paramDic setObject:@"1" forKey:@"card_num"];
    [GFRequestManager connectWithDelegate:self action:Submit_use_card param:paramDic];
}

//道具包代理方法 --- 指引（eg：查看感情度）
- (void)directToDo:(NSInteger)index
{
    [prop hideView];
    
    EmotionRankViewController * ERVC = [[EmotionRankViewController alloc] init];
    [self pushToViewController:ERVC];
}

- (void)afterShow:(NSDictionary *)dic
{
    [[CHNAlertView defaultAlertView] initWithAwardFinished:[[[dic objectForKey:@"data"] objectForKey:@"gs_message"] description] delegate:self];
}

// 顶部统一头部代理方法
- (void)setStatusBarColor:(UIColor *)color
{
    //[headerView setStatusBarColor:color];
}

- (void)ruleBtnClicked:(id)sender
{
    if ([GFStaticData getObjectForKey:kTagAppStoreClose])
    {
        needRefresh = NO;
        NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@uid=%@&token=%@&t=%@",HostWithDrawAddress, userInfo.uid, userInfo.token, [Utility dateTimeToStringLF:[NSDate date]]]];
        
        GFWebViewController * GWVC = [[GFWebViewController alloc] init];
        GWVC.pageType = WebViewTypePush;
        GWVC.requestUrl = url;
        GWVC.title = @"提现";
        GWVC.flag = 0;
        [self pushToViewController:GWVC];
    }
}

//创建底部UI
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        if ([[UserInfoCoreDataStorage sharedInstance] isCurrentUserLogin])
        {
            if ((currentTab == 1 && needLoad1) || (currentTab == 2 && needLoad2) || (currentTab == 3 && needLoad3))
            {
                return infoArr.count+1;
            }
        }
        return infoArr.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([[UserInfoCoreDataStorage sharedInstance] isCurrentUserLogin])
    {
        return 50;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UserInfoCoreDataStorage sharedInstance] isCurrentUserLogin])
    {
        if (indexPath.row == infoArr.count)
        {
            return 50;
        }
        NSDictionary * dic = [infoArr objectAtIndex:indexPath.row];
        if ([[dic objectForKey:@"img_url"] description].length)
        {
            if (iPhone6Plus)
            {
                return 233;
            }
            if (iPhone6)
            {
                return 200;
            }
            return 180;
        }
        return FirstCellHeight;
    }
    return 70;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * tableHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 50)];
    tableHeader.backgroundColor = @"#fafafa".color;
    
    if (!btn1)
    {
        btn1 = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(tableHeader.frame)-50, screenWidth/3-0.5, 50)];
    }
    btn1.titleLabel.font = NormalFontWithSize(16);
    [btn1 setTitleColor:@"#929292".color forState:UIControlStateNormal];
    [btn1 setTitleColor:@"#494949".color forState:UIControlStateSelected];
    [btn1 setBackgroundImage:[kFontColorA image] forState:UIControlStateSelected];
    [btn1 setBackgroundImage:[KSelectNewColor image] forState:UIControlStateNormal];
    [btn1 setTitle:@"跟你最亲" forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(orderBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [tableHeader addSubview:btn1];
    
    if (currentTab == 1)
    {
        btn1.selected = YES;
    }
    
    if (!btn2)
    {
        btn2 = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth/3*1, CGRectGetHeight(tableHeader.frame)-50, screenWidth/3, 50)];
    }
    btn2.titleLabel.font = NormalFontWithSize(16);
    [btn2 setTitleColor:@"#929292".color forState:UIControlStateNormal];
    [btn2 setTitleColor:@"#494949".color forState:UIControlStateSelected];
    [btn2 setBackgroundImage:[kFontColorA image] forState:UIControlStateSelected];
    [btn2 setBackgroundImage:[KSelectNewColor image] forState:UIControlStateNormal];
    [btn2 setTitle:@"最多人买" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(orderBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [tableHeader addSubview:btn2];
    
    if (!btn3)
    {
        btn3 = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth/3*2+0.5, CGRectGetHeight(tableHeader.frame)-50, screenWidth/3-0.5, 50)];
    }
    btn3.titleLabel.font = NormalFontWithSize(16);
    [btn3 setTitleColor:@"#929292".color forState:UIControlStateNormal];
    [btn3 setTitleColor:@"#494949".color forState:UIControlStateSelected];
    [btn3 setBackgroundImage:[kFontColorA image] forState:UIControlStateSelected];
    [btn3 setBackgroundImage:[KSelectNewColor image] forState:UIControlStateNormal];
    [btn3 setTitle:@"最新资讯" forState:UIControlStateNormal];
    [btn3 addTarget:self action:@selector(orderBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [tableHeader addSubview:btn3];
    
    //    for (int i = 0; i<3; i++)
    //    {
    //        UILabel * verLineLabel = [[UILabel alloc] init];
    //        if (i == 0)
    //        {
    //            verLineLabel.frame = CGRectMake(CGRectGetMaxX(btn1.frame), 0, 0.5, 50);
    //        }
    //        else if (i == 1)
    //        {
    //            verLineLabel.frame = CGRectMake(CGRectGetMaxX(btn2.frame), 0, 0.5, 50);
    //        }
    //        else if (i ==2)
    //        {
    //            verLineLabel.frame = CGRectMake(CGRectGetMaxX(btn3.frame), 0, 0.5, 50);
    //        }
    //        verLineLabel.backgroundColor = KFontNewColorM;
    //        [tableHeader addSubview:verLineLabel];
    //    }
    
    return tableHeader;
}

- (void)buttonClickedAtIndex:(NSInteger)index
{
    if (index == 0)
    {
        // 取消了，啥也不用干
    }
    else if (index == 1)
    {
        // 点击确定
    }
    else if (index == 2)
    {
        // 点击领取股票
        getStock = YES;
        [self getStock];
    }
    else if (index == 3)
    {
        // 点击取消
        getStock = NO;
        [self closeGetStock];
    }
    else if (index == 4)
    {
        // 领取股票流程，点击知道了
        [self requestUserHistory];
    }
}

- (void)getStock
{
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setObject:[infoDic objectForKey:@"gs_id"] forKey:@"gs_id"];
    [param setObject:@"2" forKey:@"gs_click"];
    [GFRequestManager connectWithDelegate:self action:Submit_receive_gift_stock param:param];
}

- (void)closeGetStock
{
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setObject:[infoDic objectForKey:@"gs_id"] forKey:@"gs_id"];
    [param setObject:@"4" forKey:@"gs_click"];
    [GFRequestManager connectWithDelegate:self action:Submit_receive_gift_stock param:param];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, screenWidth, FirstCellHeight)];
    
    UIView * backGroudView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, FirstCellHeight)];
    backGroudView.backgroundColor = KColorHeader;
    
    cell.selectedBackgroundView = backGroudView;
    
    cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.row == infoArr.count)
    {
        UILabel * loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 50)];
        loadingLabel.backgroundColor = [UIColor clearColor];
        loadingLabel.textAlignment = NSTextAlignmentCenter;
        loadingLabel.font = NormalFontWithSize(15);
        loadingLabel.textColor = KFontNewColorB;
        if ((currentTab == 1 && needLoad1) || (currentTab == 2 && needLoad2) || (currentTab == 3 && needLoad3))
        {
            loadingLabel.text = @"加载中...";
            [self getIndexStockWithSortType:currentTab];
        }
        else
        {
            return [[UITableViewCell alloc] initWithFrame:CGRectZero];
        }
        [cell addSubview:loadingLabel];
        
        return cell;
    }
    
    if (indexPath.row < infoArr.count)
    {
        if ([[UserInfoCoreDataStorage sharedInstance] isCurrentUserLogin])
        {
            NSDictionary * dic = [infoArr objectAtIndex:indexPath.row];
            
            if ([[dic objectForKey:@"img_url"] description].length)
            {
                cell.backgroundColor = kRedColor;
                
                UIImageView * disPlayRedImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 180)];

                UIImageView * redImage = [[UIImageView alloc] init];
                [disPlayRedImage sd_setImageWithURL:[NSURL URLWithString:[[dic objectForKey:@"img_url"] description]]
                           placeholderImage:nil
                                    options:SDWebImageRefreshCached
                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                      if (image) {
                                          // 判断设备适配图像大小
                                          float imageCenter = iPhone6Plus?233:iPhone6?200:180;
                                          disPlayRedImage.frame = CGRectMake(0, 0, iPhone6Plus?image.size.width/3:image.size.width/2, iPhone6Plus?image.size.height/3:image.size.height/2);
                                          disPlayRedImage.center = CGPointMake(screenWidth/2, imageCenter/2);
                                      }
                                  }];
                [cell addSubview:disPlayRedImage];
                
                UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(redImage.frame)-.5, screenWidth, .5)];
                line.backgroundColor = KFontNewColorM;
                [cell addSubview:line];
                return cell;
            }
            
            UIImageView * stockLevel = [[UIImageView alloc] initWithFrame:CGRectMake(15, 30, 29, 29)];
            stockLevel.image = [UIImage imageNamed:[dic objectForKey:@"stock_grade"]];
            [cell addSubview:stockLevel];
            
            UILabel * stockName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(stockLevel.frame)+8, CGRectGetMinY(stockLevel.frame)+7, 120, 15)];
            stockName.font = NormalFontWithSize(15);
            stockName.textColor = @"#494949".color;
            stockName.backgroundColor = [UIColor clearColor];
            stockName.text = [dic objectForKey:@"stock_name"];
            [stockName sizeToFit];
            [cell addSubview:stockName];
            
            UILabel * currentPrice = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(stockName.frame)+16, CGRectGetMinY(stockLevel.frame)+9, 120, 13)];
            currentPrice.backgroundColor = [UIColor clearColor];
            currentPrice.font = NormalFontWithSize(13);
            currentPrice.textColor = @"#494949".color;
            currentPrice.text = [[dic objectForKey:@"current_price"] description];
            [currentPrice sizeToFit];
            [cell addSubview:currentPrice];
            
            UILabel * updownRange = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(currentPrice.frame)+1, CGRectGetMinY(stockLevel.frame)+9, 120, 13)];
            updownRange.backgroundColor = [UIColor clearColor];
            updownRange.font = NormalFontWithSize(13);
            if([[dic objectForKey:@"updown_range"] componentsSeparatedByString:@"-"].count > 1)
            {
                updownRange.textColor = kGreenColor;
            }
            else
            {
                updownRange.textColor = kRedColor;
            }
            if ([[dic objectForKey:@"stock_status"] integerValue] == 1)
            {
                updownRange.textAlignment = NSTextAlignmentCenter;
                updownRange.textColor = @"#ffffff".color;
                updownRange.frame = CGRectMake(CGRectGetMaxX(currentPrice.frame)+1, CGRectGetMinY(stockLevel.frame)+8, 32, 15);
                updownRange.backgroundColor = @"#929292".color;
                updownRange.text = @"停牌";
            }
            else
            {
                updownRange.text = [NSString stringWithFormat:@"(%@)",[[dic objectForKey:@"updown_range"] description]];
                
            }
            [cell addSubview:updownRange];
            
            UILabel * descLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(stockLevel.frame)+15, screenWidth-104, 30)];
            descLabel.numberOfLines = 2;
            descLabel.font = NormalFontWithSize(13);
            descLabel.backgroundColor = [UIColor clearColor];
            descLabel.text = CHECKDATA(@"news_title");
            NSString * newsID = [[dic objectForKey:@"news_id"] description];
            if ([[UserInfoCoreDataStorage sharedInstance] getSettingInfoWithKey:newsID])
            {
                descLabel.textColor = @"#929292".color;
            }
            else
            {
                descLabel.textColor = @"#494949".color;
            }
            [cell addSubview:descLabel];
            
            UILabel * timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(descLabel.frame)+5, screenWidth-104, 10)];
            timeLabel.backgroundColor = [UIColor clearColor];
            timeLabel.font = NormalFontWithSize(10);
            timeLabel.textColor = @"#929292".color;
            timeLabel.text = CHECKDATA(@"news_time");
            [cell addSubview:timeLabel];
            
            UIButton * newsBtn = [[UIButton alloc] initWithFrame:descLabel.frame];
            newsBtn.tag = indexPath.row;
            [newsBtn addTarget:self action:@selector(didSelectNews:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:newsBtn];
            
            UIView * bottomContainer = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(descLabel.frame)+30, screenWidth, 42)];
            bottomContainer.backgroundColor = kFontColorA;
            [cell addSubview:bottomContainer];
            
            UILabel * weekLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, screenWidth/2, 12)];
            weekLabel.backgroundColor = [UIColor clearColor];
            weekLabel.textAlignment = NSTextAlignmentCenter;
            
            NSString * str1 = CHECKDATA(@"stock_sales_prompt1");
            NSString * str2 = CHECKDATA(@"stock_sales");
            NSString * str3 = CHECKDATA(@"stock_sales_prompt2");
            
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@%@",str1,str2,str3]];
            
            [str addAttribute:NSForegroundColorAttributeName value:@"#929292".color range:NSMakeRange(0,str1.length)];
            [str addAttribute:NSForegroundColorAttributeName value:@"#494949".color range:NSMakeRange(str1.length,str2.length)];
            [str addAttribute:NSForegroundColorAttributeName value:@"#929292".color range:NSMakeRange(str1.length+str2.length,str3.length)];
            
            [str addAttribute:NSFontAttributeName value:NormalFontWithSize(12) range:NSMakeRange(0,str1.length)];
            [str addAttribute:NSFontAttributeName value:NormalFontWithSize(12) range:NSMakeRange(str1.length,str2.length)];
            [str addAttribute:NSFontAttributeName value:NormalFontWithSize(12) range:NSMakeRange(str1.length+str2.length,str3.length)];
            weekLabel.attributedText = str;
            [bottomContainer addSubview:weekLabel];
            
            UIView * midLine = [[UIView alloc] initWithFrame:CGRectMake(screenWidth/2-.5, 0, 1, 42)];
            midLine.backgroundColor = kFontColorA;
            [bottomContainer addSubview:midLine];
            
            UILabel * countLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/2+34, CGRectGetMaxY(descLabel.frame)+30+13.5, 15, 15)];
            countLabel.textColor = kFontColorA;
            countLabel.layer.cornerRadius = 7.5;
            countLabel.tag = 11111;
            countLabel.layer.masksToBounds = YES;
            countLabel.textAlignment = NSTextAlignmentCenter;
            countLabel.backgroundColor = kRedColor;
            countLabel.font = NormalFontWithSize(10);
            countLabel.hidden = YES;
            countLabel.text = @"";
            [cell addSubview:countLabel];
            
            if ([CHECKDATA(@"stock_feeling_reward") integerValue])
            {
                countLabel.hidden = NO;
                countLabel.text = CHECKDATA(@"stock_feeling_reward");
            }
            
            emotionNumArr = [[GFStaticData getObjectForKey:EmotionArray] mutableCopy];
            
            if (emotionNumArr.count > 0)
            {
                NSString * stock_code = CHECKDATA(@"stock_code");

                for (int i = 0; i < emotionNumArr.count; i++)
                {
                    NSString * emotion_code = [emotionNumArr objectAtIndex:i];
                    if ([stock_code isEqualToString:emotion_code])
                    {
                        int number = [CHECKDATA(@"stock_feeling_reward") intValue] - 1;
                        if(number > 0)
                        {
                            countLabel.hidden = NO;
                            countLabel.text = [NSString stringWithFormat:@"%d",number];
                        }
                        else
                        {
                            countLabel.hidden = YES;
                        }
                    }
                }
            }

            UILabel * moodLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(countLabel.frame)+6, 15, 100, 12)];
            moodLabel.backgroundColor = [UIColor clearColor];
            
            NSString * str4 = CHECKDATA(@"stock_feeling_prompt1");
            NSString * str5 = CHECKDATA(@"stock_feeling");
            
            NSMutableAttributedString *mstr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",str4,str5]];
            
            [mstr addAttribute:NSForegroundColorAttributeName value:@"#929292".color range:NSMakeRange(0,str4.length)];
            [mstr addAttribute:NSForegroundColorAttributeName value:@"#494949".color range:NSMakeRange(str4.length,str5.length)];
            
            [mstr addAttribute:NSFontAttributeName value:NormalFontWithSize(12) range:NSMakeRange(0,str4.length)];
            [mstr addAttribute:NSFontAttributeName value:NormalFontWithSize(12) range:NSMakeRange(str4.length,str5.length)];
            moodLabel.attributedText = mstr;
            [bottomContainer addSubview:moodLabel];
            
            UIButton * addToBasket = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth-89, 30, 89, 104)];
            addToBasket.tag = indexPath.row;
            addToBasket.selected = NO;
            [addToBasket addTarget:self action:@selector(addToBasketClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:addToBasket];
            
            UIImageView * buyStock = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 23, 22)];
            buyStock.center = addToBasket.center;
            buyStock.tag = 1000;
            buyStock.image = [UIImage imageNamed:@"buystock_normal"];
            [cell addSubview:buyStock];
            
            UILabel * addLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(buyStock.frame), CGRectGetMaxY(buyStock.frame)+8, 60, 13)];
            addLabel.font = NormalFontWithSize(13);
            addLabel.textColor = @"#929292".color;
            addLabel.text = @"已加入";
            addLabel.hidden = YES;
            [cell addSubview:addLabel];
            
            UIButton * emotionBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth/2, 0, screenWidth/2, 34)];
            emotionBtn.tag = indexPath.row;
            [emotionBtn addTarget:self action:@selector(emotionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [bottomContainer addSubview:emotionBtn];
            
            NSString * code = [dic objectForKey:@"stock_code"];
            NSString * exchange = [dic objectForKey:@"stock_exchange"];
            if ([[StockInfoCoreDataStorage sharedInstance] isSelectStockWithCode:code exchange:exchange])
            {
                buyStock.image = [UIImage imageNamed:@"buystock_disable"];
                buyStock.hidden = NO;
                addLabel.hidden = NO;
                addToBasket.selected = YES;
            }
            
            UIView * line1 = [[UIView alloc] initWithFrame:CGRectMake(15, CGRectGetMinY(bottomContainer.frame)-.5, screenWidth-30, .5)];
            line1.backgroundColor = KFontNewColorM;
            [cell addSubview:line1];
            
            UIView * line2 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(bottomContainer.frame)-2, screenWidth, .5)];
            line2.backgroundColor = KFontNewColorM;
            [cell addSubview:line2];
        }
        else
        {
            NSDictionary * dic = [infoArr objectAtIndex:indexPath.row];
            cell.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
            
            UIImageView * userPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 50, 50)];
            // 去掉头像url后面的参数，因为参数为随机变动时间
            NSArray *urlArray = [[dic objectForKey:@"head"] componentsSeparatedByString:@"?"];
            NSString *headUrl = urlArray.firstObject;
            [userPhoto sd_setImageWithURL:[NSURL URLWithString:headUrl]
                         placeholderImage:[UIImage imageNamed:@"icon_user_default"]
                                  options:SDWebImageRefreshCached];
            userPhoto.layer.cornerRadius = 25;
            userPhoto.layer.masksToBounds = YES;
            [cell addSubview:userPhoto];
            
            UILabel * userName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(userPhoto.frame)+10, 27, 200, 15)];
            userName.backgroundColor = [UIColor clearColor];
            userName.textColor = KFontNewColorA;
            userName.font = NormalFontWithSize(15);
            userName.text = CHECKDATA(@"nickname");
            [userName sizeToFit];
            [cell addSubview:userName];
            
            UILabel * drawCash = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(userName.frame)+2, 27, 200, 15)];
            drawCash.backgroundColor = [UIColor clearColor];
            drawCash.textColor = KFontNewColorB;
            drawCash.font = NormalFontWithSize(15);
            if ([GFStaticData getObjectForKey:kTagAppStoreClose])
            {
                drawCash.text = @"共提现";
            }
            else
            {
                drawCash.text = @"共盈利";
            }
            
            [drawCash sizeToFit];
            [cell addSubview:drawCash];
            
            UILabel * cash = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(drawCash.frame)+2, 27, 200, 15)];
            cash.backgroundColor = [UIColor clearColor];
            cash.textColor = kRedColor;
            cash.font = NormalFontWithSize(15);
            if ([GFStaticData getObjectForKey:kTagAppStoreClose])
            {
                cash.text = [NSString stringWithFormat:@"￥%@",CHECKDATA(@"withdraw_money_sum")];
            }
            else
            {
                cash.text = [NSString stringWithFormat:@"%@",CHECKDATA(@"profit_rate")];
            }
            [cash sizeToFit];
            [cell addSubview:cash];
        }
    }
    
    return cell;
}

- (void)emotionBtnClicked:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    if (btn.tag < infoArr.count)
    {
        needRefresh = YES;
        EmotionViewController * EVC = [[EmotionViewController alloc] init];
        NSDictionary * dic = [infoArr objectAtIndex:btn.tag];
        StockInfoEntity * stockInfo = [[StockInfoCoreDataStorage sharedInstance] getStockInfoWithCode:[[dic objectForKey:@"stock_code"] description] exchange:[[dic objectForKey:@"stock_exchange"] description]];
        EVC.stockInfo = stockInfo;
        
        [GFStaticData saveObject:[dic objectForKey:@"stock_code"] forKey:EmotionCode];
        
        [self pushToViewController:EVC];
    }
}

- (void)toPropBtnOnClick:(UIButton*)sender
{
    PropBagViewController * PBVC = [[PropBagViewController alloc] init];
    [self pushToViewController:PBVC];
}


- (void)addToBasketClicked:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    
    selectedIndex = btn.tag;
    
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        return;
    }
    
    if (btn.selected)
    {
        
    }
    else
    {
        UITableViewCell * cell = [infoTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:btn.tag inSection:0]];
        
        CGRect rectInTableView = [infoTable rectForRowAtIndexPath:[NSIndexPath indexPathForRow:btn.tag inSection:0]];
        
        CGRect rect = [infoTable convertRect:rectInTableView toView:[infoTable superview]];
        
        UIImageView * buyStockImageView = (UIImageView *)[cell viewWithTag:1000];
        
        buyStockImageView.image = [UIImage imageNamed:@"buystock_disable"];
        UIImageView * animateImage = [[UIImageView alloc] initWithFrame:CGRectMake(buyStockImageView.frame.origin.x, rect.origin.y+cell.frame.size.height/2-15, buyStockImageView.frame.size.width, buyStockImageView.frame.size.height)];
        animateImage.image = [UIImage imageNamed:@"buystock_normal"];
        [self.view addSubview:animateImage];
        
        [UIView animateWithDuration:.7 animations:^{
            animateImage.frame = CGRectMake(screenWidth-160, rect.origin.y+rect.size.height/2-17.5, 40, 32);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.5 animations:^{
                animateImage.frame = CGRectMake(screenWidth/5*1+20, screenHeight-28, 30, 23);
            } completion:^(BOOL finished) {
                [animateImage removeFromSuperview];
            }];
        }];
    }
    
    NSDictionary * dic = [infoArr objectAtIndex:btn.tag];
    
    NSString * stockCode = [[dic objectForKey:@"stock_code"] description];
    NSString * stockExchange = [[dic objectForKey:@"stock_exchange"] description];
    
    if ([[StockInfoCoreDataStorage sharedInstance] isSelectStockWithCode:stockCode exchange:stockExchange])
    {
        StockInfoEntity *stockInfo = [[StockInfoCoreDataStorage sharedInstance] getStockInfoWithCode:stockCode exchange:stockExchange];
        NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
        [paramDic setObject:stockInfo.code forKey:@"stock_code"];
        [paramDic setObject:stockInfo.exchange forKey:@"stock_exchange"];
        [GFRequestManager connectWithDelegate:self action:Delete_stock_watchlist param:paramDic];
    }
    else
    {
        StockInfoEntity *stockInfo = [[StockInfoCoreDataStorage sharedInstance] getStockInfoWithCode:stockCode exchange:stockExchange];
        NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
        [paramDic setObject:stockInfo.code forKey:@"stock_code"];
        [paramDic setObject:stockInfo.exchange forKey:@"stock_exchange"];
        [GFRequestManager connectWithDelegate:self action:Submit_stock_watchlist param:paramDic];
    }
}

- (void)didSelectNews:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    NSDictionary * dic = [infoArr objectAtIndex:btn.tag];
    
    if ([[dic objectForKey:@"news_id"] description])
    {
        needRefresh = NO;
        NSString * newsID = [[dic objectForKey:@"news_id"] description];
        [[UserInfoCoreDataStorage sharedInstance] saveSettingInfoWithKey:newsID value:newsID];
        
        InformationDetailViewController * IDVC = [[InformationDetailViewController alloc] init];
        IDVC.news_url = [[dic objectForKey:@"news_url"] description];
        IDVC.stock_name = [[dic objectForKey:@"stock_name"] description];
        [self pushToViewController:IDVC];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([[UserInfoCoreDataStorage sharedInstance] isCurrentUserLogin])
    {
        if (indexPath.row < infoArr.count)
        {
            NSDictionary * dic = [infoArr objectAtIndex:indexPath.row];
            
            if ([[dic objectForKey:@"img_url"] description].length)
            {
                NSInteger showType = [[dic objectForKey:@"show_type"] integerValue];
                if (showType == 1)
                {
                    if ([[dic objectForKey:@"red_package_status"] integerValue] == 1)
                    {
                        NSMutableDictionary * param = [NSMutableDictionary dictionary];
                        [GFRequestManager connectWithDelegate:self action:Submit_index_red_package_reward param:param];
                    }
                    else
                    {
                        [[CHNAlertView defaultAlertView] showContent:@"红包已经领取过" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
                    }
                }
                else
                {
                    needRefresh = NO;
                    ShakeViewController * SVC = [[ShakeViewController alloc] init];
                    [self pushToViewController:SVC];
                }
            }
            else
            {
                needRefresh = NO;
                StockDetailViewController * SDVC = [[StockDetailViewController alloc] init];
                NSDictionary * dic = [infoArr objectAtIndex:indexPath.row];
                StockInfoEntity * stockInfo = [[StockInfoCoreDataStorage sharedInstance] getStockInfoWithCode:[[dic objectForKey:@"stock_code"] description] exchange:[[dic objectForKey:@"stock_exchange"] description]];
                SDVC.stockInfo = stockInfo;
                [self pushToViewController:SDVC];
                
                // 诸葛统计（首页列表点击）
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                dict[@"股票名"] = stockInfo.name;
                dict[@"列表序号"] = [NSString stringWithFormat:@"%d", (int)indexPath.row + 1];
                if (currentTab == 1) {
                    [[Zhuge sharedInstance] track:@"首页-跟你最亲列表点击" properties:dict];
                }
                else if (currentTab == 2) {
                    [[Zhuge sharedInstance] track:@"首页-最多人买列表点击" properties:dict];
                }
                else if (currentTab == 3) {
                    [[Zhuge sharedInstance] track:@"首页-最新资讯列表点击" properties:dict];
                }
            }
        }
    }
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return isEgoRefresh;
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    isEgoRefresh = YES;
    if ([[UserInfoCoreDataStorage sharedInstance] isCurrentUserLogin])
    {
        [self getFirstPageData:currentTab];
        [self requestUserHistory];
        [self requestCardBag];
        [self requestFeeling];
        
        if (emotionNumArr.count > 0)
        {
            [emotionNumArr removeAllObjects];
            [GFStaticData saveObject:nil forKey:EmotionCode];
            [GFStaticData saveObject:nil forKey:EmotionArray];
        }
    }
    else
    {
        [self addNoLoginUI];
        [self requestTop10];
    }
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
    
    headerView.hidden = NO;
    
    if (![[UserInfoCoreDataStorage sharedInstance] isCurrentUserLogin])
    {
        headerView.alpha = 1;
        
        if (scrollView.contentOffset.y < 30)
        {
            headerView.frame = CGRectMake(0, 0, screenWidth, 240);
        }
        else if (scrollView.contentOffset.y > 150)
        {
            headerView.frame = CGRectMake(0, -95, screenWidth, 240);
        }
        else
        {
            headerView.frame = CGRectMake(0, -95*(scrollView.contentOffset.y/150), screenWidth, 240);
        }
        
        infoTable.frame = CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, screenHeight-CGRectGetMaxY(headerView.frame));
    }
    else
    {
        if (scrollView.contentOffset.y < 30)
        {
            headerView.alpha = 0;
            
        }
        else if (scrollView.contentOffset.y > 150)
        {
            headerView.alpha = 1;
        }
        else
        {
            headerView.alpha = (scrollView.contentOffset.y/120);
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end


