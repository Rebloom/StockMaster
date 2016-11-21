//
//  SellCell.m
//  StockMaster
//
//  Created by dalikeji on 14-8-5.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "SellCell.h"
#import "NSString+UIColor.h"
@implementation SellCell

@synthesize stockName;
@synthesize stockID;
@synthesize imageView;
@synthesize leftBtn;
@synthesize rightBtn;

@synthesize rightBtnTag;

@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        stockID = [[UILabel alloc] initWithFrame:CGRectMake(15,20, 100, 75)];
        stockID.backgroundColor = kBackgroundColor;
        stockID.textColor = kTitleColorA;
        stockID.font = NormalFontWithSize(15);
        [self addSubview:stockID];
        
        stockName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(stockID.frame), 20, 100, 75)];
        stockName.backgroundColor = kBackgroundColor;
        stockName.textColor = kTitleColorA;
        stockName.font = NormalFontWithSize(15);
        [self addSubview:stockName];
        
        leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 250, 95)];
        [leftBtn addTarget:self action:@selector(leftBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:leftBtn];
        
        rigthBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth-70, 0, 70, 95)];
        [rigthBtn addTarget:self action:@selector(rightBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(26, 46, 23, 23);
        [rigthBtn addSubview:imageView];
        [self addSubview:rigthBtn];
    }
    return self;
}

- (void)rightBtnClicked:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    btn.tag = self.rightBtnTag;
    rigthBtn.selected = !rigthBtn.selected;
    if (rigthBtn.selected)
    {
        imageView.image = [UIImage imageNamed:@"buystock_normal"];
    }
    else
    {
        imageView.image = [UIImage imageNamed:@"buystock_disable"];
    }
    if ([self.delegate respondsToSelector:@selector(cellSelectedBtn:withSection:)])
    {
        [self.delegate cellSelectedBtn:btn withSection:self.tag];
    }
}

- (void)leftBtnClicked:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    if ([self.delegate respondsToSelector:@selector(cellChooseAtIndex:WithSection:)])
    {
        [self.delegate cellChooseAtIndex:btn.tag WithSection:self.tag];
    }
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
