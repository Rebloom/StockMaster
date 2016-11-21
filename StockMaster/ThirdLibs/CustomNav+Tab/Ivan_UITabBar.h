//
//  Ivan_UITabBar.h
//  CustomNavBar+TabBar
//
//  Created by Ivan on 11-5-15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CHNMacro.h"
#import "NSString+UIColor.h"

@interface Ivan_UITabBar : UITabBarController {
	NSMutableArray * buttons;
    NSMutableArray * imageArr;
	UIView * cusTomTabBarView;
    UIImageView * slideBg;
    
    UILabel * badegeLabel;//
    UILabel * NumLabel;
}

@property (nonatomic,strong) NSMutableArray * buttons;
@property (nonatomic,strong) NSArray * imageArr;

- (void)hideRealTabBar;
- (void)customTabBar;

- (void)bringCustomTabBarToFront;
- (void)hideCustomTabBar;
- (void)selectedTab:(UIButton *)button;
- (void)setBadge:(NSNotification*)_notification;
@end
