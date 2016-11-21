//
//  InformationViewController.h
//  StockMaster
//
//  Created by dalikeji on 15/3/10.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"

@interface InformationViewController : BasicViewController<UITableViewDataSource,UITableViewDelegate>
{
    UITableView * infoTableView;
    NSMutableArray * infoArr;//用来装所有得数据
    NSMutableArray * readArr;//用来装已读id
    UIView * footView;
}
@property (nonatomic, strong) StockInfoEntity * stockInfo;
@end
