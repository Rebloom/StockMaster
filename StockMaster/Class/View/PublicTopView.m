//
//  PublicTopView.m
//  StockMaster
//
//  Created by Rebloom on 15/2/12.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//


#define kPublicTopLineHeight        70

#define kPublicTopBottomHeight      50

#define kPublicTopHeight            iPhone6Plus?183:iPhone6?161:130

#define kPointNum                   9

#define kGreedLineColor             @"#6bd8b6"
#define kGreenFillColor             @"#55b597"
#define kRedLineColor               @"#fda09c"
#define kRedFillColor               @"#e26e68"

// type = 1 新用户;  = 2 盈利用户; = 3 小赔用户;  = 4 大赔用户
typedef enum USERSTATUS
{
    NewUser = 1,
    BenifitUser,
    SmallLoseUser,
    BigLoseUser,
}_USERRSTATUS;

#import "PublicTopView.h"
#import "UIImage+UIColor.h"

@implementation PublicTopView

@synthesize pointArr;

@synthesize animateArr;

@synthesize delegate;

@synthesize _userInfo;

@synthesize lineChart;

-(void)dealloc
{
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
    }
    
    pointArr = [[NSMutableArray alloc] init];
    animateArr = [[NSMutableArray alloc] init];
    
    lineChart=[[CAShapeLayer alloc] init];
    lineChart.lineCap = kCALineCapRound;
    lineChart.fillColor = nil;
    lineChart.lineWidth = 2;
    
    return self;
}

- (void)transInfo:(NSDictionary *)userInfo
{
    _userInfo = userInfo;
    for (UIView * view in self.subviews)
    {
        if (view.tag >= 1000)
        {
            [view removeFromSuperview];
        }
    }
    
    if (pointArr.count)
    {
        [pointArr removeAllObjects];
    }
    
    if (animateArr.count)
    {
        [animateArr removeAllObjects];
    }

    if (!qipaoImage)
    {
        qipaoImage = [[UIImageView alloc] init];
        qipaoImage.userInteractionEnabled = YES;
        [self addSubview:qipaoImage];
    }
    
    if (!feetView)
    {
        feetView = [[UIView alloc] initWithFrame:CGRectMake(0, kPublicTopHeight, screenWidth, 50)];
        
        [self addSubview:feetView];
    }
    
    if (!totalMoney)
    {
        totalMoney = [[UILabel alloc] init];
        totalMoney.backgroundColor = [UIColor whiteColor];
        totalMoney.font = NormalFontWithSize(13);
        totalMoney.layer.cornerRadius = 8;
        totalMoney.layer.masksToBounds = YES;
        totalMoney.textAlignment = NSTextAlignmentCenter;
        [self addSubview:totalMoney];
    }
    
    if (!rightImage && [GFStaticData getObjectForKey:kTagAppStoreClose])
    {
        rightImage = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-25, 15, 10, 19)];
        rightImage.image = [UIImage imageNamed:@"icon_jiantou3"];
        [feetView addSubview:rightImage];
    }
    
    if (!whitePoint)
    {
        whitePoint = [[UIView alloc] init];
        whitePoint.backgroundColor = [UIColor whiteColor];
        whitePoint.layer.cornerRadius = 4;
        whitePoint.layer.masksToBounds = YES;
        [self addSubview:whitePoint];
    }
    
    if (!centerPoint)
    {
        centerPoint = [[UIView alloc] init];
        centerPoint.layer.cornerRadius = 2;
        centerPoint.layer.masksToBounds = YES;
        [self addSubview:centerPoint];
    }
    
    if (!ruleBtn)
    {
        ruleBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, HeaderViewHeight-50, screenWidth, 50)];
    }
    [ruleBtn addTarget:self action:@selector(bottomBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [ruleBtn setBackgroundColor:[UIColor clearColor]];
    [self addSubview:ruleBtn];
    [self bringSubviewToFront:ruleBtn];
    
    NSArray * histroyArr = [userInfo objectForKey:@"history_assets"];
    NSMutableArray * dataArr = [NSMutableArray array];
    
    for (int i= 0; i < [histroyArr count]; i++)
    {
        [dataArr addObject:[[histroyArr objectAtIndex:i] objectForKey:@"total_yield"]];
    }
    
    float Max = 0;
    float Min = CGFLOAT_MAX;
    for (int i = 0; i < dataArr.count; i++)
    {
        if ([[dataArr objectAtIndex:i] floatValue] > Max)
        {
            Max = [[dataArr objectAtIndex:i] floatValue];
        }
        if ([[dataArr objectAtIndex:i] floatValue] < Min)
        {
            Min = [[dataArr objectAtIndex:i] floatValue];
        }
    }
    
    CGFloat base_money = [[[userInfo objectForKey:@"base_money"] description] floatValue];
    if ([[dataArr lastObject] floatValue] >= base_money)
    {
        if ([self.delegate respondsToSelector:@selector(setStatusBarColor:)])
        {
            [self.delegate setStatusBarColor:kRedColor];
        }
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(setStatusBarColor:)])
        {
            [self.delegate setStatusBarColor:kGreenColor];
        }
    }
    
    float useY = Max-Min;
    if (useY == 0)
    {
        useY = kPublicTopLineHeight;
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
            [pointArr addObject:[NSValue valueWithCGPoint:CGPointMake(0, kPublicTopLineHeight * (1 - (heightValue - Min) / useY)+kPublicTopBottomHeight)]];
            [animateArr addObject:[NSValue valueWithCGPoint:CGPointMake(0, kPublicTopLineHeight * (1 - (heightValue - Min) / useY)+kPublicTopBottomHeight)]];
        }
        [pointArr addObject:[NSValue valueWithCGPoint:CGPointMake(25+i*(screenWidth-50)/kPointNum, kPublicTopLineHeight * (1 - (heightValue - Min) / useY)+kPublicTopBottomHeight)]];
        [animateArr addObject:[NSValue valueWithCGPoint:CGPointMake(25+i*(screenWidth-50)/kPointNum, kPublicTopLineHeight * (1 - (heightValue - Min) / useY)+kPublicTopBottomHeight)]];
        
        UIView * pointView = [[UIView alloc] initWithFrame:CGRectMake(25+i*(screenWidth-50)/kPointNum-2, kPublicTopLineHeight * (1 - (heightValue - Min) / useY)+kPublicTopBottomHeight-2, 4, 4)];
        pointView.backgroundColor = [UIColor whiteColor];
        pointView.layer.masksToBounds = YES;
        pointView.layer.cornerRadius = 2;
        pointView.tag = 1000+i;
        [self addSubview:pointView];
        
        UIButton * listenerBtn = [[UIButton alloc] initWithFrame:CGRectMake(25+i*(screenWidth-50)/kPointNum-10, kPublicTopLineHeight * (1 - (heightValue - Min) / useY)+kPublicTopBottomHeight-10, 20, 20)];
        [listenerBtn addTarget:self action:@selector(listenerBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        listenerBtn.tag = i;
        [self addSubview:listenerBtn];
        
        if (i == dataArr.count-1)
        {
            qipaoImage.frame = CGRectMake(0, 0, 14, 2);
            totalMoney.frame = CGRectMake(0, 0, 115, 24);
            NSDictionary * dateInfo = [histroyArr objectAtIndex:i];
            NSString * titleStr = [NSString stringWithFormat:@"%@:%@",[dateInfo objectForKey:@"date_day"],[dateInfo objectForKey:@"total_yield"]];
            totalMoney.text = titleStr;
            
            qipaoImage.center = CGPointMake(pointView.center.x, pointView.center.y-5.5);
            totalMoney.center = CGPointMake(pointView.center.x-45, pointView.center.y-18);
            
            whitePoint.frame = CGRectMake(0, 0, 8, 8);
            whitePoint.center = CGPointMake(screenWidth-25, kPublicTopLineHeight * (1 - (heightValue - Min) / useY)+kPublicTopBottomHeight);
            
            centerPoint.frame = CGRectMake(0, 0, 4, 4);
            centerPoint.center = CGPointMake(whitePoint.center.x, whitePoint.center.y);
            
            [pointArr addObject:[NSValue valueWithCGPoint:CGPointMake(screenWidth, kPublicTopLineHeight * (1 - (heightValue - Min) / useY)+kPublicTopBottomHeight)]];
            [animateArr addObject:[NSValue valueWithCGPoint:CGPointMake(screenWidth, kPublicTopLineHeight * (1 - (heightValue - Min) / useY)+kPublicTopBottomHeight)]];
        }
    }
    NSString * totolProfit = [userInfo objectForKey:@"total_profit_money"];
    
    if ([totolProfit componentsSeparatedByString:@"-"].count > 1)
    {
        isUp = NO;
        self.backgroundColor = kGreenColor;
        totalMoney.textColor = kGreenColor;
        centerPoint.backgroundColor = kGreenColor;
        feetView.backgroundColor = @"#61c5a5".color;
        qipaoImage.image = [UIImage imageNamed:@"sanjiao"];
    }
    else
    {
        isUp = YES;
        self.backgroundColor = kRedColor;
        feetView.backgroundColor = @"#f57c76".color;
        totalMoney.textColor = kRedColor;
        centerPoint.backgroundColor = kRedColor;
        qipaoImage.image = [UIImage imageNamed:@"sanjiao"];
    }
    
    if (!headerDescLabel)
    {
        headerDescLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, screenWidth-30, 50)];
        headerDescLabel.userInteractionEnabled = YES;
        headerDescLabel.textColor = [UIColor whiteColor];
        headerDescLabel.font = NormalFontWithSize(15);
        [feetView addSubview:headerDescLabel];
    }
    headerDescLabel.text = [userInfo objectForKey:@"withdraw_pool_prompt_string"];
    
    
    if (!closedIndicator)
    {
        closedIndicator = [[RMDownloadIndicator alloc]initWithFrame:CGRectMake(15, 10, 30, 30) type:kRMClosedIndicator];
        [closedIndicator setBackgroundColor:[UIColor clearColor]];
        [closedIndicator setFillColor:[UIColor clearColor]];
        [closedIndicator setStrokeColor:kRedColor];
        closedIndicator.radiusPercent = .5;
        [feetView addSubview:closedIndicator];
    }
    
    if (!statusLabel)
    {
        statusLabel = [[UILabel alloc] initWithFrame:closedIndicator.frame];
        statusLabel.backgroundColor = [UIColor clearColor];
        statusLabel.textAlignment = NSTextAlignmentCenter;
        statusLabel.font = NormalFontWithSize(13);
        statusLabel.textColor = [UIColor whiteColor];
        [feetView addSubview:statusLabel];
    }
    statusLabel.text = [userInfo objectForKey:@"withdraw_pool_type_string"];
    
    if ([[userInfo objectForKey:@"withdraw_pool_is_time_prompt"] integerValue])
    {
        closedIndicator.hidden = NO;
    }
    else
    {
        closedIndicator.hidden = YES;
    }
    
    if ([totolProfit componentsSeparatedByString:@"-"].count > 1)
    {
        [closedIndicator setStrokeColor:@"#61c5a5".color];
    }
    else
    {
        [closedIndicator setStrokeColor:@"#f57c76".color];
    }
    [closedIndicator loadIndicator];
    
    CGFloat leftS = [[userInfo objectForKey:@"withdraw_pool_surplus_time"] floatValue];
    CGFloat totalS = [[userInfo objectForKey:@"withdraw_pool_total_time"] floatValue];
    
    CGFloat percent = leftS/totalS;
    [closedIndicator updateWithTotalBytes:1 downloadedBytes:1-percent];
    
    [self animateLine];
    [self bringSubviewToFront:qipaoImage];
    [self bringSubviewToFront:totalMoney];
}

- (void)animateLine
{
    UIBezierPath *progressline=[UIBezierPath bezierPath];
    [progressline setLineCapStyle:kCGLineCapRound];
    if (isUp)
    {
        lineChart.strokeColor = [kRedLineColor.color CGColor];
    }
    else
    {
        lineChart.strokeColor= [kGreedLineColor.color CGColor];
    }
    [self.layer addSublayer:lineChart];
    
    for (int i = 0; i < animateArr.count; i++)
    {
        CGPoint p = [(NSValue *)animateArr[i] CGPointValue];;
        if(i == 0)
        {
            [progressline moveToPoint:p];
        }
        else
        {
            [progressline addLineToPoint:p];
        }
        lineChart.path = progressline.CGPath;
    }
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 2.0;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    pathAnimation.autoreverses = NO;
    [lineChart addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
    lineChart.strokeEnd = 1.0;
    
    [UIView beginAnimations:nil context:nil]; //标记动画的开始
    //持续时间
    [UIView setAnimationDuration:2.0f];  //动画的持续时间
    
    [UIView commitAnimations];//标记动画的结束
    
    for (UIView * view in self.subviews)
    {
        if (view.tag >= 1000)
        {
            [self bringSubviewToFront:view];
        }
    }
    [self bringSubviewToFront:whitePoint];
}

- (void)listenerBtnClicked:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    
    if (btn.tag < 3)
    {
        qipaoImage.center = CGPointMake(btn.center.x, btn.center.y-5.5);
        totalMoney.center = CGPointMake(btn.center.x+30, btn.center.y-18);
    }
    else if (btn.tag > 6)
    {
        qipaoImage.center = CGPointMake(btn.center.x, btn.center.y-5.5);
        totalMoney.center = CGPointMake(btn.center.x-45, btn.center.y-18);
    }
    else
    {
        qipaoImage.center = CGPointMake(btn.center.x, btn.center.y-5.5);
        totalMoney.center = CGPointMake(btn.center.x, btn.center.y-18);
    }
    
    
    NSDictionary * dateInfo = [[_userInfo objectForKey:@"history_assets"] objectAtIndex:btn.tag];
    NSString * titleStr = [NSString stringWithFormat:@"%@:%@",[dateInfo objectForKey:@"date_day"],[dateInfo objectForKey:@"total_yield"]];
    totalMoney.text = titleStr;
    
    whitePoint.frame = CGRectMake(0, 0, 8, 8);
    whitePoint.center = btn.center;
    
    centerPoint.frame = CGRectMake(0, 0, 4, 4);
    centerPoint.center = CGPointMake(whitePoint.center.x, whitePoint.center.y);
}

- (void)bottomBtnClicked:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(ruleBtnClicked:)])
    {
        [self.delegate ruleBtnClicked:sender];
    }
}

- (void)drawRect:(CGRect)rect
{
    [self setClearsContextBeforeDrawing: YES];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, .5);
    if (isUp)
    {
        CGContextSetStrokeColorWithColor(context, kRedFillColor.color.CGColor);
        [kRedFillColor.color setFill];
    }
    else
    {
        CGContextSetStrokeColorWithColor(context, kGreenFillColor.color.CGColor);
        [kGreenFillColor.color setFill];
    }
    CGContextMoveToPoint(context, -5, kPublicTopHeight);
    if (pointArr.count > 3)
    {
        for (int i = 0; i < pointArr.count; i++)
        {
            NSValue *pointValue = pointArr[i];
            CGPoint  point      = [pointValue CGPointValue];
            CGContextAddLineToPoint(context, point.x,point.y);
        }
        CGContextAddLineToPoint(context, screenWidth+10, kPublicTopHeight);
        CGContextAddLineToPoint(context, -10, kPublicTopHeight);
        
        CGContextDrawPath(context, kCGPathFillStroke);
    }
}

@end
