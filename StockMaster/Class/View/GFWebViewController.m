//
//  GFWebViewController.m
//  StockMaster
//
//  Created by Rebloom on 14-8-20.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "GFWebViewController.h"
#import "ShareView.h"
#import "ShareManager.h"

@interface GFWebViewController ()<HeaderViewDelegate>

@end

@implementation GFWebViewController

@synthesize detailView;
@synthesize requestUrl;
@synthesize title;
@synthesize task_url;
@synthesize pageType;
@synthesize desc;
@synthesize flag;

- (void)dealloc
{
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = kBackgroundColor;
    
    topShadowView.hidden = YES;
    
    [headerView loadComponentsWithTitle:self.title];
    [headerView createLine];
    
    if (pageType == WebViewTypePresent)
    {
        [headerView closeButton];
    }
    else if(pageType == WebViewTypePush)
    {
        [headerView backButton];
    }
    
    UIButton * refreshButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth-65, beginX, 40, headerView.frame.size.height)];
    CGRect size = refreshButton.frame;
    refreshImage = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-41, beginX+13, 20, 19)];
    size = refreshImage.frame;
    [refreshImage setBackgroundColor:[UIColor clearColor]];
    refreshImage.image = [UIImage imageNamed:@"icon_shuaxin_default"];
    refreshImage.userInteractionEnabled = YES;
    [headerView addSubview:refreshImage];
    
    [refreshButton addTarget:self action:@selector(refreshBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:refreshButton];
    
    actView = [[UIActivityIndicatorView alloc] init];
    actView.userInteractionEnabled = YES;
    actView.color = KFontNewColorA;
    actView.frame = CGRectMake(screenWidth-41, beginX+13, 20, 19);
    [headerView addSubview:actView];
    
    detailView = [[UIWebView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, screenHeight-headerView.frame.size.height)];
    detailView.delegate = self;
    detailView.backgroundColor = kBackgroundColor;
    [self.view addSubview:detailView];
    
    NSURLRequest * request = [NSURLRequest requestWithURL:self.requestUrl];
    [self.detailView loadRequest:request];
}

- (void)refreshBtnOnClick:(UIButton *)sender
{
    refreshImage.hidden = YES;
    [actView startAnimating];
    
    NSURLRequest * request = [NSURLRequest requestWithURL:self.requestUrl];
    [self.detailView loadRequest:request];
    
}

- (void)buttonClicked:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    if (btn.tag == 1)
    {
        if ([self.detailView canGoBack]) {
            [self.detailView goBack];
        }
        else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else if (btn.tag == 6) {
        if (flag == 1)
        {
            CATransition *animation = [CATransition animation];
            
            [animation setDuration:0.3];
            
            [animation setType: kCATransitionMoveIn];
            
            [animation setSubtype: kCATransitionFromBottom];
            
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
            
            [self.navigationController.view.layer addAnimation:animation forKey:nil];
            
            [self.navigationController popToRootViewControllerAnimated:NO];
            
        }
        else
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *targetPage = [request.URL absoluteString];
    if ([targetPage componentsSeparatedByString:@"cmd=withdraw_deposit"].count > 1)
    {
        WithDrawCashViewController * WDCVC = [[WithDrawCashViewController alloc] init];
        [self pushToViewController:WDCVC];
    }
    else if ([targetPage componentsSeparatedByString:@"cmd=renrenlicai"].count > 1)
    { // 人人理财
        [[UIApplication sharedApplication] openURL:self.task_url];
    }
    else if ([targetPage componentsSeparatedByString:@"cmd=lianxun"].count > 1)
    { // 联讯证券
        [[UIApplication sharedApplication] openURL:self.task_url];
    }
    else if ([targetPage componentsSeparatedByString:@"cmd=withdraw_share"].count > 1)
    { // 提现分享页
        [Utility hideLoadingInView:self.view];

        ShareView *sharView = [[ShareView defaultShareView] initViewWtihNumber:4 Delegate:self WithViewController:self];
        [sharView showView];
    }
    return YES;
}

//分享
- (void)shareAtIndex:(NSInteger)index
{
    if (index == 0)
    {
        if ([TencentOAuth iphoneQQInstalled])
        {
            [[ShareManager defaultShareManager] sendTencentWithUrl:self.task_url WithDesc:self.desc WithType:SHARETOQQ];
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
            [[ShareManager defaultShareManager] sendTencentWithUrl:self.task_url WithDesc:self.desc WithType:SHARETOQZONE];
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
            [[ShareManager defaultShareManager] sendWXWithUrl:self.task_url WithDesc:self.desc WithType:WXSceneTimeline];
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
            [[ShareManager defaultShareManager] sendWXWithUrl:self.task_url WithDesc:self.desc WithType:WXSceneSession];
        }
        else
        {
            [[CHNAlertView defaultAlertView] showContent:@"还没有安装微信哟~" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
        }
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if(flag != 1)
    {
        [Utility showLoadingInView:self.view];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [Utility hideLoadingInView:self.view];
    refreshImage.hidden = NO;
    [actView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    headerView.refreshImage.hidden = NO;
    [headerView.actView stopAnimating];
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
