//
//  LearnStockDetailViewController.m
//  StockMaster
//
//  Created by Rebloom on 14-8-6.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "LearnStockDetailViewController.h"

@interface LearnStockDetailViewController ()

@end

@implementation LearnStockDetailViewController

@synthesize detailView;
@synthesize requestUrl;

- (void)dealloc
{
    [detailView release];
    [super dealloc];
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
    
    [headerView loadComponentsWithTitle:@"内容详情"];
    [headerView backButton];
    
    detailView = [[UIWebView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame), 320, screenHeight-headerView.frame.size.height)];
    detailView.delegate = self;
    [self.view addSubview:detailView];
    
    NSURLRequest * request = [NSURLRequest requestWithURL:self.requestUrl];
    [self.detailView loadRequest:request];
    // Do any additional setup after loading the view.
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [Utility showLoadingInView:self.view];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [Utility hideLoadingInView:self.view];
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
