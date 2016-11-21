//
//  BuyStockViewController.h
//  StockMaster
//
//  Created by Rebloom on 14/12/15.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import "GFTextField.h"

@interface BuyStockViewController : BasicViewController <UITextFieldDelegate,UIGestureRecognizerDelegate>
{
    UILabel * stockName;
    UILabel * stockId;
    UILabel * price;
    UILabel * buyNum;
    
    UILabel * buyHalfNum;
    UILabel * buyAllNum;
    UILabel * expireLable;
    
    GFTextField * inputNum;
    
    UIView * topView;
    UIView * stockView;
    UIView * numberView;
    UIView * bottomView;
    
    NSInteger allNumber;
    NSInteger halfNumber;
    
    UIButton * buyBtn;
    
    UIView * emptyView;
    UILabel * emptyTip;
    
    NSTimer * buyTimer;
    
    UIButton * addBtn;
    UIButton * minusBtn;
    
    UIScrollView * scrollView;
    
    UIView * mLine3;
    
    BOOL canChangeInput;
    
    BOOL canBack;
    
    BOOL warned;
    
    NSDictionary *stockDict;
}

@property (nonatomic, strong) StockInfoEntity * stockInfo;
@property (nonatomic, assign) StockHoldType holdType;

@end
