//
//  SecondViewController.h
//  StockMaster
//
//  Created by Rebloom on 14-7-22.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "HoldStockCell.h"
#import "SelectedStockCell.h"
#import "PublicTopView.h"

@interface SecondViewController : BasicViewController <UITableViewDataSource,HeaderViewDelegate,UITableViewDelegate,EGORefreshTableHeaderDelegate,HoldStockCellDelegate,SelectedStockCellDelegate,PublicTopViewDelegate>
{
    UITableView * infoTable;
    
    NSArray * holdLongStockArr;
    NSArray * holdShortStockArr;
    NSArray * selectedStockArr;
    
    EGORefreshTableHeaderView * refreshview;
    BOOL isEgoRefresh;
    
    NSTimer * secondTimer;
    
    NSInteger isTradebale;

    NSDictionary * portfolioDic;
    
    PublicTopView * publicTop;
        
    UILabel * originMoney;
    UILabel * holdStockMoney;
    UILabel * canUseMoney;
    UILabel * profitMoney;
    
    UILabel * originMoenyDesc;
    UILabel * holdStockDesc;
    UILabel * canUserDesc;
    UILabel * profitDesc;
    
    BOOL tableViewEditing;
    NSInteger selectedIndex;
    
    UIImageView * deleteImage;
    UIButton * editBtn;
}

@end
