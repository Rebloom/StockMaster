//
//  StockCell.m
//  StockMaster
//
//  Created by Rebloom on 14-7-24.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "StockCell.h"

#define CELL_SIZE 15
@implementation StockCell

@synthesize stockName;
@synthesize stockID;
@synthesize stockPrice;
@synthesize stockNum;
@synthesize stockProfit;
@synthesize rightView;
@synthesize tipLb;
@synthesize iconView;
- (void)dealloc
{
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        iconView = [[UIImageView alloc] init];
        iconView.userInteractionEnabled = YES;
        [self.contentView addSubview:iconView];
        
        tipLb = [[UILabel alloc] init];
        tipLb.backgroundColor = [UIColor clearColor];
        tipLb.font = NormalFontWithSize(CELL_SIZE);
        tipLb.textColor = kTitleColorA;
        tipLb.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:tipLb];
        
        stockName = [[UILabel alloc] init];
        stockName.backgroundColor = [UIColor clearColor];
        stockName.textAlignment = NSTextAlignmentCenter;
        stockName.textColor = kTitleColorA;
        stockName.font = NormalFontWithSize(CELL_SIZE);
        [self.contentView addSubview:stockName];
        
        stockID = [[UILabel alloc] init ];
        stockID.backgroundColor = [UIColor clearColor];
        stockID.textAlignment = NSTextAlignmentCenter;
        stockID.textColor = kTitleColorA;
        stockID.font = NormalFontWithSize(CELL_SIZE);
        [self.contentView addSubview:stockID];
        
        stockPrice = [[UILabel alloc] init ];
        stockPrice.backgroundColor = [UIColor clearColor];
        stockPrice.textAlignment = NSTextAlignmentCenter;
        stockPrice.textColor =kTitleColorA;
        stockPrice.font = NormalFontWithSize(CELL_SIZE);
        [self.contentView addSubview:stockPrice];
        
        
        stockNum = [[UILabel alloc] init];
        stockNum.backgroundColor = [UIColor clearColor];
        stockNum.textColor = kTitleColorA;
        stockNum.textAlignment = NSTextAlignmentCenter;
        stockNum.font = NormalFontWithSize(CELL_SIZE);
        [self.contentView addSubview:stockNum];
        
        stockProfit = [[UILabel alloc] init ];
        stockProfit.backgroundColor = [UIColor clearColor];
        stockProfit.textColor = kTitleColorA;
        stockProfit.textAlignment = NSTextAlignmentCenter;
        stockProfit.font = NormalFontWithSize(CELL_SIZE);
        [self.contentView addSubview:stockProfit];
        
        rightView = [[UIImageView alloc] init];
        rightView.image = [UIImage imageNamed:@"home_right"];
        rightView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:rightView];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
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
