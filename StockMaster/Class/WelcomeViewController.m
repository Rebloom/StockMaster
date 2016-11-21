//
//  WelcomeViewController.m
//  StockMaster
//
//  Created by Rebloom on 14-7-21.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "WelcomeViewController.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

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
    
    [self showIntroWithSeparatePagesInit];
    // Do any additional setup after loading the view.
}

- (void)showIntroWithSeparatePagesInit {
    EAIntroPage *page1 = [EAIntroPage page];
    page1.bgImage = [UIImage imageNamed:@"page1-568h"];
    
    EAIntroPage *page2 = [EAIntroPage page];
    page2.bgImage = [UIImage imageNamed:@"page2-568h"];
    
//    EAIntroPage *page3 = [EAIntroPage page];
//    page3.bgImage = [UIImage imageNamed:@"page3-568h"];
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1,page2]];
    
    [intro setDelegate:self];
    [intro showInView:self.view animateDuration:0.0];
}

- (void)introDidFinish
{
    HomeViewController * HVC = [[HomeViewController alloc] init];
    [HVC setSelectedTab:TabSelectedFirst];
    [HVC showTabbar];
    [self presentViewController:HVC animated:NO completion:nil];
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
