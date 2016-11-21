//
//  HeaderView.m
//  WisdomCity
//
//  Created by Rebloom on 13-10-24.
//  Copyright (c) 2013年 Rebloom. All rights reserved.
//

#import "HeaderView.h"
#import "CHNMacro.h"
#import "NSString+UIColor.h"
@implementation HeaderView

@synthesize delegate;

@synthesize refreshImage;
@synthesize actView;
@synthesize addSelectBtn;
@synthesize addSelectImage;
@synthesize buttonSelected;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
    }
    return self;
}

-(void)createLine
{
    UILabel * lineLb2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 64.5, screenWidth, 0.5)];
    lineLb2.backgroundColor = KFontNewColorM;
    [self addSubview:lineLb2];

}

- (void)setStatusBarColor:(UIColor *)color
{
    UIView * statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 20)];
    statusBarView.backgroundColor = color;
    [self addSubview:statusBarView];
    
    [self setBackgroundColor:color];
}

- (void)loadComponentsWithTitle:(NSString *)title
{
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, beginX+10, screenWidth, 25)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = title;
    titleLabel.textColor = KFontNewColorA;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = NormalFontWithSize(17);
    [self addSubview:titleLabel];

    
    //3.0 顶导统一白色
    [self setStatusBarColor:kFontColorA];
    [self setBackgroundColor:kFontColorA];

}

- (void)loadStockTitle:(StockInfoEntity *)stockInfo
{
    UILabel * stockNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, beginX+10, screenWidth/2, 15)];
    stockNameLabel.backgroundColor = [UIColor clearColor];
    stockNameLabel.text = stockInfo.name;
    stockNameLabel.textColor = [UIColor whiteColor];
    stockNameLabel.textAlignment = NSTextAlignmentRight;
    stockNameLabel.font = NormalFontWithSize(14);
    [self addSubview:stockNameLabel];
    
    UILabel * stockIDLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(stockNameLabel.frame)+3, CGRectGetMinY(stockNameLabel.frame), screenWidth/2, 15)];
    stockIDLabel.backgroundColor = [UIColor clearColor];
    stockIDLabel.text = stockInfo.code;
    stockIDLabel.textColor = [UIColor whiteColor];
    stockIDLabel.textAlignment = NSTextAlignmentLeft;
    stockIDLabel.font = NormalFontWithSize(14);
    [self addSubview:stockIDLabel];
}

-(void)logoButton
{
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(18, beginX+13, 27, 20)];
    [imageView setBackgroundColor:[UIColor clearColor]];
    [imageView setImage:[UIImage imageNamed:@"logo_right.png"]];
    [self addSubview:imageView];
}

- (void)loginButton
{
    UIButton * loginButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth-60, beginX+8, 60, 30)];
    [loginButton setBackgroundImage:[UIImage imageNamed:@"btn_login.png"] forState:UIControlStateNormal];
    [loginButton setTitle:@"登录" forState:UIControlStateNormal];
    loginButton.tag = 0;
    [loginButton addTarget:self action:@selector(headerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [loginButton setBackgroundColor:[UIColor clearColor]];
    [self addSubview:loginButton];
}


- (void)backButton
{
    UIButton * backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, beginX, 60, kTagHeaderHeight)];
    backButton.tag = 1;
    UIImageView * backImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, beginX+13, 11, 20)];
    [backImage setBackgroundColor:[UIColor clearColor]];
    backImage.image = [UIImage imageNamed:@"jiantou-zuo"];
    [self addSubview:backImage];
    [backButton addTarget:self action:@selector(headerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:backButton];
}

- (void)closeButton
{
    UIButton * closeBtn = [[UIButton alloc] init];
    closeBtn.tag = 6;
    closeBtn.frame = CGRectMake(0, 20, 60, 44);
    closeBtn.titleLabel.font = NormalFontWithSize(15);
    [closeBtn setTitleColor:KFontNewColorA forState:UIControlStateNormal];
    [closeBtn setBackgroundColor:[UIColor clearColor]];
    [closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(headerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeBtn];
}

- (void)finishButton
{
    UIButton * finishButton = [[UIButton alloc] initWithFrame:CGRectMake(0, beginX+3, 60, kTagHeaderHeight)];
    finishButton.tag = 5;
    [finishButton setTitle:@"完成" forState:UIControlStateNormal];
    finishButton.titleLabel.font = NormalFontWithSize(14);
    [finishButton setTintColor:@"#fffff".color ];
    [finishButton addTarget:self action:@selector(headerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:finishButton];
}

- (void)refreshButton
{
    UIButton * refreshButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth-65, beginX, 40, self.frame.size.height)];
    refreshButton.tag = 2;
    refreshImage = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-41, beginX+13, 20, 19)];
    [refreshImage setBackgroundColor:[UIColor clearColor]];
    refreshImage.image = [UIImage imageNamed:@"icon_refresh"];
    refreshImage.userInteractionEnabled = YES;
    [self addSubview:refreshImage];
    
    [refreshButton addTarget:self action:@selector(headerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:refreshButton];
    
    actView = [[UIActivityIndicatorView alloc] init];
    actView.userInteractionEnabled = YES;
    actView.color = kFontColorA;
    actView.frame = CGRectMake(screenWidth-41, beginX+13, 20, 19);
    [self addSubview:actView];
}

- (void)searchButton:(NSInteger)type
{
    UIButton * searchButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth-60, beginX, 60, 45)];
    searchButton.tag = 3;
    UIImageView * backImage = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-36, beginX+13, 18, 18)];
    if (type == 1)
    {
        backImage.image = [UIImage imageNamed:@"icon_search"];
    }
    else
    {
        backImage.image = [UIImage imageNamed:@"icon_search2"];
    }
    
    [self addSubview:backImage];
    [searchButton addTarget:self action:@selector(headerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:searchButton];
}

- (void)headerButtonClicked:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    if ([self.delegate respondsToSelector:@selector(buttonClicked:)])
    {
        [self.delegate buttonClicked:btn];
    }
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
