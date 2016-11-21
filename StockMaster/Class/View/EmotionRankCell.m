//
//  EmotionRankCell.m
//  StockMaster
//
//  Created by 孤星之殇 on 15/5/5.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import "EmotionRankCell.h"
#import "CHNMacro.h"
#import "UIImage+UIColor.h"
#import "NSString+UIColor.h"

@implementation EmotionRankCell
@synthesize rankImageView;
@synthesize stockNameLabel;
@synthesize totalBuyLabel;
@synthesize totalProfitLabel;
@synthesize emotionLabel;
@synthesize rankLabel;
@synthesize emotionNumLabel;
@synthesize buyNumLabel;
@synthesize profitNumLabel;

- (void)dealloc
{
}

- (void)awakeFromNib {

}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self)
    {
        [self createUI];
    }

    return self;
}

- (void)createUI
{
    rankImageView = [[UIImageView alloc] init];
    rankImageView.frame = CGRectMake(15, 24, 23, 33);
    [self addSubview:rankImageView];
    
    rankLabel = [[UILabel alloc] init];
    rankLabel.frame = CGRectMake(15, 0, 30, 80);
    rankLabel.font = NormalFontWithSize(25);
    rankLabel.textColor = KFontNewColorB;
    rankLabel.backgroundColor = [UIColor clearColor];
    rankLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:rankLabel];
    
    emotionLabel = [[UILabel alloc] init];
    emotionLabel.textAlignment = NSTextAlignmentLeft;
    emotionLabel.textColor = KFontNewColorA;
    emotionLabel.font = NormalFontWithSize(15);
    emotionLabel.backgroundColor = [UIColor clearColor];
    emotionLabel.frame = CGRectMake(CGRectGetMaxX(rankImageView.frame)+10, 24, 60, 15);
    emotionLabel.text = @"感情度：";
    [self addSubview:emotionLabel];
    
    emotionNumLabel = [[UILabel alloc] init];
    emotionNumLabel.textAlignment = NSTextAlignmentLeft;
    emotionNumLabel.textColor = kRedColor;
    emotionNumLabel.font = NormalFontWithSize(15);
    emotionNumLabel.backgroundColor = [UIColor clearColor];
    emotionNumLabel.frame = CGRectMake(CGRectGetMaxX(emotionLabel.frame), 24, 200, 15);
    [self addSubview:emotionNumLabel];
    
    stockNameLabel = [[UILabel alloc] init];
    stockNameLabel.textAlignment = NSTextAlignmentLeft;
    stockNameLabel.textColor = KFontNewColorA;
    stockNameLabel.font = NormalFontWithSize(15);
    stockNameLabel.backgroundColor = [UIColor clearColor];
    stockNameLabel.frame = CGRectMake(CGRectGetMinX(emotionLabel.frame), CGRectGetMaxY(emotionLabel.frame)+9, 75, 15);
    [self addSubview:stockNameLabel];

    totalBuyLabel = [[UILabel alloc] init];
    totalBuyLabel.textAlignment = NSTextAlignmentLeft;
    totalBuyLabel.font = NormalFontWithSize(10);
    totalBuyLabel.textColor = KFontNewColorB;
    totalBuyLabel.backgroundColor = [UIColor clearColor];
    totalBuyLabel.frame = CGRectMake(CGRectGetMaxX(stockNameLabel.frame)-10, CGRectGetMinY(stockNameLabel.frame)+2, 50, 15);
    totalBuyLabel.text = @"累计买入：";
    [self addSubview:totalBuyLabel];
    
    buyNumLabel = [[UILabel alloc] init];
    buyNumLabel.textAlignment = NSTextAlignmentLeft;
    buyNumLabel.font = BoldFontWithSize(10);
    buyNumLabel.textColor = kRedColor;
    buyNumLabel.backgroundColor = [UIColor clearColor];
    buyNumLabel.frame = CGRectMake(CGRectGetMaxX(totalBuyLabel.frame)-5, CGRectGetMinY(stockNameLabel.frame)+2, 70, 15);
    [self addSubview:buyNumLabel];
    
    totalProfitLabel = [[UILabel alloc] init];
    totalProfitLabel.textAlignment = NSTextAlignmentLeft;
    totalProfitLabel.font = NormalFontWithSize(10);
    totalProfitLabel.textColor = KFontNewColorB;
    totalProfitLabel.backgroundColor = [UIColor clearColor];
    totalProfitLabel.frame = CGRectMake(CGRectGetMaxX(buyNumLabel.frame) -25, CGRectGetMinY(totalBuyLabel.frame), 50, 15);
    totalProfitLabel.text = @"累计盈利：";
    [self addSubview:totalProfitLabel];
    
    profitNumLabel = [[UILabel alloc] init];
    profitNumLabel.textAlignment = NSTextAlignmentLeft;
    profitNumLabel.font = BoldFontWithSize(10);
    profitNumLabel.textColor = kRedColor;
    profitNumLabel.backgroundColor = [UIColor clearColor];
    profitNumLabel.frame = CGRectMake(CGRectGetMaxX(totalProfitLabel.frame)-5, CGRectGetMinY(totalBuyLabel.frame), 70, 15);
    [self addSubview:profitNumLabel];

    
    rightImageView = [[UIImageView alloc] init];
    rightImageView.image = [UIImage imageNamed:@"jiantou-you"];
    rightImageView.frame = CGRectMake(screenWidth -31, 35, 11, 20);
    [self addSubview:rightImageView];
    
    UILabel * lineLabel = [[UILabel alloc] init];
    lineLabel.backgroundColor = KLineNewBGColor1;
    lineLabel.frame  = CGRectMake(15, 79.5, screenWidth - 30,0.5 );
    [self addSubview:lineLabel];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
