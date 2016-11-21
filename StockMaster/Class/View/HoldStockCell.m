//
//  HoldStockCell.m
//  StockMaster
//
//  Created by Rebloom on 14/12/18.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "HoldStockCell.h"
#import "CHNMacro.h"

@implementation HoldStockCell

@synthesize stockName;
@synthesize stockID;
@synthesize price;
@synthesize profit;
@synthesize profitRate;
@synthesize sellBtn;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
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

        sellBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth-77, 12, 62, 34)];
        sellBtn.layer.cornerRadius = 4;
        sellBtn.layer.masksToBounds = YES;
        [sellBtn addTarget:self action:@selector(sellBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [sellBtn setBackgroundImage:[@"#e2e2e2".color image] forState:UIControlStateNormal];
        [sellBtn setTitle:@"卖" forState:UIControlStateNormal];
        [sellBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        sellBtn.titleLabel.font = NormalFontWithSize(13);
        sellBtn.tag = 2;
        [self addSubview:sellBtn];
    }
    return self;
}

- (void)sellBtnClicked:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(holdStockSellBtnClickedAtIndexPath:)]) {
        [self.delegate holdStockSellBtnClickedAtIndexPath:self.indexPath];
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
