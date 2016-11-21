//
//  EmotionRankViewController.h
//  StockMaster
//
//  Created by 孤星之殇 on 15/5/2.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import "BasicViewController.h"

@interface EmotionRankViewController : BasicViewController<UITableViewDataSource,UITableViewDelegate>
{
    UIView * topView;
    UILabel * stockNumLabel;
    UILabel * newStockNumLabel;
    
    UIView * feetView;
    UIView * refreshView;
    UILabel * refreshLabel;
    UIActivityIndicatorView * aiView;
    
    UITableView * rankTableView;
    
    NSMutableDictionary * infoDic;
    NSMutableArray * userArr;
    BOOL isRefresh;
    NSString * currentPage;
}

@end
