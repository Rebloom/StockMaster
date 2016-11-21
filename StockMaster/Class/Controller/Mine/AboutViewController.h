//
//  AboutViewController.h
//  StockMaster
//
//  Created by dalikeji on 14-11-6.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"

#import "GFWebViewController.h"

@interface AboutViewController : BasicViewController<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,CHNAlertViewDelegate>

{
    UITableView * infoTableView;
    NSMutableArray * titleArr;
    UIScrollView * scrollView;
    NSString * versionURL;
    BOOL isNewVerson;
}

@end
