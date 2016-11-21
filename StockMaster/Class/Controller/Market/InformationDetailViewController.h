//
//  InformationDetailViewController.h
//  StockMaster
//
//  Created by dalikeji on 15/3/10.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"

@interface InformationDetailViewController : BasicViewController
{
    UIWebView * webView;
    
    NSMutableDictionary * infoDict;
}
@property (nonatomic, strong) NSString * news_url;
@property (nonatomic, strong) NSString * stock_name;
@end
