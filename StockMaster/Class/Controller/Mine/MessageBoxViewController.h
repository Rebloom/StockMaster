//
//  MessageBoxViewController.h
//  StockMaster
//
//  Created by Rebloom on 15/3/13.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"

#import "NoticeViewController.h"

#import "StockDetailViewController.h"

@interface MessageBoxViewController : BasicViewController
{
    UITableView * infoTable;
    
    NSMutableArray * infoArr;
    
    BOOL needLoadMore;
    
    NSInteger removedIndex;
    
    BOOL clearAll;
    
    BOOL isFirstLoad;
}

@end
