//
//  EmotionRankCell.h
//  StockMaster
//
//  Created by 孤星之殇 on 15/5/5.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmotionRankCell : UITableViewCell
{
    UIImageView * rankImageView;
    UILabel * rankLabel;
    UIImageView * rightImageView;
    UILabel * emotionLabel;
    UILabel * emotionNumLabel;
    UILabel * stockNameLabel;
    UILabel * totalBuyLabel;
    UILabel * buyNumLabel;
    UILabel * totalProfitLabel;
    UILabel * profitNumLabel;
}
@property (nonatomic, strong)UIImageView * rankImageView;
@property (nonatomic, strong)UILabel * rankLabel;
@property (nonatomic, strong)UILabel * emotionLabel;
@property (nonatomic, strong)UILabel * stockNameLabel;
@property (nonatomic, strong)UILabel * totalBuyLabel;
@property (nonatomic, strong)UILabel * totalProfitLabel;
@property (nonatomic, strong)UILabel * profitNumLabel;
@property (nonatomic, strong)UILabel * emotionNumLabel;
@property (nonatomic, strong)UILabel * buyNumLabel;
@end
