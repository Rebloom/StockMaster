//
//  CardListCell.m
//  StockMaster
//
//  Created by dalikeji on 14-10-11.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "CardListCell.h"
#import "UIImage+UIColor.h"
#import "NSString+UIColor.h"
@implementation CardListCell

@synthesize bank_name;
@synthesize card_number;
@synthesize real_name;
@synthesize invalid;

-(void)dealloc
{
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = kFontColorA;
        [self createCell];
    }
    return self;
}

-(void)createCell
{
    bank_name = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 130, 89)];
    bank_name.textAlignment = NSTextAlignmentLeft;
    bank_name.textColor = KFontNewColorA;
    bank_name.font = NormalFontWithSize(15);
    [self.contentView addSubview:bank_name];
    
    card_number = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth-170,0, 130, 89)];
    card_number.textAlignment = NSTextAlignmentRight;
    card_number.textColor = KFontNewColorA;
    card_number.font = NormalFontWithSize(15);
    [self.contentView addSubview:card_number];
    
    invalid = [[UILabel alloc] init];
    invalid.frame = CGRectMake(CGRectGetMaxX(bank_name.frame)+10, 0, 80, 89);
    invalid.textColor = kRedColor;
    invalid.font = NormalFontWithSize(13);
    invalid.textAlignment = NSTextAlignmentLeft;
    [self addSubview:invalid];
    
    UIImageView * rightView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-31, 35, 11, 20)];
    rightView.image = [UIImage imageNamed:@"jiantou-you.png"];
    rightView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:rightView];
    
    UILabel * lineLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 89, screenWidth, 0.5)];
    lineLb.backgroundColor = KLineNewBGColor1;
    [self.contentView addSubview:lineLb];
    
    UILabel * lineLb2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 89.5, screenWidth, 0.5)];
    lineLb2.backgroundColor = KLineNewBGColor2;
    [self.contentView addSubview:lineLb2];
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
