//
//  InformationDetailViewController.m
//  StockMaster
//
//  Created by dalikeji on 15/3/10.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import "InformationDetailViewController.h"
#import "InformationDetailCell.h"

@interface InformationDetailViewController ()

@end

@implementation InformationDetailViewController

@synthesize news_url;
@synthesize stock_name;

- (void)dealloc
{
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString * title = [NSString stringWithFormat:@"%@-资讯",self.stock_name];
    [headerView loadComponentsWithTitle:title];
    [headerView createLine];
    [headerView backButton];
    headerView.backgroundColor = kFontColorA;
    [headerView setStatusBarColor:kFontColorA];
    
    CGRect frame = CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth , screenHeight - 65);
    webView  = [[UIWebView alloc] initWithFrame:frame];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",self.news_url]];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [webView setScalesPageToFit:YES];
    [webView loadRequest:req];
    
    [self.view addSubview:webView];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [super requestFailed:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
