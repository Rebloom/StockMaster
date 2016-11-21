//
//  MasterwCell.h
//  StockMaster
//
//  Created by dalikeji on 14-10-30.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MasterwCell : UITableViewCell

{
    UILabel * allLoadLabel;
    UILabel * rankLabel ;
    UILabel * name;
    UILabel * profit;
    UILabel * profitDetail;
    UILabel * lineLb;
    UILabel * holdLb;
    UIImageView * icoImage;
    UIImageView * rightView;
}
@property (nonatomic, strong) UILabel * allLoadLabel;
@property (nonatomic, strong) UILabel * rankLabel;
@property (nonatomic, strong) UILabel * name;
@property (nonatomic, strong) UILabel * profit;
@property (nonatomic, strong) UILabel * lineLb;
@property (nonatomic, strong) UILabel * holdLb;
@property (nonatomic, strong) UILabel * profitDetail;
@property (nonatomic, strong) UIImageView * icoImage;
@property (nonatomic, strong) UIImageView * rightView;
@end
