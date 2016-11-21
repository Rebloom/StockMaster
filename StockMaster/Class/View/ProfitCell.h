//
//  ProfitCell.h
//  StockMaster
//
//  Created by dalikeji on 14-9-12.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfitCell : UITableViewCell
{
    UILabel * verticalLine;
    UILabel * rankLabel;
    UIImageView * icoImage;
    UILabel * name;
    UILabel * profit;
    UILabel * profitDetail;
    UIImageView * rightView;
    UILabel * lineLb;
}
@property(nonatomic ,strong) UILabel * verticalLine;
@property(nonatomic ,strong) UILabel * rankLabel;
@property(nonatomic ,strong) UIImageView * icoImage;
@property(nonatomic ,strong) UILabel * name;
@property(nonatomic ,strong) UILabel * profit;
@property(nonatomic ,strong) UILabel * profitDetail;
@property(nonatomic ,strong) UIImageView * rightView;
@property(nonatomic ,strong) UILabel * lineLb;
@end
