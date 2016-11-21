//
//  CardListCell.h
//  StockMaster
//
//  Created by dalikeji on 14-10-11.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasicViewController.h"
@protocol CardListCellDelegate<NSObject>
-(void)cellForDelete:(NSInteger)index;
-(void)cellForManage:(NSInteger)index;
@end

@interface CardListCell : UITableViewCell
{
    UILabel * bank_name;
    UILabel * real_name;
    UILabel * card_number;
    UILabel * invalid;
}
@property(nonatomic, strong) UILabel * bank_name;
@property(nonatomic, strong) UILabel * real_name;
@property(nonatomic, strong) UILabel * card_number;
@property(nonatomic, strong) UILabel * invalid;

@property(nonatomic, weak) id<CardListCellDelegate>delegate;
@end
