//
//  TimeLine.m
//  StockMaster
//
//  Created by dalikeji on 15/3/11.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import "TimeLine.h"

@implementation TimeLine
@synthesize points = _points;
@synthesize lineType;

- (void)dealloc
{
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initSet];
    }
    return self;
}

#pragma mark 初始化参数
-(void)initSet{
    self.backgroundColor = [UIColor clearColor];
    self.startPoint = self.frame.origin;
    self.endPoint = self.frame.origin;
    self.color = @"#000000";
    self.lineWidth = 1.0f;
}

- (void)setPoints:(NSMutableArray *)points
{
    if (_points)
    {
        _points = nil;
    }
    _points = [points mutableCopy];
}

-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (self.lineType == 1 || self.lineType == 2) {
        // 画k线
        for (NSDictionary * dic in self.points)
        {
            CGPoint heightPoint,lowPoint,openPoint,closePoint;
            NSArray *heightArr,*lowArr,*openArr,*closeArr;
            heightArr = [[dic objectForKey:@"high"] componentsSeparatedByString:@","];
            lowArr = [[dic objectForKey:@"low"] componentsSeparatedByString:@","];
            openArr = [[dic objectForKey:@"open"] componentsSeparatedByString:@","];
            closeArr = [[dic objectForKey:@"closePoint"] componentsSeparatedByString:@","];
            
            heightPoint = CGPointMake([[heightArr objectAtIndex:0] floatValue], [[heightArr objectAtIndex:1] floatValue]);
            lowPoint = CGPointMake([[lowArr objectAtIndex:0] floatValue], [[lowArr objectAtIndex:1] floatValue]);
            openPoint = CGPointMake([[openArr objectAtIndex:0] floatValue], [[openArr objectAtIndex:1] floatValue]);
            closePoint = CGPointMake([[closeArr objectAtIndex:0] floatValue], [[closeArr objectAtIndex:1] floatValue]);
            [self drawKWithContext:context height:heightPoint Low:lowPoint open:openPoint close:closePoint width:self.lineWidth withColor:[[dic objectForKey:@"color"] description]];
        }
    }else{
        // 画连接线
        [self drawLineWithContext:context];
    }
}

-(void)drawLineWithContext:(CGContextRef)context
{
    NSMutableArray * tempPoints = [NSMutableArray array];
    
    for (NSDictionary * dic in self.points)
    {
        NSArray * currentArr = [[dic objectForKey:@"current"] componentsSeparatedByString:@","];
        CGPoint currentPoint = CGPointMake([[currentArr objectAtIndex:0] floatValue], [[currentArr objectAtIndex:1] floatValue]);
        [tempPoints addObject:[NSValue valueWithCGPoint:currentPoint]];
    }
    if (self.lineType == 3)
    {
        if (tempPoints.count > 1) {
            for (NSUInteger index = 0; index < tempPoints.count - 1; index++)
            {
                CGPoint p0 = [(NSValue *)tempPoints[index] CGPointValue];
                CGPoint p1 = [(NSValue *)tempPoints[index+1] CGPointValue];
                
                CGContextSetLineWidth(context,1.5);
                [kFontColorA setStroke];
                
                CGContextMoveToPoint(context, p0.x-.5, p0.y-.5);
                
                CGContextAddLineToPoint(context, p1.x-.5, p1.y-.5);
                
                if (index == tempPoints.count -2)
                {
                    UIImageView * yuanImageView = [[UIImageView alloc] init];
                    yuanImageView.image = [UIImage  imageNamed:@"zhagnzhagn_light_oval"];
                    yuanImageView.frame = CGRectMake(0, 0, 12, 12);
                    yuanImageView.center = CGPointMake(p1.x- 1, p1.y-1);
                    [self addSubview:yuanImageView];
                    
                    NSDate* now = [NSDate date];
                    NSCalendar *cal = [NSCalendar currentCalendar];
                    unsigned int unitFlags =  NSHourCalendarUnit | NSMinuteCalendarUnit ;
                    NSDateComponents *dd = [cal components:unitFlags fromDate:now];
                    
                    int hour = (int)[dd hour];
                    int min = (int)[dd minute];
                    
                    
                    if (hour >= 15)
                    {
                        yuanImageView.hidden = YES;
                    }
                    if (hour>= 9 && hour < 15 )
                    {
                        if (hour == 9)
                        {
                            if (min > 30)
                            {
                                yuanImageView.hidden = NO;
                            }
                        }
                        else
                        {
                            yuanImageView.hidden = NO;
                        }
                    }
                }
                CGContextStrokePath(context);
            }
        }
    }
    else if (self.lineType == 4)
    {
        [self drawLineTogetherWithContext:context];
    }
}

- (void)drawLineTogetherWithContext:(CGContextRef)context
{
    CGContextSetLineWidth(context, 1);
    CGContextSetShouldAntialias(context, YES);
    CGContextSetRGBStrokeColor(context,  [Utility Color:self.color RGB255:1], [Utility Color:self.color RGB255:2],
                               [Utility Color:self.color RGB255:3], self.alpha);
    if (self.startPoint.x==self.endPoint.x && self.endPoint.y==self.startPoint.y) {
        for (NSDictionary * dic in self.points) {
            NSArray * currentArr = [[dic objectForKey:@"current"] componentsSeparatedByString:@","];
            
            CGPoint currentPoint = CGPointMake([[currentArr objectAtIndex:0] floatValue], [[currentArr objectAtIndex:1] floatValue]);
            if ((int)currentPoint.y<(int)self.frame.size.height && currentPoint.y>0) {
                if ([self.points indexOfObject:dic]==0) {
                    CGContextMoveToPoint(context, currentPoint.x, currentPoint.y);
                    continue;
                }
                CGContextAddLineToPoint(context, currentPoint.x, currentPoint.y);
                CGContextStrokePath(context);
                if ([self.points indexOfObject:dic]<self.points.count) {
                    CGContextMoveToPoint(context, currentPoint.x, currentPoint.y);
                }
            }
        }
    }else{
        const CGPoint points[] = {self.startPoint,self.endPoint};
        CGContextStrokeLineSegments(context, points, 2);
    }
}

#pragma mark 画一根K线
-(void)drawKWithContext:(CGContextRef)context height:(CGPoint)heightPoint Low:(CGPoint)lowPoint open:(CGPoint)openPoint close:(CGPoint)closePoint width:(CGFloat)width withColor:(NSString *)color{
    CGContextSetShouldAntialias(context, NO);
    CGContextSetRGBStrokeColor(context,  [Utility Color:color RGB255:1], [Utility Color:color RGB255:2],
                               [Utility Color:color RGB255:3], self.alpha);
    // 定义两个点 画两点连线
    if (self.lineType == 1) {
        CGContextSetLineWidth(context, 1); // 上下阴影线的宽度
        if (self.lineWidth<=2) {
            CGContextSetLineWidth(context, .5); // 上下阴影线的宽度
        }
        const CGPoint points[] = {heightPoint,lowPoint};
        CGContextStrokeLineSegments(context, points, 2);  // 绘制线段（默认不绘制端点）
    }
    //------------------------------画影线--------------------------------
    
    
    //------------------------------交易量--------------------------------
    // 再画中间的实体
    CGContextSetLineWidth(context, width); // 改变线的宽度
    CGFloat halfWidth = 0;
    // 纠正实体的中心点为当前坐标
    openPoint = CGPointMake(openPoint.x-halfWidth, openPoint.y);
    closePoint = CGPointMake(closePoint.x-halfWidth, closePoint.y);
    
    if (self.lineType == 2) {
        openPoint = CGPointMake(heightPoint.x-halfWidth, heightPoint.y);
        closePoint = CGPointMake(lowPoint.x-halfWidth, lowPoint.y);
    }
    
    //------------------------------交易量--------------------------------
    
    // 开始画实体
    const CGPoint point[] = {openPoint,closePoint};
    CGContextSetLineCap(context, kCGLineCapButt) ;// 设置线段的端点形状，方形
    CGContextStrokeLineSegments(context, point, 2);  // 绘制线段（默认不绘制端点）
}

@end