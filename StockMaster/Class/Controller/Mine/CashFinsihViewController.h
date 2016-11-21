//
//  CashFinsihViewController.h
//  StockMaster
//
//  Created by dalikeji on 14-10-9.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import "CHNAlertView.h"

@interface CashFinsihViewController : BasicViewController<CHNAlertViewDelegate>
{
    UILabel * contentLb;
    UILabel * aboutLb;
    UIImageView * secondView;
}

@property(nonatomic,copy) NSString * card_no;
@property(nonatomic,copy) NSString * withdraw_money;
@property(nonatomic,copy) NSString * account_date;
@property(nonatomic,strong) NSDictionary * dict;
@end
