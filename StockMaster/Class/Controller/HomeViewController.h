//
//  HomeViewController.h
//  StockMaster
//
//  Created by Rebloom on 14-7-22.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"

#import "FirstViewController.h"
#import "SecondViewController.h"
#import "ThirdViewController.h"
#import "FourthViewController.h"
#import "FifthViewController.h"

#import "Ivan_UITabBar.h"
#import "PropView.h"

typedef enum SELECTEDTAB
{
    TabSelectedFirst = 0,
    TabSelectedSecond,
    TabSelectedThird,
    TabSelectedFourth,
    TabSelectedFifth,
}_SELECTEDTAB;

@interface HomeViewController : BasicViewController<cardFounctionDelegate>
{
    Ivan_UITabBar * tabBarController;
    PropView * prop;
}

@property (nonatomic, retain) Ivan_UITabBar * tabBarController;

- (void)setSelectedTab:(NSInteger)index;
- (void)showTabbar;

@end
