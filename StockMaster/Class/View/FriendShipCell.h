//
//  FriendShipCell.h
//  StockMaster
//
//  Created by dalikeji on 15/2/27.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendShipCell : UITableViewCell
{
    UIImageView * photoImg;
    UILabel * nameLabel;
    UILabel * moneyLabel;
    UILabel * lineLable;
    UIImageView * rankImageView;
    UILabel * rankLabel;
}

@property (nonatomic, strong)UIImageView * photoImg;
@property (nonatomic, strong)UILabel * nameLabel;
@property (nonatomic, strong)UILabel * moneyLabel;
@property (nonatomic, strong)UILabel * lineLable;
@property (nonatomic, strong)UIImageView * rankImageView;
@property (nonatomic, strong)UILabel * rankLabel;

@end
