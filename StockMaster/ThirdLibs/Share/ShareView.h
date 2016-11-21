//
//  ShareView.h
//  StockMaster
//
//  Created by dalikeji on 15/2/9.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHNMacro.h"
#import "NSString+UIColor.h"
#import "UIImage+UIColor.h"
#import "NSTimer+Addition.h"

@protocol ShareViewDelegate <NSObject>
@required

- (void)shareAtIndex:(NSInteger)index;

@end

@interface ShareView : UIView
{
    UIView * mainView;
   
    UIImageView * feetView;
    
    BOOL isAlert;
}

@property (nonatomic, weak) id<ShareViewDelegate>delegate;

+ (ShareView *)defaultShareView;
- (void) showView;
- (void) hideView;
- (id)initViewWtihNumber:(NSInteger)number Delegate:(id)_delegate WithViewController:(UIViewController*)viewController;


@end
