//
//  ThirdViewController.m
//  StockMaster
//
//  Created by Rebloom on 14-7-22.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "ThirdViewController.h"
#import "StockMarketViewController.h"
#import "ShakeViewController.h"
#import "MasterViewController.h"
#import "PlateViewController.h"
#import "SearchViewController.h"
#import "SubSectionViewController.h"
#import "StockLineViewController.h"
#import "LoginViewController.h"
#import "StockDetailViewController.h"

#define KUpdownPriceTag 3000
#define KUpdownRangeTag 4000

@interface ThirdViewController ()
{
    UIImage *defaultImage;
}

@end

@implementation ThirdViewController
@synthesize hotPlateArr;
@synthesize radarArr;

- (void)dealloc
{
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [thirdTimer invalidate];
    
    [super viewWillDisappear:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self requestData];
    
    thirdTimer = [NSTimer scheduledTimerWithTimeInterval:12 target:self  selector:@selector(requestAutoRefresh) userInfo:nil repeats:YES];
    [infoTable scrollRectToVisible:CGRectMake(0, 0, screenWidth, infoTable.frame.size.height) animated:YES];
    
    // 诸葛统计（查看发现页）
    [[Zhuge sharedInstance] track:@"查看发现页" properties:nil];
}

// 获取指数行情数据、热门板块数据
- (void)requestData
{
    [self requestMarket];
    [self requestHotPlate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = KSelectNewColor;
    
    hrefArr = [[NSMutableArray alloc] initWithCapacity:10];
    hotPlateArr = [[[StockInfoCoreDataStorage sharedInstance] getHotPlate] copy];
    headerArr = [[[StockInfoCoreDataStorage sharedInstance] getIndexQuotation] copy];
    
    headerView.backgroundColor = kFontColorA;
    headerView.alpha = 0;
    [headerView createLine];
    
    UILabel * searchLabel = [[UILabel alloc] init];
    searchLabel.frame = CGRectMake(14, beginX+10, screenWidth -30, 30);
    searchLabel.layer.cornerRadius = 4;
    searchLabel.font = NormalFontWithSize(14);
    searchLabel.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    searchLabel.layer.borderWidth = 0.4;
    searchLabel.backgroundColor = [UIColor clearColor];
    searchLabel.textColor = @"#d6d6d6".color;
    searchLabel.text = @"      请输入股票代码/首字母/汉字";
    [headerView addSubview:searchLabel];
    
    UIImageView * headSearchImg = [[UIImageView alloc] initWithFrame:CGRectMake(15, 7, 17, 17)];
    headSearchImg.image = [UIImage imageNamed:@"icon_search"];
    [searchLabel addSubview:headSearchImg];
    
    UIButton * headSearchBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 51)];
    [headSearchBtn addTarget:self action:@selector(searchBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:headSearchBtn];
    
    is_tradable = YES;
    is_request_by = YES;
    
    infoTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    infoTable.backgroundColor = kBackgroundColor;
    infoTable.dataSource = self;
    infoTable.delegate = self;
    infoTable.separatorStyle = NO;
    [self.view addSubview:infoTable];
    [self createFootView];
    
    
    refreshFlag = 0;
    
    //下拉刷新
    if (!refreshview)
    {
        refreshview = [[EGORefreshTableHeaderView alloc] initWithFrame: CGRectMake(0, -65, screenWidth, 65)];
        refreshview.delegate = self;
        [infoTable addSubview:refreshview];
    }
    [self createTableHeader];
}

//创建自定义头部
- (void)createTableHeader
{
    backImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, HeaderViewHeight)];
    defaultImage = [UIImage imageNamed:@"faxian2"];
    backImage.image = defaultImage;
    backImage.userInteractionEnabled = YES;
    
    imageBtn = [[UIButton alloc] init];
    imageBtn.frame = CGRectMake(0, 0, screenWidth, HeaderViewHeight-47);
    [imageBtn setBackgroundColor:[UIColor clearColor]];
    [imageBtn addTarget:self action:@selector(imageBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [backImage addSubview:imageBtn];
    
    thirdHeader = [[UIView alloc] initWithFrame:CGRectMake(0, HeaderViewHeight-47, screenWidth,47)];
    thirdHeader.backgroundColor = @"#f57c76".color;
    [backImage addSubview:thirdHeader];
    thirdHeader.alpha = 1;
    
    UIImageView * searchImage = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 17, 17)];
    searchImage.image = [UIImage imageNamed:@"icon_search"];
    [thirdHeader addSubview:searchImage];
    
    UILabel * searchLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(searchImage.frame)+10, 0, screenWidth-15, 47)];
    searchLabel.backgroundColor = [UIColor clearColor];
    searchLabel.font = NormalFontWithSize(13);
    searchLabel.textColor = @"#ffffff".color;
    searchLabel.text = @"股票代码/首字母/汉字";
    [thirdHeader addSubview:searchLabel];
    
    UIButton * searchStockBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 47)];
    [searchStockBtn addTarget:self action:@selector(searchBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [thirdHeader addSubview:searchStockBtn];
    
    infoTable.tableHeaderView = backImage;
}

- (void)imageBtnOnClick:(UIButton*)sender
{
    NSDictionary * dict = [hrefArr objectAtIndex:0];
    if (![[dict objectForKey:@"href"] isEqualToString:@""]&&[dict objectForKey:@"href"])
    {
        GFWebViewController * GWVC = [[GFWebViewController alloc] init];
        GWVC.title = [dict objectForKey:@"href_title"];
        GWVC.pageType = WebViewTypePresent;
        GWVC.flag = 0;
        GWVC.requestUrl = [NSURL URLWithString:[dict objectForKey:@"href"]];
        [self  presentViewController:GWVC animated:YES completion:nil];
    }
}

// 获取指数行情数据
- (void)requestMarket
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:@"1" forKey:@"request_by"];
    [GFRequestManager connectWithDelegate:self action:Get_stock_index_quotation param:paramDic];
}

// 获取热门板块数据
- (void)requestHotPlate
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:@"1" forKey:@"request_by"];
    [GFRequestManager connectWithDelegate:self action:Get_index_hot_plate param:paramDic];
}

- (void)requestAutoRefresh
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:@"2" forKey:@"request_by"];
    [GFRequestManager connectWithDelegate:self action:Get_stock_index_quotation param:paramDic];
    
    
    NSMutableDictionary * paramDictionary = [NSMutableDictionary dictionary];
    [paramDictionary setObject:@"2" forKey:@"request_by"];
    [GFRequestManager connectWithDelegate:self action:Get_index_hot_plate param:paramDictionary];
}

- (void)requestRadarAction:(NSString*) action withStart_id:(NSString*)start_id
{
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setObject:action forKey:@"action"];
    [param setObject:start_id forKey:@"start_id"];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    //结束下拉刷新
    isEgoRefresh = NO;
    [refreshview egoRefreshScrollViewDataSourceDidFinishedLoading:infoTable];
    
    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:2];
    
    ASIFormDataRequest * formdataRequest = (ASIFormDataRequest *)request;
    if ([formdataRequest.action isEqualToString:Get_index_hot_plate])
    {
        NSDictionary * data = [requestInfo objectForKey:@"data"];
        NSArray * plateArr  = [data objectForKey:@"plate_list"];
        [[StockInfoCoreDataStorage sharedInstance] saveHotPlate:plateArr];
        hotPlateArr = [[StockInfoCoreDataStorage sharedInstance] getHotPlate];
        
        hrefArr = [[data objectForKey:@"image_list"] mutableCopy];
        NSString * imageUrl = [[[data objectForKey:@"image_list"] firstObject] objectForKey:@"image_url"];
        [backImage sd_setImageWithURL:[NSURL URLWithString:imageUrl]
                     placeholderImage:defaultImage
                              options:SDWebImageRefreshCached
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                if (nil == error) {
                                    defaultImage = image;
                                }
                            }];
        
        NSInteger tradable = 0;
        if (plateArr.count > 0)
        {
            NSDictionary * plateDict = [plateArr firstObject];
            tradable = [[plateDict objectForKey:@"is_tradable"] integerValue];
        }
        
        if (tradable == 0)
        {
            [thirdTimer pauseTimer];
        }

    }
    else if ([formdataRequest.action isEqualToString:Get_stock_radar_list])
    {
        // refreshFlag = 0 时是第一次加载数据 和 下拉刷新
        // refreshFlag = 1 时是局部加载
        if (refreshFlag == 0)
        {
            if ([radarArr count])
            {
                [radarArr removeAllObjects];
            }
            radarArr = [[requestInfo objectForKey:@"data"] mutableCopy];
            footView.hidden =YES;
            infoTable.tableFooterView = nil;
        }
        else if(refreshFlag == 1)
        {
            //插入  将新数据插再数组前面
            NSMutableArray * temp = [[requestInfo objectForKey:@"data"] mutableCopy];
            if (temp.count>0)
            {
                footView.hidden = YES;
                infoTable.tableFooterView = nil;
                for (int i = 0;i < temp.count; i++)
                {
                    [radarArr addObject:[temp objectAtIndex:i]];
                }
            }
            else
            {
                footView.hidden = NO;
                infoTable.tableFooterView = footView;
            }
        }
    }
    else if ([formdataRequest.action isEqualToString:Get_stock_index_quotation])
    {
        NSArray * tempArr = [requestInfo objectForKey:@"data"];
        [[StockInfoCoreDataStorage sharedInstance] saveIndexQuotation:tempArr];
        headerArr = [[[StockInfoCoreDataStorage sharedInstance] getIndexQuotation] copy];
    }
    [infoTable reloadData];
}

// 添加tableview底部数据
- (void)createFootView
{
    footView = [[UIView alloc] init];
    footView.frame = CGRectMake(0, 0, screenWidth, 156);
    footView.backgroundColor = [UIColor clearColor];
    
    infoTable.tableFooterView = footView;
    
    UILabel * ideaLabel = [[UILabel alloc] init];
    ideaLabel.frame = CGRectMake(0,footView.frame.size.height-90, screenWidth, 12);
    ideaLabel.text = @"免费炒股，大赚真钱";
    ideaLabel.textAlignment = NSTextAlignmentCenter;
    ideaLabel.textColor = KFontNewColorC;
    ideaLabel.font = NormalFontWithSize(12);
    [footView addSubview:ideaLabel];
    
    UIImageView * iconImgView = [[UIImageView alloc] init];
    iconImgView.frame = CGRectMake(screenWidth/2-15, CGRectGetMinY(ideaLabel.frame) - 33, 30, 23);
    iconImgView.image = [UIImage imageNamed:@"zhangzhang"];
    [footView addSubview:iconImgView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    else if(section == 1)
    {
        return 1;
    }
    else if (section == 2)
    {
        return 3;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 2)
    {
        return 42;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 84;
    }
    else if (indexPath.section == 1)
    {
        return 90;
    }
    return 80;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    view.frame = CGRectMake(0, 0, screenWidth, 46);
    view.userInteractionEnabled = YES;
    
    UILabel * nameLabel = [[UILabel alloc] init];
    nameLabel.frame = CGRectMake(15, 30, 200, 16);
    nameLabel.text = @"热门板块";
    nameLabel.textColor = @"#929292".color;
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.font = NormalFontWithSize(16);
    [view addSubview:nameLabel];
    
    UIImageView * rightView = [[UIImageView alloc] init];
    rightView.image = [UIImage imageNamed:@"icon_discovery_right"];
    rightView.frame = CGRectMake(screenWidth-26, 29, 9, 16);
    [view addSubview:rightView];
    
    UIButton * bkBtn = [[UIButton alloc] init];
    bkBtn.frame = CGRectMake(0, 0, screenWidth, 46);
    [bkBtn setBackgroundColor: [UIColor clearColor]];
    [bkBtn addTarget:self action:@selector(bkBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:bkBtn];
    
    return view;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 130)];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setBackgroundColor:kFontColorA];
    
    if(indexPath.section == 0)
    {
        cell.backgroundColor = @"#f5f5f5".color;
        NSArray * nameArray = @[@"股票排行",@"股神排行",@"抖一抖"];
        
        for (int i = 0; i<3; i++) {
            UILabel * contentLabel = [[UILabel alloc]init];
            contentLabel.frame = CGRectMake(i*screenWidth/3, 84-28, screenWidth/3, 15);
            contentLabel.textAlignment = NSTextAlignmentCenter;
            contentLabel.textColor = KFontNewColorA;
            contentLabel.font = NormalFontWithSize(13);
            contentLabel.text = [nameArray objectAtIndex:i];
            [cell addSubview:contentLabel];
            
            UIButton * btn = [[UIButton alloc] init];
            btn.frame = CGRectMake(i*screenWidth/3, 0, screenWidth/3, 130);
            btn.tag = 1000+i;
            [btn addTarget:self action:@selector(firstOnClick:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:btn];
            
            UIImageView * iconIv = [[UIImageView alloc] init];
            if (i == 0)
            {
                iconIv.frame = CGRectMake(34.5, 33, 30, 30);
            }
            else if (i == 1)
            {
                iconIv.frame = CGRectMake(140.5, 33, 30, 30);
            }
            else if (i == 2)
            {
                iconIv.frame = CGRectMake(247.5, 33, 30, 30);
            }
            iconIv.center = CGPointMake(contentLabel.center.x, 30);
            iconIv.image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_third_%d",i+1]];
            [cell addSubview:iconIv];
            
            UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, 83.5, screenWidth, .5)];
            line.backgroundColor = @"#e2e2e2".color;
            [cell addSubview:line];
        }
    }
    else if (indexPath.section == 1)
    {
        for (int i = 0; i<2; i++ ) {
            UILabel * lineLabel = [[UILabel alloc] init];
            lineLabel.frame = CGRectMake(screenWidth/3*(i+1), 15, 0.5, 60);
            lineLabel.backgroundColor = KColorHeader;
            [cell addSubview:lineLabel];
        }
        for (int i = 0; i < 3; i++)
        {
            UILabel * szLb = [[UILabel alloc] init];
            szLb.frame = CGRectMake(screenWidth/3*i, 17, screenWidth/3, 13);
            szLb.backgroundColor = [UIColor clearColor];
            szLb.textColor =KFontNewColorA;
            szLb.font = NormalFontWithSize(13);
            szLb.textAlignment = NSTextAlignmentCenter;
            [cell addSubview:szLb];
            
            UILabel * szDataLb = [[UILabel alloc] init];
            szDataLb.frame = CGRectMake(screenWidth/3*i, CGRectGetMaxY(szLb.frame)+11, screenWidth/3, 16);
            szDataLb.backgroundColor = [UIColor clearColor];
            szDataLb.textAlignment = NSTextAlignmentCenter;
            szDataLb.font = NormalFontWithSize(16);
            [cell addSubview:szDataLb];
            
            UILabel * updown_priceLabel = [[UILabel alloc] init];
            updown_priceLabel.frame = CGRectMake(screenWidth/3*i, CGRectGetMaxY(szDataLb.frame)+10, screenWidth/3, 10);
            updown_priceLabel.font = NormalFontWithSize(10);
            updown_priceLabel.tag =KUpdownPriceTag +i;
            updown_priceLabel.textAlignment = NSTextAlignmentCenter;
            updown_priceLabel.backgroundColor = [UIColor clearColor];
            [cell addSubview:updown_priceLabel];
            
            UIButton * headerBtn = [[UIButton alloc] initWithFrame:CGRectMake(i*screenWidth/3, 0, screenWidth/3, 130)];
            [headerBtn addTarget:self action:@selector(indexBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            headerBtn.tag = i;
            [cell addSubview:headerBtn];
            
            if (headerArr.count>0)
            {
                IndexQuotationEntity * indexQuatation = [headerArr objectAtIndex:i];
                
                szDataLb.text = indexQuatation.currentPrice;
                szLb.text =  indexQuatation.name;

                NSString * updown_price = indexQuatation.updownPrice;
                NSString * updown_range = indexQuatation.updownRange;
                
                NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@  %@",updown_price,updown_range]];

                if ([indexQuatation.updown isEqualToString:@"up"])
                {
                    szDataLb.textColor = kRedColor;
                    updown_priceLabel.textColor = kRedColor;
                    [str addAttribute:NSForegroundColorAttributeName value:kRedColor range:NSMakeRange(0,updown_price.length)];
                    
                    [str addAttribute:NSForegroundColorAttributeName value:kRedColor range:NSMakeRange(updown_price.length+2,updown_range.length)];
                }
                else if ([indexQuatation.updown isEqualToString:@"down"])
                {
                    szDataLb.textColor = kGreenColor;
                    updown_priceLabel.textColor = kGreenColor;
                    [str addAttribute:NSForegroundColorAttributeName value:kGreenColor range:NSMakeRange(0,updown_price.length)];
                    
                    [str addAttribute:NSForegroundColorAttributeName value:kGreenColor range:NSMakeRange(updown_price.length,updown_range.length)];
                }
                
                [str addAttribute:NSFontAttributeName value:NormalFontWithSize(10) range:NSMakeRange(0,updown_price.length)];
                [str addAttribute:NSFontAttributeName value:NormalFontWithSize(10) range:NSMakeRange(updown_price.length,updown_range.length)];
                
                updown_priceLabel.attributedText = str;
            }
        }
        UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, 89.5, screenWidth, .5)];
        line.backgroundColor = @"#e2e2e2".color;
        [cell addSubview:line];
    }
    else if (indexPath.section == 2)
    {
        if (!hotPlateArr.count)
        {
            return [[UITableViewCell alloc] initWithFrame:CGRectZero];
        }
        for (int i = 0; i < 3; i++)
        {
            HotPlateEntity * hotPlate = [hotPlateArr objectAtIndex:indexPath.row*3+i];
            
            UILabel * nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/3*i, 20, screenWidth/3, 13)];
            nameLabel.backgroundColor = [UIColor clearColor];
            nameLabel.textAlignment = NSTextAlignmentCenter;
            nameLabel.font = NormalFontWithSize(13);
            nameLabel.textColor = @"#494949".color;
            nameLabel.text = hotPlate.plateInfo.name;
            [cell addSubview:nameLabel];
            
            UILabel * rangeLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/3*i, CGRectGetMaxY(nameLabel.frame)+10, screenWidth/3, 15)];
            rangeLabel.backgroundColor = [UIColor clearColor];
            rangeLabel.textAlignment = NSTextAlignmentCenter;
            rangeLabel.font = NormalFontWithSize(15);
            if ([hotPlate.plateInfo.updownRange componentsSeparatedByString:@"-"].count > 1)
            {
                rangeLabel.textColor = kGreenColor;
            }
            else
            {
                rangeLabel.textColor = kRedColor;
            }
            rangeLabel.text = hotPlate.plateInfo.updownRange;
            [cell addSubview:rangeLabel];
            
            UIButton * listenBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth/3*i, 0, screenWidth/3, 80)];
            [listenBtn addTarget:self action:@selector(smallBKBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
            listenBtn.tag = 10000+indexPath.row*3+i;
            [cell addSubview:listenBtn];
            
            if (i != 0)
            {
                UIView * lineV = [[UIView alloc] initWithFrame:CGRectMake(screenWidth/3*i, 15, .5, 50)];
                lineV.backgroundColor = @"#e2e2e2".color;
                [cell addSubview:lineV];
            }
            
        }
        UIView * lineH = [[UIView alloc] initWithFrame:CGRectMake(15, 79.5, screenWidth, .5)];
        lineH.backgroundColor = @"#e2e2e2".color;
        if (indexPath.row == 2)
        {
            lineH.frame = CGRectMake(0, 79.5, screenWidth, .5);
        }
        [cell addSubview:lineH];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self judgeCanShow];
}

// 去股票榜、股神榜还是抖一抖
- (void)firstOnClick:(UIButton *)sender
{
    if ([self judgeCanShow])
    {
        if (sender.tag == 1000)
        {
            StockMarketViewController * SMVC = [[StockMarketViewController alloc] init];
            [self pushToViewController:SMVC];
        }
        else if (sender.tag == 1001)
        {
            MasterViewController * MVC = [[MasterViewController alloc] init];
            [self pushToViewController:MVC];
        }
        else if (sender.tag == 1002)
        {
            ShakeViewController * SVC = [[ShakeViewController alloc] init];
            [self pushToViewController:SVC];
        }
    }
}

// 下拉刷新停止复位
- (void)stopLoading
{
    refreshView.hidden = NO;
}

// 去热门板块选择页
- (void)bkBtnOnClick:(UIButton *)sender
{
    if ([self judgeCanShow]) {
        PlateViewController * PVC = [[PlateViewController alloc] init];
        [self pushToViewController:PVC];
    }
}

// 去小版块详情页
-(void)smallBKBtnOnClick:(UIButton*)sender
{
    if ([self judgeCanShow])
    {
        NSInteger i = sender.tag - 10000;
        SubSectionViewController * SSVC = [[SubSectionViewController alloc] init];
        if (hotPlateArr.count>0)
        {
            HotPlateEntity * hotPlate = [hotPlateArr objectAtIndex:i];
            SSVC.plate_code = [hotPlate.plateInfo.code copy];
            SSVC.plate_name = [hotPlate.plateInfo.name copy];
        }
        [self pushToViewController:SSVC];
    }
}

// 去指数的详情页面
-(void)indexBtnClicked:(UIButton*)sender
{
    if ([self judgeCanShow])
    {
        UIButton * btn = (UIButton *)sender;
        if (headerArr.count > btn.tag)
        {
            IndexQuotationEntity * indexQuotation = [headerArr objectAtIndex:btn.tag];
            StockInfoEntity * stockInfo = [[StockInfoCoreDataStorage sharedInstance] getStockInfoWithCode:indexQuotation.code exchange:indexQuotation.exchange];

            if (stockInfo.code && stockInfo.exchange)
            {
                StockDetailViewController * SDVC = [[StockDetailViewController alloc] init];
                SDVC.stockInfo = stockInfo;
                [self pushToViewController:SDVC];
            }
        }
    }
}

// 去搜索页面
-(void)searchBtnClicked:(UIButton*)sender
{
    if ([self judgeCanShow]) {
        SearchViewController * SVC = [[SearchViewController alloc] init];
        [self.navigationController pushViewController:SVC animated:NO];
    }
}

// 判断是否需要登录
- (BOOL)judgeCanShow
{
    if (![[UserInfoCoreDataStorage sharedInstance] isCurrentUserLogin])
    {
        LoginViewController * SLVC = [[LoginViewController alloc] init];
        SLVC.flag = 2;
        SLVC.selectType = 3;
        [self pushToViewController:SLVC];
        return NO;
    }
    return YES;
}

-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return isEgoRefresh;
}

-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    isEgoRefresh = YES;
    [self requestData];
    [self requestRadarAction:@"1" withStart_id:@"0"];
    refreshFlag = 0;
}

-(NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [NSDate date];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [refreshview egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [refreshview egoRefreshScrollViewDidScroll:scrollView];
    
    if (scrollView.contentOffset.y < 30)
    {
        thirdHeader.alpha = 1;
        thirdHeader.userInteractionEnabled = YES;
        
        headerView.alpha = 0;
        [self.view bringSubviewToFront:infoTable];
    }
    else if (scrollView.contentOffset.y > screenHeight)
    {
        thirdHeader.alpha = 0;
        thirdHeader.userInteractionEnabled = YES;
        headerView.alpha = 1;
        [self.view bringSubviewToFront:headerView];
        [self.view sendSubviewToBack:infoTable];
    }
    else
    {
        thirdHeader.alpha = 0;
        thirdHeader.userInteractionEnabled = NO;

        headerView.alpha = (scrollView.contentOffset.y/120);
        [self.view sendSubviewToBack:infoTable];
        [self.view bringSubviewToFront:headerView];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
