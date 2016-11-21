//
//  InformationCell.m
//  StockMaster
//
//  Created by dalikeji on 15/3/13.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import "InformationCell.h"
#import "CHNMacro.h"
#import "BasicViewController.h"

@implementation InformationCell
@synthesize redLabel;
@synthesize timeLabel;
@synthesize titleLabel;
@synthesize contentLabel;

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
    UILabel * lineLabel = [[UILabel alloc] init];
    lineLabel.frame = CGRectMake(0, 100.5, screenWidth , 0.5);
    lineLabel.backgroundColor = KColorHeader;
    [self addSubview:lineLabel];

    redLabel = [[UILabel alloc] init];
    redLabel.frame = CGRectMake(15, 15, 6, 6);
    redLabel.layer.cornerRadius = 3;
    redLabel.layer.masksToBounds = YES;
    redLabel.backgroundColor = kRedColor;
    [self addSubview:redLabel];
    
    timeLabel = [[UILabel alloc] init];
    timeLabel.frame = CGRectMake(CGRectGetMaxX(redLabel.frame)+ 15, 12, 100, 12);
    timeLabel.textAlignment = NSTextAlignmentLeft;
    timeLabel.textColor = KFontNewColorB;
    timeLabel.font = NormalFontWithSize(11);
    timeLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:timeLabel];
    
    titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(15,CGRectGetMaxY(timeLabel.frame) +10, screenWidth - 30, 15);
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = NormalFontWithSize(15);
    titleLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:titleLabel];
    
    contentLabel = [[UILabel alloc] init];
    contentLabel.frame = CGRectMake(15, CGRectGetMaxY(titleLabel.frame)+10 , screenWidth - 30, 30);
    contentLabel.textAlignment = NSTextAlignmentLeft;
    contentLabel.font = NormalFontWithSize(13);
    contentLabel.backgroundColor = [UIColor clearColor];
    contentLabel.numberOfLines = 0;
    [self addSubview:contentLabel];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
