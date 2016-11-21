//
//  Ivan_UITabBar.m
//  CustomNavBar+TabBar
//
//  Created by Ivan on 11-5-15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Ivan_UITabBar.h"
#import "UIBadgeView.h"
#import "GFStaticData.h"
#define kTabCellWidth  [UIScreen mainScreen].bounds.size.width/5-1

@implementation Ivan_UITabBar
@synthesize buttons;
@synthesize imageArr;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"hideCustomTabBar" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideCustomTabBar)
                                                 name: @"hideCustomTabBar"
                                               object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"bringCustomTabBarToFront" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bringCustomTabBarToFront)
                                                 name: @"bringCustomTabBarToFront"
                                               object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"setBadge" object:nil];

    slideBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    if (self.buttons.count)
    {
        // 已经有了 不需要再创建了
    }
    else
    {
        [self hideRealTabBar];
        [self customTabBar];
    }
}

- (void)hideRealTabBar{
    for(UIView *view in self.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            view.hidden = YES;
            break;
        }
    }
}


//自定义tabbar
- (void)customTabBar
{
    
    
    CGRect tabBarFrame = CGRectMake(0, screenHeight-49, screenWidth, 49);
    cusTomTabBarView = [[UIView alloc] initWithFrame:tabBarFrame];
    cusTomTabBarView.backgroundColor = [kFontColorA colorWithAlphaComponent:.95];
    
    UILabel * lineLb2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 0.5)];
    lineLb2.backgroundColor = KFontNewColorM;
    [cusTomTabBarView addSubview:lineLb2];

//    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
//    
//    UIVisualEffectView *effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
//    
//    effectview.frame =CGRectMake(0,0, screenWidth,49/2);
//
//    [cusTomTabBarView addSubview:effectview];
    
    //创建按钮
    self.buttons = [NSMutableArray arrayWithCapacity:5];
    for (int i = 0; i < 5; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(i*kTabCellWidth, 0, kTabCellWidth, 50);
        btn.tag = i;
        [btn addTarget:self action:@selector(selectedTab:) forControlEvents:UIControlEventTouchUpInside];
        
        UIViewController * v = [self.viewControllers objectAtIndex:i];
        
        
        UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(i*kTabCellWidth+1, 36, kTabCellWidth, 10)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = v.tabBarItem.title;
        titleLabel.font = NormalFontWithSize(10);
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = KFontNewColorB;
        titleLabel.tag = 1000+i;
        [self.buttons addObject:btn];
        
        UIImageView * imageView = [[UIImageView alloc] initWithImage:v.tabBarItem.image];
        imageView.frame = CGRectMake(i*kTabCellWidth+21, 9, 23, 23);
        imageView.center = CGPointMake(titleLabel.center.x, titleLabel.center.y - 22);
        imageView.tag = 1000+i;
        
        [cusTomTabBarView addSubview:btn];
        [cusTomTabBarView addSubview:imageView];
        [cusTomTabBarView addSubview:titleLabel];
        
        
        //2.6.5  临时需求（仅限4月使用）
        if (i == 3)
        {
            if (![[GFStaticData getObjectForKey:KTAGFLAG] boolValue])
            {
                if (!badegeLabel) {
                    badegeLabel = [[UILabel alloc] initWithFrame:CGRectMake(btn.bounds.size.width/2+10, 8, 8, 8)];
                    badegeLabel.backgroundColor = [UIColor redColor];
                    badegeLabel.textAlignment = NSTextAlignmentCenter;
                    badegeLabel.layer.cornerRadius = 4;
                    badegeLabel.layer.masksToBounds = YES;
                    badegeLabel.textColor =  [UIColor whiteColor];
                    [btn addSubview:badegeLabel];
                    [btn bringSubviewToFront:badegeLabel];
                }
            }
        }
        else if (i == 0)
        {
            if (!NumLabel)
            {
                NumLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/10+10, 5, 15, 15)];
                NumLabel.backgroundColor = kRedColor;
                NumLabel.textAlignment = NSTextAlignmentCenter;
                NumLabel.layer.cornerRadius = 7.5;
                NumLabel.layer.masksToBounds = YES;
                NumLabel.font = NormalFontWithSize(10);
                NumLabel.textColor =  [UIColor whiteColor];
                [btn addSubview:NumLabel];
                NumLabel.hidden = YES;
            }
        }
    }
    [self.view addSubview:cusTomTabBarView];
    [cusTomTabBarView addSubview:slideBg];
}

//切换tabbar
- (void)selectedTab:(UIButton *)button
{
    self.selectedIndex = button.tag;
    
    //2.6.5  临时需求（仅限4月使用）
    if (self.selectedIndex == 3)
    {
        if (badegeLabel)
        {
            badegeLabel.hidden = YES;
            [GFStaticData saveObject:@"YES" forKey:KTAGFLAG];
        }
    }
    
    [self performSelector:@selector(slideTabBg:) withObject:button];
}

//将自定义的tabbar显示出来
- (void)bringCustomTabBarToFront
{
    [self performSelector:@selector(hideRealTabBar)];
    [cusTomTabBarView setHidden:NO];
}

//隐藏自定义tabbar
- (void)hideCustomTabBar
{
    [self performSelector:@selector(hideRealTabBar)];
    CAKeyframeAnimation * animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.1;
    animation.delegate = self;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.5, 0.5, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.0, 0.0, 0.0)]];
    animation.values = values;
    [cusTomTabBarView.layer addAnimation:animation forKey:nil];
}


//动画结束回调
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (anim.duration==0.1)
    {
        [cusTomTabBarView setHidden:YES];
    }
}

//切换滑块位置
- (void)slideTabBg:(UIButton *)btn
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.2];
    [UIView setAnimationDelegate:self];
    [slideBg setImage:[UIImage imageNamed:[imageArr objectAtIndex:btn.tag]]];
    if (!btn)
    {
        if (iPhone6)
        {
            slideBg.frame = CGRectMake(25, 7, 23, 23);//btn.frame;
        }
        else if (iPhone6Plus)
        {
            slideBg.frame = CGRectMake(29, 7, 23, 23);//btn.frame;
        }
        else
        {
            slideBg.frame = CGRectMake(20, 7, 23, 23);//btn.frame;
        }
    }
    else
    {
        slideBg.frame = CGRectMake(btn.frame.origin.x+21, btn.frame.origin.y+9, 23, 23);//btn.frame;
        slideBg.center = CGPointMake(btn.center.x, btn.center.y-7);
    }
    [UIView commitAnimations];
    
    for (UIView * view in cusTomTabBarView.subviews)
    {
        NSInteger viewTag = view.tag-1000;
        if ([view isKindOfClass:[UIImageView class]])
        {
            if (viewTag >= 0)
            {
                if (btn.tag == viewTag)
                {
                    view.hidden = YES;
                }
                else
                {
                    view.hidden = NO;
                }
            }
        }
        else if ([view isKindOfClass:[UILabel class]])
        {
            UILabel * labelView = (UILabel *)view;
            if (viewTag >= 0)
            {
                if (btn.tag == viewTag)
                {
                    labelView.textColor = kRedColor;
                }
                else
                {
                    labelView.textColor = KFontNewColorB;
                }
            }
        }
    }
}

//设置badge
- (void)setBadge:(NSString *)badge
{
    NumLabel.text = badge;
    
    if ([badge integerValue] > 0)
    {
        NumLabel.hidden = NO;
    }
    else
    {
        NumLabel.hidden = YES;
    }
}


@end
