//
//  BuySearchViewController.h
//  StockMaster
//
//  Created by Rebloom on 15/1/31.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import "GFTextField.h"
#import "SellCell.h"
#import "CHNAlertView.h"
#import "BuyStockViewController.h"

@interface BuySearchViewController : BasicViewController <UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,SellCellDelegate,CHNAlertViewDelegate>
{
    GFTextField * searchTv;
    
    UITableView * stockTableview;
    UIImageView * downView ;
    
    BOOL isSearch;
    BOOL isPinyin;
    
    NSMutableArray * searchArr;
    
    NSMutableDictionary * stockDic;
    
    NSInteger selectedIndex;
    NSInteger selectedSection;
    NSInteger isNumberPad;
}

@end
