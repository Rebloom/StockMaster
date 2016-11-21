//
//  StockLineViewController.h
//  StockMaster
//
//  Created by dalikeji on 15/3/12.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import "CHNLineView.h"
@interface StockLineViewController : BasicViewController

{
    CGFloat  ViewWidth;
    CGFloat  ViewHeight;
    CGFloat  everyWidth;
    
    UIView * topView;
    UILabel * nameLabel;
    UILabel * priceLabel;
    UILabel * highLabel;
    UILabel * lowLabel;
    UILabel * openLabel;
    UILabel * closeLable;
    
    UIView * bannerView;
    UIView * orangeLine;
    CHNLineView *  lineView;
}
@property(nonatomic, strong)StockInfoEntity * stockInfo;
@end
