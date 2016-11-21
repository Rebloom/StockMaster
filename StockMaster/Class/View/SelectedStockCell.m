//
//  SelectedStockCell.m
//  StockMaster
//
//  Created by Rebloom on 14/12/19.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "SelectedStockCell.h"

@implementation SelectedStockCell

@synthesize stockName;
@synthesize stockID;
@synthesize price;
@synthesize updownRange;
@synthesize buyButton;
@synthesize profit;
@synthesize profitRate;

@synthesize delegate;

- (void)dealloc
{
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        
        stockName = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 70, 20)];
        stockName.backgroundColor = [UIColor clearColor];
        stockName.textColor = KFontNewColorA;
        stockName.textAlignment = NSTextAlignmentLeft;
        stockName.font = NormalFontWithSize(15);
        [self addSubview:stockName];
        
        stockID = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(stockName.frame)+7, 60, 11)];
        stockID.backgroundColor = [UIColor clearColor];
        stockID.textColor = KFontNewColorB;
        stockID.textAlignment = NSTextAlignmentLeft;
        stockID.font = NormalFontWithSize(10);
        [self addSubview:stockID];
        
        price = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/4+10, 15, 65, 20)];
        price.backgroundColor = [UIColor clearColor];
        price.textColor = KFontNewColorA;
        price.textAlignment = NSTextAlignmentLeft;
        price.font = NormalFontWithSize(15);
        [self addSubview:price];
        
        priceDesc = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/4+10, CGRectGetMaxY(price.frame)+7, 65, 10)];
        priceDesc.backgroundColor = [UIColor clearColor];
        priceDesc.textColor = KFontNewColorB;
        priceDesc.textAlignment = NSTextAlignmentLeft;
        priceDesc.font = NormalFontWithSize(10);
        priceDesc.text = @"现价";
        [self addSubview:priceDesc];
        
        profit = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/2, 15, 65, 20)];
        profit.backgroundColor = [UIColor clearColor];
        profit.font = NormalFontWithSize(15);
        profit.textAlignment = NSTextAlignmentLeft;
        [self addSubview:profit];
        
        profitRate = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/2, CGRectGetMaxY(profit.frame)+7, 65, 11)];
        profitRate.textAlignment = NSTextAlignmentLeft;
        profitRate.backgroundColor = [UIColor clearColor];
        profitRate.textColor = KFontNewColorB;
        profitRate.font = NormalFontWithSize(10);
        [self addSubview:profitRate];
        profitRate.text = @"涨跌幅";
        
        buyButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth-77, 12, 62, 34)];
        buyButton.layer.cornerRadius = 4;
        buyButton.layer.masksToBounds = YES;
        [buyButton addTarget:self action:@selector(editBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [buyButton setBackgroundImage:[@"#e2e2e2".color image] forState:UIControlStateNormal];
        [buyButton setBackgroundImage:[kRedColor image] forState:UIControlStateSelected];
        [buyButton setBackgroundImage:[[UIColor whiteColor] image] forState:UIControlStateDisabled];
        [buyButton setTitle:@"详" forState:UIControlStateNormal];
        [buyButton setTitle:@"删除" forState:UIControlStateSelected];
        [buyButton setTitle:@"不可买" forState:UIControlStateDisabled];
        [buyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [buyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        buyButton.titleLabel.font = NormalFontWithSize(13);
        buyButton.tag = 2;
        [self addSubview:buyButton];
    }
    return self;
}

- (void)editBtnClicked:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    
    if ([self.delegate respondsToSelector:@selector(SelectedStockCellClickedAtIndex:withTag:)])
    {
        [self.delegate SelectedStockCellClickedAtIndex:btn.tag withTag:self.tag];
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
