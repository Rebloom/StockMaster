//
//  InformationDetailCell.m
//  StockMaster
//
//  Created by dalikeji on 15/3/11.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import "InformationDetailCell.h"
#import "CHNMacro.h"
#import "BasicViewController.h"

@implementation InformationDetailCell
@synthesize titleLabel;
@synthesize newsPaperLabel;
@synthesize stockLabel;
@synthesize dateLabel;
@synthesize contentLabel;
@synthesize webView;

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
    titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(20, 20, screenWidth - 40, 40);
    titleLabel.textColor = KFontNewColorA;
    titleLabel.numberOfLines = 0;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = NormalFontWithSize(17);
    [self addSubview:titleLabel];
    
    newsPaperLabel = [[UILabel alloc] init];
    newsPaperLabel.frame = CGRectMake(20, CGRectGetMaxY(titleLabel.frame)+10, 60, 11);
    newsPaperLabel.textColor = KFontNewColorB;
    newsPaperLabel.backgroundColor = [UIColor clearColor];
    newsPaperLabel.textAlignment = NSTextAlignmentLeft;
    newsPaperLabel.font = NormalFontWithSize(11);
    [self addSubview:newsPaperLabel];
    
    stockLabel =  [[UILabel alloc] init];
    stockLabel.frame = CGRectMake(CGRectGetMaxX(newsPaperLabel.frame)+10, CGRectGetMaxY(titleLabel.frame)+10, 70, 11);
    stockLabel.textColor = KFontNewColorB;
    stockLabel.backgroundColor = [UIColor clearColor];
    stockLabel.textAlignment = NSTextAlignmentLeft;
    stockLabel.font = NormalFontWithSize(11);
    [self addSubview:stockLabel];
    
    dateLabel = [[UILabel alloc] init];
    dateLabel.frame = CGRectMake(CGRectGetMaxX(stockLabel.frame)+10, CGRectGetMaxY(titleLabel.frame)+10, 100, 11);
    dateLabel.textColor = KFontNewColorB;
    dateLabel.backgroundColor = [UIColor clearColor];
    dateLabel.textAlignment = NSTextAlignmentLeft;
    dateLabel.font = NormalFontWithSize(11);
    [self addSubview:dateLabel];
    
    UILabel * lineLabel = [[UILabel alloc] init];
    lineLabel.backgroundColor = kLineBGColor2;
    lineLabel.frame = CGRectMake(15, CGRectGetMaxY(dateLabel.frame)+15, screenWidth - 30, 1);
    [self addSubview:lineLabel];
    
    contentLabel = [[UILabel alloc ]init];
    contentLabel.frame = CGRectMake(20, CGRectGetMaxY(lineLabel.frame)+10, screenWidth - 40, 500);
    contentLabel.textColor = KFontNewColorA;
    contentLabel.numberOfLines = 0;
    contentLabel.backgroundColor = [UIColor clearColor];
    contentLabel.textAlignment = NSTextAlignmentLeft;
    contentLabel.font = NormalFontWithSize(13);
    contentLabel.adjustsFontSizeToFitWidth = YES;
//    [self addSubview:contentLabel];
    
    self.userInteractionEnabled = NO;
    
    CGRect frame = CGRectMake(20, CGRectGetMaxY(lineLabel.frame)+10, screenWidth - 40, 500);
    webView  = [[UIWebView alloc] initWithFrame:frame];//rect是你设计好大小的矩形
    [self addSubview:webView];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
