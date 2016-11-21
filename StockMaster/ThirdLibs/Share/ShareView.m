//
//  ShareView.m
//  StockMaster
//
//  Created by dalikeji on 15/2/9.
//  Copyright (c) 2015年 Rebloom. All rights reserved.
//

#import "ShareView.h"

@implementation ShareView
@synthesize delegate;


- (void)dealloc
{
}

+ (ShareView *)defaultShareView
{
    static ShareView * defaultShareView = nil;
    if (!defaultShareView)
    {
        defaultShareView = [[ShareView alloc] init];
    }
    return defaultShareView;
}

- (id)initViewWtihNumber:(NSInteger)number Delegate:(id)_delegate WithViewController:(UIViewController*)viewController
{
    [self clearSubview];
    
    if (self = [super init])
    {
        if(!mainView)
        {
            mainView = [[UIView alloc] init];
        }
        mainView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
        mainView.hidden = NO;
        mainView.backgroundColor = [UIColor clearColor];
        [viewController.view addSubview:mainView];
        
        
        UIView * topView = [[UIView alloc] init];
        topView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
        topView.alpha = 0.5;
        topView.backgroundColor = @"#000000".color;
        [mainView addSubview:topView];
        
        UIButton * hideBtn = [[UIButton alloc] init];
        hideBtn.frame = topView.frame;
        hideBtn.tag = 10;
        hideBtn.backgroundColor = [UIColor clearColor];
        [hideBtn addTarget:self action:@selector(buttonOnClick:) forControlEvents:UIControlEventTouchUpInside
         ];
        [mainView addSubview:hideBtn];
        
        if (!feetView)
        {
            feetView = [[UIImageView alloc] init];
        }
        feetView.backgroundColor = [UIColor whiteColor];
        feetView.userInteractionEnabled = YES;
        feetView.hidden = NO;
        feetView.frame = CGRectMake(0, screenHeight - 240, screenWidth, 240);
        [viewController.view addSubview:feetView];
        [viewController.view bringSubviewToFront:feetView];
        
        for (int i = 0; i< number; i++)
        {
            UIButton * btn = [[UIButton alloc] init];
            btn.tag = i;
            UIImageView * imgView = [[UIImageView alloc] init];
            if (i == 0)
            {
                [btn setFrame:CGRectMake(20, 12.5, 90, 75)];
                imgView.frame = CGRectMake(40, 25, 50, 50);
                imgView.image = [UIImage imageNamed:@"qq"];
            }
            else if (i == 1)
            {
                [btn setFrame:CGRectMake(110, 12.5, 90, 75)];
                imgView.frame = CGRectMake(135, 25, 50, 50);
                imgView.image = [UIImage imageNamed:@"qzone"];
            }
            else if (i == 2)
            {
                [btn setFrame:CGRectMake(200, 12.5, 90, 75)];
                imgView.frame = CGRectMake(225, 25, 50, 50);
                imgView.image = [UIImage imageNamed:@"pengyouquan"];
            }
            else if (i == 3)
            {
                [btn setFrame:CGRectMake(20, 87.5, 90, 75)];
                imgView.frame = CGRectMake(40, 100, 50, 50);
                imgView.image = [UIImage imageNamed:@"weixin"];
            }
            else if (i == 4)
            {
                [btn setFrame:CGRectMake(110, 87.5, 90, 75)];
                imgView.frame = CGRectMake(135, 100, 50, 50);
                imgView.image = [UIImage imageNamed:@"weibo"];
            }
            [feetView addSubview:imgView];
            
            [btn addTarget:self action:@selector(buttonOnClick:) forControlEvents:UIControlEventTouchUpInside];
            [feetView addSubview:btn];
            [feetView bringSubviewToFront:imgView];
        }
        
        UIButton * cancelBtn = [[UIButton alloc] init];
        cancelBtn.tag = 10;
        cancelBtn.frame = CGRectMake(20, 240-20-44, screenWidth - 40, 44);
        cancelBtn.layer.cornerRadius = 5;
        cancelBtn.layer.masksToBounds = YES;
        cancelBtn.titleLabel.font = NormalFontWithSize(16);
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn setBackgroundImage:[KSelectNewColor1 image] forState:UIControlStateNormal];
        [cancelBtn setBackgroundImage:[KSelectNewColor2 image ] forState:UIControlStateSelected];
        [cancelBtn setBackgroundImage:[KSelectNewColor2 image] forState:UIControlStateHighlighted];
        [cancelBtn addTarget:self action:@selector(buttonOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [cancelBtn  setTitleColor:KFontNewColorA forState:UIControlStateNormal];
        [feetView addSubview:cancelBtn];
        
        CATransition *animation = [CATransition animation];
        
        [animation setDuration:0.5];
        
        [animation setType: kCATransitionMoveIn];
        
        [animation setSubtype: kCATransitionFromTop];
        
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
        
        [feetView.layer addAnimation:animation forKey:nil];
        
        self.delegate = _delegate;
    }
    
    self.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    return self;
}


- (void)showView
{
    mainView.hidden = NO;
    feetView.hidden = NO;
}

- (void)buttonOnClick:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(shareAtIndex:)])
    {
        UIButton * btn = (UIButton *)sender;
        [self.delegate shareAtIndex:btn.tag];
        [self hideView];
    }
}

// 点击取消按钮
- (void)hideView
{
    [UIView beginAnimations:@"Animation" context:nil];
    [UIView setAnimationDuration:0.4];
    feetView.frame = CGRectMake(0, screenHeight, screenWidth, 202);
    [UIView commitAnimations];
    [self performSelector:@selector(handleTimer) withObject:self afterDelay:0.4];
}

-(void)handleTimer
{
    mainView.hidden = YES;
    feetView.hidden = YES;
    feetView.frame = CGRectMake(0, screenHeight - 202, screenWidth, 202);
    [self clearSubview];
}

// 清除视图块子视图
-(void)clearSubview
{
    if (mainView)
    {
        for (UIView * view in mainView.subviews)
        {
            [view removeFromSuperview];
        }
    }
    if (feetView)
    {
        for (UIView * view in feetView.subviews)
        {
            feetView.backgroundColor = [UIColor clearColor];
            [view removeFromSuperview];
        }
    }
}

@end
