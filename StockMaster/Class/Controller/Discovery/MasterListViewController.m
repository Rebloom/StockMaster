//
//  MasterListViewController.m
//  StockMaster
//
//  Created by Rebloom on 14-8-6.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "MasterListViewController.h"
#import "UIImageView+WebCache.h"
#import "ProfitCell.h"
#import "MasterwCell.h"

#define KTagIconView   1111
#define KTagNameLabel   2222
#define KTagRankNumLabel    3333
#define KTagProfitNumLabel  4445
#define KTagRankIv  5555
#define KTagProfitIv  6666

@interface MasterListViewController ()

@end

@implementation MasterListViewController

@synthesize pageType;

- (void)dealloc
{
    for (ASIFormDataRequest * request in [RequestQueue instance].requestList)
    {
        // 界面切换的时候，取消请求
        if ([request.action isEqualToString:Get_total_profit_rank]
            ||[request.action isEqualToString:Get_daily_profit_rank]
            ||[request.action isEqualToString:Get_daily_pathos_rank]
            ||[request.action isEqualToString:Get_seven_profit_rank]
            ||[request.action isEqualToString:Get_thirty_profit_rank]
            ||[request.action isEqualToString:Get_counterattack_rank])
        {
            [request cancel];
            request.delegate = nil;
        }
    }
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
    
    // 排行榜列表数据
    infoDic = [[NSMutableDictionary alloc] initWithCapacity:10];
    // 用户个人信息
    userDic = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    NSArray * titleArr = @[@"总收益榜",@"30日收益榜",@"7日收益榜",@"1日收益榜",@"1日悲情榜",@"逆袭榜"];
    
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, beginX+7, screenWidth, 25)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = [titleArr objectAtIndex:pageType];
    titleLabel.textColor = KFontNewColorA;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = NormalFontWithSize(17);
    [headerView addSubview:titleLabel];
    
    timeLabel = [[UILabel alloc] init];
    timeLabel.frame = CGRectMake(0, 50, screenWidth, 11);
    timeLabel.font = NormalFontWithSize(11);
    timeLabel.text = @"更新时间：";
    timeLabel.textColor = KFontNewColorB;
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.backgroundColor = [UIColor clearColor];
    [headerView addSubview:timeLabel];
    
    [headerView backButton];
    [headerView createLine];
    headerView.backgroundColor = kFontColorA;
    [headerView setStatusBarColor:kFontColorA];
    self.view.backgroundColor = KSelectNewColor;
    
    infoTable = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, screenHeight-headerView.frame.size.height)];
    infoTable.backgroundColor = KSelectNewColor;
    infoTable.dataSource = self;
    infoTable.delegate = self;
    infoTable.separatorStyle = NO;
    [self.view addSubview:infoTable];
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 0.1)];
    infoTable.tableFooterView = footView;
    [infoTable reloadData];
    
    [self createHeaderView];
    
    [self requestMasterList];
}

// 初始化头部布局
-(void)createHeaderView
{
    headView = [[UIView alloc] init];
    headView.userInteractionEnabled =YES;
    headView.frame = CGRectMake(0, 0, screenWidth, 160);
    headView.backgroundColor = kFontColorA;
    infoTable.tableHeaderView = headView;
    
    UIImageView * iconView = [[UIImageView alloc] init];
    iconView.frame =CGRectMake(20, 40, 80, 80);
    iconView.layer.cornerRadius = 40;
    iconView.layer.masksToBounds =YES;
    iconView.tag = KTagIconView;
    iconView.image = [UIImage imageNamed:@"icon_user_default"];
    [headView addSubview:iconView];
    
    UILabel * nameLabel = [[UILabel alloc] init];
    nameLabel.frame = CGRectMake(CGRectGetMaxX(iconView.frame) +30, 46, 100, 20);
    nameLabel.text = @"";
    nameLabel.tag = KTagNameLabel ;
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.textColor = KFontNewColorA;
    nameLabel.font = NormalFontWithSize(16);
    [headView addSubview:nameLabel];
    
    UILabel * profitNumLabel  = [[UILabel alloc] init];
    profitNumLabel.frame = CGRectMake(CGRectGetMaxX(iconView.frame)+30 , CGRectGetMaxY(nameLabel.frame)+10, 90, 20);
    profitNumLabel.text = @"";
    profitNumLabel.tag = KTagProfitNumLabel;
    profitNumLabel.textAlignment = NSTextAlignmentLeft;
    profitNumLabel.textColor = KFontNewColorA;
    profitNumLabel.font = NormalFontWithSize(20);
    [headView addSubview:profitNumLabel];
    
    UILabel * profitLabel  = [[UILabel alloc] init];
    profitLabel.frame = CGRectMake(CGRectGetMaxX(iconView.frame)+30 , CGRectGetMaxY(profitNumLabel.frame)+10, 80, 20);
    if (pageType == 0)
    {
        profitLabel.text = @"总收益率";
    }
    else if (pageType == 1)
    {
        profitLabel.text = @"30日收益率";
    }
    else if (pageType == 2)
    {
        profitLabel.text = @"7日收益率";
    }
    else if (pageType == 3)
    {
        profitLabel.text = @"1日收益率";
    }
    else if (pageType == 4)
    {
        profitLabel.text = @"1日收益率";
    }
    profitLabel.textAlignment = NSTextAlignmentLeft;
    profitLabel.textColor = KFontNewColorB;
    profitLabel.font = NormalFontWithSize(13);
    [headView addSubview:profitLabel];
    
    UIImageView * profitIv = [[UIImageView alloc] init];
    if (pageType == 0)
    {
        profitIv.frame = CGRectMake(CGRectGetMaxX(profitLabel.frame)-25, CGRectGetMidY(profitLabel.frame)-5 , 6, 10);
    }
    else if (pageType == 1)
    {
        profitIv.frame = CGRectMake(CGRectGetMaxX(profitLabel.frame)-10, CGRectGetMidY(profitLabel.frame)-5 , 6, 10);
    }
    else
    {
        profitIv.frame = CGRectMake(CGRectGetMaxX(profitLabel.frame)-15, CGRectGetMidY(profitLabel.frame)-5 , 6, 10);
    }
    profitIv.tag = KTagProfitIv;
    profitIv.image = [UIImage imageNamed:@""];
    [headView addSubview: profitIv];
    
    UILabel * rankNumLabel  = [[UILabel alloc] init];
    rankNumLabel.frame = CGRectMake(CGRectGetMaxX(profitNumLabel.frame)+10 , CGRectGetMaxY(nameLabel.frame)+10, 80, 20);
    rankNumLabel.text = @" ";
    rankNumLabel.tag = KTagRankNumLabel;
    rankNumLabel.textAlignment = NSTextAlignmentLeft;
    rankNumLabel.textColor = KFontNewColorA;
    rankNumLabel.font = NormalFontWithSize(20);
    [headView addSubview:rankNumLabel];
    
    UILabel * rankLabel  = [[UILabel alloc] init];
    rankLabel.frame = CGRectMake(CGRectGetMinX(rankNumLabel.frame) , CGRectGetMaxY(rankNumLabel.frame)+10, 50, 20);
    rankLabel.text = @"排名";
    rankLabel.textAlignment = NSTextAlignmentLeft;
    rankLabel.textColor = KFontNewColorB;
    rankLabel.font = NormalFontWithSize(13);
    [headView addSubview:rankLabel];
    
    UIImageView * rankIv = [[UIImageView alloc] init];
    rankIv.frame = CGRectMake(CGRectGetMaxX(rankLabel.frame)-15, CGRectGetMidY(rankLabel.frame)-5, 6, 10);
    rankIv.tag = KTagRankIv;
    rankIv.image = [UIImage imageNamed:@""];
    [headView addSubview: rankIv];
    
    UILabel * lineLb2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 168, screenWidth, 0.5)];
    lineLb2.backgroundColor = KLineNewBGColor3;
    [headView addSubview:lineLb2];
    
    UILabel * lineLb3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 168.5, screenWidth, 0.5)];
    lineLb3.backgroundColor = KLineNewBGColor4;
    [headView addSubview:lineLb3];
    
    UIButton * selfBtn = [[UIButton alloc] init];
    selfBtn.frame = CGRectMake(0, 0, screenWidth, 160);
    selfBtn.backgroundColor = [UIColor clearColor];
    [selfBtn addTarget:self action:@selector(selfBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:selfBtn];
}

// 请求榜单信息（根据不同的页面参数）
- (void)requestMasterList
{
    NSString * action = @"";
    switch (pageType) {
        case 0:
            action = Get_total_profit_rank;
            break;
        case 1:
            action = Get_thirty_profit_rank;
            break;
        case 2:
            action = Get_seven_profit_rank ;
            break;
        case 3:
            action = Get_daily_profit_rank ;
            break;
        case 4:
            action = Get_daily_pathos_rank;
            break;
        case 5:
            action = Get_counterattack_rank;
            break;
            
        default:
            break;
    }
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [GFRequestManager connectWithDelegate:self action:action param:param];
}

// 请求成功
- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    [infoTable reloadInputViews];
    ASIFormDataRequest * formDataRequest = (ASIFormDataRequest *)request;
    if ([formDataRequest.action isEqualToString:Get_total_profit_rank]
        ||[formDataRequest.action isEqualToString:Get_daily_profit_rank]
        ||[formDataRequest.action isEqualToString:Get_daily_pathos_rank]
        ||[formDataRequest.action isEqualToString:Get_seven_profit_rank]
        ||[formDataRequest.action isEqualToString:Get_thirty_profit_rank]
        ||[formDataRequest.action isEqualToString:Get_counterattack_rank])
    {
        infoDic = [[requestInfo objectForKey:@"data"] mutableCopy];
        userDic = [[infoDic objectForKey:@"user_rank"] mutableCopy];
        [self deliverDict:infoDic];
    }
    
    [infoTable reloadData];
}

// 处理返回数据
-(void)deliverDict:(NSMutableDictionary*)dictionary
{
    NSDictionary * dict = [dictionary objectForKey:@"user_rank"];
    if (dict.count>0)
    {
        UILabel * nameLabel = (UILabel*)[headView viewWithTag:KTagNameLabel];
        UILabel * rankNumLabel = (UILabel*)[headView viewWithTag:KTagRankNumLabel];
        UILabel * profitNumLabel = (UILabel*)[headView viewWithTag:KTagProfitNumLabel];
        UIImageView * iconView = (UIImageView*)[headView viewWithTag:KTagIconView];
        UIImageView * profitIv = (UIImageView*)[headView viewWithTag:KTagProfitIv];
        UIImageView * rankIv = (UIImageView*) [headView viewWithTag:KTagRankIv];
        
        timeLabel.text =[NSString stringWithFormat:@"更新时间：%@",[[dict objectForKey:@"update_time"]description]];
        nameLabel.text = [dict objectForKey:@"nickname"];
        rankNumLabel.text = [[dict objectForKey:@"rank"] description];
        profitNumLabel.text = [[dict objectForKey:@"profit_rate"] description];
        [iconView sd_setImageWithURL:[NSURL URLWithString:[[dict objectForKey:@"head"] description]]
                    placeholderImage:[UIImage imageNamed:@"icon_user_default"]
                             options:SDWebImageRefreshCached];
        if ([[dict objectForKey:@"profit_updown"] isEqualToString:@"up"])
        {
            [profitIv setImage:[UIImage imageNamed:@"icon_xiangshang2"]];
        }
        else
        {
            [profitIv setImage:[UIImage imageNamed:@"icon_xiangxia2"]];
        }
        
        if ([[dict objectForKey:@"rank_updown"] isEqualToString:@"up"])
        {
            [rankIv setImage:[UIImage imageNamed:@"icon_xiangshang2"]];
        }
        else
        {
            [rankIv setImage:[UIImage imageNamed:@"icon_xiangxia2"]];
        }
    }
}

// 请求失败
- (void)requestFailed:(ASIHTTPRequest *)request
{
    [super requestFailed:request];
    [infoTable reloadInputViews];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[infoDic objectForKey:@"rank_list"] count]+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 134;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * picArr = @[@"icon_diyi",@"icon_dier",@"icon_disan"];
    static NSString * cellIDT = @"NORMALCELL";
    
    MasterwCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIDT];
    cell.backgroundColor = kFontColorA;
    
    NSMutableArray * infoArr = [infoDic objectForKey:@"rank_list"];
    
    if (!cell)
    {
        cell = [[MasterwCell alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 134)];
    }
    
    if (indexPath.row == infoArr.count)
    {
        if (infoArr.count == 0)
        {
            cell.allLoadLabel.text = @"加载中...";
        }
        else
        {
            cell.backgroundColor = [UIColor clearColor];
            UIImageView * iconImgView = [[UIImageView alloc] init];
            iconImgView.frame = CGRectMake(screenWidth/2-15, 42, 30, 23);
            iconImgView.image = [UIImage imageNamed:@"zhangzhang"];
            [cell addSubview:iconImgView];
            
            UILabel * ideaLabel = [[UILabel alloc] init];
            ideaLabel.frame = CGRectMake(0,CGRectGetMaxY(iconImgView.frame)+10, screenWidth, 12);
            ideaLabel.text = @"免费炒股，大赚真钱";
            ideaLabel.textAlignment = NSTextAlignmentCenter;
            ideaLabel.textColor = KFontNewColorC;
            ideaLabel.font = NormalFontWithSize(12);
            [cell addSubview:ideaLabel];
        }
        return cell;
    }
    
    if (indexPath.row<infoArr.count) {
        NSDictionary * dic = [infoArr objectAtIndex:indexPath.row];
        if (indexPath.row<3) {
            UIImageView * rankIv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[picArr objectAtIndex:indexPath.row]]];
            rankIv.frame = CGRectMake(20, 52, 23,33);
            [cell addSubview:rankIv];
        }else{
            cell.rankLabel.textColor = kTitleColorA;
            cell.rankLabel.text = [[NSString stringWithFormat:@"%d", (int)indexPath.row+1] description];
        }
        
        NSString * iconUrlStr = CHECKDATA(@"head");
        if (iconUrlStr.length)
        {
            [cell.icoImage sd_setImageWithURL:[NSURL URLWithString:[[dic objectForKey:@"head"] description]]
                             placeholderImage:[UIImage imageNamed:@"icon_user_default"]
                                      options:SDWebImageRefreshCached];
        }
        else
        {
            cell.icoImage.image = [UIImage imageNamed:@"icon_user_default"];
        }
        
        NSString * nickName = CHECKDATA(@"nickname");
        if ([Utility lenghtWithString:nickName] > 14)
        {
            for (int i = 0; i < nickName.length; i++)
            {
                NSString * apartStr = [nickName substringToIndex:i];
                // 汉字字符集
                NSString * pattern  = @"[\u4e00-\u9fa5]";
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
                // 计算中文字符的个数
                NSInteger numMatch = [regex numberOfMatchesInString:apartStr options:NSMatchingReportProgress range:NSMakeRange(0, apartStr.length)];
                if (apartStr.length+numMatch == 14)
                {
                    nickName = [NSString stringWithFormat:@"%@...",apartStr];
                    break;
                }
            }
        }
        cell.name.text = nickName;
        if (pageType == 0)
        {
            cell.profit.text = @"总收益率: ";
            cell.profitDetail.frame = CGRectMake(CGRectGetMaxX(cell.profit.frame)-40, CGRectGetMinY(cell.profit.frame), screenWidth-120, 20);
        }
        else if (pageType == 1)
        {
            cell.profit.text = @"30日收益率: ";
            cell.profitDetail.frame = CGRectMake(CGRectGetMaxX(cell.profit.frame)-20, CGRectGetMinY(cell.profit.frame),  screenWidth-120, 20);
        }
        else if (pageType == 2)
        {
            cell.profit.text = @"7日收益率: ";
            cell.profitDetail.frame = CGRectMake(CGRectGetMaxX(cell.profit.frame)-30, CGRectGetMinY(cell.profit.frame),  screenWidth-120, 20);
        }
        else if (pageType == 3)
        {
            cell.profit.text = @"1日收益率: ";
            cell.profitDetail.frame = CGRectMake(CGRectGetMaxX(cell.profit.frame)-30, CGRectGetMinY(cell.profit.frame),  screenWidth-120, 20);
        }
        else if (pageType == 4)
        {
            cell.profit.text = @"1日最低收益率: ";
            cell.profitDetail.frame = CGRectMake(CGRectGetMaxX(cell.profit.frame), CGRectGetMinY(cell.profit.frame),  screenWidth-120, 20);
        }
        cell.profitDetail.text = [[dic objectForKey:@"profit_rate"] description];
        if ([[dic objectForKey:@"stock_code"] description].length>0)
        {
            cell.holdLb.text = [NSString stringWithFormat:@"最新买入: %@(%@)",[dic objectForKey:@"stock_name"],[dic objectForKey:@"stock_code"]];
        }
        else
        {
            cell.holdLb.text = [NSString stringWithFormat:@"最新买入: 暂无"];
        }
        
        [cell addSubview:cell.rightView];
        [cell addSubview:cell.lineLb];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray * infoArr = [infoDic objectForKey:@"rank_list"];
    if (indexPath.row < infoArr.count)
    {
        MasterDetailViewController * MDVC = [[MasterDetailViewController alloc] init];
        MDVC.passDic = [infoArr objectAtIndex:indexPath.row];
        MDVC.showUid = [[[infoArr objectAtIndex:indexPath.row] objectForKey:@"uid"] copy];
        [self pushToViewController:MDVC];
    }
}

// 去用户详情页面
-(void)selfBtnOnClick:(UIButton *)sender
{
    NSMutableArray * infoArr = [infoDic objectForKey:@"rank_list"];
    
    MasterDetailViewController * MDVC = [[MasterDetailViewController alloc] init];
    MDVC.passDic = [infoArr objectAtIndex:0];
    MDVC.showUid = [[userDic objectForKey:@"uid"] copy];
    [self pushToViewController:MDVC];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end