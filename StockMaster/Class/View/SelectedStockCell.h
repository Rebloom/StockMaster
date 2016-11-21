//
//  SelectedStockCell.h
//  StockMaster
//
//  Created by Rebloom on 14/12/19.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CHNMacro.h"
#import "NSString+UIColor.h"
#import "UIImage+UIColor.h"

@protocol SelectedStockCellDelegate <NSObject>

- (void)SelectedStockCellClickedAtIndex:(NSInteger)index withTag:(NSInteger)tag;

@end

@interface SelectedStockCell : UITableViewCell
{
    UILabel * stockName;
    UILabel * stockID;
    UILabel * price;
    UILabel * priceDesc;
    
    UILabel * updownRange;
    
    UIButton * buyButton;
}

@property (nonatomic, strong) UILabel * stockName;
@property (nonatomic, strong) UILabel * stockID;
@property (nonatomic, strong) UILabel * price;
@property (nonatomic, strong) UILabel * updownRange;
@property (nonatomic, strong) UIButton * buyButton;
@property (nonatomic, strong) UILabel * profit;
@property (nonatomic, strong) UILabel * profitRate;

@property (nonatomic, weak) id <SelectedStockCellDelegate> delegate;

@end
