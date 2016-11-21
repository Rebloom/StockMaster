//
//  GFWebViewController.h
//  StockMaster
//
//  Created by Rebloom on 14-8-20.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

typedef enum WebViewType
{
    WebViewTypePush = 1,
    WebViewTypePresent = 2
}_WebViewType;

#import "BasicViewController.h"

#import "WithDrawCashViewController.h"


@interface GFWebViewController : BasicViewController <UIWebViewDelegate>
{
    UIImageView * refreshImage;
    UIActivityIndicatorView * actView ;
//    NSInteger flag;// = 0 返回上一页面  =1 返回主界面
}

@property (nonatomic, strong) UIWebView * detailView;

@property (nonatomic, strong) NSURL * requestUrl;

@property (nonatomic, copy) NSString * title;

@property (nonatomic, assign) NSInteger pageType;

@property (nonatomic, strong) NSURL * task_url;

@property (nonatomic, strong) NSString * desc;

@property (nonatomic, assign) NSInteger flag;// = 0 返回上一页面  =1 返回主界面
@end
