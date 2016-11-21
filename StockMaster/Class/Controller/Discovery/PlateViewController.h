//
//  PlateViewController.h
//  StockMaster
//
//  Created by dalikeji on 14/11/25.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "NIDropDown.h"
@interface PlateViewController : BasicViewController<UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate,NIDropDownDelegate>
{
    UITableView * infoTabelView ;
    UIImageView * upDownView;
    UIImageView * imageView ;
    UIView * topView;
    
    NSArray * infoArr;
    NSMutableArray * mArr;
    
    BOOL isUpDown;
    NSString * deliverType;
    NSInteger index;
    
    EGORefreshTableHeaderView * refreshview;
    BOOL isEgoRefresh;
    
    NIDropDown * dropDown;
    
    NSTimer * plateTimer;
}

@end
