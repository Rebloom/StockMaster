//
//  TimeLineView.h
//  StockMaster
//
//  Created by dalikeji on 15/3/11.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+UIColor.h"
#import "CHNMacro.h"
#import "GFRequestManager.h"
#import "TKAlertCenter.h"

#import "TimeLine.h"
#import "StockPoint.h"
#import "MBProgressHUD.h"
#import "CHNAlertView.h"

#import "StockInfoCoreDataStorage.h"


@interface TimeLineView : UIView<ASIHTTPRequestDelegate,CHNAlertViewDelegate>
{
    CGFloat bottomBoxHeight;    // 下面视图的高
    CGFloat kLineWidth;         // K线的宽，用来计算可以存放K线实体的个数
    CGFloat kLinePadding;
    
    UIView *kView;              // k线图
    UIView *volumeView;         // 成交量视图
    
    CGFloat MADays;

    UILabel *volMaxValueLab;    // 显示成交量最大值

    CGPoint touchViewPoint;
    
    CGFloat maxValue;
    CGFloat minValue;
    CGFloat maxRangeValue;
    CGFloat minRangeValue;
    CGFloat volMaxValue;
    CGFloat volMinValue;
    
    NSMutableArray * totalData;      // 全部的数据
    NSMutableArray * currentData;    // 存储为对象
    NSMutableArray * kLineTimeData;  // 分时数据
    BOOL isTimeLine;
    
    TimeLine * kLine;
    TimeLine * volumeLine;
    TimeLine * timeLine;

    UIImageView * volumeImageLine;
}

@property (nonatomic, strong) StockInfoEntity * stockInfo;
@property (nonatomic, copy) NSString * type;

@property (nonatomic, assign)CGFloat kLineWidth;
@property (nonatomic, assign)CGFloat kLinePadding;

- (void)start;
- (void)requestKLineWithType:(NSString *)stockType;

@end
