//
//  MineDetailViewController.h
//  StockMaster
//
//  Created by dalikeji on 14-11-7.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import "Ivan_UITabBar.h"
@interface MineDetailViewController : BasicViewController<UIScrollViewDelegate>
{
    UIImageView * firstView;
    UIImageView * secondView ;
    UIImageView * thirdView;
    UIImageView * fourthView;
    UIImageView * fifthView;
    UIImageView * tempView;
    UIImageView * partOneView;
    UIImageView * partTwoView;
    UIImageView * partThreeView;
    UIImageView * partFourView;
    UIScrollView * scrollView;
    UIImageView * iconView;
    UIImageView * picIv;
    UILabel *  tipLb;
    UILabel * numLabel;
    
    Ivan_UITabBar * tabBarController;
}
@property(nonatomic,strong) NSDictionary * infoDic;
@end
