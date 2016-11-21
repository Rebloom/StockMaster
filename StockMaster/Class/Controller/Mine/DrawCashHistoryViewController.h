//
//  DrawCashHistoryViewController.h
//  StockMaster
//
//  Created by Rebloom on 14-7-31.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//
#import "BasicViewController.h"
@interface DrawCashHistoryViewController :BasicViewController<UITableViewDataSource, UITableViewDelegate>
{
    
    UITableView * infoTable;
    
    NSMutableArray * listArr;
    NSMutableDictionary * listDic ;
    NSMutableDictionary * tempDic ;
    
    NSMutableArray * firstArr;
    NSMutableArray * secondArr;
    
    BOOL isFirst;
    
    NSInteger sectionNum ;
    
    NSMutableArray * selectedSection;
    
    NSInteger selectedIndex;
    NSInteger showedSection;
    
    NSInteger tipSection;
    NSInteger tipRow;
}
@end
