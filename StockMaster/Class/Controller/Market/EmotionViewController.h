//
//  EmotionViewController.h
//  StockMaster
//
//  Created by 孤星之殇 on 15/4/29.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import "BasicViewController.h"
#import "PropView.h"
@interface EmotionViewController : BasicViewController<UITableViewDataSource,UITableViewDelegate,cardFounctionDelegate>
{
    UIView * bgView;
    UIView * footView;
    UILabel * tipLabel;
    
    UILabel * emotionNumLabel;
    UILabel * emotion;
    
    UITableView * infoTable;
    UIScrollView * cardScrollView;
        
    NSMutableDictionary * infoDic;
    PropView * prop;
    
    NSString * reward_type;
    UIView * feetView;
}

@property(nonatomic, assign)NSInteger emotionType;// = 2 从感情排行跳转
@property(nonatomic, strong)StockInfoEntity * stockInfo;
@end
