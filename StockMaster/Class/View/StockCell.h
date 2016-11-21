//
//  StockCell.h
//  StockMaster
//
//  Created by Rebloom on 14-7-24.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHNMacro.h"
#import "NSString+UIColor.h"

@interface StockCell : UITableViewCell
{
    UILabel * stockName;
    UILabel * stockID;
    UILabel * stockPrice;
    UILabel * stockNum;
    UILabel * stockProfit;
    UILabel * tipLb;
    UIImageView * rightView ;
    UIImageView * iconView;
}

@property (nonatomic, strong) UILabel *stockName;
@property (nonatomic, strong) UILabel *stockID;
@property (nonatomic, strong) UILabel *stockPrice;
@property (nonatomic, strong) UILabel *stockNum;
@property (nonatomic, strong) UILabel *stockProfit;
@property (nonatomic, strong) UIImageView * rightView;
@property (nonatomic, strong) UIImageView * iconView;
@property (nonatomic, strong) UILabel * tipLb;
@end
