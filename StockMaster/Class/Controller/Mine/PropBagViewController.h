//
//  PropBagViewController.h
//  StockMaster
//
//  Created by 孤星之殇 on 15/6/30.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import "BasicViewController.h"
#import "PropBagCell.h"
#import "PropView.h"
@interface PropBagViewController : BasicViewController<UITableViewDataSource,UITableViewDelegate,funcDelegate,cardFounctionDelegate>
{
    UITableView * infoTableView;
    NSArray * infoArr;
    PropView * prop;
    NSInteger  propFlag;
    NSString * cardName;
    
    NSString * descStr;
    
    NSString * selectedCardID;
}
@end
