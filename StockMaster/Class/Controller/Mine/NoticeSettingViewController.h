//
//  NoticeSettingViewController.h
//  StockMaster
//
//  Created by Rebloom on 15/3/16.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"

@interface NoticeSettingViewController : BasicViewController <UIPickerViewDataSource,UIPickerViewDelegate>
{
    UILabel * stockName;
    UILabel * stockID;
    UILabel * currentPrice;
    UILabel * updownRange;
    
    UILabel * switchLabel;
    UISwitch * stockSwitch;
    
    UILabel * upRangeLabel;
    UILabel * downRangeLabel;
    
    UILabel * upRange;
    UILabel * downRange;
    
    UILabel * upPrice;
    UILabel * downPrice;
    
    UIView * switchView;
    UIView * rangeView;
    
    UIView * pickContainer;
    UIView * barView;
    UIPickerView * pickView;
    
    NSMutableArray * upArr;
    NSMutableArray * downArr;
    
    BOOL isUp;
    BOOL isOn;
    
    NSString * upKey;
    NSString * downKey;
    NSInteger selectedIndex;
    
    UILabel * tipLabel;
}

@property (nonatomic, strong) StockInfoEntity * stockInfo;

@end
