//
//  InformationCell.h
//  StockMaster
//
//  Created by dalikeji on 15/3/13.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InformationCell : UITableViewCell
{
    UILabel * redLabel;
    UILabel * timeLabel;
    UILabel * titleLabel;
    UILabel * contentLabel;
}

@property(nonatomic,strong) UILabel * redLabel;
@property(nonatomic,strong) UILabel * timeLabel;
@property(nonatomic,strong) UILabel * titleLabel;
@property(nonatomic,strong) UILabel * contentLabel;

@end
