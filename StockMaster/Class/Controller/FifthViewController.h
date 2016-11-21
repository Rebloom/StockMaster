//
//  FifthViewController.h
//  StockMaster
//
//  Created by Rebloom on 14/11/4.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import "CHNAlertView.h"
#import "PublicTopView.h"
#import "LineChartView.h"

@interface FifthViewController : BasicViewController<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,CHNAlertViewDelegate>
{
    UITableView * infoTableView;
    UIImageView * topView;
    UIView * footView;
    UIView * headView;
    
    UILabel * nameLabel;
    UILabel * phoneLabel;
    UILabel * leftLabel;
    UILabel * rightLabel;
    UIImageView * imgView;
    UIImageView * secondView;
    UIImageView * bgView;
    
    NSMutableArray *  titleArr;
    NSMutableArray*  imageArr;
    NSArray * faqQuestionArr;
    NSMutableDictionary * pushDic;

}

@end
