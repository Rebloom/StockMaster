//
//  CHNLineView.m
//  StockMaster
//
//  Created by Rebloom on 14-8-25.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "CHNLineView.h"

#define kLeftLabelTag   1024
#define kRightLabelTag  2048

#define kShowViewLeftLabel  2000
#define kShowViewRightLabel 3000
#define kShowTimeLeftLabel  4000
#define kShowTimeRightLabel 5000

#define kColorTime      @"#ffffff"
#define kColorAvgTime   @"#ffa500"

#define kColorMA5       @"#3d78ff"
#define kColorMA10      @"#dda843"
#define kColorMA20      @"#ce4bce"

#define kTagLineColor   @"#464544".color
#define kTagLabelColor  @"#ff3c3c".color

static NSMutableArray * judgePoints;

@implementation CHNLineView
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
    if (self) {
        viewHeight = screenWidth;
        viewWidth  = screenHeight;
        
        xWidth = viewWidth -40;               // k线图宽度
        yHeight = 57*4;             // k线图高度
        bottomBoxHeight = 40;       // 底部成交量图的高度
        kLineWidth = 10;             // k线实体的宽度
        kLinePadding = 1;           // k实体的间隔
        MADays = 20;
        maxValue = 0;
        minValue = CGFLOAT_MAX;
        volMaxValue = 0;
        volMinValue = CGFLOAT_MAX;
        
        startIndex = 0;
        kCount = xWidth/(kLineWidth+kLinePadding); // K线中实体的总数
        
        totalData = [[NSMutableArray alloc] init];
        currentData = [[NSMutableArray alloc] init];
        kLineTimeData = [[NSMutableArray alloc] init];
        judgePoints = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)start
{
    [self drawBox];
    [self requestKLineWithType:self.type];
}

-(void)drawBox{
    if (kView == nil)
    {
        kView = [[UIView alloc] init ];
        if (screenWidth == 320)
        {
            kView.frame = CGRectMake(15, 30, viewWidth-40, 130);
            
        }
        else if (screenWidth == 375)
        {
            kView.frame = CGRectMake(15, 30, viewWidth-40, 150);
        }
        else if (screenWidth == 414)
        {
            kView.frame = CGRectMake(15, 30, viewWidth-40, 170);
        }
        kView.backgroundColor = kLineBgColor3;
        kView.userInteractionEnabled = YES;
        [self addSubview:kView];
        
        UIView * headerLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, .5)];
        headerLine.backgroundColor = kLineBgColor4;
        [self addSubview:headerLine];
        
        // 点击手势
        if (!tapGesture)
        {
            tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizerHandler:)];
            [self addGestureRecognizer:tapGesture];
        }
        // 长按手势
        if (!longPressGesture)
        {
            longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizerHandler:)];
            longPressGesture.minimumPressDuration = .3;
            longPressGesture.allowableMovement = 50;
            [self addGestureRecognizer:longPressGesture];
        }
        
        // 拖动手势
        if (!panGesture)
        {
            panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizerHandler:)];
            [self addGestureRecognizer:panGesture];
        }
        
        
        if (!pinchGesture)
        {
            pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizerHandler:)];
            [self addGestureRecognizer:pinchGesture];
        }
    }
    
    if (!showView)
    {
        showView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 105)];
        showView.layer.cornerRadius = 5;
        showView.layer.masksToBounds = YES;
        showView.backgroundColor = [UIColor whiteColor];
        
        NSArray * nameArr = @[@"日期",@"开盘",@"最高",@"最低",@"收盘",@"涨跌幅",@"成交量"];
        
        for (int i = 0; i < nameArr.count; i++)
        {
            UILabel * descLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, i*15, 30, 15)];
            descLabel.backgroundColor = [UIColor clearColor];
            descLabel.font = NormalFontWithSize(8);
            descLabel.textColor = [UIColor darkGrayColor];
            descLabel.tag = kShowViewLeftLabel+i;
            descLabel.textAlignment = NSTextAlignmentLeft;
            descLabel.text = [nameArr objectAtIndex:i];
            [showView addSubview:descLabel];
            
            UILabel * contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, i*15, 45, 15)];
            contentLabel.backgroundColor = [UIColor clearColor];
            contentLabel.font = NormalFontWithSize(8);
            contentLabel.textColor = [UIColor darkGrayColor];
            contentLabel.tag = kShowViewRightLabel+i;
            contentLabel.textAlignment = NSTextAlignmentRight;
            [showView addSubview:contentLabel];
        }
        
        showView.hidden = YES;
        [kView addSubview:showView];
    }
    
    if (!showTimeLineView)
    {
        showTimeLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 75)];
        showTimeLineView.layer.cornerRadius = 5;
        showTimeLineView.layer.masksToBounds = YES;
        showTimeLineView.backgroundColor = [UIColor whiteColor];
        
        NSArray * nameArr = @[@"时间",@"现价",@"涨幅",@"均价",@"现量"];
        
        for (int i = 0; i < nameArr.count; i++)
        {
            UILabel * descLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, i*15, 30, 15)];
            descLabel.backgroundColor = [UIColor clearColor];
            descLabel.font = NormalFontWithSize(8);
            descLabel.textColor = [UIColor darkGrayColor];
            descLabel.tag = kShowTimeLeftLabel+i;
            descLabel.textAlignment = NSTextAlignmentLeft;
            descLabel.text = [nameArr objectAtIndex:i];
            [showTimeLineView addSubview:descLabel];
            
            UILabel * contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, i*15, 45, 15)];
            contentLabel.backgroundColor = [UIColor clearColor];
            contentLabel.font = NormalFontWithSize(8);
            contentLabel.textColor = [UIColor darkGrayColor];
            contentLabel.tag = kShowTimeRightLabel+i;
            contentLabel.textAlignment = NSTextAlignmentRight;
            [showTimeLineView addSubview:contentLabel];
        }
        
        showTimeLineView.hidden = YES;
        [kView addSubview:showTimeLineView];
    }
    
    if (volumeView == nil) {
        volumeView = [[UIView alloc] init];
        volumeView.frame = CGRectMake(CGRectGetMinX(kView.frame),screenWidth-bottomBoxHeight -100, xWidth, bottomBoxHeight);
        volumeView.backgroundColor = kLineBgColor3;
        volumeView.userInteractionEnabled = YES;
        [self addSubview:volumeView];
    }
    
    if (startDateLab == nil) {
        startDateLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(volumeView.frame)-15
                                                                 , CGRectGetMaxY(volumeView.frame)
                                                                 , 50, 15)];
        startDateLab.font = NormalFontWithSize(10);
        startDateLab.text = @"--";
        startDateLab.textColor = KFontNewColorA;
        startDateLab.backgroundColor = [UIColor clearColor];
        [self addSubview:startDateLab];
    }
    
    if (midDateLab == nil)
    {
        midDateLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(volumeView.frame)-15
                                                               , CGRectGetMaxY(volumeView.frame)
                                                               , 70, 15)];
        midDateLab.textAlignment = NSTextAlignmentLeft;
        midDateLab.font = NormalFontWithSize(10);
        midDateLab.text = @"--";
        midDateLab.textColor = KFontNewColorA;
        midDateLab.backgroundColor = [UIColor clearColor];
        [self addSubview:midDateLab];
    }
    
    // 显示结束日期控件
    if (endDateLab==nil) {
        endDateLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(volumeView.frame)-50
                                                               , CGRectGetMaxY(volumeView.frame)
                                                               , 50, 15)];
        endDateLab.font = NormalFontWithSize(10);
        endDateLab.text = @"--";
        endDateLab.textColor = KFontNewColorA;
        endDateLab.backgroundColor = [UIColor clearColor];
        endDateLab.textAlignment = NSTextAlignmentRight;
        [self addSubview:endDateLab];
    }
    
    // 显示成交量最大值
    if (volMaxValueLab == nil)
    {
        
        volumeImageLine = [[UIImageView alloc] init];
        [self addSubview:volumeImageLine];
        
        volMaxValueLab = [[UILabel alloc] init];
        volMaxValueLab.font = NormalFontWithSize(10);
        volMaxValueLab.text = @"--";
        volMaxValueLab.textColor = KFontNewColorA;
        volMaxValueLab.backgroundColor = [UIColor clearColor];
        volMaxValueLab.textAlignment = NSTextAlignmentLeft;
        [self addSubview:volMaxValueLab];
        
        if (screenWidth == 320)
        {
            volumeImageLine.frame = CGRectMake(65, screenWidth-bottomBoxHeight -100, viewWidth- 85, .5);
            volMaxValueLab.frame = CGRectMake(15,screenWidth-bottomBoxHeight -107,55,15);
            
        }
        else if (screenWidth == 375)
        {
            volumeImageLine.frame = CGRectMake(65, screenWidth-bottomBoxHeight -120, viewWidth- 85, .5);
            volMaxValueLab.frame = CGRectMake(15,screenWidth-bottomBoxHeight -127,55,15);
        }
        else if (screenWidth == 414)
        {
            volumeImageLine.frame = CGRectMake(65, screenWidth-bottomBoxHeight -130, viewWidth- 85, .5);
            volMaxValueLab.frame = CGRectMake(15,screenWidth-bottomBoxHeight -137,55,15);
        }
        volumeImageLine.image = [UIImage imageNamed:@"xuxian"];
    }
    
    
    // 添加平均线值显示
    // MA5 均线价格显示控件
    if (MA5Label == nil)
    {
        MA5Label = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/2+40, 15, 50, 15)];
        MA5Label.backgroundColor = [UIColor clearColor];
        MA5Label.font = NormalFontWithSize(10);
        MA5Label.text = @"MA5:--";
        MA5Label.textColor = kColorMA5.color;
        [MA5Label sizeToFit];
        MA5Label.hidden = YES;
        [self addSubview:MA5Label];
    }
    
    // MA10 均线价格显示控件
    if (MA10Label == nil)
    {
        MA10Label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(MA5Label.frame)+40, 15, 50, 15)];
        MA10Label.backgroundColor = [UIColor clearColor];
        MA10Label.font = NormalFontWithSize(10);
        MA10Label.text = @"MA10:--";
        MA10Label.textColor = kColorMA10.color;
        [MA10Label sizeToFit];
        MA10Label.hidden = YES;
        [self addSubview:MA10Label];
    }
    
    // MA20 均线价格显示控件
    if (MA20Label == nil)
    {
        MA20Label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(MA10Label.frame)+40, 15, 50, 15)];
        MA20Label.backgroundColor = [UIColor clearColor];
        MA20Label.font = NormalFontWithSize(10);
        MA20Label.text = @"MA20:--";
        MA20Label.textColor = kColorMA20.color;
        [MA20Label sizeToFit];
        MA20Label.hidden = YES;
        [self addSubview:MA20Label];
    }
}

- (void)changeBtnClicked:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    if (btn.tag == 1)
    {
        startIndex--;
    }
    else if (btn.tag == 2)
    {
        startIndex++;
    }
    [self updateKLines];
}

- (void)requestKLineWithType:(NSString *)stockType
{
    self.userInteractionEnabled = NO;
    [self hideLongPressViews];
    [MBProgressHUD showHUDAddedTo:self animated:YES];
    NSString * action = @"";
    if ([stockType isEqualToString:Get_time_share])
    {
        action = Get_time_share;
    }
    else
    {
        action = Get_k_line;
    }
    NSMutableDictionary * param = [NSMutableDictionary dictionary];
    if (stockInfo.code)
    {
        [param setObject:stockInfo.code forKey:@"stock_code"];
        [param setObject:stockType forKey:@"k_line_type"];
        [param setObject:stockInfo.exchange forKey:@"stock_exchange"];
        [param setObject:@"" forKey:@"start_date"];
        [param setObject:@"" forKey:@"end_date"];
        [param setObject:@"300" forKey:@"count"];
        [GFRequestManager connectWithDelegate:self action:action param:param];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [MBProgressHUD hideHUDForView:self animated:YES];
    self.userInteractionEnabled = YES;
    
    NSString * encodeString = [request.responseString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    encodeString = [encodeString stringByReversed];
    
    NSString * decodeString = [encodeString authCodeDecoded:kTagDecryptorKey];
    
    NSDictionary * back = [[[[decodeString componentsSeparatedByString:kFlagDepartRequestInfoString] lastObject] objectFromJSONString] mutableCopy];
    
    if (back == nil)
    {
        [[CHNAlertView defaultAlertView] showContent:@"暂无数据" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
        return;
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
        if ([formDataRequest.action isEqualToString:Get_k_line])
        {
            if ([[back objectForKey:@"data"] isKindOfClass:[NSArray class]])
            {
                isTimeLine = NO;
                [self changeTotalDataToStockPoint:[back objectForKey:@"data"]];
                [self firstUpdateKLine];
                [self updateKLines];
            }
        }
        else if ([formDataRequest.action isEqualToString:Get_time_share])
        {
            if ([[back objectForKey:@"data"] isKindOfClass:[NSArray class]])
            {
                isTimeLine = YES;
                [self changeKTimeLineToPoint:[back objectForKey:@"data"]];
                [self updateKLines];
            }
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [MBProgressHUD hideHUDForView:self animated:YES];
    [[CHNAlertView defaultAlertView] showContent:@"网络连接失败" cancelTitle:nil sureTitle:@"确定" withDelegate:self withType:6];
}

- (void)changeTotalDataToStockPoint:(NSMutableArray *)totalArr
{
    if (totalData.count)
    {
        [totalData removeAllObjects];
    }
    
    for (NSDictionary * dic in totalArr)
    {
        StockPoint * stockP = [[StockPoint alloc] init];
        stockP.date = [Utility departDateString:[[dic objectForKey:@"date"] description]];
        stockP.high = [[dic objectForKey:@"high"] description];
        stockP.low = [[dic objectForKey:@"low"] description];
        stockP.open = [[dic objectForKey:@"open"] description];
        stockP.close = [[dic objectForKey:@"close"] description];
        stockP.volume = [[dic objectForKey:@"volume"] description];
        stockP.updown_range = [[dic objectForKey:@"updown_range"] description];
        stockP.updown = [[dic objectForKey:@"updown_price"] description];
        
        stockP.ma5 = CHECKDATA(@"ma5");
        stockP.ma10 = CHECKDATA(@"ma10");
        stockP.ma20 = CHECKDATA(@"ma20");
        
        [totalData addObject:stockP];
    }
}

- (void)changeDataToStockPoint
{
    maxValue = 0;
    minValue = CGFLOAT_MAX;
    volMaxValue = 0;
    volMinValue = CGFLOAT_MAX;
    
    [currentData removeAllObjects];
    
    if (totalData.count == 0)
    {
        return;
    }
    
    if (startIndex+kCount > totalData.count )
    {
        startIndex = totalData.count-kCount;
        if (startIndex < 0)
        {
            startIndex = 0;
        }
    }
    
    for (NSInteger i = 0; i < kCount; i++)
    {
        if (i >= totalData.count)
        {
            //do nothing
        }
        else
        {
            [currentData addObject:[totalData objectAtIndex:i+startIndex]];
        }
    }
    
    for (StockPoint * stockP in currentData)
    {
        // K线的最高最低值
        if ([stockP.high floatValue] > maxValue)
        {
            maxValue = [stockP.high floatValue];
        }
        if ([stockP.low floatValue] < minValue)
        {
            minValue = [stockP.low floatValue];
        }
        // 成交量的最高最低值
        if ([stockP.volume floatValue] > volMaxValue)
        {
            volMaxValue = [stockP.volume floatValue];
        }
        if ([stockP.volume floatValue] < volMinValue)
        {
            volMinValue = [stockP.volume floatValue];
        }
    }
}

-(void)drawBoxWithKline
{
    if (isTimeLine)
    {
        [self drawMAWithIndex:1 andColor:kColorTime];
        [self drawMAWithIndex:2 andColor:kColorAvgTime];
    }
    else
    {
        [self changeDataToStockPoint];
        
        // MA5
        [self drawMAWithIndex:5 andColor:kColorMA5];
        // MA10
        [self drawMAWithIndex:10 andColor:kColorMA10];
        // MA20
        [self drawMAWithIndex:20 andColor:kColorMA20];
        
        [self drawKLine];
    }
    
    [self drawVolumeLine];
}

#pragma mark K线图
- (void)drawKLine
{
    // 开始画连K线
    // x轴从0 到 框框的宽度 mainboxView.frame.size.width 变化
    // y轴为每个间隔的连线，如，今天的点连接明天的点
    NSArray *ktempArray = [self changeKDataToPoint]; // 换算成实际每天收盘价坐标数组
    if (!kLine)
    {
        kLine = [[CHNLine alloc] initWithFrame:CGRectMake(0, 0, kView.frame.size.width, kView.frame.size.height)];
        [kView addSubview:kLine];
    }
    kLine.points = [NSMutableArray arrayWithArray:ktempArray];
    kLine.lineWidth = kLineWidth;
    kLine.lineType = LINE_CANDLE;
    [kLine setNeedsDisplay];
}

#pragma mark 成交量
- (void)drawVolumeLine
{
    // 开始画连成交量
    NSArray * voltempArray = [NSMutableArray array];
    if (isTimeLine)
    {
        voltempArray = [self changeVolumePointWithData:kLineTimeData];
    }
    else
    {
        voltempArray = [self changeVolumePointWithData:currentData];
    }
    
    if (!volumeLine)
    {
        volumeLine = [[CHNLine alloc] initWithFrame:CGRectMake(0, 0, volumeView.frame.size.width, volumeView.frame.size.height)];
        [volumeView addSubview:volumeLine];
    }
    
    volumeLine.points = [NSMutableArray arrayWithArray:voltempArray];
    volumeLine.lineWidth = kLineWidth;
    volumeLine.lineType = LINE_VOLUME;
    [volumeLine setNeedsDisplay];
}


#pragma mark 画均线
-(void)drawMAWithIndex:(int)index andColor:(NSString*)color{
    NSArray *tempArray = [self changeMADataToPoint:index]; // 换算成实际坐标数组
    
    if (index == 1)
    {
        if (!timeLine)
        {
            timeLine = [[CHNLine alloc] initWithFrame:CGRectMake(0, 2, kView.frame.size.width, kView.frame.size.height)];
            [kView addSubview:timeLine];
        }
        timeLine.color = color;
        timeLine.points = [NSMutableArray arrayWithArray:tempArray];
        timeLine.lineType = LINE_CURRENT_PRICE;
        [timeLine setNeedsDisplay];
    }
    else if (index == 2)
    {
        if (!timeAvgLine)
        {
            timeAvgLine = [[CHNLine alloc] initWithFrame:CGRectMake(0, 0, kView.frame.size.width, kView.frame.size.height)];
            [kView addSubview:timeAvgLine];
        }
        timeAvgLine.color = color;
        timeAvgLine.points = [NSMutableArray arrayWithArray:tempArray];
        timeAvgLine.lineType = LINE_AVG_PRICE;
        [timeAvgLine setNeedsDisplay];
    }
    else if(index == 5)
    {
        if (!MA5Line)
        {
            MA5Line = [[CHNLine alloc] initWithFrame:CGRectMake(0, 0, kView.frame.size.width, kView.frame.size.height)];
            [kView addSubview:MA5Line];
        }
        MA5Line.color = color;
        MA5Line.points = [NSMutableArray arrayWithArray:tempArray];
        MA5Line.lineType = LINE_AVG_PRICE;
        [MA5Line setNeedsDisplay];
    }
    else if (index == 10)
    {
        if (!MA10Line)
        {
            MA10Line = [[CHNLine alloc] initWithFrame:CGRectMake(0, 0, kView.frame.size.width, kView.frame.size.height)];
            [kView addSubview:MA10Line];
        }
        MA10Line.color = color;
        MA10Line.points = [NSMutableArray arrayWithArray:tempArray];
        MA10Line.lineType = LINE_AVG_PRICE;
        [MA10Line setNeedsDisplay];
    }
    else if (index == 20)
    {
        if (!MA20Line)
        {
            MA20Line = [[CHNLine alloc] initWithFrame:CGRectMake(0, 0, kView.frame.size.width, kView.frame.size.height)];
            [kView addSubview:MA20Line];
        }
        MA20Line.color = color;
        MA20Line.points = [NSMutableArray arrayWithArray:tempArray];
        MA20Line.lineType = LINE_AVG_PRICE;
        [MA20Line setNeedsDisplay];
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
        else if (type == 5)
        {
            currentValue = [stockP.ma5 floatValue];
        }
        else if (type == 10)
        {
            currentValue = [stockP.ma10 floatValue];
        }
        else if (type == 20)
        {
            currentValue = [stockP.ma20 floatValue];
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
    
    StockPoint * lastP = [currentData lastObject];
    if (lastP.ma5.length)
    {
        MA5Label.frame = CGRectMake(screenWidth/2+40, 15, 50, 15);
        MA5Label.text = [NSString stringWithFormat:@"MA5:%.2f",[lastP.ma5 floatValue]];
        [MA5Label sizeToFit];
    }
    if (lastP.ma10.length)
    {
        MA10Label.frame = CGRectMake(CGRectGetMaxX(MA5Label.frame)+10, 15, 50, 15);
        MA10Label.text = [NSString stringWithFormat:@"MA10:%.2f",[lastP.ma10 floatValue]];
        [MA10Label sizeToFit];
    }
    if (lastP.ma20.length)
    {
        MA20Label.frame = CGRectMake(CGRectGetMaxX(MA10Label.frame)+10, 15, 50, 15);
        MA20Label.text = [NSString stringWithFormat:@"MA20:%.2f",[lastP.ma20 floatValue]];
        [MA20Label sizeToFit];
    }
    
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
        [dic setObject:stockP.ma5 forKey:@"ma5"];
        [dic setObject:stockP.ma10 forKey:@"ma10"];
        [dic setObject:stockP.ma20 forKey:@"ma20"];
        
        [tempArr addObject:dic];
        
        
        PointStartX += kLineWidth+kLinePadding; // 生成下一个点的x轴
    }
    judgePoints = [tempArr copy];
    
    return tempArr;
}

- (void)updateLeftLabel
{
    // 平均线
    CGFloat padValue = (maxValue - minValue) / 4;
    CGFloat padRealValue = (kView.frame.size.height-2) / 4;
    
    if (isDrawLeftLabel)
    {
        // 不再画了
        for (int i = 0; i < 5; i++)
        {
            for (UIView * view in kView.subviews)
            {
                if (view.tag == kLeftLabelTag+i)
                {
                    UILabel * leftLabel = (UILabel *)view;
                    if (isTimeLine)
                    {
                        if(i < 2)
                        {
                            leftLabel.textColor = kGreenColor;
                        }
                        else if (i == 2)
                        {
                            leftLabel.textColor = KFontNewColorA;
                        }
                        else
                        {
                            leftLabel.textColor = kRedColor;
                        }
                    }
                    else
                    {
                        leftLabel.textColor = KFontNewColorA;
                    }
                    leftLabel.text = [NSString stringWithFormat:@"%.2f",padValue*i+minValue];
                }
            }
        }
    }
    else
    {
        for (int i = 0; i < 5; i++)
        {
            CGFloat y = kView.frame.size.height-padRealValue*i-2;
            UILabel *leftLabel = [[UILabel alloc] init];
            leftLabel.tag = kLeftLabelTag+i;
            leftLabel.text = [NSString stringWithFormat:@"%.2f",padValue*i+minValue];
            leftLabel.textColor = KFontNewColorA;
            leftLabel.frame = CGRectMake(0, y-40/2, 38, 35);
            leftLabel.font = NormalFontWithSize(10);
            leftLabel.textAlignment = NSTextAlignmentLeft;
            leftLabel.backgroundColor = [UIColor clearColor];
            [kView addSubview:leftLabel];
            
            UIView * lineView = [[UIView alloc] init ];
            lineView.backgroundColor = kLineBgColor4;
            lineView.frame = CGRectMake(0, CGRectGetMidY(leftLabel.frame)+5, viewWidth - 40, .5);
            [kView addSubview:lineView];
            
            UIView * shuLineView = [[UIView alloc] init];
            shuLineView.backgroundColor = kLineBgColor4;
            if (screenWidth == 320)
            {
                shuLineView.frame = CGRectMake(i* CGRectGetWidth(kView.frame)/4, 1, .5, 130);
            }
            else if (screenWidth == 375)
            {
                shuLineView.frame = CGRectMake(i* CGRectGetWidth(kView.frame)/4, 1, .5, 150);
            }
            else if (screenWidth == 414)
            {
                shuLineView.frame = CGRectMake(i* CGRectGetWidth(kView.frame)/4, 1, .5, 170);
            }
            [kView addSubview:shuLineView];
        }
        
        isDrawLeftLabel = YES;
    }
    
    if (isDrawRightLabel)
    {
        // 不再画了
        for (int i = 0; i < 5; i++)
        {
            for (UIView * view in kView.subviews)
            {
                if (view.tag == kRightLabelTag+i)
                {
                    UILabel * rightLabel = (UILabel *)view;
                    if (isTimeLine)
                    {
                        if(i < 2)
                        {
                            rightLabel.textColor = kGreenColor;
                        }
                        else if (i == 2)
                        {
                            rightLabel.textColor = KFontNewColorA;
                        }
                        else
                        {
                            rightLabel.textColor = kRedColor;
                        }
                    }
                    else
                    {
                        rightLabel.textColor = KFontNewColorA;
                    }
                    [self setRightLabelText:rightLabel withIndex:i];
                }
            }
        }
    }
    else
    {
        for (int i = 0; i < 5; i++)
        {
            CGFloat y = kView.frame.size.height-padRealValue*i-2;
            UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewWidth - 70, y-40/2, 38, 35)];
            rightLabel.tag = kRightLabelTag+i;
            [self setRightLabelText:rightLabel withIndex:i];
            rightLabel.textColor = kTagLabelColor;
            rightLabel.font = NormalFontWithSize(10);
            rightLabel.textAlignment = NSTextAlignmentLeft;
            rightLabel.backgroundColor = [UIColor clearColor];
            [kView addSubview:rightLabel];
        }
        isDrawRightLabel = YES;
    }
    
    for (int i = 0; i < 5; i++)
    {
        for (UIView * view in kView.subviews)
        {
            if (view.tag == kRightLabelTag+i)
            {
                UILabel * rightLabel = (UILabel *)view;
                if (isTimeLine)
                {
                    rightLabel.hidden = NO;
                }
                else
                {
                    rightLabel.hidden = YES;
                }
            }
        }
    }
}

- (void)setRightLabelText:(UILabel *)rightLabel withIndex:(NSInteger)index
{
    switch (index) {
        case 0:
            rightLabel.text = [NSString stringWithFormat:@"%.2f%%",minRangeValue];
            break;
        case 1:
            rightLabel.text = [NSString stringWithFormat:@"%.2f%%",minRangeValue/2];
            break;
        case 2:
            rightLabel.text = @"0.00%";
            break;
        case 3:
            rightLabel.text = [NSString stringWithFormat:@"%.2f%%",maxRangeValue/2];
            break;
        case 4:
            rightLabel.text = [NSString stringWithFormat:@"%.2f%%",maxRangeValue];
            break;
        default:
            break;
    }
}

- (void)updateVolumeLabel
{
    if (volMaxValue > 9999999)
    {
        volMaxValueLab.text = [NSString stringWithFormat:@"%.2f亿手",volMaxValue/100000000];
    }
    else if (volMaxValue > 99999)
    {
        volMaxValueLab.text = [NSString stringWithFormat:@"%.2f万手",volMaxValue/10000];
    }
    else
    {
        volMaxValueLab.text = [NSString stringWithFormat:@"%.0f手",volMaxValue];
    }
}

- (void)updateDateLabel
{
    if (isTimeLine)
    {
        startDateLab.text = @"09:30";
        midDateLab.text = @"11:30/13:00";
        endDateLab.text = @"15:00";
        midDateLab.frame = CGRectMake(CGRectGetMidX(volumeView.frame)-45
                                      , CGRectGetMaxY(volumeView.frame)
                                      , 70, 15);
        endDateLab.frame = CGRectMake(CGRectGetMaxX(volumeView.frame)-50
                                      , CGRectGetMaxY(volumeView.frame)
                                      , 50, 15);
    }
    else
    {
        StockPoint * stockF = [currentData firstObject];
        startDateLab.text = stockF.date;
        startDateLab.frame = CGRectMake(CGRectGetMinX(volumeView.frame)-15
                                        , CGRectGetMaxY(volumeView.frame)
                                        , 50, 15);
        
        StockPoint * stockM = [currentData objectAtIndex:currentData.count/2];
        midDateLab.text = stockM.date;
        midDateLab.frame = CGRectMake(CGRectGetMidX(volumeView.frame)-15
                                      , CGRectGetMaxY(volumeView.frame)
                                      , 70, 15);
        
        StockPoint * stockL = [currentData lastObject];
        endDateLab.text = stockL.date;
        endDateLab.frame = CGRectMake(CGRectGetMaxX(volumeView.frame)-30
                                      , CGRectGetMaxY(volumeView.frame)
                                      , 50, 15);
    }
}

- (void)changeKTimeLineToPoint:(NSArray *)backArr
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
    
    for (int i = 0; i < backArr.count; i++)
    {
        NSDictionary * dic = [backArr objectAtIndex:i];
        StockPoint * stockP = [[StockPoint alloc] init];
        stockP.price = [[dic objectForKey:@"price"] description];
        stockP.avgPrice = [[dic objectForKey:@"avg_price"] description];
        stockP.updown_range = [[dic objectForKey:@"updown_range"] description];
        stockP.volume = [[dic objectForKey:@"volume"] description];
        stockP.date = [[dic objectForKey:@"time"] description];
        stockP.updown = [[dic objectForKey:@"updown"] description];
        
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
        
        CGFloat volumevalue = [stockP.volume floatValue];           // 得到每份成交量
        CGFloat y           = volMaxValue - volMinValue ;           // y的价格高度
        CGFloat yViewHeight = volumeView.frame.size.height ;        // y的实际像素高度
        // 换算成实际的坐标
        CGFloat volumePointY= yViewHeight * (1 - (volumevalue - volMinValue*.75) / y);
        // 把开盘价收盘价放进去好计算实体的颜色
        CGFloat openvalue = [stockP.open floatValue];               // 得到开盘价
        CGFloat closevalue = [stockP.close floatValue];             // 得到收盘价
        
        if (isTimeLine)
        {
            if ([stockP.updown isEqualToString:@"up"])
            {
                [dic setObject:kLineRed forKey:@"color"];
            }
            else
            {
                [dic setObject:kLineGreen forKey:@"color"];
            }
        }
        else
        {
            if (openvalue <= closevalue)
            {
                [dic setObject:kLineRed forKey:@"color"];
            }
            else
            {
                [dic setObject:kLineGreen forKey:@"color"];
            }
        }
        
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

- (void)showTimeViewWithIndex:(NSInteger)index
{
    showTimeLineView.hidden = NO;
    if (index > 120)
    {
        showTimeLineView.frame = CGRectMake(0, 0, 75, 75);
    }
    else
    {
        showTimeLineView.frame = CGRectMake(viewWidth - 112, 0, 75, 75);
    }
    [kView bringSubviewToFront:showTimeLineView];
    
    StockPoint * stockP = [kLineTimeData objectAtIndex:index];
    
    NSArray * valueArr = @[stockP.date, stockP.price, [NSString stringWithFormat:@"%@",stockP.updown_range], stockP.avgPrice,[NSString stringWithFormat:@"%@手",stockP.volume]];
    
    for (UIView * subView in showTimeLineView.subviews)
    {
        if ([subView isKindOfClass:[UILabel class]])
        {
            UILabel * rightLabel = (UILabel *)subView;
            if (rightLabel.tag - kShowTimeRightLabel >= 0)
            {
                NSInteger i = rightLabel.tag-kShowTimeRightLabel;
                rightLabel.text = [valueArr objectAtIndex:i];
                
                if ([stockP.updown_range componentsSeparatedByString:@"-"].count > 1)
                {
                    rightLabel.textColor = kLowColor;
                }
                else
                {
                    rightLabel.textColor = kHighColor;
                }
                if (i == 0 || i == 4)
                {
                    rightLabel.textColor = [UIColor darkGrayColor];
                }
                if (i == 4)
                {
                    if ([[valueArr objectAtIndex:i] integerValue] > 9999999)
                    {
                        rightLabel.text = [NSString stringWithFormat:@"%.2f亿手",volMaxValue/100000000];
                    }
                    else if ([[valueArr objectAtIndex:i] integerValue] > 99999)
                    {
                        rightLabel.text = [NSString stringWithFormat:@"%.2f万手",[[valueArr objectAtIndex:i] floatValue]/10000];
                    }
                    else
                    {
                        rightLabel.text = [NSString stringWithFormat:@"%d手",[[valueArr objectAtIndex:i] intValue]];
                    }
                }
            }
        }
    }
}

- (void)showViewWithIndex:(NSInteger)index
{
    showView.hidden = NO;
    
    if (index > currentData.count/2)
    {
        showView.frame = CGRectMake(0, 0, 80, 105);
    }
    else
    {
        showView.frame = CGRectMake(viewWidth - 120, 0, 80, 105);
    }
    [kView bringSubviewToFront:showView];
    
    StockPoint * stockP = [currentData objectAtIndex:index];
    
    NSArray * valueArr = @[stockP.date, stockP.open, stockP.high, stockP.low, stockP.close, stockP.updown_range, stockP.volume];
    
    for (UIView * subView in showView.subviews)
    {
        if ([subView isKindOfClass:[UILabel class]])
        {
            UILabel * rightLabel = (UILabel *)subView;
            if (rightLabel.tag - kShowViewRightLabel >= 0)
            {
                NSInteger i = rightLabel.tag-kShowViewRightLabel;
                rightLabel.text = [valueArr objectAtIndex:i];
                
                if ([stockP.updown_range componentsSeparatedByString:@"-"].count > 1)
                {
                    rightLabel.textColor = kLowColor;
                }
                else
                {
                    rightLabel.textColor = kHighColor;
                }
                if (i == 0 || i == 6)
                {
                    rightLabel.textColor = [UIColor darkGrayColor];
                }
                if (i == 6)
                {
                    if ([[valueArr objectAtIndex:i] integerValue] > 9999999)
                    {
                        rightLabel.text = [NSString stringWithFormat:@"%.2f亿手",volMaxValue/100000000];
                    }
                    else if ([[valueArr objectAtIndex:i] integerValue] > 999999)
                    {
                        rightLabel.text = [NSString stringWithFormat:@"%.2f万手",[[valueArr objectAtIndex:i] floatValue]/10000];
                    }
                    else
                    {
                        rightLabel.text = [NSString stringWithFormat:@"%d手",[[valueArr objectAtIndex:i] intValue]];
                    }
                }
            }
        }
    }
}

- (void)hideLongPressViews
{
    showView.hidden = YES;
    showTimeLineView.hidden = YES;
    [horizontalLine removeFromSuperview];
    [verticalLine removeFromSuperview];
    [horizontalLabel removeFromSuperview];
    [verticalLabel removeFromSuperview];
    
    horizontalLine = nil;
    verticalLine = nil;
    horizontalLabel = nil;
    verticalLabel = nil;
}

- (void)gestureRecognizerHandler:(id)gesture
{
    if ([gesture isEqual:longPressGesture])
    {
        UILongPressGestureRecognizer * longPress = (UILongPressGestureRecognizer *) gesture;
        touchViewPoint = [longPress locationInView:kView];
        [self updateLines];
    }
    else if ([gesture isEqual:panGesture])
    {
        [self hideLongPressViews];
        if (!isTimeLine)
        {
            UIPanGestureRecognizer * pan = (UIPanGestureRecognizer *) gesture;
            if (pan.state == UIGestureRecognizerStateChanged)
            {
                CGPoint point = [pan translationInView:self];
                
                startIndex -= point.x/kLineWidth;
                
                if (point.y > 0)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTagUpdateMarketFrame object:@"DOWN"];
                }
                else
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTagUpdateMarketFrame object:@"UP"];
                }
                
                [self updateKLines];
            }
        }
        else
        {
            UIPanGestureRecognizer * pan = (UIPanGestureRecognizer *) gesture;
            if (pan.state == UIGestureRecognizerStateChanged)
            {
                CGPoint point = [pan translationInView:self];
                
                if (point.y > 0)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTagUpdateMarketFrame object:@"DOWN"];
                }
                else
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTagUpdateMarketFrame object:@"UP"];
                }
            }
        }
    }
    else if ([gesture isEqual:pinchGesture])
    {
        [self hideLongPressViews];
        if (!isTimeLine)
        {
            UIPinchGestureRecognizer * pinch = (UIPinchGestureRecognizer *) gesture;
            if (pinch.state == UIGestureRecognizerStateChanged)
            {
                kLineWidth = pinch.scale*8;
                [self updateKLines];
            }
        }
    }
    else if ([gesture isEqual:tapGesture])
    {
        [self hideLongPressViews];
    }
}

- (void)updateKLineInfo
{
    if (isTimeLine)
    {
        MA5Line.hidden = YES;
        MA10Line.hidden = YES;
        MA20Line.hidden = YES;
        MA5Label.hidden = YES;
        MA10Label.hidden = YES;
        MA20Label.hidden = YES;
        kLine.hidden = YES;
        
        timeLine.hidden = NO;
        timeAvgLine.hidden = NO;
        if (screenWidth == 320)
        {
            volumeImageLine.frame = CGRectMake(65, screenWidth-bottomBoxHeight -100, viewWidth- 85, .5);
            volMaxValueLab.frame = CGRectMake(15,screenWidth-bottomBoxHeight -107,55,15);
            
        }
        else if (screenWidth == 375)
        {
            volumeImageLine.frame = CGRectMake(65, screenWidth-bottomBoxHeight -120, viewWidth- 85, .5);
            volMaxValueLab.frame = CGRectMake(15,screenWidth-bottomBoxHeight -127,55,15);
        }
        else if (screenWidth == 414)
        {
            volumeImageLine.frame = CGRectMake(65, screenWidth-bottomBoxHeight -130, viewWidth- 85, .5);
            volMaxValueLab.frame = CGRectMake(15,screenWidth-bottomBoxHeight -137,55,15);
        }
    }
    else
    {
        MA5Line.hidden = NO;
        MA10Line.hidden = NO;
        MA20Line.hidden = NO;
        MA5Label.hidden = NO;
        MA10Label.hidden = NO;
        MA20Label.hidden = NO;
        kLine.hidden = NO;
        
        timeLine.hidden = YES;
        timeAvgLine.hidden = YES;
        if (screenWidth == 320)
        {
            volumeImageLine.frame = CGRectMake(65, screenWidth-bottomBoxHeight -100, viewWidth- 85, .5);
            volMaxValueLab.frame = CGRectMake(15,screenWidth-bottomBoxHeight -107,55,15);
            
        }
        else if (screenWidth == 375)
        {
            volumeImageLine.frame = CGRectMake(65, screenWidth-bottomBoxHeight -120, viewWidth- 85, .5);
            volMaxValueLab.frame = CGRectMake(15,screenWidth-bottomBoxHeight -127,55,15);
        }
        else if (screenWidth == 414)
        {
            volumeImageLine.frame = CGRectMake(65, screenWidth-bottomBoxHeight -130, viewWidth- 85, .5);
            volMaxValueLab.frame = CGRectMake(15,screenWidth-bottomBoxHeight -137,55,15);
        }
    }
    
    if (kLineWidth > 30)
    {
        kLineWidth = 30;
    }
    if (kLineWidth < 4)
    {
        kLineWidth = 4;
    }
    if (isTimeLine)
    {
        if (screenWidth == 320)
        {
            kLineWidth = 2.2;
        }
        else if (screenWidth == 375)
        {
            kLineWidth = 2.6;
        }
        else if (screenWidth == 414)
        {
            kLineWidth = 2.9;
        }
    }
    
    kCount = xWidth/(kLineWidth+kLinePadding); // K线中实体的总数
    
    if (startIndex < 0)
    {
        startIndex = 0;
        return;
    }
}

- (void)firstUpdateKLine
{
    if (kLineWidth > 30)
    {
        kLineWidth = 30;
    }
    if (kLineWidth < 4)
    {
        kLineWidth = 4;
    }
    if (isTimeLine)
    {
        kLineWidth = 1;
    }
    
    kCount = xWidth/(kLineWidth+kLinePadding); // K线中实体的总数
    
    startIndex = totalData.count-kCount;
}

- (void)updateKLines
{
    [self updateKLineInfo];
    self.clearsContextBeforeDrawing = YES;
    [self drawBoxWithKline];
    
    [self updateLeftLabel];
    [self updateVolumeLabel];
    [self updateDateLabel];
}

-(void)updateLines
{
    if (horizontalLine == nil)
    {
        horizontalLine = [[UIView alloc] initWithFrame:CGRectMake(0, 32, 0.5, viewHeight -100)];
        horizontalLine.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:horizontalLine];
        horizontalLine.hidden = YES;
    }
    
    if (verticalLine == nil)
    {
        verticalLine = [[UIView alloc] initWithFrame:CGRectMake(0, 32, viewWidth -80, 0.5)];
        verticalLine.backgroundColor = [UIColor lightGrayColor];
        verticalLine.hidden = YES;
        [self addSubview:verticalLine];
    }
    
    if (horizontalLabel == nil)
    {
        CGRect oneFrame = horizontalLine.frame;
        oneFrame.size = CGSizeMake(50, 12);
        horizontalLabel = [[UILabel alloc] initWithFrame:oneFrame];
        horizontalLabel.font = NormalFontWithSize(8);
        
        horizontalLabel.backgroundColor = [UIColor lightGrayColor];
        horizontalLabel.textColor = [UIColor blackColor];
        horizontalLabel.textAlignment = NSTextAlignmentCenter;
        horizontalLabel.alpha = 0.8;
        horizontalLabel.hidden = YES;
        horizontalLabel.layer.cornerRadius = 5;
        horizontalLabel.layer.masksToBounds = YES;
        [self addSubview:horizontalLabel];
    }
    
    if (verticalLabel == nil) {
        CGRect oneFrame = verticalLine.frame;
        oneFrame.size = CGSizeMake(50, 12);
        verticalLabel = [[UILabel alloc] initWithFrame:oneFrame];
        verticalLabel.font = NormalFontWithSize(8);
        
        verticalLabel.backgroundColor = [UIColor lightGrayColor];
        verticalLabel.textColor = [UIColor blackColor];
        verticalLabel.textAlignment = NSTextAlignmentCenter;
        verticalLabel.alpha = 0.8;
        verticalLabel.hidden = YES;
        verticalLabel.layer.cornerRadius = 5;
        verticalLabel.layer.masksToBounds = YES;
        [self addSubview:verticalLabel];
    }
    
    CGFloat temp = screenWidth - 320;
    horizontalLine.frame = CGRectMake(touchViewPoint.x, 32, 0.5, 195 +temp);
    verticalLine.frame = CGRectMake(40, touchViewPoint.y, viewWidth - 65 , 0.5);
    
    CGRect Frame1 = horizontalLine.frame;
    Frame1.size = CGSizeMake(50, 12);
    horizontalLabel.frame = Frame1;
    CGRect Frame2 = verticalLine.frame;
    Frame2.size = CGSizeMake(50, 12);
    verticalLabel.frame = Frame2;
    
    horizontalLine.hidden = NO;
    verticalLine.hidden = NO;
    horizontalLabel.hidden = NO;
    verticalLabel.hidden = NO;
    [self isKPointWithPoint:touchViewPoint];
}

-(void)isKPointWithPoint:(CGPoint)point{
    CGFloat itemPointX = 0;
    for (int i = 0; i < judgePoints.count; i++)
    {
        NSDictionary * dic = [judgePoints objectAtIndex:i];
        CGPoint itemPoint = CGPointMake(0, 0);
        if (isTimeLine)
        {
            NSString * pointStr = [dic objectForKey:@"current"];
            NSArray * points = [pointStr componentsSeparatedByString:@","];
            //分时即时价格坐标
            itemPoint = CGPointMake([[points objectAtIndex:0] floatValue], [[points objectAtIndex:1] floatValue]);
            if (point.x>judgePoints.count*kLineWidth)
            {
                [self hideLongPressViews];
                return;
            }
        }
        else
        {
            NSString * pointStr = [dic objectForKey:@"closePoint"];
            NSArray * points = [pointStr componentsSeparatedByString:@","];
            // 收盘价的坐标
            itemPoint = CGPointMake([[points objectAtIndex:0] floatValue], [[points objectAtIndex:1] floatValue]);
            if (point.x>(currentData.count-1)*(kLineWidth+kLinePadding))
            {
                [self hideLongPressViews];
                return;
            }
        }
        itemPointX = itemPoint.x;
        int itemX = (int)itemPointX;
        int pointX = (int)point.x;
        if (itemX == pointX || point.x-itemX <= kLineWidth/2) {
            // 垂直提示日期控件
            horizontalLabel.text = [dic objectForKey:@"date"];
            if(isTimeLine)
            {
                // 显示即时价格
                [self showTimeViewWithIndex:i];
                verticalLabel.text = [NSString stringWithFormat:@"%@",[dic objectForKey:@"price"]];
            }
            else
            {
                [self showViewWithIndex:i];
                // 显示收盘价
                verticalLabel.text = [NSString stringWithFormat:@"%@",[dic objectForKey:@"close"]];
                // 均线值显示
                MA5Label.text = [NSString stringWithFormat:@"MA5:%.2f",[[dic objectForKey:@"ma5"] floatValue]];
                [MA5Label sizeToFit];
                MA10Label.text = [NSString stringWithFormat:@"MA10:%.2f",[[dic objectForKey:@"ma10"]floatValue]];
                [MA10Label sizeToFit];
                MA10Label.frame = CGRectMake(MA5Label.frame.origin.x+MA5Label.frame.size.width+10, MA10Label.frame.origin.y, MA10Label.frame.size.width, MA10Label.frame.size.height);
                MA20Label.text = [NSString stringWithFormat:@"MA20:%.2f",[[dic objectForKey:@"ma20"] floatValue]];
                [MA20Label sizeToFit];
                MA20Label.frame = CGRectMake(MA10Label.frame.origin.x+MA10Label.frame.size.width+10, MA20Label.frame.origin.y, MA20Label.frame.size.width, MA20Label.frame.size.height);
            }
            
            horizontalLine.frame = CGRectMake(15+itemPointX,horizontalLine.frame.origin.y, horizontalLine.frame.size.width, horizontalLine.frame.size.height);
            verticalLine.frame = CGRectMake(verticalLine.frame.origin.x,itemPoint.y+30, verticalLine.frame.size.width, verticalLine.frame.size.height);
            
            horizontalLabel.frame = CGRectMake(itemPoint.x-horizontalLabel.frame.size.width/2+15, viewHeight -95, horizontalLabel.frame.size.width, horizontalLabel.frame.size.height);
            verticalLabel.frame = CGRectMake(0,itemPoint.y - verticalLabel.frame.size.height/2+30,
                                             verticalLabel.frame.size.width, verticalLabel.frame.size.height);
            break;
        }
    }
}

- (void)buttonClickedAtIndex:(NSInteger)index
{
    
}
@end
