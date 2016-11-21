//
//  HistoryCell.m
//  StockMaster
//
//  Created by dalikeji on 14-10-20.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "HistoryCell.h"
#import "CHNMacro.h"
#import "NSString+UIColor.h"
#define CELL_SIZE 15
@implementation HistoryCell

@synthesize fifthLabel;
@synthesize secondLabel;
@synthesize thirdLabel;
@synthesize fourthLabel;
@synthesize firstLabel;
@synthesize marketIv;
@synthesize withdrawBtn;
-(void)dealloc
{
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        firstLabel = [[UILabel alloc] init];
        firstLabel.backgroundColor = [UIColor clearColor];
        firstLabel.textAlignment = NSTextAlignmentLeft;
        firstLabel.numberOfLines = 0;
        firstLabel.textColor = KFontNewColorA;
        firstLabel.font = NormalFontWithSize(CELL_SIZE);
        [self addSubview:firstLabel];
        
        secondLabel = [[UILabel alloc] init ];
        secondLabel.backgroundColor = [UIColor clearColor];
        secondLabel.textAlignment = NSTextAlignmentLeft;
        secondLabel.textColor = KFontNewColorA;
        secondLabel.numberOfLines = 0;
        secondLabel.font = NormalFontWithSize(CELL_SIZE);
        [self addSubview:secondLabel];
        
        thirdLabel = [[UILabel alloc] init ];
        thirdLabel.backgroundColor = [UIColor clearColor];
        thirdLabel.textAlignment = NSTextAlignmentLeft;
        thirdLabel.textColor =KFontNewColorA;
        thirdLabel.numberOfLines = 0;
        thirdLabel.font = NormalFontWithSize(CELL_SIZE);
        [self addSubview:thirdLabel];
        
        
        fourthLabel = [[UILabel alloc] init];
        fourthLabel.backgroundColor = [UIColor clearColor];
        fourthLabel.textColor = KFontNewColorA;
        fourthLabel.textAlignment = NSTextAlignmentRight;
        fourthLabel.font = NormalFontWithSize(CELL_SIZE);
        [self addSubview:fourthLabel];
        
        fifthLabel = [[UILabel alloc] init ];
        fifthLabel.backgroundColor = [UIColor clearColor];
        fifthLabel.textColor = KFontNewColorA;
        fifthLabel.textAlignment = NSTextAlignmentCenter;
        fifthLabel.font = NormalFontWithSize(CELL_SIZE);
        [self addSubview:fifthLabel];
        
        marketIv = [[UIImageView alloc ]init];
        [self addSubview:marketIv];
        
        withdrawBtn = [[UIButton alloc] init];
        withdrawBtn.backgroundColor = [UIColor clearColor];
        withdrawBtn.adjustsImageWhenHighlighted = NO;
        [self addSubview:withdrawBtn];
        
        self.backgroundColor = kFontColorA;
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
