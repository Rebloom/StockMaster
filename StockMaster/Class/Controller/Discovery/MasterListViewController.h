//
//  MasterListViewController.h
//  StockMaster
//
//  Created by Rebloom on 14-8-6.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import "MasterDetailViewController.h"

@interface MasterListViewController : BasicViewController <UIScrollViewDelegate,UITableViewDataSource, UITableViewDelegate>
{
    UITableView * infoTable;
    UILabel * timeLabel ;
    NSMutableDictionary * infoDic;
    NSMutableDictionary * userDic;
    UIView * headView;
}

@property (nonatomic, assign) NSInteger pageType;

@end
