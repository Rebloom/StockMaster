//
//  MineDetailViewController.m
//  StockMaster
//
//  Created by dalikeji on 14-11-7.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "MineDetailViewController.h"
#import "LineChartView.h"
#import "UIImage+UIColor.h"
#import "CHNMacro.h"
#import "ReBirthViewController.h"
@interface MineDetailViewController ()

@end

@implementation MineDetailViewController
@synthesize infoDic;
-(void)dealloc
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor =KSelectNewColor;
    
    [headerView backButton];
    [headerView loadComponentsWithTitle:@"我的业绩"];
    [headerView createLine];
    [headerView setStatusBarColor: kFontColorA];
    headerView.backgroundColor = kFontColorA;

    scrollView = [[UIScrollView alloc] init];
    scrollView.frame = CGRectMake(0, CGRectGetMaxY(headerView.frame), screenWidth, screenHeight);
    scrollView.delegate = self;
    scrollView.contentSize = CGSizeMake(screenWidth, 980);
    scrollView. backgroundColor = [UIColor clearColor];
    scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    
    [self createFirstPart];
    [self createSecondPart];
    [self createThirdPart];
    [self createFourthPart];
    [self createFifthPart];
}

-(void)requestBuyGoods
{
    NSMutableDictionary * paramDic = [NSMutableDictionary dictionary];
    [GFRequestManager connectWithDelegate:self action:Get_user_buy_goods param:paramDic];
}

- (void)setDict:(NSDictionary *)_dict
{
    infoDic = _dict;
}

-(void)requestFinished:(ASIHTTPRequest *)request
{
    [super requestFinished:request];
    
    ASIFormDataRequest * formdataRequest = (ASIFormDataRequest *)request;
    if ([formdataRequest.action isEqualToString:Get_user_buy_goods])
    {
        NSDictionary * mDictionary = [requestInfo objectForKey:@"data"] ;
        numLabel.text = [NSString stringWithFormat:@"%@%@%@!", [[mDictionary objectForKey:@"number"] description],[mDictionary objectForKey:@"unit"],[mDictionary objectForKey:@"goods_name"]];
        tipLb.text = [[mDictionary objectForKey:@"result"] description];
        [picIv sd_setImageWithURL:[NSURL URLWithString:[[mDictionary objectForKey:@"goods_img"] description]]
                 placeholderImage:[UIImage imageNamed:@"icon_user_default"]
                          options:SDWebImageRefreshCached];
    }
}

-(void)createFirstPart
{
    if (!firstView) {
        firstView = [[UIImageView alloc] init];
    }
    firstView.frame = CGRectMake(0, 0, screenWidth, 150);
    firstView.userInteractionEnabled =YES;
    firstView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:firstView];
    
    iconView = [[UIImageView alloc] init];
    [iconView sd_setImageWithURL:[NSURL URLWithString:[[infoDic objectForKey:@"head"] description]]
                placeholderImage:[UIImage imageNamed:@"icon_user_default"]
                         options:SDWebImageRefreshCached];
    
    iconView.frame = CGRectMake(20, 40, 70, 70);
    iconView.layer.cornerRadius = 35;
    iconView.layer.masksToBounds = YES;
    [firstView addSubview:iconView];
    
    UILabel * perLabel = [[UILabel alloc] init];
    perLabel.frame = CGRectMake(CGRectGetMaxX(iconView.frame)+20, 40, 100, 40);
    perLabel.text = [infoDic objectForKey:@"total_profit"];
    perLabel.textAlignment = NSTextAlignmentLeft;
    perLabel.font = NormalFontWithSize(20);
    [firstView addSubview:perLabel];
    
    UILabel * perNumLabel = [[UILabel alloc] init];
    perNumLabel.frame = CGRectMake(CGRectGetMaxX(iconView.frame)+20, CGRectGetMaxY(perLabel.frame), 100, 20);
    perNumLabel.textAlignment = NSTextAlignmentLeft;
    perNumLabel.textColor = KFontNewColorB;
    perNumLabel.text = @"总收益率";
    perNumLabel.font = NormalFontWithSize(13);
    [firstView addSubview:perNumLabel];

    
    UILabel * rankLabel = [[UILabel alloc] init];
    rankLabel.frame = CGRectMake(CGRectGetMaxX(perLabel.frame)+20, 40, 60, 40);
    NSString * rankNum = [[infoDic objectForKey:@"profit_ranking"] description];
    if ([rankNum integerValue]<9999)
    {
        rankLabel.text = rankNum;
    }
    else if([rankNum integerValue] == 10000)
    {
        rankLabel.text = @"1万";
    }
    else if ([rankNum integerValue]>10000)
    {
        rankLabel.text = @"1万+";
    }
    
    rankLabel.textAlignment = NSTextAlignmentLeft;
    rankLabel.font = NormalFontWithSize(20);
    [firstView addSubview:rankLabel];
    
    UILabel * rankNumLabel = [[UILabel alloc] init];
    rankNumLabel.frame = CGRectMake(CGRectGetMaxX(perLabel.frame)+20, CGRectGetMaxY(rankLabel.frame), 60, 20);
    rankNumLabel.textAlignment = NSTextAlignmentLeft;
    rankNumLabel.textColor = KFontNewColorB;
    rankNumLabel.text = @"排名";
    rankNumLabel.font = NormalFontWithSize(13);
    [firstView addSubview:rankNumLabel];
    
    UIImageView * perNumIv = [[UIImageView alloc] init];
    [firstView addSubview:perNumIv];
    
    UIImageView * rankIv = [[UIImageView alloc] init];
    [firstView addSubview:rankIv];
    
    NSString * profit_status = [[infoDic objectForKey:@"profit_status"] description];
    if ([profit_status isEqualToString:@"1"]) {
        rankIv.frame = CGRectZero;
        perNumIv.frame = CGRectZero;
    }
    else
    {
        if ([[[infoDic objectForKey:@"ranking_status"] description] isEqualToString:@"1"])
        {
            rankIv.image = [UIImage imageNamed:@"shang"];
            rankIv.frame = CGRectMake(260, 85, 5.5, 10);
            rankLabel.textColor = kRedColor;
        }
        else if ([[[infoDic objectForKey:@"ranking_status"] description] isEqualToString:@"2"])
        {
            rankIv.image = [UIImage imageNamed:@"xia"];
            rankIv.frame = CGRectMake(260, 85, 5.5, 10);
            rankLabel.textColor = kGreenColor;
        }
        if ([[[infoDic objectForKey:@"profit_ranking_status"] description] isEqualToString:@"1"])
        {
            perNumIv.image = [UIImage imageNamed:@"shang"];
            perNumIv.frame = CGRectMake(165, 85, 5.5, 10);
            perLabel.textColor = kRedColor;

        }
        else if ([[[infoDic objectForKey:@"profit_ranking_status"] description] isEqualToString:@"2"])
        {
            perNumIv.image = [UIImage imageNamed:@"xia"];
            perNumIv.frame = CGRectMake(165, 85, 5.5, 10);
            perLabel.textColor = kGreenColor;
        }
    }
}

-(void)createSecondPart
{
    if (!secondView)
    {
        secondView = [[UIImageView alloc] init];
    }
    secondView.frame = CGRectMake(0, CGRectGetMaxY(firstView.frame), screenWidth, 100);
    secondView.userInteractionEnabled =YES;
    secondView.backgroundColor = KSelectNewColor;
    [scrollView addSubview:secondView];
    
    UILabel * lineLb1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 0.5)];
    lineLb1.backgroundColor = KLineNewBGColor1;
    [secondView addSubview:lineLb1];
    
    UILabel * lineLb2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.5, screenWidth, 0.5)];
    lineLb2.backgroundColor = KLineNewBGColor2;
    [secondView addSubview:lineLb2];
   
    NSArray * arr = @[@"总资产",@"虚拟本金",@"盈亏金额",@"可提现金额"];
    for(int i = 0;i<arr.count ;i++)
    {
        UILabel * lb = [[UILabel alloc] init];
        if (i<2)
        {
            lb.frame = CGRectMake(20+i*150, 20, 65, 14);
        }
        else
        {
            lb.frame = CGRectMake(20+(i-2)*150, 62, 65, 14);
        }
        lb.text = [arr objectAtIndex:i];
        lb.textAlignment = NSTextAlignmentLeft;
        lb.textColor = KFontNewColorB;
        lb.font = NormalFontWithSize(13);
        [secondView addSubview:lb];
    }
    if (infoDic.count) {
        NSArray * arr2 = @[[infoDic objectForKey:@"total_assets"],[infoDic objectForKey:@"base_money"],[infoDic objectForKey:@"total_profit_money"],[infoDic objectForKey:@"withdraw_money"]];
        for(int i = 0;i<arr2.count ;i++)
        {
            UILabel * lb = [[UILabel alloc] init];
            if (i == 0)
            {
                lb.frame = CGRectMake(70+i*150, 20, 100, 14);
            }
            if (i == 1)
            {
                lb.frame = CGRectMake(80+i*150, 20, 100, 14);
            }
            else if(i == 2)
            {
                lb.frame = CGRectMake(80+(i-2)*150, 62, 100, 14);
            }
            else if(i == 3)
            {
                 lb.frame = CGRectMake(90+(i-2)*150, 62, 100, 14);
            }
            lb.text =[NSString stringWithFormat:@"￥%@", [arr2 objectAtIndex:i]];
            lb.textAlignment = NSTextAlignmentLeft;
            lb.textColor = KFontNewColorA;
            lb.font = NormalFontWithSize(13);
            [secondView addSubview:lb];
        }
    }
    
    UILabel * lineLb3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 99, screenWidth, 0.5)];
    lineLb3.backgroundColor = KLineNewBGColor1;
    [secondView addSubview:lineLb3];
    
    UILabel * lineLb4 = [[UILabel alloc] initWithFrame:CGRectMake(0, 99.5, screenWidth, 0.5)];
    lineLb4.backgroundColor = KLineNewBGColor2;
    [secondView addSubview:lineLb4];
}


-(void)createThirdPart
{
    if (!thirdView)
    {
        thirdView = [[UIImageView alloc] init];
    }
    thirdView.frame = CGRectMake(0, CGRectGetMaxY(secondView.frame), screenWidth, 350);
    thirdView.userInteractionEnabled =YES;
    thirdView.backgroundColor = kFontColorA;
    thirdView.alpha = 1;
    [scrollView addSubview:thirdView];
    
    LineChartView *lineChartView = [[LineChartView alloc] initWithFrame:CGRectMake(0, 90, screenWidth, 270)];
    NSMutableArray *pointArr = [[NSMutableArray alloc] init];
    
    NSArray * histroyArr = [infoDic objectForKey:@"history_assets"];
    NSMutableArray * dataArr = [[NSMutableArray alloc] initWithCapacity:10];
    
    for (int i= 0; i<[histroyArr count]; i++)
    {
        [dataArr addObject: [[histroyArr objectAtIndex:i] objectForKey:@"total_yield"]];
    }
    
    float Max = 0;
    float oldMax = 0;
    float Min = CGFLOAT_MAX;
    float oldMin = 0;
    
    for (int i = 0; i < dataArr.count; i++)
    {
        if ([[dataArr objectAtIndex:i] floatValue] > Max)
        {
            Max = [[dataArr objectAtIndex:i] floatValue];
            oldMax = Max;
        }
        if ([[dataArr objectAtIndex:i] floatValue] < Min)
        {
            Min = [[dataArr objectAtIndex:i] floatValue];
            oldMin = Min;
        }
    }
    
    NSInteger lastData = 0;
    CGFloat base_money = [[[infoDic objectForKey:@"base_money"] description]floatValue];
    if (base_money <= [[dataArr lastObject] floatValue])
    {
        lastData = 1;
    }
    else
    {
        lastData = 2;
    }
    
    float useH = 120;
    
    float useY = Max-Min;
    if (useY == 0) {
        useY = 1;
        useH = 65;
        lastData = 3;
    }
    else
    {
        useY = Max-Min;
    }
    
    for (int i = 0; i < dataArr.count; i++)
    {
        CGFloat heightValue = [[dataArr objectAtIndex:i] floatValue];
        
        if (i == 0)
        {
            [pointArr addObject:[NSValue valueWithCGPoint:CGPointMake(0, useH * (1 - (heightValue - Min) / useY)+10)]];
        }
        [pointArr addObject:[NSValue valueWithCGPoint:CGPointMake(23+i*68, useH * (1 - (heightValue - Min) / useY)+10)]];
        if (i == dataArr.count-1)
        {
            [pointArr addObject:[NSValue valueWithCGPoint:CGPointMake(screenWidth, useH * (1 - (heightValue - Min) / useY)+10)]];
        }
    }
    [lineChartView setArray:pointArr];
    [lineChartView setFlag:lastData];
    [thirdView addSubview:lineChartView];
    
    if (pointArr.count > 1)
    {
        for (int i = 0; i < pointArr.count; i++)
        {
            NSValue *pointValue = pointArr[i];
            CGPoint  point      = [pointValue CGPointValue];
            
            if (i != 0 && i!= pointArr.count-1) {
                UILabel  * label = [[UILabel alloc]init];
                label.center = point;
                label.frame = CGRectMake(point.x-2.5, point.y-2.5+90, 5, 5);
                label.layer.cornerRadius = 2.5;
                label.layer.masksToBounds = YES;
                if (lastData == 1 || lastData == 3)
                {
                    label.backgroundColor = kRedColor;
                }
                else if (lastData == 2)
                {
                    label.backgroundColor = kGreenColor;
                }
                label.alpha = 1;
                [thirdView addSubview:label];
            }
            if (i == pointArr.count - 2)
            {
                UIImageView * iV = [[UIImageView alloc] init];
                iV.image = [UIImage imageNamed:@""];
                if (lastData == 1 ||lastData ==3 )
                {
                    iV.image = [UIImage imageNamed:@"qipaohong"];
                    iV.frame = CGRectMake(point.x-77, point.y+95, 90, 24);
                }
                else if (lastData == 2)
                {
                    iV.image = [UIImage imageNamed:@"qipaolv"];
                    iV.frame = CGRectMake(point.x-77, point.y+63, 90, 24);
                }
                
                [thirdView addSubview:iV];
                
                UILabel * label = [[UILabel alloc] init];
                label.frame = CGRectMake(0, 0, 90, 24);
                label.textColor = kFontColorA;
                label.textAlignment = NSTextAlignmentCenter;
                label.text =  [NSString stringWithFormat:@"总资产 %@",[[[[infoDic objectForKey:@"history_assets"] objectAtIndex:i-1 ] objectForKey:@"total_yield" ]description]];
                label.font = NormalFontWithSize(10);
                [iV addSubview:label];
            }
        }
    }
    
    NSInteger  num = 0;
    
    if (lastData == 1)
    {
        Max = Max+(base_money *0.1);
        Min = Min - (base_money *0.15);
        num = 5;
    }
    else if (lastData == 2)
    {
        Max = Max + (base_money *0.15);
        Min = Min - (base_money *0.1);
        num = 5;
    }
    else if (lastData == 3)
    {
        Max = Max + (base_money *0.1);
        Min = Min - (base_money *0.1);
        num = 3;
    }
    
    for (int i = 0; i<num; i++) {
        UILabel * moneyLabel = [[UILabel alloc] init];
        if (lastData == 3)
        {
            if (i == 0)
            {
                moneyLabel.frame = CGRectMake(5, 10, 30, 30);
                moneyLabel.text = [NSString stringWithFormat:@"%d",((int)((Max)/100))*100];
            }
            else if (i == 1)
            {
                moneyLabel.frame = CGRectMake(5, 150, 30, 30);
                moneyLabel.text = [NSString stringWithFormat:@"%d",((int)([[[dataArr lastObject] description]integerValue]/100))*100];
            }
            else if (i == 2)
            {
                moneyLabel.frame = CGRectMake(5, 290, 30, 30);
                moneyLabel.text = [NSString stringWithFormat:@"%d",((int)((Min)/100))*100];
            }
        }
        else
        {
            if (i == 0)
            {
                moneyLabel.frame = CGRectMake(5, 10, 30, 30);
                moneyLabel.text = [NSString stringWithFormat:@"%d",((int)((Max)/100))*100];
            }
            else if (i == 1)
            {
                moneyLabel.frame = CGRectMake(5, 95, 30, 30);
                moneyLabel.text = [NSString stringWithFormat:@"%d",((int)((oldMax)/100))*100];
            }
            else if (i == 2)
            {
                moneyLabel.frame = CGRectMake(5, 215, 30, 30);
                moneyLabel.text = [NSString stringWithFormat:@"%d",((int)((oldMin)/100))*100];
            }
            else if (i == 3)
            {
                moneyLabel.frame = CGRectMake(5, 290, 30, 30);
                moneyLabel.text = [NSString stringWithFormat:@"%d",((int)((Min)/100))*100];
            }
        }
        moneyLabel.alpha = .5;
        moneyLabel.textAlignment = NSTextAlignmentLeft;
        if (lastData == 1 ||lastData ==3)
        {
            moneyLabel.textColor = kRedColor;
        }
        else if (lastData == 2)
        {
            moneyLabel.textColor = kGreenColor;
        }
        moneyLabel.font = NormalFontWithSize(10);
        moneyLabel.backgroundColor = [UIColor clearColor];
        [thirdView addSubview:moneyLabel];
        [thirdView bringSubviewToFront:moneyLabel];
    }
    
    NSArray * tempArr = [infoDic objectForKey:@"history_assets"];
    for (int i = 0; i<[tempArr count]; i++) {
        UILabel * dayLabel = [[UILabel alloc] init];
        dayLabel.frame = CGRectMake(15+i*65, CGRectGetHeight(thirdView.frame)- 20,65, 10);
        dayLabel.text = [[tempArr objectAtIndex:i] objectForKey:@"date"];
        dayLabel.textAlignment = NSTextAlignmentLeft;
        dayLabel.textColor = kFontColorA;
        dayLabel.font = NormalFontWithSize(10);
        dayLabel.backgroundColor = [UIColor clearColor];
        [thirdView addSubview:dayLabel];
    }
}

-(void)createFourthPart
{
    if (!fourthView) {
        fourthView = [[UIImageView alloc] init];
    }
    fourthView.frame = CGRectMake(0, CGRectGetMaxY(thirdView.frame), screenWidth, 160);
    fourthView.userInteractionEnabled =YES;
    fourthView.backgroundColor = kFontColorA;
    [scrollView addSubview:fourthView];
    
    if ([[[infoDic objectForKey:@"profit_status"] description] isEqualToString:@"1"] )
    {
        [self createPartOne];
    }
    else if ([[[infoDic objectForKey:@"profit_status"] description] isEqualToString:@"2"])
    {
        [self requestBuyGoods];
        [self createPartTwo];
    }
    else if ([[[infoDic objectForKey:@"profit_status"] description] isEqualToString:@"3"])
    {
        [self createPartThree];
    }
    else if ([[[infoDic objectForKey:@"profit_status"]description] isEqualToString:@"4"])
    {
        [self createPartFour];
    }
}

-(void)createFifthPart
{
    if (!fifthView) {
        fifthView = [[UIImageView alloc] init];
    }
    fifthView.frame = CGRectMake(0, CGRectGetMaxY(fourthView.frame), screenWidth, 150);
    fifthView.userInteractionEnabled =YES;
    fifthView.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:fifthView];
    
    UILabel * lineLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 0.5)];
    lineLb.backgroundColor = KLineNewBGColor3;
    [fifthView addSubview:lineLb];
    
    UILabel * lineLb1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.5, screenWidth, 0.5)];
    lineLb1.backgroundColor = KLineNewBGColor4;
    [fifthView addSubview:lineLb1];
    
    UIImageView * iconIv = [[UIImageView alloc] init];
    iconIv.frame = CGRectMake(145, 52, 30, 23);
    iconIv.image = [UIImage imageNamed:@"zhangzhang"];
    [fifthView addSubview:iconIv];
    
    UILabel * ideaLabel = [[UILabel alloc] init];
    ideaLabel.frame = CGRectMake(0, CGRectGetMaxY(iconIv.frame)+10, screenWidth, 15);
    ideaLabel.text = @"免费炒股，大赚真钱";
    ideaLabel.textAlignment = NSTextAlignmentCenter;
    ideaLabel.textColor = KFontNewColorC;
    ideaLabel.font = NormalFontWithSize(12);
    [fifthView addSubview:ideaLabel];
}

-(void)createPartOne
{
    if (!partOneView)
    {
        partOneView = [[UIImageView alloc] init];
    }
    partOneView.userInteractionEnabled = YES;
    partOneView.frame = CGRectMake(0, 0, fourthView.frame.size.width, fourthView.frame.size.height);
    partOneView.backgroundColor = [UIColor clearColor];
    [fourthView addSubview:partOneView];
    
    UILabel * tipLabel = [[UILabel alloc]init];
    tipLabel.frame = CGRectMake(20, 40, 280, 15);
    tipLabel.textColor = KFontNewColorA;
    tipLabel.textAlignment = NSTextAlignmentLeft;
    tipLabel.text = @"股神，你怎么还没买股票啊。少挣多少钱啊！";
    tipLabel.font = NormalFontWithSize(14);
    tipLabel.backgroundColor = [UIColor clearColor];
    [partOneView addSubview:tipLabel];
    
    UIButton * nowBuyBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(tipLabel.frame)+20, 280, 44)];
    nowBuyBtn.tintColor = kFontColorA;
    nowBuyBtn.layer.cornerRadius = 5;
    nowBuyBtn.layer.masksToBounds = YES;
    nowBuyBtn.titleLabel.font = NormalFontWithSize(16);
    [nowBuyBtn setTitle:@"这就去买" forState:UIControlStateNormal];
    [nowBuyBtn setBackgroundImage:[KFontNewColorD image] forState:UIControlStateNormal];
    [nowBuyBtn setBackgroundImage:[KBtnSelectNewColorA image ] forState:UIControlStateSelected];
    [nowBuyBtn setBackgroundImage:[KBtnSelectNewColorA image] forState:UIControlStateHighlighted];
    [nowBuyBtn addTarget:self action:@selector(nowBuyBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [partOneView addSubview:nowBuyBtn];
}

-(void)createPartTwo
{
    if (!partTwoView)
    {
        partTwoView = [[UIImageView alloc] init];
    }
    partTwoView.userInteractionEnabled = YES;
    partTwoView.frame =CGRectMake(0, 0, fourthView.frame.size.width, fourthView.frame.size.height);
    partTwoView.backgroundColor = [UIColor clearColor];
    [fourthView addSubview:partTwoView];
    
    picIv = [[UIImageView alloc] init];
    picIv.frame = CGRectMake(20, 40, 70, 70);
    picIv.layer.cornerRadius = 35;
    picIv.layer.masksToBounds = YES;
    [partTwoView addSubview:picIv];
    
    UILabel * firstLabel =  [[UILabel alloc] init];
    firstLabel.frame = CGRectMake(100, 40, 200, 15);
    firstLabel.text = @"股神，挣这么多钱";
    firstLabel.textAlignment = NSTextAlignmentLeft;
    firstLabel.textColor = KFontNewColorA;
    firstLabel.font = NormalFontWithSize(15);
    [partTwoView addSubview:firstLabel];
    
    UILabel * secondLabel = [[UILabel alloc] init];
    secondLabel.frame = CGRectMake(100, 60, 30, 15);
    secondLabel.text = @"能买";
    secondLabel.textAlignment = NSTextAlignmentLeft;
    secondLabel.textColor = KFontNewColorA;
    secondLabel.font = NormalFontWithSize(15);
    [partTwoView addSubview:secondLabel];
    
    numLabel = [[UILabel alloc] init];
    numLabel.frame = CGRectMake(130, 60, 150, 15);
    numLabel.text = @"";
    numLabel.textAlignment = NSTextAlignmentLeft;
    numLabel.textColor = KFontNewColorD;
    numLabel.font = NormalFontWithSize(15);
    [partTwoView addSubview:numLabel];
    
    tipLb = [[UILabel alloc] init];
    tipLb.frame = CGRectMake(100, 80, 150, 15);
    tipLb.textColor = KFontNewColorA;
    tipLb.text = @"";
    tipLb.textAlignment = NSTextAlignmentLeft;
    tipLb.font = NormalFontWithSize(15);
    [partTwoView addSubview:tipLb];
    
}

-(void)createPartThree
{
    if (!partThreeView)
    {
        partThreeView = [[UIImageView alloc] init];
    }
    partThreeView.userInteractionEnabled = YES;
    partThreeView.frame = CGRectMake(0, 0, fourthView.frame.size.width, fourthView.frame.size.height);
    partThreeView.backgroundColor = [UIColor clearColor];
    [fourthView addSubview:partThreeView];
    
    UILabel * tipLabel = [[UILabel alloc]init];
    tipLabel.frame = CGRectMake(20, 40, 280, 15);
    tipLabel.textColor = KFontNewColorA;
    tipLabel.textAlignment = NSTextAlignmentLeft;
    tipLabel.text = @"加油，你还差一点点就能提现了！";
    tipLabel.font = NormalFontWithSize(14);
    tipLabel.backgroundColor = [UIColor clearColor];
    [partThreeView addSubview:tipLabel];
    
    UIButton * nowBuyBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(tipLabel.frame)+20, 280, 44)];
    nowBuyBtn.tintColor = kFontColorA;
    nowBuyBtn.layer.cornerRadius = 5;
    nowBuyBtn.layer.masksToBounds = YES;
    nowBuyBtn.titleLabel.font = NormalFontWithSize(16);
    [nowBuyBtn setTitle:@"找只金股把本翻" forState:UIControlStateNormal];
    [nowBuyBtn setBackgroundImage:[KFontNewColorD image] forState:UIControlStateNormal];
    [nowBuyBtn setBackgroundImage:[KBtnSelectNewColorA image ] forState:UIControlStateSelected];
    [nowBuyBtn setBackgroundImage:[KBtnSelectNewColorA image] forState:UIControlStateHighlighted];
    [nowBuyBtn addTarget:self action:@selector(nowBuyBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [partThreeView addSubview:nowBuyBtn];
}

-(void)createPartFour
{
    if (!partFourView)
    {
        partFourView = [[UIImageView alloc] init];
    }
    partFourView.userInteractionEnabled = YES;
    partFourView.frame = CGRectMake(0, 0, fourthView.frame.size.width, fourthView.frame.size.height);
    partFourView.backgroundColor = [UIColor clearColor];
    [fourthView addSubview:partFourView];
    
    UILabel * recoverLabel = [[UILabel alloc]init];
    recoverLabel.frame = CGRectMake(20, 40, 280, 15);
    recoverLabel.textColor = KFontNewColorA;
    recoverLabel.textAlignment = NSTextAlignmentLeft;
    recoverLabel.text = @"点击神钮，虚拟本金立即回升至4600.00";
    recoverLabel.font = NormalFontWithSize(14);
    recoverLabel.backgroundColor = [UIColor clearColor];
    [partFourView addSubview:recoverLabel];
    
    UIButton * nowBuyBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(recoverLabel.frame)+20, 280, 44)];
    nowBuyBtn.tintColor = kFontColorA;
    nowBuyBtn.layer.cornerRadius = 5;
    nowBuyBtn.layer.masksToBounds = YES;
    nowBuyBtn.titleLabel.font = NormalFontWithSize(16);
    [nowBuyBtn setTitle:@"复活" forState:UIControlStateNormal];
    [nowBuyBtn setBackgroundImage:[KFontNewColorD image] forState:UIControlStateNormal];
    [nowBuyBtn setBackgroundImage:[KBtnSelectNewColorA image ] forState:UIControlStateSelected];
    [nowBuyBtn setBackgroundImage:[KBtnSelectNewColorA image] forState:UIControlStateHighlighted];
    [nowBuyBtn addTarget:self action:@selector(recoverBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [partFourView addSubview:nowBuyBtn];

}

-(void)nowBuyBtnOnClick:(UIButton*)sender
{
    [self back];
   [[NSNotificationCenter defaultCenter] postNotificationName:KTAGVCSWITCH object:[NSString stringWithFormat:@"%d",ThirdVCTag]];
}

-(void)cashOnClick:(UIButton *)sender
{
    [self back];
    [[NSNotificationCenter defaultCenter] postNotificationName:KTAGVCSWITCH object:[NSString stringWithFormat:@"%d",ThirdVCTag]];
}

-(void)recoverBtnOnClick:(UIButton *)sender
{
    ReBirthViewController * RBVC = [[ReBirthViewController alloc] init];
    [self pushToViewController:RBVC];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
