//
//  InformationDetailCell.h
//  StockMaster
//
//  Created by dalikeji on 15/3/11.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InformationDetailCell : UITableViewCell
{
    UILabel * titleLabel ;
    UILabel * newsPaperLabel;
    UILabel * stockLabel ;
    UILabel * dateLabel;
    UILabel * contentLabel;
    
    UIWebView * webView;
}

@property(nonatomic, strong) UILabel * titleLabel;
@property(nonatomic, strong) UILabel * newsPaperLabel;
@property(nonatomic, strong) UILabel * stockLabel ;
@property(nonatomic, strong) UILabel * dateLabel;
@property(nonatomic, strong) UILabel * contentLabel;

@property(nonatomic, strong) UIWebView * webView;

@end
