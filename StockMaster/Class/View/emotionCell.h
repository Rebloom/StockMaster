//
//  emotionCell.h
//  StockMaster
//
//  Created by 孤星之殇 on 15/4/29.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface emotionCell : UITableViewCell
{
    UILabel * nameLabel;
    UILabel * numberLabel;
    UILabel * tipsLabel;
    UILabel * lineLabel;
    UILabel * desLabel;
}

@property (nonatomic, strong)UILabel * nameLabel;
@property (nonatomic, strong)UILabel * numberLabel;
@property (nonatomic, strong)UILabel * tipsLabel;
@property (nonatomic, strong)UILabel * lineLabel;
@property (nonatomic, strong)UILabel * desLabel;

@end
