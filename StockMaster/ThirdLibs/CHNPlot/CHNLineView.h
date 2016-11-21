//
//  CHNLineView.h
//  StockMaster
//
//  Created by Rebloom on 14-8-25.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+UIColor.h"
#import "GFRequestManager.h"
#import "TKAlertCenter.h"

#import "CHNLine.h"
#import "StockPoint.h"
#import "MBProgressHUD.h"
#import "CHNAlertView.h"
#import "StockInfoCoreDataStorage.h"

typedef void(^updateBlock)(id);

@interface CHNLineView : UIView <ASIHTTPRequestDelegate,CHNAlertViewDelegate>
{
    CGFloat xWidth;             // 整体视图的宽
    CGFloat yHeight;            // 上面视图的高
    CGFloat bottomBoxHeight;    // 下面视图的高
    CGFloat kLineWidth;         // K线的宽，用来计算可以存放K线实体的个数
    CGFloat kLinePadding;
    int kCount;                 // k线中实体的总数 通过 xWidth / kLineWidth 计算而来

    UIView *kView;              // k线图
    UIView *volumeView;         // 成交量视图
    UIView *horizontalLine;     // 垂直线
    UIView *verticalLine;       // 水平线
    UILabel *horizontalLabel;
    UILabel *verticalLabel;
    
    CGFloat MADays;
    UILabel *MA5Label;               // 5均线显示
    UILabel *MA10Label;              // 10均线
    UILabel *MA20Label;              // 20均线

    UIView * showView;
    UIView * showTimeLineView;
    
    UILabel * startDateLab;
    UILabel * midDateLab;
    UILabel * endDateLab;
    UILabel *volMaxValueLab;    // 显示成交量最大值

    UITapGestureRecognizer * tapGesture;
    UIPinchGestureRecognizer *pinchGesture;
    UILongPressGestureRecognizer * longPressGesture;
    UIPanGestureRecognizer * panGesture;
    CGPoint touchViewPoint;
    
    CGFloat maxValue;
    CGFloat minValue;
    CGFloat maxRangeValue;
    CGFloat minRangeValue;
    CGFloat volMaxValue;
    CGFloat volMinValue;
    
    CGFloat viewWidth;
    CGFloat viewHeight;

    NSInteger startIndex;
    NSMutableArray * totalData;      // 全部的数据
    NSMutableArray * currentData;    // 存储为对象
    NSMutableArray * kLineTimeData;  // 分时数据
    BOOL isTimeLine;
    
    CHNLine * kLine;
    CHNLine * volumeLine;
    CHNLine * MA5Line;
    CHNLine * MA10Line;
    CHNLine * MA20Line;
    CHNLine * timeLine;
    CHNLine * timeAvgLine;
    
    BOOL isDrawLeftLabel;
    BOOL isDrawRightLabel;
    
    UIImageView * volumeImageLine;
}

@property (nonatomic, strong) StockInfoEntity * stockInfo;
@property (nonatomic, copy) NSString * type;

@property (nonatomic, assign)CGFloat kLineWidth;
@property (nonatomic, assign)CGFloat kLinePadding;

-(void)start;
- (void)requestKLineWithType:(NSString *)stockType;

@end
