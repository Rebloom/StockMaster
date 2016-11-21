//
//  EarnMoneyViewController.h
//  StockMaster
//
//  Created by 孤星之殇 on 15/4/2.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import "CardViewController.h"
#import "GFTextField.h"
#import "ManageCardViewController.h"
#import "WithDrawSellViewController.h"

@interface EarnMoneyViewController : BasicViewController <UITextFieldDelegate,UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate,BankCardDelegate>
{
    GFTextField * muchTextField;
    UIImageView * topView;
    UILabel * withdrawCashLabel;
    UILabel * withDrawDescLabel;
    UITableView * cardTableView;
    NSMutableArray * infoArr;
    NSMutableDictionary * bank_infoDic;
    NSString * moneyStr ;
}
@property (nonatomic,assign) NSInteger flag;
@end
