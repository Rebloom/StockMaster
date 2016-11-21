//
//  PropBagCell.h
//  StockMaster
//
//  Created by 孤星之殇 on 15/7/1.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol funcDelegate <NSObject>

- (void)propCardFunction:(NSInteger)tag;

- (void)buyCardFunction:(NSInteger)tag;

@end

@interface PropBagCell : UITableViewCell
{
    UILabel * nameLabel;
    UILabel * desLabel;    
    UIImageView * propImageView;
    UILabel * lineLabel;
}

@property (nonatomic, strong)UILabel * nameLabel;
@property (nonatomic, strong)UILabel * desLabel;
@property (nonatomic, strong)UIImageView * propImageView;
@property (nonatomic, strong)UILabel * lineLabel;

@property (nonatomic, strong) UILabel * numberLabel;
@property (nonatomic, strong) UILabel * useLabel;
@property (nonatomic, strong) UILabel * timeupLabel;
@property (nonatomic, strong) UILabel * originPrice;
@property (nonatomic, strong) UIView * originPriceLine;
@property (nonatomic, strong) UILabel * currentPrice;

@property (nonatomic, strong) UIButton * useBtn;
@property (nonatomic, strong) UIButton * buyBtn;

@property (nonatomic, weak)id<funcDelegate>delegate;
@end
