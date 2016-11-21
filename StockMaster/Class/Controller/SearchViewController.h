//
//  SearchViewController.h
//  StockMaster
//
//  Created by dalikeji on 14-9-3.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import "GFTextField.h"
#import "RoyaDialView.h"
#import "SellCell.h"
#import "RoyaDialViewDelegate.h"
#import "CHNAlertView.h"

@interface SearchViewController : BasicViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,SellCellDelegate,CHNAlertViewDelegate>
{
    GFTextField * searchTv;
    RoyaDialView * royaDialView;
    
    UITableView * stockTableview;
    UIImageView * downView ;
    
    BOOL isSearch;
    BOOL isPinyin;
    
    NSMutableArray * searchArr;
    NSMutableArray * hotArr;
    NSMutableArray * historyArr;
    
    NSArray * selectStockArr;
    
    NSMutableDictionary * stockDic;
    
    NSInteger selectedIndex;
    NSInteger selectedSection;
    NSInteger isNumberPad;
    NSInteger sectionFlag; // 用来标记 有几个section    = 0 有2个（历史、热门）   =1 有1个（热门）  =2（搜索）
    NSInteger indexSection; //用来区分section是第几个
}
@end
