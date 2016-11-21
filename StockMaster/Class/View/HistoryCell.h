//
//  HistoryCell.h
//  StockMaster
//
//  Created by dalikeji on 14-10-20.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryCell : UITableViewCell
{
    UILabel * firstLabel;
    UILabel * secondLabel;
    UILabel * thirdLabel;
    UILabel * fourthLabel;
    UILabel * fifthLabel;
    UIImageView * marketIv;
    
    UIButton * withdrawBtn;
}

@property (nonatomic, strong) UILabel *firstLabel;
@property (nonatomic, strong) UILabel *secondLabel;
@property (nonatomic, strong) UILabel *thirdLabel;
@property (nonatomic, strong) UILabel *fourthLabel;
@property (nonatomic, strong) UILabel *fifthLabel;
@property (nonatomic, strong) UIImageView * marketIv;
@property (nonatomic, strong) UIButton * withdrawBtn;

@end
