//
//  PropView.h
//  StockMaster
//
//  Created by 孤星之殇 on 15/7/1.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol cardFounctionDelegate <NSObject>

//道具包代理方法 --- 使用卡片
- (void)cardToUse:(NSInteger)index;

//道具包代理方法 --- 指引（eg：查看感情度）
- (void)directToDo:(NSInteger)index;

- (void)addBtnClicked:(id)sender;
- (void)minusBtnClicked:(id)sender;
- (void)buyBtnClicked:(id)sender;

@end

@interface PropView : UIView
{
    UIView * mainView;
    UIImageView * cardView;
    
    UIButton * leftImage;
    UIButton * rightImage;
    
    UILabel * numLabel;
    UIButton * closeBtn;
    UIButton * buyBtn;
}

@property (nonatomic,weak)id<cardFounctionDelegate>delegate;
@property (nonatomic,strong) UILabel * numLabel;
@property (nonatomic,strong) UIButton * leftImage;
@property (nonatomic,assign) BOOL isShow;
@property (nonatomic,assign) BOOL isAdd;
@property (nonatomic,strong) UIButton * buyBtn;

+ (PropView *)defaultShareView;
- (void) showView;
- (void) hideView;

- (id)initViewWithName:(NSString *)name WithDescription:(NSString *)description WithType:(NSInteger)type Delegate:(id)_delegate WithImageURL:(NSString *)imageURL WithDirect:(NSString *)direct WithPrompt:(NSString *)prompt isBuy:(BOOL)buy cardPrice:(NSString *)price usable:(NSString *)money ExpireTime:(NSString *)expireTime;


@end
