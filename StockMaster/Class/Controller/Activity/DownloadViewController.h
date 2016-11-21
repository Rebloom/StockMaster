//
//  DownloadViewController.h
//  StockMaster
//
//  Created by 孤星之殇 on 15/6/8.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import "BasicViewController.h"
#import "DownloadCell.h"

@interface DownloadViewController : BasicViewController<UITableViewDataSource,UITableViewDelegate,DownloadToAward>
{
    UITableView * infoTableView;
    UIView * footView;
    UIView * headView;
    UILabel * downLoadLabel;
    
    NSMutableArray * mArr;
    
    BOOL isJump; // YES 跳转到app stroe ;   NO  不跳转  进行提交任务操作
}

@end
