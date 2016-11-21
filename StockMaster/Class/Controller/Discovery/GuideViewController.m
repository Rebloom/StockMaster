//
//  GuideViewController.m
//  StockMaster
//
//  Created by Rebloom on 14-8-5.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "GuideViewController.h"

@interface GuideViewController ()

@end

@implementation GuideViewController

- (void)dealloc
{
    [infoTable release];
    [infoArr release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor =kBackgroundColor;
    [headerView loadComponentsWithTitle:@"新手指引"];
    [headerView backButton];
    
    infoArr = [[NSMutableArray alloc] init];
    
    infoTable = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame), 320, screenHeight-headerView.frame.size.height)];
    infoTable.backgroundColor = kBackgroundColor;
    infoTable.dataSource = self;
    infoTable.delegate = self;
    infoTable.separatorStyle = NO;
    [self.view addSubview:infoTable];
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0.1)];
    infoTable.tableFooterView = footView;
    [infoTable reloadData];
    [footView release];
    
    [self requestGuideList];
}

- (void)requestGuideList
{
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [GFRequestManager connectWithDelegate:self action:Get_guidance param:param];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    NSDictionary * back = [request.responseString objectFromJSONString];
    if ([super judgeBackInfo:back])
    {
        infoArr = [[back objectForKey:@"data"] mutableCopy];
    }
    [infoTable reloadData];
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
    return 58;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 320, 58)];
    cell.backgroundColor = kBackgroundColor;
    NSDictionary * dic = [infoArr objectAtIndex:indexPath.row];

    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200, 58)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = NormalFontWithSize(17);
    titleLabel.textColor = kTitleColorA;
    titleLabel.text = [dic objectForKey:@"title"];
    [cell addSubview:titleLabel];
    [titleLabel release];
    
    UIImageView * rightView = [[UIImageView alloc] initWithFrame:CGRectMake(295, 23, 7, 12)];
    rightView.image = [UIImage imageNamed:@"home_right"];
    rightView.backgroundColor = [UIColor clearColor];
    [cell addSubview:rightView];
    [rightView release];
    
    UILabel * lineLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 57.5, 320, 0.5)];
    lineLb.backgroundColor = kLineBGColor2;
    [cell addSubview:lineLb];
    [lineLb release];
    
    return [cell autorelease];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    NSDictionary * dic = [infoArr objectAtIndex:indexPath.row];
    GFWebViewController * GWVC = [[[GFWebViewController alloc] init] autorelease];
    GWVC.requestUrl = [NSURL URLWithString:[[dic objectForKey:@"url"] description]];
    GWVC.title = [[dic objectForKey:@"title"] description];
    
    [self pushToViewController:GWVC];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
