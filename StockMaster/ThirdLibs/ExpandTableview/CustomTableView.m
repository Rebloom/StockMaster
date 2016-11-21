//
//  CustomTableView.m
//  
//
//  Created by klbest1 on 14-5-22.
//  Copyright (c) 2014年 @"". All rights reserved.
//

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import "CustomTableView.h"

@interface CustomTableView ()
{
    SlideTableViewCell *slidedCell;
}

@property (nonatomic,assign) BOOL canCustomEdit;

@end

@implementation CustomTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        if (_homeTableView == nil) {
            _homeTableView = [[UITableView alloc] initWithFrame:frame];
            _homeTableView.delegate = self;
            _homeTableView.dataSource = self;
            [_homeTableView setBackgroundColor:[UIColor clearColor]];
        }
        if (_tableInfoArray == Nil) {
            _tableInfoArray = [[NSMutableArray alloc] init];
        }
        [self addSubview:_homeTableView];
        [self createRefreshHeaderView];
    }
    return self;
}

-(void)dealloc{
    _delegate = nil;
    [_tableInfoArray removeAllObjects],[_tableInfoArray release], _tableInfoArray = Nil;
    [_refreshHeaderView release];
    [_homeTableView release];
    [super dealloc];
}

-(void)setCanCustomEdit:(BOOL)canCustomEdit{

}

#pragma mark 创建下拉刷新Header
-(void)createRefreshHeaderView{
    
	if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:_homeTableView.frame];
		view.delegate = self;
		[self insertSubview:view belowSubview:_homeTableView];
		_refreshHeaderView = view;
		[view release];
	}
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
    
}

#pragma mark 其他辅助功能
#pragma mark 强制列表刷新
-(void)forceToFreshData{
    [_homeTableView setContentOffset:CGPointMake(_homeTableView.contentOffset.x,  - 66) animated:YES];
    double delayInSeconds = .2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [_refreshHeaderView forceToRefresh:_homeTableView];
    });
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([_delegate respondsToSelector:@selector(numberOfRowsInTableView:InSection:FromView:)]) {
       NSInteger vRows = [_dataSource numberOfRowsInTableView:tableView InSection:section FromView:self];
        mRowCount = vRows;
        return mRowCount + 1;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([_delegate respondsToSelector:@selector(heightForRowAthIndexPath:IndexPath:FromView:)]) {
        float vRowHeight = [_delegate heightForRowAthIndexPath:tableView IndexPath:indexPath FromView:self];
        return vRowHeight;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *vMoreCellIdentify = @"loadMoreCell";
    if (indexPath.row == mRowCount) {
        LoadMoreCell *vCell = [tableView dequeueReusableCellWithIdentifier:vMoreCellIdentify];
        if (vCell == Nil) {
            vCell = [[[NSBundle mainBundle] loadNibNamed:@"LoadMoreCell" owner:self options:Nil] lastObject];
            vCell.indicatorView.hidden = YES;
        }
        
        return vCell;
    }else{
        if ([_dataSource respondsToSelector:@selector(cellForRowInTableView:IndexPath:FromView:)]) {
            SlideTableViewCell *vCell = [_dataSource cellForRowInTableView:tableView IndexPath:indexPath FromView:self];
            vCell.delegate = self;
            return vCell;
        }
    }
    return Nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == mRowCount) {
        if ([_delegate respondsToSelector:@selector(loadData:FromView:)]) {
            LoadMoreCell *vLoadCell =(LoadMoreCell *)[tableView cellForRowAtIndexPath:indexPath];
            vLoadCell.userInteractionEnabled = NO;
            [vLoadCell.indicatorView setHidden:NO];
            [vLoadCell.indicatorView startAnimating];
            [_delegate loadData:^(int aAddedRowCount) {
                NSInteger vNewRowCount = aAddedRowCount;
                if (vNewRowCount > 0) {
                    NSMutableArray *indexPaths = [NSMutableArray array];
                    for (NSInteger lIndex = mRowCount; lIndex < mRowCount + vNewRowCount; lIndex++) {
                        [indexPaths addObject:[NSIndexPath indexPathForRow:lIndex inSection:0]];
                    }
                    [tableView beginUpdates];
                    [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                    [tableView endUpdates];
                    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
                    vLoadCell.userInteractionEnabled = YES;
                    [vLoadCell.indicatorView setHidden:YES];
                    [vLoadCell.indicatorView stopAnimating];
                }
            }FromView:self];
        }
    }else{
        if ([_delegate respondsToSelector:@selector(didSelectedRowAthIndexPath:IndexPath: FromView:)]) {
            [_delegate didSelectedRowAthIndexPath:tableView IndexPath:indexPath FromView:self];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if (slidedCell == [tableView cellForRowAtIndexPath:indexPath]) {
        [slidedCell hideMenuView:YES Animated:YES ];
        return NO;
    }
    return YES;
}

#pragma mark Data Source Loading / Reloading Methods
- (void)reloadTableViewDataSource{
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
    if ([_delegate respondsToSelector:@selector(refreshData: FromView:)]) {
        [_delegate refreshData:^{
            [self doneLoadingTableViewData];
        } FromView:self];
    }else{
        [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
    }
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.homeTableView];
    [self.homeTableView reloadData];
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_refreshHeaderView egoRefreshScrollViewWillBeginScroll:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}

#pragma mark - EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}


#pragma mark SlideTableViewCellDelegate
-(void)didCellWillShow:(id)aSender{
    slidedCell = aSender;
    self.canCustomEdit = YES;
}

-(void)didCellWillHide:(id)aSender{
    slidedCell = nil;
    self.canCustomEdit = NO;
}

-(void)didCellHided:(id)aSender{
    slidedCell = nil;
    self.canCustomEdit = NO;
}

-(void)didCellShowed:(id)aSender{
    slidedCell = aSender;
    self.canCustomEdit = YES;
    NSLog(@"调用Delegate");
}

#pragma mark HitViewDelegate
-(UIView *)hitViewHitTest:(CGPoint)point withEvent:(UIEvent *)event TouchView:(UIView *)aView{
    BOOL vCloudReceiveTouch = NO;
//    CGPoint vTouchPoint = [self convertPoint:point fromView:self.homeTableView];
    CGRect vSlidedCellRect = [self convertRect:slidedCell.frame fromView:self.homeTableView];
    vCloudReceiveTouch = CGRectContainsPoint(vSlidedCellRect, point);
    if (!vCloudReceiveTouch) {
        [slidedCell hideMenuView:YES Animated:YES];
    }
    return vCloudReceiveTouch ? [slidedCell hitTest:point withEvent:event] : aView;
}

#pragma mark 点击删除
-(void)didCellClickedDeleteButton:(UITableViewCell *)aSender{
    self.canCustomEdit = NO;
    NSIndexPath *vIndex = [self.homeTableView indexPathForCell:aSender];
    if ([_delegate respondsToSelector:@selector(didDeleteCellAtIndexpath:IndexPath:FromView:)]) {
        [_delegate didDeleteCellAtIndexpath:self.homeTableView IndexPath:vIndex FromView:self];
    }
    [self.homeTableView deleteRowsAtIndexPaths:@[vIndex,] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark 点击更多
-(void)didCellClickedMoreButton:(id)aSender{
}

@end
