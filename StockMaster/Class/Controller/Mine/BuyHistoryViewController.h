//
//  BuyHistoryViewController.h
//  StockMaster
//
//  Created by Rebloom on 14-7-24.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import "HistoryCell.h"

@interface BuyHistoryViewController : BasicViewController <UITableViewDataSource, UITableViewDelegate>
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
    NSMutableArray * tempArray;
    
    NSInteger selectedIndex;
    NSInteger showedSection;
}



@end
