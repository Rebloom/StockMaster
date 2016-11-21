//
//  AboutViewController.m
//  StockMaster
//
//  Created by dalikeji on 14-11-6.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "AboutViewController.h"
@interface AboutViewController ()

@end

@implementation AboutViewController

- (void)dealloc
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
    
    [headerView loadComponentsWithTitle:@"关于"];
    [headerView backButton];
    [headerView createLine];
    headerView.backgroundColor = kFontColorA;
    [headerView setStatusBarColor:kFontColorA];
    
    isNewVerson = NO;
    
    titleArr = [[NSMutableArray alloc] initWithCapacity:5];
    [titleArr addObject:@"版本"];
    if ([GFStaticData getObjectForKey:kTagAppStoreClose])
    {
        [titleArr addObject:@"版本介绍"];
    }
    [titleArr addObject:@"软件许可协议"];
    [titleArr addObject:@"交易规则"];
    [titleArr addObject:@"帮助"];
    
    [self createUI];
}

-(void)createUI
{
    if (!scrollView)
    {
        scrollView = [[UIScrollView alloc] init];
    }
    scrollView.frame = CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, screenHeight);
    scrollView.delegate = self;
    scrollView.contentSize = CGSizeMake(screenWidth, 690);
    scrollView. backgroundColor = KSelectNewColor;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    
    if ([GFStaticData getObjectForKey:kTagAppStoreClose])
    {
        UIImageView * iconIV = [[UIImageView alloc] init];
        iconIV.frame = CGRectMake(screenWidth/2 - 70, 20, 140, 140);
        iconIV.image = [UIImage imageNamed:@"erweima"];
        [scrollView addSubview:iconIV];
    }
    else
    {
        UIImageView * iconIV = [[UIImageView alloc] init];
        iconIV.frame = CGRectMake(screenWidth/2-35, 20, 70, 70);
        iconIV.layer.cornerRadius = 35;
        iconIV.layer.masksToBounds = YES;
        iconIV.image = [UIImage imageNamed:@"icon_head"];
        [scrollView addSubview:iconIV];
        
//        UILabel * nameLb = [[UILabel alloc]init];
//        nameLb.frame = CGRectMake(0, CGRectGetMaxY(iconIV.frame)+19, screenWidth, 16);
//        nameLb.textColor = KFontNewColorA;
//        nameLb.textAlignment = NSTextAlignmentCenter;
//        nameLb.font = NormalFontWithSize(15);
//        nameLb.text = @"涨涨";
//        [scrollView addSubview:nameLb];
//        
//        UILabel * contentLb = [[UILabel alloc]init];
//        contentLb.frame = CGRectMake(0, CGRectGetMaxY(nameLb.frame)+8, screenWidth, 13);
//        contentLb.textColor = KFontNewColorB;
//        contentLb.textAlignment = NSTextAlignmentCenter;
//        contentLb.font = NormalFontWithSize(12);
//        contentLb.text = @"免费炒股，大赚真钱";
//        [scrollView addSubview:contentLb];
    }
    
    infoTableView = [[UITableView alloc] init];
    infoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    infoTableView.delegate = self;
    infoTableView.dataSource = self;
    infoTableView.scrollEnabled = NO;
    infoTableView.backgroundColor = kBackgroundColor;
    infoTableView.frame = CGRectMake(0, ([GFStaticData getObjectForKey:kTagAppStoreClose])?180:110, screenWidth, [titleArr count]*60);
    [scrollView addSubview:infoTableView];
    
    UIImageView * iconImgView = [[UIImageView alloc] init];
    iconImgView.frame = CGRectMake(screenWidth/2 - 15, CGRectGetMaxY(infoTableView.frame) +52, 30, 23);
    iconImgView.image = [UIImage imageNamed:@"zhangzhang"];
    [scrollView addSubview:iconImgView];
    
    UILabel * ideaLabel = [[UILabel alloc] init];
    ideaLabel.frame = CGRectMake(0,CGRectGetMaxY(iconImgView.frame)+10, screenWidth, 12);
    ideaLabel.text = @"免费炒股，大赚真钱";
    ideaLabel.textAlignment = NSTextAlignmentCenter;
    ideaLabel.textColor = KFontNewColorC;
    ideaLabel.font = NormalFontWithSize(12);
    [scrollView addSubview:ideaLabel];
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return titleArr.count;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * mineCell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 280, 30)];
    mineCell.backgroundColor = kFontColorA;
    mineCell.selectedBackgroundView = [[UIView alloc] initWithFrame:mineCell.frame];
    mineCell.selectedBackgroundView.backgroundColor = KSelectNewColor;
    
    UIImageView * rightView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth -31, 20, 11, 20)];
    rightView.image = [UIImage imageNamed:@"jiantou-you"];
    rightView.backgroundColor = [UIColor clearColor];
    [mineCell addSubview:rightView];
    
    if (indexPath.row==0)
    {
        rightView.hidden = YES;
        mineCell.selectedBackgroundView.backgroundColor = kFontColorA;
    }
    else if (indexPath.row==1)
    {
        rightView.hidden = NO;
    }
    else if (indexPath.row==2)
    {
        rightView.hidden = NO;
    }
    else if (indexPath.row==3)
    {
        rightView.hidden = NO;
    }
    else if (indexPath.row == 4)
    {
        rightView.hidden = NO;
    }
    
    UILabel * title = [[UILabel alloc] init ];
    title.frame=CGRectMake(20, 0, 100, 60);
    title.backgroundColor = [UIColor clearColor];
    title.textColor = KFontColorE;
    title.font = NormalFontWithSize(14);
    title.text = [titleArr objectAtIndex:indexPath.row];
    [mineCell addSubview:title];
    
    UILabel * rightLabel = [[UILabel alloc] init];
    rightLabel.frame=CGRectMake(screenWidth - 120, 0, 100, 60);
    rightLabel.backgroundColor = [UIColor clearColor];
    rightLabel.textAlignment = NSTextAlignmentRight;
    rightLabel.font = NormalFontWithSize(14);
    if (indexPath.row == 0)
    {
        rightLabel.text = [NSString stringWithFormat:@"v%@(%@)", kAppVersion, kBuildVersion];
        rightLabel.textColor = KFontNewColorB;
    }
    else if (indexPath.row == 1)
    {
        rightLabel.textColor = KFontNewColorD;
    }
    [mineCell addSubview:rightLabel];
    
    UILabel * lineLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 59, screenWidth, 0.5)];
    lineLb.backgroundColor = KLineNewBGColor1;
    [mineCell addSubview:lineLb];
    
    if(indexPath.row == 4)
    {
        UILabel * lineLb2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 59.5, screenWidth, 0.5)];
        lineLb2.backgroundColor = KLineNewBGColor2;
        [mineCell addSubview:lineLb2];
    }
    
    return mineCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (indexPath.row == 0)
    {
        return;
    }
    else if (indexPath.row == ([GFStaticData getObjectForKey:kTagAppStoreClose]?1:0))
    {
        GFWebViewController * GWVC = [[GFWebViewController alloc] init];
        GWVC.title = @"版本介绍";
        GWVC.pageType = WebViewTypePresent;
        GWVC.flag = 0;
        GWVC.requestUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://m.aizhangzhang.com/html5/update_desc.html?client_version=%@&client_type=iOS",kAppVersion]];
        [self presentViewController:GWVC animated:YES completion:nil];
    }
    else if (indexPath.row == ([GFStaticData getObjectForKey:kTagAppStoreClose]?2:1))
    {
        GFWebViewController * GWVC = [[GFWebViewController alloc] init];
        GWVC.title = @"软件许可协议";
        GWVC.pageType = WebViewTypePresent;
        GWVC.flag = 0;
        GWVC.requestUrl = [NSURL URLWithString:SoftwareAgreementUrl];
        [self  presentViewController:GWVC animated:YES completion:nil];
    }
    else if (indexPath.row == ([GFStaticData getObjectForKey:kTagAppStoreClose]?3:2))
    {
        GFWebViewController * GWVC = [[GFWebViewController alloc] init];
        GWVC.title = @"交易规则";
        GWVC.pageType = WebViewTypePresent;
        GWVC.flag = 0;
        GWVC.requestUrl = [NSURL URLWithString:TradeRuleUrl];
        [self  presentViewController:GWVC animated:YES completion:nil];
    }
    else if (indexPath.row == ([GFStaticData getObjectForKey:kTagAppStoreClose]?4:3))
    {
        GFWebViewController * GWVC = [[GFWebViewController alloc] init];
        GWVC.title = @"帮助";
        GWVC.pageType = WebViewTypePresent;
        GWVC.flag = 0;
        GWVC.requestUrl = [NSURL URLWithString:HelpUrl];
        [self  presentViewController:GWVC animated:YES completion:nil];
    }
    [infoTableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
}

-(void)requestVerson
{
    [GFRequestManager connectWithDelegate:self action:Get_versions param:nil];
}

-(void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    
    ASIFormDataRequest * formdataRequest = (ASIFormDataRequest *)request;
    if ([formdataRequest.action isEqualToString:Get_versions])
    {
        NSDictionary * dic = [requestInfo objectForKey:@"data"];
        CGFloat currentVersion = [[dic objectForKey:@"version_number"] floatValue];
        versionURL = [[[dic objectForKey:@"url"] description] copy];
        if ([kAppVersion floatValue] < currentVersion)
        {
            isNewVerson = YES;
            [[CHNAlertView defaultAlertView] showContent:@"当前有新版本,请前往更新,以便于您更好的使用" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
        }
        else
        {
            isNewVerson = NO;
            [[CHNAlertView defaultAlertView] showContent:@"当前为最新版本" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
        }
    }
}

- (void)buttonClickedAtIndex:(NSInteger)index
{
    if (isNewVerson)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:versionURL]];
    }
    else
    {
        return;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
