//  CardViewController.h
//  StockMaster
//
//  Created by dalikeji on 14-10-9.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import "CardListCell.h"
#import "CHNAlertView.h"

@protocol BankCardDelegate <NSObject>

-(void) sendInfo:(NSMutableDictionary*) dict;

@end

@interface CardViewController : BasicViewController<UITableViewDataSource,UITableViewDelegate,CHNAlertViewDelegate>
{
    UITableView * cardTableView;
    UIButton * manageBtn;
    BOOL isManage;
    //    NSMutableArray * listArr ;//用来存储数据 再cell中显示的
    NSMutableArray * manageArr;//用来传到修改银行卡
}

@property (nonatomic,assign) NSInteger deliverType;
@property (nonatomic,weak) id<BankCardDelegate> delegate;

@end
