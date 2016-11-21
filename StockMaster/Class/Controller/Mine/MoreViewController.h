//
//  MoreViewController.h
//  StockMaster
//
//  Created by dalikeji on 14-11-6.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import "ShareView.h"


#import "NoticeViewController.h"

@interface MoreViewController : BasicViewController<UITableViewDataSource,UITableViewDelegate,ShareViewDelegate>
{
    UITableView * infoTableView;
    NSMutableArray * titleArr;
}

@end
