//
//  WithDrawSellViewController.h
//  StockMaster
//
//  Created by Rebloom on 14/12/22.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "SellStockViewController.h"

@interface WithDrawSellViewController : BasicViewController <EGORefreshTableHeaderDelegate>
{
    UITableView * infoTable;
    EGORefreshTableHeaderView * refreshview;
    
    BOOL isEgoRefresh;
}

@end
