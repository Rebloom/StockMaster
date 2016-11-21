//
//  EAIntroPage.h
//  EAIntroView
//
//  Copyright (c) 2013 Evgeny Aleksandrov.
//

#import <Foundation/Foundation.h>

@interface EAIntroPage : NSObject

// title image Y position - from top of the screen
// title and description labels Y position - from bottom of the screen
@property (nonatomic, strong) UIImage *bgImage;
@property (nonatomic, strong) UIImage *titleImage;
@property (nonatomic, assign) CGFloat imgPositionY;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, assign) CGFloat titlePositionY;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) UIFont *descFont;
@property (nonatomic, strong) UIColor *descColor;
@property (nonatomic, assign) CGFloat descPositionY;

// if customView is set - all other properties are ignored
@property (nonatomic, strong) UIView *customView;

+ (EAIntroPage *)page;
+ (EAIntroPage *)pageWithCustomView:(UIView *)customV;

@end
