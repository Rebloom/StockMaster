//
//  NoticeViewController.h
//  StockMaster
//
//  Created by Rebloom on 15/3/17.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"

#import "NoticeSettingViewController.h"

@interface NoticeViewController : BasicViewController
{
    NSMutableArray * noticedStock;
    NSMutableArray * unnoticedStock;
    
    UITableView * infoTable;
    
    UISwitch * openStockSwitch;
//    UISwitch * onListSwitch;
//    UISwitch * withdrawSwitch;
}
@end
