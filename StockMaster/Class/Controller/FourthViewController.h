//
//  FourthViewController.h
//  StockMaster
//
//  Created by Rebloom on 14-7-22.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import "NSString+UIColor.h"
#import "UIImage+UIColor.h"
#import "EGORefreshTableHeaderView.h"
#import "CycleScrollView.h"

//taskStatus = 1没有做;  = 2 做过没领奖;  = 3 领奖了
typedef enum GUESSTASKSTATUS
{
    UNDONE = 1,
    UNREWARD,
    REWARD,
    UNFINISH,
}_GUESSTASKSTATUS;

@interface FourthViewController : BasicViewController <UITableViewDataSource, UITableViewDelegate,EGORefreshTableHeaderDelegate,CHNAlertViewDelegate,UIScrollViewDelegate>
{
    UITableView * infoTable;
    NSArray * infoArr;
    NSArray * bannerArr; // 存放轮播banner
    
    BOOL isEgoRefresh;
    EGORefreshTableHeaderView * tableHeader;
    
    CycleScrollView *bannerCycleView;
    UIPageControl *bannerPageControl;
}

@end
