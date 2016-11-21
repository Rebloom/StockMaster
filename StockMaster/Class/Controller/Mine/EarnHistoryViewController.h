//
//  EarnHistoryViewController.h
//  StockMaster
//
//  Created by dalikeji on 14-11-10.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import "GFTextField.h"
@interface EarnHistoryViewController :BasicViewController<UITableViewDataSource, UITableViewDelegate>
{
    
    UITableView * infoTable;
    UILabel * timeLb;
    
    NSMutableArray * listArr;
    NSMutableDictionary * listDic ;
    NSMutableDictionary * tempDic ;
    
    NSMutableArray * firstArr;
    NSMutableArray * secondArr;
    
    BOOL isFirst;
    
    NSInteger sectionNum ;
    
    NSMutableArray * selectedSection;
    
    NSInteger selectedIndex;
    NSInteger showedSection;

}@end
