//
//  StockDetailViewController.h
//  StockMaster
//
//  Created by dalikeji on 15/3/10.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "NSTimer+Addition.h"
#import "TimeLineView.h"
#import "PropView.h"

@interface StockDetailViewController : BasicViewController<UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate,cardFounctionDelegate>
{
    EGORefreshTableHeaderView * refreshview;
    
    UITableView * infoTableView;
    UIView * tableHead;
    
    UILabel * priceLabel;
    UILabel * percentLabel;
    UILabel * compareLabel;
    UILabel * profitLabel;
    UILabel * statusLabel;
    
    UILabel * timeLabel; // 市场状态与日期时间
    
    UIScrollView *holdScrollView;
    UIView *holdLongView;
    UIView *holdShortView;
    UIPageControl *pageControl;
    
    UIView * buttonView;
    UIView * operateView;
    
    UIButton * buyLongButton;
    UIButton * buyShortButton;
    UIButton * sellLongButton;
    UIButton * sellShortButton;
    UIButton * moreOperateButton;
    UIButton * selectButton; // 添加自选按钮
    UIButton * remindButton; // 添加提醒按钮
    UILabel * buyTipPoint; // 买跌提示红点
    UILabel * moreTipPoint; // 卖跌提示红点
    
    TimeLineView * lineView;
    
    PropView * prop;
    
    BOOL isEgoRefresh;
    BOOL isMoreOpen; // 更多操作弹层开关
    
    NSTimer * marketTimer;
    
    NSInteger lightNum;
    
    UIImageView * bottomImageView;
    UIImageView * smallImageView;
    UIImageView * bigImageView;
    UILabel * smallNumLabel;
    
    BOOL showOrHide;
    
    NSTimer * heartTimer;
}

@property (nonatomic, strong) StockInfoEntity * stockInfo;
@property (nonatomic, copy) NSString * title;

@end
