//
//  HeaderView.h
//  WisdomCity
//
//  Created by Rebloom on 13-10-24.
//  Copyright (c) 2013年 Rebloom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFStaticData.h"
#import "StockInfoCoreDataStorage.h"

@protocol HeaderViewDelegate <NSObject>

@optional
- (void)buttonClicked:(id)sender;

@end

@interface HeaderView : UIView

@property (nonatomic, weak) id <HeaderViewDelegate> delegate;
@property (nonatomic, strong) UIImageView * refreshImage;
@property (nonatomic, strong) UIActivityIndicatorView * actView;
@property (nonatomic, strong) UIButton * addSelectBtn;
@property (nonatomic, strong) UIImageView * addSelectImage;
@property (nonatomic, assign) BOOL buttonSelected;

- (void)loadStockTitle:(StockInfoEntity *)stockInfo;
- (void)loadComponentsWithTitle:(NSString *)title;
- (void)loginButton;
- (void)backButton;
- (void)searchButton:(NSInteger)type;
- (void)logoButton;
- (void)refreshButton;
- (void)finishButton;
- (void)closeButton;
- (void)setStatusBarColor:(UIColor *)color;
- (void)createLine;

@end
