//
//  LearnStockViewController.m
//  StockMaster
//
//  Created by Rebloom on 14-8-5.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "LearnStockViewController.h"

@interface LearnStockViewController ()

@end

@implementation LearnStockViewController

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
    
    [headerView loadComponentsWithTitle:@"股市学堂"];
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
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray * nameArr = @[@"新手入门",@"基本面分析",@"技术面分析",@"高手进阶"];
    
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    view.backgroundColor = [UIColor lightGrayColor];
    
    UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 200, 20)];
    title.backgroundColor = [UIColor clearColor];
    title.font = NormalFontWithSize(12);
    title.textColor = [UIColor blackColor];
    [view addSubview:title];
    title.text = [nameArr objectAtIndex:section];
    [title release];
    
    return [view autorelease];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 320, 80)];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    for (int i = 0; i < 4; i++)
    {
        UIButton * responseBtn = [[UIButton alloc] initWithFrame:CGRectMake(i*80, 0, 80, 80)];
        [responseBtn addTarget:self action:@selector(responseBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:responseBtn];
        [responseBtn release];
        
        UIImageView * bgImage = [[UIImageView alloc] initWithFrame:CGRectMake(15+i*80, 5, 50, 50)];
        bgImage.backgroundColor = MY_COLOR(i*50+50, i*50, i*50, 1);
        [cell addSubview:bgImage];
        [bgImage release];
        
        UILabel * descLabel = [[UILabel alloc] initWithFrame:CGRectMake(0+i*80, 60, 80, 20)];
        descLabel.textAlignment = NSTextAlignmentCenter;
        descLabel.backgroundColor = [UIColor clearColor];
        descLabel.font = NormalFontWithSize(14);
        descLabel.textColor = [UIColor blackColor];
        descLabel.text = @"基础知识";
        [cell addSubview:descLabel];
        [descLabel release];
    }
    
    return [cell autorelease];
}

- (void)responseBtnClicked:(id)sender
{
    //去列表页面
    learnStockListViewController * LSLVC = [[[learnStockListViewController alloc] init] autorelease];
    [self pushToViewController:LSLVC];
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
