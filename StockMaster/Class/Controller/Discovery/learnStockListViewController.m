//
//  learnStockListViewController.m
//  StockMaster
//
//  Created by Rebloom on 14-8-5.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "learnStockListViewController.h"

@interface learnStockListViewController ()

@end

@implementation learnStockListViewController
@synthesize title;

- (void)dealloc
{
    [infoTable release];
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
    if (title)
    {
        [headerView loadComponentsWithTitle:title];
    }
    else
    {
        [headerView loadComponentsWithTitle:@"基础知识"];
    }
    [headerView backButton];
    
    infoTable = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame), 320, screenHeight-headerView.frame.size.height)];
    infoTable.backgroundColor = [UIColor whiteColor];
    infoTable.dataSource = self;
    infoTable.delegate = self;
    [self.view addSubview:infoTable];
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0.1)];
    infoTable.tableFooterView = footView;
    [infoTable reloadData];
    [footView release];
    // Do any additional setup after loading the view.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
    
    UIImageView * icoImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 30, 30)];
    icoImage.image = [UIImage imageNamed:@"btn_back"];
    [cell addSubview:icoImage];
    [icoImage release];
    
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 200, 25)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = BoldFontWithSize(20);
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.text = @"为什么要买股票";
    [cell addSubview:titleLabel];
    [titleLabel release];
    
    return [cell autorelease];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LearnStockDetailViewController * LSDVC = [[[LearnStockDetailViewController alloc] init] autorelease];
    LSDVC.requestUrl = [NSURL URLWithString:@"http://www.youguu.com/opms/html/article/3/2014/0220/486.html"];
    [self pushToViewController:LSDVC];
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
