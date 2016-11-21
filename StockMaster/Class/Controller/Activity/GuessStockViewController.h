//
//  GuessStockViewController.h
//  StockMaster
//
//  Created by Rebloom on 14/11/15.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"

@interface GuessStockViewController : BasicViewController <CHNAlertViewDelegate>
{
    UITableView * infoTable;
    
    UIImageView * guessResultImage;
    UIView * centerLine;
    UILabel * guessResultLabel;
    UILabel * guessResultDescLabel;
    
    NSMutableArray * infoArr;
    NSDictionary * infoDic;
    
    UIImageView * guessIcon;
    UILabel * desc1Label;
    
    UIButton * topRewardBtn;
}

@end
