//
//  SubSectionViewController.h
//  StockMaster
//
//  Created by dalikeji on 14/11/26.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import "EGORefreshTableHeaderView.h"
@interface SubSectionViewController : BasicViewController<UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate>
{
    UITableView * infoTabelView;
    
    NSMutableArray * infoArr;
    
    EGORefreshTableHeaderView * refreshview;
    
    NSString * sort_key ;
    
    BOOL isEgoRefresh;
    BOOL isFirst;
    BOOL isSecond;
    BOOL isThird;
    BOOL is_tradable;
    BOOL is_request_by;
    
    UIImageView * updownIv1;
    UIImageView * updownIv2;
    UIImageView * updownIv3;
    NSInteger  flag;
    
    NSDate * date;
    NSTimer * subTimer;
    NSInteger time;
}
@property (nonatomic, copy) NSString * plate_code;
@property (nonatomic, copy) NSString * plate_name;
@end
