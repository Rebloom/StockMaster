//
//  WithDrawCashViewController.h
//  StockMaster
//
//  Created by Rebloom on 14-7-29.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//


#import "BasicViewController.h"
#import "CardViewController.h"
#import "GFTextField.h"
#import "ManageCardViewController.h"
#import "WithDrawSellViewController.h"

@interface WithDrawCashViewController : BasicViewController <UITextFieldDelegate,UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate,BankCardDelegate>
{
    GFTextField * muchTextField;
    UIImageView * topView;
    UILabel * withdrawCashLabel;
    UILabel * withDrawDescLabel;
    UILabel * ruleLb;
    UITableView * cardTableView;
    NSMutableArray * infoArr;
    NSMutableDictionary * bank_infoDic;
    NSString * moneyStr ;
}
@property (nonatomic,assign) NSInteger flag;
@end
