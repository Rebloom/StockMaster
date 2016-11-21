//
//  ProfitCell.m
//  StockMaster
//
//  Created by dalikeji on 14-9-12.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "ProfitCell.h"
#import "UIImage+UIColor.h"
#import "NSString+UIColor.h"
#import "CHNMacro.h"
@implementation ProfitCell

@synthesize verticalLine;
@synthesize rankLabel;
@synthesize icoImage;
@synthesize name;
@synthesize profit;
@synthesize profitDetail;
@synthesize rightView;
@synthesize lineLb;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        verticalLine = [[UILabel alloc] initWithFrame:CGRectMake(57, 0, 1, 62.5)];
        verticalLine.backgroundColor = kLineBGColor2;
        [self addSubview:verticalLine];
        
        
        rankLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 47, 63)];
        rankLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:21];
        rankLabel.textAlignment = NSTextAlignmentCenter;
        rankLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:rankLabel];
        
        
        
        icoImage = [[UIImageView alloc] initWithFrame:CGRectMake(72, 8, 40, 40)];
        icoImage.layer.cornerRadius = 20;
        icoImage.layer.masksToBounds = YES;
        [self addSubview:icoImage];
        
        
        name = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(icoImage.frame)+12, 10, screenWidth-120, 20)];
        name.backgroundColor = [UIColor clearColor];
        name.font = NormalFontWithSize(17);
        name.textColor =kTitleColorA;
        [name sizeToFit];
        [self addSubview:name];
        
        
        profit = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(icoImage.frame)+12, CGRectGetMaxY(name.frame)+5, 40, 20)];
        profit.backgroundColor = [UIColor clearColor];
        profit.font = NormalFontWithSize(12);
        profit.textColor =@"#717171".color;
        [profit sizeToFit];
        [self addSubview:profit];
        
        
        profitDetail = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(profit.frame)+5, CGRectGetMaxY(name.frame)+5, screenWidth-120, 20)];
        profitDetail.backgroundColor = [UIColor clearColor];
        profitDetail.font = NormalFontWithSize(12);
        profitDetail.textColor =kSelectBarColor;
        [profitDetail sizeToFit];
        [self addSubview:profitDetail];
        
        
        
        rightView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-25, 23, 7, 12)];
        rightView.image = [UIImage imageNamed:@"home_right"];
        rightView.backgroundColor = [UIColor clearColor];
        [self addSubview:rightView];
        
        
        lineLb = [[UILabel alloc] initWithFrame:CGRectMake(10, 62.5, screenWidth-20, 0.5)];
        lineLb.backgroundColor = kLineBGColor2;
        [self addSubview:lineLb];
        
    }
    return self;
}



- (void)awakeFromNib
{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
