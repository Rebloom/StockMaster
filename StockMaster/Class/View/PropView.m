//
//  PropView.m
//  StockMaster
//
//  Created by 孤星之殇 on 15/7/1.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import "PropView.h"
#import "NSString+UIColor.h"
#import "CHNMacro.h"
#import "AppDelegate.h"
#import "EmotionViewController.h"

@implementation PropView
@synthesize delegate;
@synthesize numLabel;
@synthesize leftImage;
@synthesize isShow;
@synthesize isAdd;
@synthesize buyBtn;

- (void)dealloc
{
}

+(PropView*)defaultShareView
{
    static PropView * defaultCardView = nil;
    if (!defaultCardView)
    {
        defaultCardView = [[PropView alloc] init];
    }

    return defaultCardView;
}

- (void)showView
{
    isShow = YES;
    mainView.hidden = NO;
    cardView.hidden = NO;
}

-(void)hideView
{
    isShow = NO;
    mainView.hidden = YES;
    cardView.hidden = YES;
}

//使用道具（暂无可用）弹层
- (id)init
{
    self = [super init];
    
    return self;
}

- (id)initViewWithName:(NSString *)name WithDescription:(NSString *)description WithType:(NSInteger)type Delegate:(id)_delegate WithImageURL:(NSString *)imageURL WithDirect:(NSString *)direct WithPrompt:(NSString *)prompt isBuy:(BOOL)buy cardPrice:(NSString *)price usable:(NSString *)money ExpireTime:(NSString *)expireTime
{
    [self clearSubview];

    if (self = [super init])
    {
        if (!mainView)
        {
            mainView = [[UIView alloc] init];
        }
        mainView.userInteractionEnabled = YES;
        mainView.backgroundColor = [UIColor blackColor];
        mainView.alpha = 0.4;
        mainView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
        [[UIApplication sharedApplication].keyWindow addSubview:mainView];

        
        UIButton * hideBtn = [[UIButton alloc] init];
        hideBtn.frame = CGRectMake(0, 0, screenWidth, screenHeight);
        [hideBtn setBackgroundColor:[UIColor clearColor]];
        [hideBtn addTarget:self action:@selector(hideView) forControlEvents:UIControlEventTouchUpInside];
        [mainView addSubview:hideBtn];
        
        if (!cardView)
        {
            cardView = [[UIImageView alloc] init];
        }
        cardView.backgroundColor = kFontColorA;
        cardView.userInteractionEnabled = YES;
        cardView.frame = CGRectMake((screenWidth-275)/2, 100, 275, 400);
        [[UIApplication sharedApplication].keyWindow addSubview:cardView];
        
        UIImageView * detailImageView = [[UIImageView alloc] init];
        detailImageView.backgroundColor = [UIColor lightGrayColor];
        [detailImageView sd_setImageWithURL:[NSURL URLWithString:imageURL]
                   placeholderImage:nil];
        detailImageView.frame = CGRectMake(0, 0, 275, 175);
        detailImageView.backgroundColor = [UIColor grayColor];
        [cardView addSubview:detailImageView];
        
        UILabel * nameLabel = [[UILabel alloc] init];
        nameLabel.text = name;
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.textColor = KFontNewColorA;
        nameLabel.frame = CGRectMake(15, CGRectGetMaxY(detailImageView.frame)+15, CGRectGetWidth(cardView.frame)-30, 17);
        nameLabel.font = NormalFontWithSize(16);
        [cardView addSubview:nameLabel];
        
        if (expireTime.length)
        {
            [nameLabel sizeToFit];
            UILabel * expireTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(nameLabel.frame)+5, CGRectGetMidY(nameLabel.frame)-6, 200, 12)];
            expireTimeLabel.backgroundColor = [UIColor clearColor];
            expireTimeLabel.font = NormalFontWithSize(12);
            expireTimeLabel.textColor = KFontNewColorB;
            expireTimeLabel.text = expireTime;
            [cardView addSubview:expireTimeLabel];
        }
        
        UILabel * desLabel= [[UILabel alloc] init];
        desLabel.textAlignment = NSTextAlignmentLeft;
        desLabel.textColor = KFontNewColorB;
        desLabel.text = description;
        desLabel.font = NormalFontWithSize(13);
        desLabel.numberOfLines = 0;
        
        //调整描述行间距
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:desLabel.text];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:5];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [desLabel.text length])];
        desLabel.attributedText = attributedString;
        
        CGSize size = CGSizeMake(CGRectGetWidth(cardView.frame)-30, CGFLOAT_MAX);
        CGSize labelSize = [desLabel sizeThatFits:size];
        desLabel.frame = CGRectMake(15, CGRectGetMaxY(nameLabel.frame)+15, CGRectGetWidth(cardView.frame)-30, labelSize.height);

        [cardView addSubview:desLabel];
        
        // 处理购买卡片逻辑
        if(buy)
        {
            UIView * containerView = [[UIView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(desLabel.frame)+10, screenWidth-20, 27)];
            [cardView addSubview:containerView];
            
            leftImage = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 27, 27)];
            leftImage.tag = self.tag+1;
            leftImage.enabled = NO;
            [leftImage setBackgroundImage:[UIImage imageNamed:@"icon_buycard_left_enabled"] forState:UIControlStateNormal];
            [leftImage setBackgroundImage:[UIImage imageNamed:@"icon_buycard_right_disabled"] forState:UIControlStateDisabled];
            [leftImage addTarget:self action:@selector(minusBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [containerView addSubview:leftImage];
            
            rightImage = [[UIButton alloc] initWithFrame:CGRectMake(cardView.frame.size.width-27-20, 0, 27, 27)];
            rightImage.tag = self.tag+1;
            [rightImage setBackgroundImage:[UIImage imageNamed:@"icon_buycard_right_enabled"] forState:UIControlStateNormal];
            [rightImage setBackgroundImage:[UIImage imageNamed:@"icon_buycard_right_disabled"] forState:UIControlStateDisabled];
            [rightImage addTarget:self action:@selector(addBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [containerView addSubview:rightImage];
            
            numLabel = [[UILabel alloc] initWithFrame:CGRectMake(27, 0, cardView.frame.size.width-37*2, 27)];
            numLabel.backgroundColor = [UIColor clearColor];
            numLabel.font = NormalFontWithSize(15);
            numLabel.text = @"1";
            numLabel.textAlignment = NSTextAlignmentCenter;
            [containerView addSubview:numLabel];
            
            UIView * upLine = [[UIView alloc] initWithFrame:CGRectMake(27, 0, cardView.frame.size.width-37*2, .5)];
            upLine.backgroundColor = kLineBGColor2;
            [containerView addSubview:upLine];
            
            UIView * downLine = [[UIView alloc] initWithFrame:CGRectMake(27, 26.5, cardView.frame.size.width-37*2, .5)];
            downLine.backgroundColor = kLineBGColor2;
            [containerView addSubview:downLine];
            
            UILabel * desc = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(containerView.frame)+13, cardView.frame.size.width-30, 15)];
            desc.backgroundColor = [UIColor clearColor];
            desc.font = NormalFontWithSize(13);
            desc.textColor = KFontNewColorB;
            desc.text = money;
            desc.textAlignment = NSTextAlignmentRight;
            [cardView addSubview:desc];
            
            closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(desc.frame)+5, (cardView.frame.size.width-20-16)/2, 44)];
            [closeBtn addTarget:self action:@selector(closeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            closeBtn.layer.cornerRadius = 4;
            closeBtn.layer.masksToBounds = YES;
            closeBtn.titleLabel.font = NormalFontWithSize(13);
            closeBtn.backgroundColor = KColorHeader;
            [closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
            [closeBtn setTitleColor:KFontNewColorA forState:UIControlStateNormal];
            [cardView addSubview:closeBtn];
            
            buyBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(closeBtn.frame)+16, CGRectGetMaxY(desc.frame)+5,(cardView.frame.size.width-20-16)/2, 44)];
            [buyBtn addTarget:self action:@selector(buyBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            buyBtn.titleLabel.font = NormalFontWithSize(13);
            buyBtn.layer.cornerRadius = 4;
            buyBtn.layer.masksToBounds = YES;
            [buyBtn setTitle:price forState:UIControlStateNormal];
            [buyBtn setTitleColor:kFontColorA forState:UIControlStateNormal];
            [buyBtn setBackgroundImage:kRedColor.image forState:UIControlStateNormal];
            [buyBtn setBackgroundImage:kRedColor.image forState:UIControlStateHighlighted];
            [buyBtn setBackgroundImage:kRedColor.image forState:UIControlStateSelected];
            [cardView addSubview:buyBtn];
            
            [self showView];
            self.delegate = _delegate;
            self.frame = CGRectMake(0, 0, screenWidth, screenHeight);
            return self;
        }
        
        UIButton * directBtn = [[UIButton alloc] init];
        directBtn.frame = CGRectMake(CGRectGetWidth(cardView.frame) -165 , CGRectGetMaxY(desLabel.frame), 150, 30);
        directBtn.backgroundColor = [UIColor clearColor];
        [directBtn setTitleColor:KFontNewColorB forState:UIControlStateNormal];
        [directBtn addTarget:self action:@selector(directBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [cardView addSubview:directBtn];
        
        UILabel * directLabel = [[UILabel alloc] init];
        directLabel.textAlignment = NSTextAlignmentRight;
        directLabel.font = NormalFontWithSize(13);
        directLabel.textColor = KFontNewColorB;
        directLabel.text = direct;
        directLabel.frame = CGRectMake(0, 15, 150, 15);
        [directBtn addSubview:directLabel];
        
        UIButton * funcBtn = [[UIButton alloc] init];
        funcBtn.tag = type;
        funcBtn.layer.cornerRadius = 4;
        funcBtn.layer.masksToBounds = YES;
        funcBtn.titleLabel.font = NormalFontWithSize(13);
        funcBtn.backgroundColor = KColorHeader;
        if (type == 1)
        {
            //可以使用
            funcBtn.frame = CGRectMake(15, CGRectGetMaxY(directBtn.frame)+15, (CGRectGetWidth(cardView.frame)-30)/2-7.5, 44);
            [funcBtn setTitle:@"关闭" forState:UIControlStateNormal];
            [funcBtn setTitleColor:KFontNewColorA forState:UIControlStateNormal];
        }
        else if (type == 2)
        {
            //暂时不可使用
            funcBtn.frame = CGRectMake(15, CGRectGetMaxY(directBtn.frame)+15, CGRectGetWidth(cardView.frame)-30, 44);
            [funcBtn setTitle:prompt forState:UIControlStateNormal];
            [funcBtn setTitleColor:KFontNewColorA forState:UIControlStateNormal];
        }
        [funcBtn addTarget:self action:@selector(funcBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [cardView addSubview:funcBtn];
        
        if (type == 1)
        {
            UIButton * useBtn = [[UIButton alloc] init];
            useBtn.frame = CGRectMake(CGRectGetMaxX(funcBtn.frame)+15, CGRectGetMaxY(directBtn.frame)+15, CGRectGetWidth(funcBtn.frame), CGRectGetHeight(funcBtn.frame));
            useBtn.titleLabel.font = NormalFontWithSize(13);
            useBtn.layer.cornerRadius = 4;
            useBtn.layer.masksToBounds = YES;
            [useBtn setTitle:prompt forState:UIControlStateNormal];
            [useBtn setTitleColor:kFontColorA forState:UIControlStateNormal];
            [useBtn setBackgroundImage:kRedColor.image forState:UIControlStateNormal];
            [useBtn setBackgroundImage:kRedColor.image forState:UIControlStateHighlighted];
            [useBtn setBackgroundImage:kRedColor.image forState:UIControlStateSelected];
            [useBtn addTarget:self action:@selector(useBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
            [cardView addSubview:useBtn];
        }

        cardView.frame = CGRectMake((screenWidth-275)/2, (screenHeight -335-labelSize.height)/2, 275, 330+labelSize.height);
        
        [self showView];
        self.delegate = _delegate;
    }
    
    self.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    return self;
}

// 点击－号
- (void)minusBtnClicked:(id)sender
{
    isAdd = NO;
    if ([self.delegate respondsToSelector:@selector(minusBtnClicked:)])
    {
        [self.delegate minusBtnClicked:sender];
    }
}

// 点击+号
- (void)addBtnClicked:(id)sender
{
    isAdd = YES;
    if ([self.delegate respondsToSelector:@selector(minusBtnClicked:)])
    {
        [self.delegate addBtnClicked:sender];
    }
}

// 点击关闭
- (void)closeBtnClicked:(id)sender
{
    [self hideView];
}

// 点击购买
- (void)buyBtnClicked:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(buyBtnClicked:)])
    {
        [self.delegate buyBtnClicked:sender];
    }
}

//关闭
- (void)funcBtnOnClick:(UIButton*)sender
{
    [self hideView];
}

//指向去哪儿进行操作
- (void)directBtnOnClick:(UIButton*)sender
{
    if ([self.delegate respondsToSelector:@selector(directToDo:)])
    {
        [self.delegate directToDo:sender.tag];
    }
}

//立即使用
- (void)useBtnOnClick:(UIButton*)sender
{
    if ([self.delegate respondsToSelector:@selector(cardToUse:)])
    {
        [self.delegate cardToUse:sender.tag];
    }
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
    if (cardView)
    {
        for (UIView * view in cardView.subviews)
        {
            [view removeFromSuperview];
        }
    }
}

@end
