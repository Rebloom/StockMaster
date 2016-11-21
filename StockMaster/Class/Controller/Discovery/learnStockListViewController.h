//
//  learnStockListViewController.h
//  StockMaster
//
//  Created by Rebloom on 14-8-5.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"

#import "LearnStockDetailViewController.h"

@interface learnStockListViewController : BasicViewController
{
    UITableView * infoTable;
}

@property (nonatomic, copy) NSString * title;

@end
