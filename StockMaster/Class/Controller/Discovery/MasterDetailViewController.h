//
//  MasterDetailViewController.h
//  StockMaster
//
//  Created by Rebloom on 14-8-6.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"

@interface MasterDetailViewController : BasicViewController
{
    UIButton * holdBtn;
    UIButton * historyBtn;
    UIView   * topView;
    UITableView * infoTable;
    UIImageView * bgView;
    UIImageView * photoView;
    UIImageView * totalIv;
    UIImageView * profitIv;
    UILabel * totalProfit;
    UILabel * accuracy;
    UIScrollView * scrollview;
    
    NSMutableArray * holdArray;
    NSMutableArray * historyArray;
    NSMutableArray * tempArray;
    NSMutableArray * recoverArr;
    NSMutableArray * dieArr;
    NSMutableArray * sendRecoverArr;
    NSMutableArray * sendDieArr;
    
    NSInteger selectedBtnIndex;
    NSInteger recoverIndex;
}

@property (nonatomic, strong) NSDictionary * passDic;
@property (nonatomic, strong) NSString * showUid;

@end
