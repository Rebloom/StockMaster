//
//  MasterViewController.h
//  StockMaster
//
//  Created by Rebloom on 14-8-6.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"

#import "MasterListViewController.h"

@interface MasterViewController : BasicViewController
{
    UITableView * infoTable;
    NSMutableArray * firstArr;
    NSMutableArray * secondArr;
    NSMutableArray * thirdArr;
}

@end
