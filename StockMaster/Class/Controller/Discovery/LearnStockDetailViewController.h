//
//  LearnStockDetailViewController.h
//  StockMaster
//
//  Created by Rebloom on 14-8-6.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"

@interface LearnStockDetailViewController : BasicViewController <UIWebViewDelegate>

@property (nonatomic, retain) UIWebView * detailView;

@property (nonatomic, retain) NSURL * requestUrl;

@end
