//
//  emotionCell.m
//  StockMaster
//
//  Created by 孤星之殇 on 15/4/29.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import "emotionCell.h"
#import "CHNMacro.h"
#import "NSString+UIColor.h"
#import "UIImage+UIColor.h"

@implementation emotionCell

@synthesize nameLabel;
@synthesize numberLabel;
@synthesize tipsLabel;
@synthesize lineLabel;
@synthesize desLabel;

- (void)dealloc
{
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
    nameLabel = [[UILabel alloc] init];
    nameLabel.font = NormalFontWithSize(15);
    nameLabel.frame = CGRectMake(15, 15,200, 16);
    nameLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:nameLabel];
    
    desLabel = [[UILabel alloc] init];
    desLabel.frame = CGRectMake(15, CGRectGetMaxY(nameLabel.frame)+7.5, screenWidth -60, 13);
    desLabel.textAlignment = NSTextAlignmentLeft;
    desLabel.textColor = KFontNewColorB;
    desLabel.numberOfLines = 0;
    desLabel.font = NormalFontWithSize(13);
    [self addSubview:desLabel];
    
    numberLabel = [[UILabel alloc] init];
    numberLabel.font = NormalFontWithSize(15);
    numberLabel.frame = CGRectMake(screenWidth -45, 0   , 45, 80);
    numberLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:numberLabel];
    
    lineLabel = [[UILabel alloc] init];
    lineLabel.backgroundColor = KLineNewBGColor1;
    lineLabel.frame = CGRectMake(0, 79.5, screenWidth, 0.5);
    [self addSubview:lineLabel];
    
    tipsLabel = [[UILabel alloc] init];
    tipsLabel.numberOfLines = 0;
    tipsLabel.font = NormalFontWithSize(13);
    [self addSubview:tipsLabel];
    
    self.backgroundColor = kFontColorA;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
