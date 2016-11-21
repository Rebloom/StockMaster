//
//  CustomTableView.h
//
//
//  Created by klbest1 on 14-5-22.
//  Copyright (c) 2014年 @"". All rights reserved.
//

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "SlideTableViewCell.h"

@class CustomTableView;
@protocol CustomTableViewDelegate <NSObject>
@required;
-(float)heightForRowAthIndexPath:(UITableView *)aTableView IndexPath:(NSIndexPath *)aIndexPath FromView:(CustomTableView *)aView;
-(void)didSelectedRowAthIndexPath:(UITableView *)aTableView IndexPath:(NSIndexPath *)aIndexPath FromView:(CustomTableView *)aView;
-(void)loadData:(void(^)(int aAddedRowCount))complete FromView:(CustomTableView *)aView;
-(void)refreshData:(void(^)())complete FromView:(CustomTableView *)aView;

@optional
-(void)didDeleteCellAtIndexpath:(UITableView *)aTableView IndexPath:(NSIndexPath *)aIndexPath FromView:(CustomTableView *)aView;
//- (void)tableViewWillBeginDragging:(UIScrollView *)scrollView;
//- (void)tableViewDidScroll:(UIScrollView *)scrollView;
////- (void)tableViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
//- (BOOL)tableViewEgoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view FromView:(CustomTableView *)aView;
@end

@protocol CustomTableViewDataSource <NSObject>
@required;
-(NSInteger)numberOfRowsInTableView:(UITableView *)aTableView InSection:(NSInteger)section FromView:(CustomTableView *)aView;
-(SlideTableViewCell *)cellForRowInTableView:(UITableView *)aTableView IndexPath:(NSIndexPath *)aIndexPath FromView:(CustomTableView *)aView;

@end

@interface CustomTableView : UIView<UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate,SlideTableViewCellDelegate>
{
    EGORefreshTableHeaderView *_refreshHeaderView;
    NSInteger     mRowCount;
}
//  Reloading var should really be your tableviews datasource
//  Putting it here for demo purposes
@property (nonatomic,assign) BOOL reloading;

@property (nonatomic,retain) UITableView *homeTableView;
@property (nonatomic,retain) NSMutableArray *tableInfoArray;
@property (nonatomic,assign) id<CustomTableViewDataSource> dataSource;
@property (nonatomic,assign) id<CustomTableViewDelegate>  delegate;

- (void)reloadTableViewDataSource;
#pragma mark 强制列表刷新
-(void)forceToFreshData;

@end
