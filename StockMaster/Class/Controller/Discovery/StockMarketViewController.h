//
//  StockMarketViewController.h
//  StockMaster
//
//  Created by dalikeji on 14/11/24.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import "EGORefreshTableHeaderView.h"

@interface StockMarketViewController :BasicViewController<UITableViewDataSource,HeaderViewDelegate,UITableViewDelegate,EGORefreshTableHeaderDelegate>
{
    UITableView * infoTabelView;
    
    UILabel * refreshLabel ;
    
    UIImageView * updownIv1;
    UIImageView * updownIv2;
    UIImageView * updownIv3;
    
    NSArray * infoArr;
    NSMutableArray * totalArr;
    
    UIActivityIndicatorView * aiView;
    EGORefreshTableHeaderView * refreshview;
    BOOL isEgoRefresh; //下拉刷新
    BOOL isRefresh;  //上拉刷新
    
    BOOL isFirst;
    BOOL isSecond;
    BOOL isThird;
    
    BOOL is_tradable;
    BOOL is_request_by;
    
    NSInteger  flag;
    NSInteger  refreshFlag; //refreshFlag = 0 时是第一次加载数据 和 下拉刷新
    
    NSString * page;
    NSString * sort_key;
    
    NSDate * date;
    NSTimer * stockMarketTimer;
    NSInteger time;
    
    UIButton * cancelBtn;
}

@end
