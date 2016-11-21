//
//  DrawCashViewController.h
//  StockMaster
//
//  Created by Rebloom on 14-7-31.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import "GFTextField.h"
@interface DrawCashViewController : BasicViewController<UITextFieldDelegate>
{
    GFTextField * phone;
    UILabel * cardIDLabel;
    UILabel * cardNameLabel;
    UILabel * cardBankLabel;
    UILabel * cardDrawCashLabel;
    
    UIButton * checkCodeBtn;
    int time;
    NSTimer * drawCashTimer;
    NSInteger flag;
    NSMutableArray * messageArr;
    UIButton * submitBtn;
    NSDate * date;
    NSInteger codeFlag;
}

@property (nonatomic, copy) NSString * cardID;
@property (nonatomic, copy) NSString * cardName;
@property (nonatomic, copy) NSString * cardBank;
@property (nonatomic, copy) NSString * cardDrawCash;
@property (nonatomic, copy) NSString * bankType;
@property (nonatomic, copy) NSString * real_name;
@property (nonatomic, copy) NSString * card_no;
@property (nonatomic, copy) NSString * mobile;
@property (nonatomic, copy) NSString * idcard;
@property (nonatomic, copy) NSString * branchBankID;

@end
