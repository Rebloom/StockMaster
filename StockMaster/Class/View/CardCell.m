//
//  CardCell.m
//  StockMaster
//
//  Created by Rebloom on 14-7-29.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "CardCell.h"
#import "CHNMacro.h"
#import "NSString+UIColor.h"

@implementation CardCell
@synthesize bankImage;
@synthesize bankName;
@synthesize bankType;
@synthesize bankID;
@synthesize cellBgView;
@synthesize logoView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor purpleColor];
        
        cellBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, screenWidth-20, 90)];
        [self addSubview:cellBgView];
        
        logoView = [[UIImageView alloc] initWithFrame:CGRectMake(13, 15, 30, 29)];
        [cellBgView addSubview:logoView];
        
        
        bankName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(logoView.frame)+10, 15, screenWidth-120, 20)];
        bankName.backgroundColor = [UIColor clearColor];
        bankName.textColor = kFontColorD;
        bankName.font = BoldFontWithSize(14);
        [cellBgView addSubview:bankName];
        
        bankType = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(logoView.frame)+10, CGRectGetMaxY(bankName.frame), 200, 20)];
        bankType.backgroundColor = [UIColor clearColor];
        bankType.textColor = kFontColorD;
        bankType.font = NormalFontWithSize(10);
        [cellBgView addSubview:bankType];
        
        bankID = [[UILabel alloc] initWithFrame:CGRectMake(80-10, CGRectGetMaxY(bankType.frame)+5, screenWidth-100, 30)];
        bankID.backgroundColor = [UIColor clearColor];
        bankID.textAlignment = NSTextAlignmentRight;
        bankID.textColor = kFontColorD;
        bankID.font = NormalFontWithSize(13);
        [cellBgView addSubview:bankID];
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
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
