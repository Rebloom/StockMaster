//
//  PropBagCell.m
//  StockMaster
//
//  Created by 孤星之殇 on 15/7/1.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import "PropBagCell.h"
#import "CHNMacro.h"
#import "NSString+UIColor.h"
#import "UIImage+UIColor.h"

@implementation PropBagCell
@synthesize nameLabel;
@synthesize desLabel;
@synthesize propImageView;
@synthesize delegate;
@synthesize lineLabel;

@synthesize numberLabel;
@synthesize useLabel;
@synthesize timeupLabel;
@synthesize originPrice;
@synthesize originPriceLine;
@synthesize currentPrice;

@synthesize useBtn;
@synthesize buyBtn;

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
    propImageView = [[UIImageView alloc] init];
    propImageView.frame = CGRectMake(15, 15, 70, 70);
    propImageView.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:propImageView];
    
    numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(propImageView.frame)-18, 15, 18, 15)];
    numberLabel.textColor = [UIColor whiteColor];
    numberLabel.textAlignment = NSTextAlignmentCenter;
    numberLabel.font = NormalFontWithSize(12);
    [self addSubview:numberLabel];
    
    useLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(propImageView.frame)-22.5, 70, 22.5)];
    useLabel.textAlignment = NSTextAlignmentCenter;
    useLabel.textColor = [UIColor whiteColor];
    useLabel.font = NormalFontWithSize(15);
    [self addSubview:useLabel];
    
    useBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(propImageView.frame)-30, 90, 44)];
    [useBtn addTarget:self action:@selector(funcBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:useBtn];
    
    buyBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth-125, CGRectGetMaxY(propImageView.frame)-30, 120, 44)];
    [buyBtn addTarget:self action:@selector(buyBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:buyBtn];

    nameLabel = [[UILabel alloc] init];
    nameLabel.frame = CGRectMake(CGRectGetMaxX(propImageView.frame)+9, CGRectGetMinY(propImageView.frame), 200, 16);
    nameLabel.font = NormalFontWithSize(15);
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.textColor = KFontNewColorA;
    [self addSubview:nameLabel];
    
    timeupLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(nameLabel.frame)+11, CGRectGetMinY(propImageView.frame), 120, 16)];
    timeupLabel.backgroundColor = [UIColor clearColor];
    timeupLabel.font = NormalFontWithSize(10);
    timeupLabel.textColor = KFontNewColorA;
    timeupLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:timeupLabel];
    
    currentPrice = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth-115, CGRectGetMinY(useLabel.frame)+1, 100, 15)];
    currentPrice.backgroundColor = [UIColor clearColor];
    currentPrice.font = NormalFontWithSize(15);
    currentPrice.textAlignment = NSTextAlignmentRight;
    [self addSubview:currentPrice];
    
    originPrice = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(currentPrice.frame)-30, CGRectGetMinY(useLabel.frame), 49, 15)];
    originPrice.backgroundColor = [UIColor clearColor];
    originPrice.font = NormalFontWithSize(15);
    originPrice.textAlignment = NSTextAlignmentRight;
    [self addSubview:originPrice];
    
    originPriceLine = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(currentPrice.frame)-30, 0, 49, 1)];
    originPriceLine.center = originPrice.center;
    [self addSubview:originPriceLine];
    
    desLabel = [[UILabel alloc] init];
    desLabel.numberOfLines = 0;
    desLabel.textColor = KFontNewColorB;
    desLabel.textAlignment = NSTextAlignmentLeft;
    desLabel.font = NormalFontWithSize(13);
    [self addSubview:desLabel];
    
    lineLabel = [[UILabel alloc] init];
    lineLabel.frame = CGRectMake(0, 99.5, screenWidth, 0.5);
    lineLabel.backgroundColor = KFontNewColorM;
    [self addSubview:lineLabel];
}

- (void)funcBtnOnClick:(UIButton*)sender
{
    if ([self.delegate respondsToSelector:@selector(propCardFunction:)])
    {
        [self.delegate propCardFunction:sender.tag];
    }
}

- (void)buyBtnOnClick:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    if ([self.delegate respondsToSelector:@selector(buyCardFunction:)])
    {
        [self.delegate buyCardFunction:btn.tag];
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
