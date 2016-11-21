//
//  FriendShipViewController.h
//  StockMaster
//
//  Created by dalikeji on 15/2/27.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import "FriendShipCell.h"

@interface FriendShipViewController : BasicViewController<UITableViewDataSource,UITableViewDelegate>
{
    UITableView * infoTable;
    UIView * footView;
    
    NSMutableArray * userArr;
    NSString * currentPage;
    
    BOOL isRefresh;  //上拉刷新
    UILabel * refreshLabel ;
    UIActivityIndicatorView * aiView;

    UIView * feetView;
    UIView * refreshView;
}

@end
