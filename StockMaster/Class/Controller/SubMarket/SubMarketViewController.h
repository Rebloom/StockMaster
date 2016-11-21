//
//  SubMarketViewController.h
//  StockMaster
//
//  Created by dalikeji on 14-9-22.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import "GFTextField.h"
#import "WithDrawListViewController.h"

@interface SubMarketViewController : BasicViewController <UITextFieldDelegate>
{
    UILabel * numDetailLabel ;
    UILabel * priceDetailLabel;
    UILabel * nameLabel;
    UIView * containerView;
    UIImageView * stockIv;
    UILabel * priceLabel;
    UILabel * buyLabel;
    UILabel * sellLabel;
    UILabel * sellNumLabel;
    GFTextField * contentTv;
    UIImageView * downView;
    UIButton * commitBtn;
    
    
    NSString * exchangeStr;
    NSString * stockCodeStr;
    NSString * markeyStr;
    
    NSString * tradePrice; //当前价格
    NSString * tradeCount; //可卖（买）数量
    
}

@property (nonatomic, assign) NSInteger flag;
@property (nonatomic, retain) Stock * stock;
@property (nonatomic, assign) BOOL fromFirst;

@end
