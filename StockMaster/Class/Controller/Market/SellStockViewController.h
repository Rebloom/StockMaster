//
//  SellStockViewController.h
//  StockMaster
//
//  Created by Rebloom on 14-10-13.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "GFTextField.h"

@class SecondViewController;

@interface SellStockViewController : BasicViewController<UITextFieldDelegate>
{
    UILabel * stockName;
    UILabel * stockId;
    UILabel * price;
    UILabel * sellNum;
    
    UILabel * sellHalfNum;
    UILabel * sellAllNum;
    UILabel * expireLable;
    
    GFTextField * inputNum;

    UIView * stockView;
    UIView * numberView;
    UIView * bottomView;
    
    NSInteger allNumber;
    NSInteger halfNumber;
    
    NSDictionary *stockDict;
    
    UIButton * sellBtn;
    
    UIView * emptyView;
    UILabel * emptyTip;
    
    NSTimer * sellTimer;
    
    BOOL canChangeInput;
    
    UIButton * addBtn;
    UIButton * minusBtn;
}

@property (nonatomic, strong) StockInfoEntity * stockInfo;
@property (nonatomic, assign) StockHoldType holdType;

@end
