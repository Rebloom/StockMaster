//
//  SellCell.h
//  StockMaster
//
//  Created by dalikeji on 14-8-5.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHNMacro.h"

@protocol SellCellDelegate <NSObject>

- (void)cellSelectedBtn:(UIButton *)btn withSection:(NSInteger)section;

- (void)cellChooseAtIndex:(NSInteger)index WithSection:(NSInteger)section;

@end

@interface SellCell : UITableViewCell
{
    UILabel * stockName;
    UILabel * stockID;
    UILabel * addLabel;
    UIImageView * imageView;
    UIButton * leftBtn;
    UIButton * rigthBtn;
}

@property (nonatomic, strong) UILabel *stockName;
@property (nonatomic, strong) UILabel *stockID;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton * leftBtn;
@property (nonatomic, strong) UIButton * rightBtn;

@property (nonatomic, assign) NSInteger rightBtnTag;

@property (nonatomic, weak) id <SellCellDelegate> delegate;
@end