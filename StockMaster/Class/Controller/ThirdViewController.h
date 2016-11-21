//
//  ThirdViewController.h
//  StockMaster
//
//  Created by Rebloom on 14-7-22.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "CHNAlertView.h"
@interface ThirdViewController : BasicViewController <UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate,CHNAlertViewDelegate>
{
    UIView * footView;
    BOOL isEgoRefresh;
    NSInteger refreshFlag;
    UITableView * infoTable;
    UIImageView * refreshView;
    NSMutableArray * headerArr;
    EGORefreshTableHeaderView * refreshview;
    
    NSDate * date;
    NSTimer * thirdTimer;
    NSInteger time;
    
    BOOL is_tradable;//用来判断是否自动刷新
    BOOL is_request_by; //用来识别第一次进入页面的人工刷新
    BOOL isTimer;
    
    UIImageView * backImage;
    UIView * thirdHeader;
    
    UIButton * imageBtn;
    
    NSMutableArray * hrefArr;
}

@property (nonatomic, strong) NSMutableArray * radarArr;

@property (nonatomic, strong) NSArray * hotPlateArr;

@end
