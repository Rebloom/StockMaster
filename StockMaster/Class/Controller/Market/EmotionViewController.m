//
//  EmotionViewController.m
//  StockMaster
//
//  Created by 孤星之殇 on 15/4/29.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import "EmotionViewController.h"
#import "emotionCell.h"
#import "EmotionRankViewController.h"

@interface EmotionViewController ()

@end

@implementation EmotionViewController
@synthesize emotionType;
@synthesize stockInfo;

- (void)dealloc
{
}

- (void)createRank
{
    //3.2版本屏蔽感情度排行

//    if (self.emotionType != 2)
//    {
//        UIButton * btn = [[UIButton alloc] init];
//        btn.frame = CGRectMake(screenWidth -60, 20, 60, 44);
//        btn.backgroundColor = [UIColor clearColor];
//        
//        UIImageView * rankImageView = [[UIImageView alloc] init];
//        rankImageView.frame = CGRectMake(CGRectGetWidth(btn.frame) - 38, (CGRectGetHeight(btn.frame) -19)/2, 23, 19);
//        rankImageView.image = [UIImage imageNamed:@"ganqingdu_paihang"];
//        [btn addSubview:rankImageView];
//        
//        [btn addTarget:self action:@selector(btnOnClick:) forControlEvents:UIControlEventTouchUpInside];
//        [headerView addSubview:btn];
//    }
    
    UILabel * nameLabel = [[UILabel alloc] init];
    nameLabel.text = self.stockInfo.name;
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.textColor = KFontNewColorA;
    nameLabel.font = NormalFontWithSize(15);
    nameLabel.frame = CGRectMake(0, 25, screenWidth, 15);
    [headerView addSubview:nameLabel];
    
    UILabel * codeLabel = [[UILabel alloc] init];
    codeLabel.text = self.stockInfo.code;
    codeLabel.textAlignment = NSTextAlignmentCenter;
    codeLabel.textColor = KFontNewColorA;
    codeLabel.font = NormalFontWithSize(13);
    codeLabel.frame = CGRectMake(0, 45, screenWidth, 13);
    [headerView addSubview:codeLabel];
}

- (void)btnOnClick:(UIButton*)sender
{
    EmotionRankViewController * ERVC = [[EmotionRankViewController alloc] init];
    [self pushToViewController:ERVC];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    infoDic = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    headerView.backgroundColor = kFontColorA;
    [headerView backButton];
    [headerView createLine];
    
    [self createHeadView]; 
    [self createTableView];
    [self createFeetView];
    
    [self createRank];
    
    [self requestFeelingData];
}

- (void)createTableView
{
    infoTable = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, screenHeight-CGRectGetHeight(headerView.frame))];
    infoTable.backgroundColor = kBackgroundColor;
    infoTable.dataSource = self;
    infoTable.delegate = self;
    infoTable.separatorStyle = NO;
    [self.view addSubview:infoTable];
    infoTable.tableHeaderView = bgView;
}

- (void)createFeetView
{
    if (!feetView)
    {
        feetView = [[UIView alloc] init];
    }
    feetView.frame = CGRectMake(0, 0, screenWidth, 150);
    feetView.backgroundColor = [UIColor clearColor];

    UILabel * lineLabel = [[UILabel alloc] init];
    lineLabel.frame = CGRectMake(0, 0, screenWidth, 0.5);
    lineLabel.backgroundColor = KFontNewColorJ;
    [feetView addSubview:lineLabel];

    UIImageView * iconImgView = [[UIImageView alloc] init];
    iconImgView.frame = CGRectMake(screenWidth/2-15, 52, 30, 23);
    iconImgView.image = [UIImage imageNamed:@"zhangzhang"];
    [feetView addSubview:iconImgView];

    UILabel * ideaLabel = [[UILabel alloc] init];
    ideaLabel.frame = CGRectMake(0,CGRectGetMaxY(iconImgView.frame)+10, screenWidth, 12);
    ideaLabel.text = @"免费炒股，大赚真钱";
    ideaLabel.textAlignment = NSTextAlignmentCenter;
    ideaLabel.textColor = KFontNewColorC;
    ideaLabel.font = NormalFontWithSize(12);
    [feetView addSubview:ideaLabel];

    infoTable.tableFooterView = feetView;
}

- (void)createHeadView
{
    if (!bgView)
    {
        bgView = [[UIView alloc] init];
    }
    bgView.frame = CGRectMake(0, 0, screenWidth, 211);
    bgView.backgroundColor = KSelectNewColor;
    [self.view addSubview:bgView];

    if (!emotionNumLabel)
    {
        emotionNumLabel = [[UILabel alloc] init];
    }
    emotionNumLabel.frame = CGRectMake(0, 50, screenWidth, 38);
    emotionNumLabel.textAlignment = NSTextAlignmentCenter;
    emotionNumLabel.textColor = kRedColor;
    emotionNumLabel.font = BoldFontWithSize(36);
    emotionNumLabel.text = @"--";
    [bgView addSubview:emotionNumLabel];
    
    if (!emotion)
    {
        emotion = [[UILabel alloc] init];
    }
    emotion.frame = CGRectMake(0, CGRectGetMaxY(emotionNumLabel.frame)+7.5, screenWidth, 15);
    emotion.textAlignment = NSTextAlignmentCenter;
    emotion.textColor = KFontNewColorA;
    emotion.font = NormalFontWithSize(15);
    emotion.text = @"感情度";
    [bgView addSubview:emotion];
    
    [self createScrollView];
}

- (void)createScrollView
{
    [self clearSubViews];
    
    NSArray * awardArr = [infoDic objectForKey:@"list_reward"];
    
    if (!cardScrollView)
    {
        cardScrollView = [[UIScrollView alloc]init];
    }
    cardScrollView.frame = CGRectMake(0, 211-100, screenWidth, 90);
    cardScrollView.showsHorizontalScrollIndicator = NO;
    cardScrollView.scrollsToTop = NO;
    cardScrollView.contentSize = CGSizeMake(60*awardArr.count, 90);
    if (infoDic.allKeys > 0)
    {
        for (int i = 0; i<awardArr.count; i++)
        {
            UIButton * btn = [[UIButton alloc] init];
            btn.frame = CGRectMake(15+75*i, 7.5, 60, 100);
            btn.backgroundColor = [UIColor clearColor];
            btn.tag = i;

            if (i == awardArr.count - 1)
            {
                btn.enabled = NO;
            }
            else
            {
                btn.enabled = YES;
            }
            [btn addTarget:self action:@selector(awardBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
            [cardScrollView addSubview:btn];
            
            UIImageView * cardImgView = [[UIImageView alloc] init];
            
            cardImgView.frame = CGRectMake(0, 0, 60, 60);
            [cardImgView sd_setImageWithURL:[NSURL URLWithString:[[awardArr objectAtIndex:i] objectForKey:@"img"]]
                           placeholderImage:[UIImage imageNamed:@"jingqingqidai"]
                                    options:SDWebImageRefreshCached];
            [btn addSubview:cardImgView];
            
            UILabel * nameLabel = [[UILabel alloc] init];
            nameLabel.font = NormalFontWithSize(13);
            nameLabel.textAlignment = NSTextAlignmentCenter;
            nameLabel.textColor = KFontNewColorA;
            nameLabel.text = [[awardArr objectAtIndex:i] objectForKey:@"reward_name"];
            nameLabel.frame = CGRectMake(CGRectGetMinX(cardImgView.frame)-10, CGRectGetMaxY(cardImgView.frame)+7.5, CGRectGetWidth(cardImgView.frame)+20, 13);
            [btn addSubview:nameLabel];
        }
    }

    [bgView addSubview:cardScrollView];
}

- (void)clearSubViews
{
    if (cardScrollView)
    {
        for (UIView * view in cardScrollView.subviews)
        {
            [view removeFromSuperview];
        }
    }
}

- (void)awardBtnOnClick:(UIButton*)sender
{
    NSArray * awardArr = [infoDic objectForKey:@"list_reward"];
    
    if (awardArr.count>0)
    {
        reward_type = [[awardArr objectAtIndex:sender.tag] objectForKey:@"reward_type"];
        [self requestAwardData:reward_type];
    }
}

- (void)requestFeelingData
{
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setObject:self.stockInfo.code forKey:@"stock_code"];
    [param setObject:self.stockInfo.exchange forKey:@"stock_exchange"];
    [GFRequestManager connectWithDelegate:self action:Get_stock_feeling_v2 param:param];
}

- (void)requestAwardData:(NSString*)type
{
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setObject:self.stockInfo.code forKey:@"stock_code"];
    [param setObject:self.stockInfo.exchange forKey:@"stock_exchange"];
    [param setObject:type forKey:@"reward_type"];
    [GFRequestManager connectWithDelegate:self action:Show_card_info_feeling param:param];
}

- (void)requestCardAward:(NSString*)type
{
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setObject:self.stockInfo.code forKey:@"stock_code"];
    [param setObject:self.stockInfo.exchange forKey:@"stock_exchange"];
    [param setObject:type forKey:@"reward_type"];
    [GFRequestManager connectWithDelegate:self action:Submit_card_feeling_reward param:param];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    
    ASIFormDataRequest * formDataRequest = (ASIFormDataRequest*)request;
    if ([formDataRequest.action isEqualToString:Get_stock_feeling_v2])
    {
        infoDic = [[requestInfo objectForKey:@"data"] mutableCopy];
        [self deliverDic:infoDic];
    }
    else if ([formDataRequest.action isEqualToString:Show_card_info_feeling])
    {
        NSDictionary * dict = [requestInfo objectForKey:@"data"];
        [self propCardInfo:dict];
    }
    else if ([formDataRequest.action isEqualToString:Submit_card_feeling_reward])
    {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:@"领取成功" withType:ALERTTYPEERROR];
        [self requestFeelingData];

        NSString * code = [GFStaticData getObjectForKey:EmotionCode] ;
        
        if (code)
        {
            
            NSMutableArray  * emotionNumArr = [[NSMutableArray alloc] initWithCapacity:10];
            
            if ([GFStaticData getObjectForKey:EmotionArray])
            {
                emotionNumArr = [[GFStaticData getObjectForKey:EmotionArray] mutableCopy];
            }
            
            [emotionNumArr addObject:code];
            
            NSArray * tempArr = [NSArray arrayWithArray:emotionNumArr];
            
            NSSet *set = [NSSet setWithArray:tempArr];
            
            [emotionNumArr removeAllObjects];
            
            for (NSString * str in set)
            {
                [emotionNumArr addObject:str];
            }
            
            [GFStaticData saveObject:emotionNumArr forKey:EmotionArray];
        }
    }
    
    [infoTable reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
   }

- (void)deliverDic:(NSMutableDictionary*)dict
{
    emotionNumLabel.text = [dict objectForKey:@"feeling"];
    [self createScrollView];
}

- (void)propCardInfo:(NSDictionary *)dic
{
    NSInteger type;
    NSInteger propFlag = [CHECKDATA(@"status") integerValue];
    if (propFlag == 1 || propFlag == 10)
    {
        type = 1;
    }
    else
    {
        type = 2;
    }
    
    prop =  [[PropView defaultShareView] initViewWithName:CHECKDATA(@"card_name") WithDescription:CHECKDATA(@"desc") WithType:type Delegate:self WithImageURL:CHECKDATA(@"img") WithDirect:[CHECKDATA(@"link_to") integerValue]?@"查看感情度":@""  WithPrompt:CHECKDATA(@"button_desc") isBuy:NO cardPrice:@"" usable:@"" ExpireTime:@""];
    prop.delegate = self;
    [prop showView];
}

- (void)cardToUse:(NSInteger)index
{
    [prop hideView];
    [self requestCardAward:reward_type];
}

- (void)directToDo:(NSInteger)index
{
    [prop hideView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[infoDic objectForKey:@"list_feeling"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.f;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellStock = @"cellID";
    emotionCell * cell = [tableView dequeueReusableCellWithIdentifier:cellStock];
    
    if (cell == nil)
    {
        cell = [[emotionCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellStock];
    }
    
    cell.frame = CGRectMake(0, 0, screenWidth, 80);
    
    if (infoDic.allKeys > 0)
    {
        NSDictionary * dict = [[infoDic objectForKey:@"list_feeling"] objectAtIndex:indexPath.row];
        
        cell.nameLabel.text = [dict objectForKey:@"feeling_name"];
        cell.desLabel.text = [dict objectForKey:@"desc"];
        cell.numberLabel.text = [dict objectForKey:@"feeling_num"];
    }
    
    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
