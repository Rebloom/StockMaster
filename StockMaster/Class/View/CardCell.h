//
//  CardCell.h
//  StockMaster
//
//  Created by Rebloom on 14-7-29.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardCell : UITableViewCell
{
    UIImageView * bankImage;
    UILabel * bankName;
    UILabel * bankType;
    UILabel * bankID;
    UIImageView * cellBgView;
    UIImageView * logoView;
}

@property (nonatomic, strong) UIImageView * bankImage;
@property (nonatomic, strong) UILabel * bankName;
@property (nonatomic, strong) UILabel * bankType;
@property (nonatomic, strong) UILabel * bankID;
@property (nonatomic, strong) UIImageView * cellBgView;
@property (nonatomic, strong) UIImageView * logoView;
@end
