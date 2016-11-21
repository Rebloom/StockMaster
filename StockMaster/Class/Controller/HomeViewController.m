//
//  HomeViewController.m
//  StockMaster
//
//  Created by Rebloom on 14-7-22.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "HomeViewController.h"

#import "StockDetailViewController.h"

#import "Mine/MessageBoxViewController.h"
#import "AppDelegate.h"
#import "PropBagViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

@synthesize tabBarController;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    [AppDelegate instance].HVC = self;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTabbar) name:kTagShowTabbarNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideTabbar) name:kTagHideTabbarNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(vcSwitch:) name:KTAGVCSWITCH object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setBadgeNum:) name:KTAGBADGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedRemoteNoti:) name:kTagReceivedRemoteNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(propCardNoti:) name:kTagPropCardNoti object:nil];
}

- (void)receivedRemoteNoti:(NSNotification *)noti
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

- (void)propCardNoti:(NSNotification*)noti
{
    [[TKAlertCenter defaultCenter] postAlertWithMessage:[[noti object] stringValue] withType:ALERTTYPEERROR];
    
    NSDictionary * dic = (NSDictionary*)[noti object];

    NSInteger type;
    NSInteger propFlag = [CHECKDATA(@"status") integerValue];
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

- (void)cardToUse:(NSInteger)index
{
    [prop hideView];
    
    PropBagViewController * PBVC = [[PropBagViewController alloc] init];
    [self pushToViewController:PBVC];
}

- (void)setSelectedTab:(NSInteger)index
{
    FirstViewController * first = [[FirstViewController alloc] init];
    SecondViewController * second = [[SecondViewController alloc] init];
    ThirdViewController * third = [[ThirdViewController alloc] init];
    FourthViewController * fourth = [[FourthViewController alloc] init];
    FifthViewController * fifth = [[FifthViewController alloc] init];
    
    UINavigationController * navFirst = [[UINavigationController alloc] initWithRootViewController:first];
    navFirst.navigationBarHidden = YES;
    UINavigationController * navSecond = [[UINavigationController alloc] initWithRootViewController:second];
    navSecond.navigationBarHidden = YES;
    UINavigationController * navThird = [[UINavigationController alloc] initWithRootViewController:third];
    navThird.navigationBarHidden = YES;
    UINavigationController * navFourth = [[UINavigationController alloc] initWithRootViewController:fourth];
    navFourth.navigationBarHidden = YES;
    UINavigationController * navFifth = [[UINavigationController alloc] initWithRootViewController:fifth];
    navFifth.navigationBarHidden = YES;
    
    navFirst.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"涨涨" image:[UIImage imageNamed:@"king_normal"] tag:1];
    navSecond.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"买卖" image:[UIImage imageNamed:@"icon_tabbar_second_normal"] tag:2];
    navThird.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"发现" image:[UIImage imageNamed:@"discovery_normal"] tag:3];
    navFourth.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"赚钱" image:[UIImage imageNamed:@"makemoney_normal"] tag:4];
    navFifth.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"我的" image:[UIImage imageNamed:@"mine_normal"] tag:5];
    
    tabBarController = [[Ivan_UITabBar alloc] init];
    tabBarController.imageArr = [NSArray arrayWithObjects:@"king_selected",@"icon_tabbar_second_selected",@"discovery_selected",@"makemoney_selected",@"mine_selected",nil];
    tabBarController.viewControllers = [NSArray arrayWithObjects:navFirst,navSecond,navThird,navFourth,navFifth,nil];
    [self.view addSubview:tabBarController.view];
    
    if(tabBarController.buttons.count)
    {
        [tabBarController selectedTab:[tabBarController.buttons objectAtIndex:index]];
    }
    else
    {
        [self performSelector:@selector(methodAfter:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)index],@"key",nil] afterDelay:.3];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self showTabbar];
}

- (void)methodAfter:(id)userInfo
{
    NSDictionary * dic = (NSDictionary *)userInfo;
    NSInteger index = [[dic objectForKey:@"key"] integerValue];
    [tabBarController selectedTab:[tabBarController.buttons objectAtIndex:index]];
}

-(void)vcSwitch:(NSNotification*)notifi
{
    [tabBarController selectedTab:[tabBarController.buttons objectAtIndex:[[notifi object] integerValue]]];
}

- (void)setBadgeNum:(NSNotification*)notifi
{
    [tabBarController setBadge:[notifi object]];
}

- (void)showTabbar
{
    if (tabBarController)
    {
        [tabBarController bringCustomTabBarToFront];
    }
}

- (void)hideTabbar
{
    if (tabBarController)
    {
        [tabBarController hideCustomTabBar];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
