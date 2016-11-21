//
//  HoldStockCell.h
//  StockMaster
//
//  Created by Rebloom on 14/12/18.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NSString+UIColor.h"
#import "UIImage+UIColor.h"

@protocol HoldStockCellDelegate <NSObject>

@required

- (void)holdStockSellBtnClickedAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface HoldStockCell : UITableViewCell
{
    UILabel * stockName;
    UILabel * stockID;
    UILabel * price;
    UILabel * priceDesc;
    UILabel * numberDesc;
    
    UILabel * profitLabel;
    
    UIButton * sellBtn;
    
    BOOL isShowMore;
}

@property (nonatomic, strong) UILabel * stockName;
@property (nonatomic, strong) UILabel * stockID;
@property (nonatomic, strong) UILabel * price;
@property (nonatomic, strong) UILabel * profit;
@property (nonatomic, strong) UILabel * profitRate;
@property (nonatomic, strong) UIButton * sellBtn;
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, weak) id <HoldStockCellDelegate> delegate;

@end
