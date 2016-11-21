//
//  TimeLineView.m
//  StockMaster
//
//  Created by dalikeji on 15/3/11.
//  Copyright (c) 2015年 Lee. All rights reserved.
//

#import "TimeLineView.h"

#define kLeftLabelTag   1024
#define kRightLabelTag  2048

#define kShowViewLeftLabel  2000
#define kShowViewRightLabel 3000
#define kShowTimeLeftLabel  4000
#define kShowTimeRightLabel 5000

#define kColorTime      @"#ffffff"
#define kColorAvgTime   @"#ffa500"

#define kTagLineColor   @"#464544".color
#define kTagLabelColor  @"#ff3c3c".color

static NSMutableArray * judgePoints;

@implementation TimeLineView
@synthesize kLinePadding;
@synthesize kLineWidth;
@synthesize stockInfo;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        kLineWidth = 10;             // k线实体的宽度
        kLinePadding = 1;           // k实体的间隔
        maxValue = 0;
        minValue = CGFLOAT_MAX;
        volMaxValue = 0;
        volMinValue = CGFLOAT_MAX;
        
        totalData = [[NSMutableArray alloc] init];
        currentData = [[NSMutableArray alloc] init];
        kLineTimeData = [[NSMutableArray alloc] init];
        judgePoints = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)start
{
    // 创建线图界面
    [self drawTimeLine];
    // 读取缓存，绘制线图
    NSArray *lineArray = [[StockInfoCoreDataStorage sharedInstance] getStockMinuteLineWithCode:stockInfo.code exchange:stockInfo.exchange];
    if (lineArray.count > 0) {
        [self changeKTimeLineToPoint:lineArray];
        [self updateKLines];
    }
    
    [self requestKLineWithType:self.type];
}

- (void)drawTimeLine
{
    if (kView == nil)
    {
        kView = [[UIView alloc] initWithFrame:CGRectMake(20, 0, screenWidth, 60)];
        kView.backgroundColor = [UIColor clearColor];
        kView.userInteractionEnabled = YES;
        [self addSubview:kView];
    }
    
    if (volumeView == nil) {
        volumeView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(kView.frame),CGRectGetMaxY(kView.frame)+10, screenWidth -40, 30)];
        volumeView.backgroundColor = [UIColor clearColor];
        volumeView.userInteractionEnabled = YES;
        [self addSubview:volumeView];
    }
    // 显示成交量最大值
    if (volMaxValueLab == nil)
    {
        volumeImageLine = [[UIImageView alloc] init];
        volumeImageLine.frame = CGRectMake(20, CGRectGetMaxY(kView.frame)/2+5, screenWidth-40, .5);
        [self addSubview:volumeImageLine];
    }
}

- (void)requestKLineWithType:(NSString *)stockType
{
    self.userInteractionEnabled = NO;
    NSString * action = @"";
    action = Get_time_share;
    
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    [param setObject:stockInfo.code forKey:@"stock_code"];
    [param setObject:stockType forKey:@"k_line_type"];
    [param setObject:stockInfo.exchange forKey:@"stock_exchange"];
    [param setObject:@"" forKey:@"start_date"];
    [param setObject:@"" forKey:@"end_date"];
    [param setObject:@"300" forKey:@"count"];
    [GFRequestManager connectWithDelegate:self action:action param:param];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    self.userInteractionEnabled = YES;
    
    NSString * encodeString = [request.responseString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    encodeString = [encodeString stringByReversed];
    
    NSString * decodeString = [encodeString authCodeDecoded:kTagDecryptorKey];
    
    NSDictionary * back = [[[[decodeString componentsSeparatedByString:kFlagDepartRequestInfoString] lastObject] objectFromJSONString] mutableCopy];
    
    if (back == nil)
    {
        [[CHNAlertView defaultAlertView] showContent:@"暂无数据" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
    }
    if ([[back objectForKey:@"err_code"] integerValue])
    {
        [[CHNAlertView defaultAlertView] showContent:[[back objectForKey:@"message"] description] cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
        return;
    }
    else
    {
        NSArray * temp = [back objectForKey:@"data"];
        if (!temp.count)
        {
            [[CHNAlertView defaultAlertView] showContent:@"当前股票暂时不能进行交易" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
            return;
        }
        ASIFormDataRequest * formDataRequest = (ASIFormDataRequest *)request;
        
        if ([formDataRequest.action isEqualToString:Get_time_share])
        {
            if ([[back objectForKey:@"data"] isKindOfClass:[NSArray class]])
            {
                isTimeLine = YES;
                NSArray *lineArray = [back objectForKey:@"data"];
                lineArray = [[StockInfoCoreDataStorage sharedInstance] saveStockMinuteLine:lineArray code:stockInfo.code exchange:stockInfo.exchange];
                [self changeKTimeLineToPoint:lineArray];
                [self updateKLines];
            }
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [[CHNAlertView defaultAlertView] showContent:@"网络连接失败" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
}

-(void)drawBoxWithKline
{
    [self clearSubview];
    [self drawMAWithIndex:1 andColor:kColorTime];
    [self drawVolumeLine];
}

- (void)clearSubview
{
    if (timeLine)
    {
        for (UIView * view in timeLine.subviews)
        {
            [view removeFromSuperview];
        }
    }
}

#pragma mark 成交量
- (void)drawVolumeLine
{
    // 开始画连成交量
    NSArray * voltempArray = [NSMutableArray array];
    
    voltempArray = [self changeVolumePointWithData:kLineTimeData];
    
    if (!volumeLine)
    {
        volumeLine = [[TimeLine alloc] initWithFrame:CGRectMake(0, 0, volumeView.frame.size.width, volumeView.frame.size.height)];
        volumeLine.alpha = 0.3;
        [volumeView addSubview:volumeLine];
    }
    volumeImageLine.image = [UIImage imageNamed:@"zhangzhang_xuxian_white"];
    
    volumeLine.points = [NSMutableArray arrayWithArray:voltempArray];
    volumeLine.lineWidth = kLineWidth;
    volumeLine.lineType = 2;
    [volumeLine setNeedsDisplay];
}

//#pragma mark 画均线
-(void)drawMAWithIndex:(int)index andColor:(NSString*)color{
    NSArray *tempArray = [self changeMADataToPoint:index]; // 换算成实际坐标数组
    
    if (index == 1)
    {
        if (!timeLine)
        {
            timeLine = [[TimeLine alloc] initWithFrame:CGRectMake(0, 2, kView.frame.size.width, kView.frame.size.height)];
            [kView addSubview:timeLine];
        }
        timeLine.color = color;
        timeLine.points = [NSMutableArray arrayWithArray:tempArray];
        timeLine.lineType = 3;
        [timeLine setNeedsDisplay];
    }
}

- (NSArray *)changeMADataToPoint:(NSInteger)type
{
    NSMutableArray * tempArr = [[NSMutableArray alloc] init];
    CGFloat PointStartX = 0.0f; // 起始点坐标
    
    NSMutableArray * temp = [[NSMutableArray alloc] init];
    if (type == 1 || type == 2)
    {
        temp = kLineTimeData;
    }
    else
    {
        temp = currentData;
    }
    
    for (StockPoint * stockP in temp)
    {
        CGFloat currentValue = 0.0;
        if (type == 1)
        {
            currentValue = [stockP.price floatValue];
        }
        else if (type == 2)
        {
            currentValue = [stockP.avgPrice floatValue];
        }
        
        NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
        if (isTimeLine)
        {
            [dic setObject:stockP.price forKey:@"price"];
            [dic setObject:stockP.avgPrice forKey:@"avg_price"];
        }
        
        CGFloat Y = kView.frame.size.height-2;
        
        CGFloat currentPointY = Y - ((currentValue - minValue) / (maxValue - minValue) * Y)+3;
        NSString * pointStr = [NSString stringWithFormat:@"%lf,%lf",PointStartX, currentPointY];
        [dic setObject:pointStr forKey:@"current"];
        
        [dic setObject:stockP.date forKey:@"date"];
        [dic setObject:stockP.volume forKey:@"volume"];
        
        [tempArr addObject:dic];
        
        if (type == 1 || type == 2)
        {
            PointStartX += kLineWidth;
        }
        else
        {
            PointStartX += kLineWidth+kLinePadding; // 生成下一个点的x轴
        }
    }
    if (type == 1)
    {
        judgePoints = [tempArr copy];
    }
    return tempArr;
}

- (NSArray *)changeKDataToPoint
{
    NSMutableArray * tempArr = [[NSMutableArray alloc] init];
    CGFloat PointStartX = kLineWidth/2; // 起始点坐标
    
    for (StockPoint * stockP in currentData)
    {
        CGFloat openvalue   = [stockP.open floatValue];             // 得到开盘价
        CGFloat heightvalue = [stockP.high floatValue];             // 得到最高价
        CGFloat lowvalue    = [stockP.low floatValue];              // 得到最低价
        CGFloat closevalue  = [stockP.close floatValue];            // 得到收盘价
        
        CGFloat useH = kView.frame.size.height-2;
        CGFloat useY = maxValue-minValue;
        
        // 换算成实际的坐标
        CGFloat heightPointY = useH * (1 - (heightvalue - minValue) / useY)+3;
        CGFloat lowPointY = useH * (1 - (lowvalue - minValue) / useY)+3;
        CGFloat openPointY = useH * (1 - (openvalue - minValue) / useY)+3;
        CGFloat closePointY = useH * (1 - (closevalue - minValue) / useY)+3;
        
        if (openPointY == closePointY)
        {
            closePointY +=.01;
        }
        
        NSString * heightPointStr = [NSString stringWithFormat:@"%lf,%lf",PointStartX,heightPointY];
        NSString * lowPointStr = [NSString stringWithFormat:@"%lf,%lf",PointStartX,lowPointY];
        NSString * openPointStr = [NSString stringWithFormat:@"%lf,%lf",PointStartX,openPointY];
        NSString * closePointStr = [NSString stringWithFormat:@"%lf,%lf",PointStartX,closePointY];
        
        NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
        [dic setObject:heightPointStr forKey:@"high"];
        [dic setObject:lowPointStr forKey:@"low"];
        [dic setObject:openPointStr forKey:@"open"];
        [dic setObject:closePointStr forKey:@"closePoint"];
        if (openvalue <= closevalue)
        {
            [dic setObject:kLineRed forKey:@"color"];
        }
        else
        {
            [dic setObject:kLineGreen forKey:@"color"];
        }
        [dic setObject:stockP.date forKey:@"date"];
        [dic setObject:stockP.close forKey:@"close"];
        
        [tempArr addObject:dic];
        
        
        PointStartX += kLineWidth+kLinePadding; // 生成下一个点的x轴
    }
    judgePoints = [tempArr copy];
    
    return tempArr;
}

- (void)changeKTimeLineToPoint:(NSArray *)lineArr
{
    maxValue = 0;
    minValue = CGFLOAT_MAX;
    maxRangeValue = 0;
    minRangeValue = CGFLOAT_MAX;
    volMaxValue = 0;
    volMinValue = CGFLOAT_MAX;
    
    if (kLineTimeData.count)
    {
        [kLineTimeData removeAllObjects];
    }
    
    CGFloat yestodayPrice = 0.0f;
    
    for (int i = 0; i < lineArr.count; i++)
    {
        MinuteLineEntity *minuteLine = [lineArr objectAtIndex:i];
        StockPoint * stockP = [[StockPoint alloc] init];
        stockP.price = minuteLine.price;
        stockP.avgPrice = minuteLine.avgPrice;
        stockP.updown_range = minuteLine.updownRange;
        stockP.volume = minuteLine.volume;
        stockP.date = minuteLine.time;
        stockP.updown = minuteLine.updown;
        
        if (i == 0)
        {
            yestodayPrice = [stockP.price floatValue]/(1+[stockP.updown_range floatValue]/100);
        }
        
        CGFloat rangeFloat = [[[stockP.updown_range componentsSeparatedByString:@"%"] objectAtIndex:0] floatValue];
        
        if (rangeFloat > maxRangeValue)
        {
            maxRangeValue = rangeFloat;
        }
        if (rangeFloat < minRangeValue)
        {
            minRangeValue = rangeFloat;
        }
        
        if ([stockP.volume floatValue] > volMaxValue)
        {
            volMaxValue = [stockP.volume floatValue];
        }
        if ([stockP.volume floatValue] < volMinValue)
        {
            volMinValue = [stockP.volume floatValue];
        }
        
        [kLineTimeData addObject:stockP];
    }
    if (maxRangeValue > -minRangeValue)
    {
        minRangeValue = -maxRangeValue;
    }
    else
    {
        maxRangeValue = -minRangeValue;
    }
    
    maxValue = yestodayPrice*(1+maxRangeValue/100);
    minValue = yestodayPrice*(1+minRangeValue/100);
    
    if (maxValue-minValue < .1)
    {
        maxRangeValue *= 2;
        minRangeValue *= 2;
        maxValue = yestodayPrice*(1+maxRangeValue/100);
        minValue = yestodayPrice*(1+minRangeValue/100);
    }
}

#pragma mark  把股市数据换算成成交量的实际坐标数组（下表）
-(NSArray*)changeVolumePointWithData:(NSArray*)data
{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    CGFloat PointStartX = kLineWidth/2; // 起始点坐标
    for (StockPoint * stockP in data)
    {
        NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
        
        CGFloat volumevalue = [stockP.volume floatValue];  // 得到每份成交量
        CGFloat y           = volMaxValue - volMinValue ;           // y的价格高度
        CGFloat yViewHeight = volumeView.frame.size.height ;        // y的实际像素高度
        // 换算成实际的坐标
        CGFloat volumePointY= yViewHeight * (1 - (volumevalue - volMinValue*.75) / y);
        // 把开盘价收盘价放进去好计算实体的颜色
        CGFloat openvalue = [stockP.open floatValue];    // 得到开盘价
        CGFloat closevalue = [stockP.close floatValue];   // 得到收盘价
        
        [dic setObject:@"@000000".color forKey:@"color"];
        
        NSString * volumePointStartStr = [NSString stringWithFormat:@"%lf,%lf",PointStartX,yViewHeight];
        NSString * volumePointStr = [NSString stringWithFormat:@"%lf,%lf",PointStartX,volumePointY];
        NSString * openPointStr = [NSString stringWithFormat:@"%lf,%lf",PointStartX,openvalue];
        NSString * closePointStr = [NSString stringWithFormat:@"%lf,%lf",PointStartX,closevalue];
        
        [dic setObject:volumePointStartStr forKey:@"high"];
        [dic setObject:volumePointStr forKey:@"low"];
        [dic setObject:openPointStr forKey:@"open"];
        [dic setObject:closePointStr forKey:@"closePoint"];
        
        [tempArray addObject:dic];
        
        if ([data isEqual:currentData])
        {
            PointStartX += kLineWidth+kLinePadding; // 生成下一个点的x轴
        }
        else if ([data isEqual:kLineTimeData])
        {
            PointStartX += kLineWidth;
        }
        
    }
    return tempArray;
}

- (void)updateKLineInfo
{
    kLine.hidden = YES;
    
    timeLine.hidden = NO;
    volumeImageLine.frame = CGRectMake(20, CGRectGetMaxY(kView.frame)/2+5, screenWidth-40, .5);
    
    if (screenWidth == 320)
    {
        kLineWidth = 1.1;
    }
    else if (screenWidth == 375)
    {
        kLineWidth = 1.3;
    }
    else if (screenWidth == 414)
    {
        kLineWidth = 1.4;
    }
}

- (void)updateKLines
{
    [self updateKLineInfo];
    self.clearsContextBeforeDrawing = YES;
    [self drawBoxWithKline];
}

- (void)buttonClickedAtIndex:(NSInteger)index
{
    
}
@end
