//
//  MasterwCell.m
//  StockMaster
//
//  Created by dalikeji on 14-10-30.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "MasterwCell.h"
#import "NSString+UIColor.h"
#import "CHNMacro.h"
@implementation MasterwCell
@synthesize rankLabel;
@synthesize name;
@synthesize allLoadLabel;
@synthesize profitDetail;
@synthesize profit;
@synthesize icoImage;
@synthesize rightView;
@synthesize lineLb;
@synthesize holdLb;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createUI];
    }
    return self;
}

-(void)dealloc
{
}

-(void)createUI
{
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = kFontColorA;
    
    allLoadLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 134)];
    allLoadLabel.backgroundColor = [UIColor clearColor];
    allLoadLabel.textAlignment = NSTextAlignmentCenter;
    allLoadLabel.textColor = kFontColorC;
    allLoadLabel.font = NormalFontWithSize(14);
    [self addSubview:allLoadLabel];
    
    rankLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 47, 134)];
    rankLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:21];
    rankLabel.textAlignment = NSTextAlignmentLeft;
    rankLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:rankLabel];
    
    
    icoImage = [[UIImageView alloc] initWithFrame:CGRectMake(63, 20, 50, 50)];
    icoImage.layer.cornerRadius = 25;
    icoImage.layer.masksToBounds = YES;
    [self addSubview:icoImage];
    
    name = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(icoImage.frame)+20, 38, 200, 17)];
    name.backgroundColor = [UIColor clearColor];
    name.textAlignment = NSTextAlignmentLeft;
    name.font = NormalFontWithSize(16);
    name.textColor = KFontNewColorA;
    [self addSubview:name];
    
    profit = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(icoImage.frame), CGRectGetMaxY(icoImage.frame)+10, 110, 20)];
    profit.backgroundColor = [UIColor clearColor];
    profit.textColor =KFontNewColorA;
    profit.textAlignment = NSTextAlignmentLeft;
    profit.font = NormalFontWithSize(15);
    [self addSubview:profit];
    
    profitDetail = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(profit.frame), CGRectGetMinY(profit.frame), 200, 20)];
    profitDetail.backgroundColor = [UIColor clearColor];
    profitDetail.font = NormalFontWithSize(15);
    profitDetail.textAlignment = NSTextAlignmentLeft;
    profitDetail.textColor =KFontNewColorA;
    [self addSubview:profitDetail];
    
    holdLb = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(profit.frame), CGRectGetMaxY(profit.frame), 240, 20)];
    holdLb.backgroundColor = [UIColor clearColor];
    holdLb.font = NormalFontWithSize(13);
    holdLb.textAlignment = NSTextAlignmentLeft;
    holdLb.textColor =KFontNewColorB;
    [self addSubview:holdLb];
    
    
    rightView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-31, 57, 11, 20)];
    rightView.image = [UIImage imageNamed:@"home_right"];
    rightView.backgroundColor = [UIColor clearColor];
    
    lineLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 133.5, screenWidth, 0.5)];
    lineLb.backgroundColor = KColorHeader;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
