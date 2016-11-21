//
//  CHNAlertView.m
//  StockMaster
//
//  Created by Rebloom on 14-10-12.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "CHNAlertView.h"
#import "UIImage+UIColor.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import "CHNMacro.h"

static const char * const kAHAlertViewButtonBlockKey = "AHAlertViewButtonBlock";

//// Key used to associate block objects with their respective buttons
//static const char * const AHAlertViewButtonBlockKey = "AHAlertViewButtonBlock";
//
//static const NSInteger AHViewAutoresizingFlexibleSizeAndMargins =
//UIViewAutoresizingFlexibleLeftMargin |
//UIViewAutoresizingFlexibleWidth |
//UIViewAutoresizingFlexibleRightMargin |
//UIViewAutoresizingFlexibleTopMargin |
//UIViewAutoresizingFlexibleHeight |
//UIViewAutoresizingFlexibleBottomMargin;

// These hardcoded constants affect the layout of alert views but were not deemed
// important enough to expose via UIAppearance selectors. If you disagree with that
// assessment, you can either tweak them here as your application requires, or you
// can submit an issue or pull request to make layout behavior more flexible.
static CGFloat AHAlertViewDefaultWidth = 320;
static const CGFloat AHAlertViewMinimumHeight = 172;
static const CGFloat AHAlertViewDefaultButtonHeight = 40;
static const CGFloat AHAlertViewDefaultTextFieldHeight = 26;
static const CGFloat AHAlertViewTitleLabelBottomMargin = 8;
static const CGFloat AHAlertViewMessageLabelBottomMargin = 16;
static const CGFloat AHAlertViewTextFieldBottomMargin = 8;
static const CGFloat AHAlertViewTextFieldLeading = -1;
static const CGFloat AHAlertViewButtonBottomMargin = 4;
static const CGFloat AHAlertViewButtonHorizontalSpacing = 4;

CGFloat CGAffineTransformGetAbsoluteRotationAngleDifference(CGAffineTransform t1, CGAffineTransform t2)
{
    CGFloat dot = t1.a * t2.a + t1.c * t2.c;
    CGFloat n1 = sqrtf(t1.a * t1.a + t1.c * t1.c);
    CGFloat n2 = sqrtf(t2.a * t2.a + t2.c * t2.c);
    return acosf(dot / (n1 * n2));
}

typedef void (^AHAnimationCompletionBlock)(BOOL); // Internal.

@implementation CHNAlertView

@synthesize title = _title;
@synthesize message = _message;
@synthesize delegate;

@synthesize otherButtons = _otherButtons;
@synthesize backgroundImage = _backgroundImage;
@synthesize destructiveButton = _destructiveButton;
@synthesize titleLabel;
@synthesize dismissalStyle = _dismissalStyle;
@synthesize backgroundImageView;
@synthesize cancelButtonBackgroundImagesForControlStates;
@synthesize buttonBackgroundImagesForControlStates;
@synthesize contentInsets;
@synthesize destructiveButtonBackgroundImagesForControlStates;
@synthesize presentationStyle = _presentationStyle;
@synthesize plainTextField;
@synthesize titleTextAttributes;
@synthesize messageLabel;
@synthesize alertViewStyle;
@synthesize messageTextAttributes;
@synthesize cancelButton = _cancelButton;
@synthesize visible;
@synthesize buttonTitleTextAttributes;
@synthesize secureTextField;

@synthesize buttonHeight=_buttonHeight;
@synthesize textFieldHeight=_textFieldHeight;
@synthesize titleLabelBottomMargin=_titleLabelBottomMargin;
@synthesize messageLabelBottomMargin=_messageLabelBottomMargin;
@synthesize textFieldBottomMargin=_textFieldBottomMargin;
@synthesize textFieldLeading=_textFieldLeading;
@synthesize buttonBottomMargin=_buttonBottomMargin;
@synthesize buttonHorizontalSpacing=_buttonHorizontalSpacing;

- (void)dealloc
{
    for(id button in _otherButtons)
        objc_setAssociatedObject(button, kAHAlertViewButtonBlockKey, nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    if(_cancelButton)
        objc_setAssociatedObject(_cancelButton, kAHAlertViewButtonBlockKey, nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    if(_destructiveButton)
        objc_setAssociatedObject(_destructiveButton, kAHAlertViewButtonBlockKey, nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
    
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

+ (CHNAlertView *) defaultAlertView
{
    static CHNAlertView * defaultAlertView = nil;
    if (!defaultAlertView)
    {
        defaultAlertView = [[CHNAlertView alloc] init];
        AHAlertViewDefaultWidth = screenWidth;
        
    }
    return defaultAlertView;
}

+ (void)initialize
{
    [self applySystemAlertAppearance];
}

+ (void)applySystemAlertAppearance {
    // Set up default values for all UIAppearance-compatible selectors
    
    [[self appearance] setBackgroundImage:[self alertBackgroundImage]];
    
    [[self appearance] setContentInsets:UIEdgeInsetsMake(16, 8, 8, 8)];
    
    [[self appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIFont boldSystemFontOfSize:17], UITextAttributeFont,
                                               [UIColor whiteColor], UITextAttributeTextColor,
                                               [UIColor blackColor], UITextAttributeTextShadowColor,
                                               [NSValue valueWithCGSize:CGSizeMake(0, -1)], UITextAttributeTextShadowOffset,
                                               nil]];
    
    [[self appearance] setMessageTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                 [UIFont systemFontOfSize:15], UITextAttributeFont,
                                                 [UIColor whiteColor], UITextAttributeTextColor,
                                                 [UIColor blackColor], UITextAttributeTextShadowColor,
                                                 [NSValue valueWithCGSize:CGSizeMake(0, -1)], UITextAttributeTextShadowOffset,
                                                 nil]];
    
    [[self appearance] setButtonTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                     [UIFont boldSystemFontOfSize:17], UITextAttributeFont,
                                                     [UIColor whiteColor], UITextAttributeTextColor,
                                                     [UIColor blackColor], UITextAttributeTextShadowColor,
                                                     [NSValue valueWithCGSize:CGSizeMake(0, -1)], UITextAttributeTextShadowOffset,
                                                     nil]];
    
    [[self appearance] setButtonBackgroundImage:[self normalButtonBackgroundImage] forState:UIControlStateNormal];
    
    [[self appearance] setCancelButtonBackgroundImage:[self cancelButtonBackgroundImage] forState:UIControlStateNormal];
    
    
    [[self appearance] setButtonHeight:AHAlertViewDefaultButtonHeight];
    [[self appearance] setTextFieldHeight:AHAlertViewDefaultTextFieldHeight];
    [[self appearance] setTitleLabelBottomMargin:AHAlertViewTitleLabelBottomMargin];
    [[self appearance] setMessageLabelBottomMargin:AHAlertViewMessageLabelBottomMargin];
    [[self appearance] setTextFieldBottomMargin:AHAlertViewTextFieldBottomMargin];
    [[self appearance] setTextFieldLeading:AHAlertViewTextFieldLeading];
    [[self appearance] setButtonBottomMargin:AHAlertViewButtonBottomMargin];
    [[self appearance] setButtonHorizontalSpacing:AHAlertViewButtonHorizontalSpacing];
}

- (void)clearSubViews
{
    if (self)
    {
        for (UIView * view in self.subviews)
        {
            [view removeFromSuperview];
        }
    }
}

#pragma mark - Instance life cycle methods

- (id)initWithAwardText:(NSString *)text desc1:(NSString *)desc1 desc2:(NSString *)desc2 buttonDesc:(NSString *)desc delegate:(id)_delegate
{
    [self clearSubViews];
    if (self = [super init])
    {
        _presentationStyle = AHAlertViewPresentationStyleDefault;
        _dismissalStyle = AHAlertViewDismissalStyleDefault;
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(deviceOrientationChanged:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
        self.backgroundColor = [UIColor clearColor];
        
        UIView * containerView = [[UIView alloc] initWithFrame:CGRectMake((screenWidth-280)/2, 0, 280, 152)];
        containerView.backgroundColor = [UIColor whiteColor];
        containerView.layer.cornerRadius = 8;
        [self addSubview:containerView];
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@%@",desc1,text,desc2]];
        
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,desc1.length)];
        
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(desc1.length,text.length)];
        
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(desc1.length+text.length,desc2.length)];
        
        [str addAttribute:NSFontAttributeName value:NormalFontWithSize(13) range:NSMakeRange(0,desc1.length)];
        
        [str addAttribute:NSFontAttributeName value:NormalFontWithSize(15) range:NSMakeRange(desc1.length,text.length)];
        
        [str addAttribute:NSFontAttributeName value:NormalFontWithSize(13) range:NSMakeRange(desc1.length+text.length,desc2.length)];
        
        UILabel * titleL = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, 250, 40)];
        titleL.numberOfLines = 2;
        titleL.attributedText = str;
        
        [containerView addSubview:titleL];
        
        UIImageView * shadowImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 96, 280, 1)];
        shadowImage.image = [UIImage imageNamed:@"shadow_first"];
        [containerView addSubview:shadowImage];
        
        UIButton * knownBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(shadowImage.frame), 280, 56)];
        [knownBtn addTarget:self action:@selector(bottomBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [knownBtn setTitle:desc forState:UIControlStateNormal];
        [knownBtn setTitleColor:kRedColor forState:UIControlStateNormal];
        [containerView addSubview:knownBtn];
        
        self.delegate = _delegate;
        
        [self show];
    }
    self.frame = CGRectMake(0, 0, screenWidth, 152);
    return self;
}

- (id)initWithAwardFinished:(NSString *)_messageL delegate:(id)_delegate
{
    [self clearSubViews];
    if (self = [super init])
    {
        _presentationStyle = AHAlertViewPresentationStyleDefault;
        _dismissalStyle = AHAlertViewDismissalStyleDefault;
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(deviceOrientationChanged:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
        self.backgroundColor = [UIColor clearColor];
        
        UIView * containerView = [[UIView alloc] initWithFrame:CGRectMake((screenWidth-270)/2, 0, 270, 350)];
        containerView.backgroundColor = [UIColor whiteColor];
        [self addSubview:containerView];
        
        UILabel * titleL = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 270, 16)];
        titleL.backgroundColor = [UIColor clearColor];
        titleL.textAlignment = NSTextAlignmentCenter;
        titleL.textColor = KFontNewColorA;
        titleL.font = NormalFontWithSize(16);
        titleL.text = _messageL;
        [containerView addSubview:titleL];
        
        UILabel * titleD = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titleL.frame)+5, 270, 16)];
        titleD.backgroundColor = [UIColor clearColor];
        titleD.textAlignment = NSTextAlignmentCenter;
        titleD.textColor = kRedColor;
        titleD.font = NormalFontWithSize(13);
        titleD.text = @"开市时间09:30-11:30 13:00-15:00";
        [containerView addSubview:titleD];
        
        UIImageView * showImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(titleD.frame)+50, 238, 69)];
        showImage.image = [UIImage imageNamed:@"jiaoyi"];
        [containerView addSubview:showImage];
        
        UIButton * sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        sureBtn.tag = 4;
        [sureBtn addTarget:self action:@selector(bottomBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        sureBtn.frame = CGRectMake(25, 350-84, 220, 44);;
        sureBtn.layer.cornerRadius = 5;
        sureBtn.layer.masksToBounds = YES;
        [sureBtn setTitle:@"知道了" forState:UIControlStateNormal];
        [sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sureBtn setBackgroundImage:[kRedColor image] forState:UIControlStateNormal];
        [sureBtn setBackgroundImage:[KColorHeader image] forState:UIControlStateSelected];
        [sureBtn setBackgroundImage:[KColorHeader image] forState:UIControlStateHighlighted];
        sureBtn.clipsToBounds = YES;
        [containerView addSubview:sureBtn];
    }
    
    self.frame = CGRectMake(0, 0, screenWidth, 350);
    self.delegate = _delegate;
    [self show];
    
    return self;
}

- (id)initWithAwardStockName:(NSString *)name amount:(NSString *)amount price:(NSString *)price message:(NSString *)message delegate:(id)_delegate
{
    [self clearSubViews];
    if (self = [super init])
    {
        _presentationStyle = AHAlertViewPresentationStyleDefault;
        _dismissalStyle = AHAlertViewDismissalStyleDefault;
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(deviceOrientationChanged:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
        self.backgroundColor = [UIColor clearColor];
        
        UIView * containerView = [[UIView alloc] initWithFrame:CGRectMake((screenWidth-270)/2, 0, 270, 350)];
        containerView.backgroundColor = [UIColor whiteColor];
        [self addSubview:containerView];
        
        UIImageView * closeImage = [[UIImageView alloc] initWithFrame:CGRectMake(255, 10, 30, 30)];
        closeImage.image = [UIImage imageNamed:@"guanbi"];
        [self addSubview:closeImage];
        
        UIButton * closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(220, 0, 50, 50)];
        closeBtn.tag = 3;
        [closeBtn addTarget:self action:@selector(bottomBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeBtn];
        
        UIView * topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 270, 175)];
        topView.backgroundColor = kRedColor;
        [containerView addSubview:topView];
        
        UIImageView * smileImage = [[UIImageView alloc] initWithFrame:CGRectMake(99, 40, 72, 72)];
        smileImage.image = [UIImage imageNamed:@"xiaolian"];
        [containerView addSubview:smileImage];
        
        UILabel * messageL = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(smileImage.frame)+20, 270, 16)];
        messageL.textAlignment = NSTextAlignmentCenter;
        messageL.backgroundColor = [UIColor clearColor];
        messageL.textColor = [UIColor whiteColor];
        messageL.font = NormalFontWithSize(16);
        messageL.text = message;
        [containerView addSubview:messageL];
        
        amount = [NSString stringWithFormat:@"%@股",amount];
        
        NSString * priceDesc = @"价值";
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@%@%@",amount,name,priceDesc,price]];
        
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,amount.length)];
        [str addAttribute:NSForegroundColorAttributeName value:kRedColor range:NSMakeRange(amount.length,name.length)];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(amount.length+name.length,priceDesc.length)];
        [str addAttribute:NSForegroundColorAttributeName value:kRedColor range:NSMakeRange(amount.length+name.length+priceDesc.length,price.length)];
        
        [str addAttribute:NSFontAttributeName value:NormalFontWithSize(16) range:NSMakeRange(0,amount.length)];
        [str addAttribute:NSFontAttributeName value:NormalFontWithSize(16) range:NSMakeRange(amount.length,name.length)];
        [str addAttribute:NSFontAttributeName value:NormalFontWithSize(16) range:NSMakeRange(amount.length+name.length,priceDesc.length)];
        [str addAttribute:NSFontAttributeName value:NormalFontWithSize(16) range:NSMakeRange(amount.length+name.length+priceDesc.length,price.length)];
        
        UILabel * titleL = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topView.frame)+40, 270, 16)];
        titleL.textAlignment = NSTextAlignmentCenter;
        titleL.numberOfLines = 1;
        titleL.attributedText = str;
        [containerView addSubview:titleL];
        
        UIButton * sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        sureBtn.tag = 2;
        [sureBtn addTarget:self action:@selector(bottomBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        sureBtn.frame = CGRectMake(25, CGRectGetMaxY(titleL.frame)+40, 220, 44);;
        sureBtn.layer.cornerRadius = 5;
        sureBtn.layer.masksToBounds = YES;
        [sureBtn setTitle:@"领取" forState:UIControlStateNormal];
        [sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sureBtn setBackgroundImage:[kRedColor image] forState:UIControlStateNormal];
        [sureBtn setBackgroundImage:[KColorHeader image] forState:UIControlStateSelected];
        [sureBtn setBackgroundImage:[KColorHeader image] forState:UIControlStateHighlighted];
        sureBtn.clipsToBounds = YES;
        [containerView addSubview:sureBtn];
    }
    
    self.frame = CGRectMake(0, 0, screenWidth, 350);
    self.delegate = _delegate;
    [self show];
    
    return self;
}

- (id)initWithNormalType:(NSString *)title content:(NSString *)content cancelTitle:(NSString *)cancelTitle sureTitle:(NSString *)sureTitle withDelegate:(id)_delegate
{
    [self clearSubViews];
    if (self = [super init])
    {
        _presentationStyle = AHAlertViewPresentationStyleDefault;
        _dismissalStyle = AHAlertViewDismissalStyleDefault;
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(deviceOrientationChanged:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
        self.backgroundColor = [UIColor clearColor];
        
        UIView * containerView = [[UIView alloc] initWithFrame:CGRectMake((screenWidth-280)/2, 0, 280, 175)];
        containerView.backgroundColor = [UIColor whiteColor];
        containerView.layer.cornerRadius = 5;
        [self addSubview:containerView];
        
        UILabel * title1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 280, 20)];
        title1.textAlignment = NSTextAlignmentCenter;
        title1.backgroundColor = [UIColor clearColor];
        title1.textColor = [UIColor darkGrayColor];
        title1.font = BoldFontWithSize(15);
        title1.text = title;
        [containerView addSubview:title1];
        
        if (content.length)
        {
            UILabel * desc1LabelDesc = [[UILabel alloc] initWithFrame:CGRectMake(25, CGRectGetMaxY(title1.frame)+17, 280, 50)];
            desc1LabelDesc.numberOfLines = 0;
            desc1LabelDesc.backgroundColor = [UIColor clearColor];
            desc1LabelDesc.textColor = [UIColor lightGrayColor];
            desc1LabelDesc.font = NormalFontWithSize(14);
            desc1LabelDesc.text = content;
            [desc1LabelDesc sizeToFit];
            [containerView addSubview:desc1LabelDesc];
        }
        else
        {
            title1.frame = CGRectMake(20, 20, 230, 100);
            title1.font = BoldFontWithSize(16);
            title1.numberOfLines = 5;
            [containerView reloadInputViews];
        }
        
        [self addCancelBtn:cancelTitle sureBtn:sureTitle onView:containerView withType:1];
        self.delegate = _delegate;
        [self show];
    }
    self.frame = CGRectMake(0, 0, screenWidth, 180);
    return self;
}

- (id)initWithTitle:(NSString *)title withDelegate:(id)_delegate
{
    [self clearSubViews];
    if (self = [super init])
    {
        _presentationStyle = AHAlertViewPresentationStyleDefault;
        _dismissalStyle = AHAlertViewDismissalStyleDefault;
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(deviceOrientationChanged:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
        self.backgroundColor = [UIColor clearColor];
        
        UIView * containerView = [[UIView alloc] initWithFrame:CGRectMake((screenWidth-280)/2, 0, 280, 151)];
        containerView.backgroundColor = [UIColor whiteColor];
        containerView.layer.cornerRadius = 5;
        [self addSubview:containerView];
        
        UILabel * desc1LabelDesc = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, 240, 50)];
        desc1LabelDesc.backgroundColor = [UIColor clearColor];
        desc1LabelDesc.textColor = KFontNewColorA;
        desc1LabelDesc.font = NormalFontWithSize(15);
        [containerView addSubview:desc1LabelDesc];
        
        NSString * str1 = @"可用余额不足，还差";
        NSString * str2 = title;
        NSString * str3 = @"能提现";
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@%@",str1,str2,str3]];
        
        [str addAttribute:NSForegroundColorAttributeName value:KFontNewColorA range:NSMakeRange(0,str1.length)];
        [str addAttribute:NSForegroundColorAttributeName value:kRedColor range:NSMakeRange(str1.length,str2.length)];
        [str addAttribute:NSForegroundColorAttributeName value:KFontNewColorA range:NSMakeRange(str1.length+str2.length,str3.length)];
        
        [str addAttribute:NSFontAttributeName value:NormalFontWithSize(15) range:NSMakeRange(0,str1.length)];
        [str addAttribute:NSFontAttributeName value:NormalFontWithSize(15) range:NSMakeRange(str1.length,str2.length)];
        [str addAttribute:NSFontAttributeName value:NormalFontWithSize(15) range:NSMakeRange(str1.length+str2.length,str3.length)];
        
        desc1LabelDesc.attributedText = str;
        
        [self addCancelBtn:@"取消" sureBtn:@"卖股票" onView:containerView];
        self.delegate = _delegate;
        [self show];
    }
    self.frame = CGRectMake(0, 0, screenWidth, 180);
    return self;
}

- (void)addCancelBtn:(NSString *)cancelTitle sureBtn:(NSString *)sureTitle onView:(UIView *)view
{
    UIView * line1 = [[UIView alloc] initWithFrame:CGRectMake(0, view.frame.size.height-45, 280, .5)];
    line1.backgroundColor = [UIColor lightGrayColor];
    [view addSubview:line1];
    
    UIButton * cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.tag = 0;
    [cancelBtn addTarget:self action:@selector(bottomBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.frame = CGRectMake(0, view.frame.size.height-45, 140, 44);
    [cancelBtn setTitle:cancelTitle forState:UIControlStateNormal];
    [cancelBtn setTitleColor:kFontColorD forState:UIControlStateNormal];
    cancelBtn.clipsToBounds = YES;
    [view addSubview:cancelBtn];
    
    UIView * line2 = [[UIView alloc] initWithFrame:CGRectMake(135, view.frame.size.height-45, .5, 45)];
    line2.backgroundColor = [UIColor lightGrayColor];
    [view addSubview:line2];
    
    UIButton * sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sureBtn.tag = 1;
    [sureBtn addTarget:self action:@selector(bottomBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    sureBtn.frame = CGRectMake(view.frame.size.width/2, view.frame.size.height-45, view.frame.size.width/2, 44);
    [sureBtn setTitle:sureTitle forState:UIControlStateNormal];
    [sureBtn setTitleColor:kRedColor forState:UIControlStateNormal];
    sureBtn.clipsToBounds = YES;
    [view addSubview:sureBtn];
}

- (id)initContent:(NSString *)content cancelTitle:(NSString *)cancelTitle sureTitle:(NSString *)sureTitle withDelegate:(id)_delegate withType:(NSInteger)type
{
    [self clearSubViews];
    if (self = [super init])
    {
        _presentationStyle = AHAlertViewPresentationStyleDefault;
        _dismissalStyle = AHAlertViewDismissalStyleDefault;
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(deviceOrientationChanged:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
        self.backgroundColor = [UIColor clearColor];
        
        UIView * containerView = [[UIView alloc] initWithFrame:CGRectMake((screenWidth-280)/2, 0, 280, 151)];
        containerView.backgroundColor = [UIColor whiteColor];
        containerView.layer.cornerRadius = 5;
        [self addSubview:containerView];
        
        UILabel * desc1LabelDesc = [[UILabel alloc] init];
        desc1LabelDesc.backgroundColor = [UIColor clearColor];
        desc1LabelDesc.textColor = KFontNewColorA;
        desc1LabelDesc.font = NormalFontWithSize(15);
        desc1LabelDesc.numberOfLines = 0;
        [containerView addSubview:desc1LabelDesc];
        
        UILabel * numberLabel = [[UILabel alloc] init];
        numberLabel.backgroundColor = [UIColor clearColor];
        numberLabel.textColor = KFontNewColorD;
        numberLabel.textAlignment = NSTextAlignmentLeft;
        numberLabel.font = NormalFontWithSize(15);
        [containerView addSubview:numberLabel];
        
        if (type == 1)
        {
            //拨电话
            desc1LabelDesc.text = @"呼叫";
            desc1LabelDesc.frame = CGRectMake(0, 0, 100, 95);
            desc1LabelDesc.textAlignment =  NSTextAlignmentRight;
            
            numberLabel.frame = CGRectMake(105, 0, 140, 95);
            numberLabel.text = content;
        }
        else if (type == 2)
        {
            
            NSString * str1 = [[content componentsSeparatedByString:@","] objectAtIndex:0];
            NSString * str2 = [[content componentsSeparatedByString:@","] objectAtIndex:1];
            
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",str1,str2]];
            
            [str addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,str1.length)];
            [str addAttribute:NSForegroundColorAttributeName value:kRedColor range:NSMakeRange(str1.length,str2.length)];
            
            [str addAttribute:NSFontAttributeName value:NormalFontWithSize(15) range:NSMakeRange(0,str1.length)];
            [str addAttribute:NSFontAttributeName value:NormalFontWithSize(15) range:NSMakeRange(str1.length,str2.length)];
            //换手机号 联系客服
            desc1LabelDesc.frame = CGRectMake(30, 30, 230, 35);
            desc1LabelDesc.attributedText = str;
            desc1LabelDesc.textAlignment =  NSTextAlignmentLeft;
        }
        else if (type == 3)
        {
            //手机号码无效
            desc1LabelDesc.frame = CGRectMake(20, 40, 240, 20);
            desc1LabelDesc.text = content;
            desc1LabelDesc.textAlignment = NSTextAlignmentCenter;
            
            numberLabel.frame = CGRectZero;
            numberLabel.text = @"";
        }
        else if (type == 4)
        {
            //未完成注册
            desc1LabelDesc.frame = CGRectMake(20, 40, 240, 20);
            desc1LabelDesc.text =  content;
            desc1LabelDesc.textAlignment = NSTextAlignmentCenter;
            
            numberLabel.frame = CGRectZero;
            numberLabel.text = @"";
        }
        else if (type == 5)
        {
            //使用复活功能
            desc1LabelDesc.frame = CGRectMake(20, 30, 240, 40);
            desc1LabelDesc.numberOfLines = 2;
            desc1LabelDesc.text =  content;
            desc1LabelDesc.textAlignment = NSTextAlignmentCenter;
            
            numberLabel.frame = CGRectZero;
            numberLabel.text = @"";
        }
        else if(type == 6)
        {
            //错误弹窗
            desc1LabelDesc.frame = CGRectMake(20, 30, 240, 50);
            desc1LabelDesc.text = content;
            desc1LabelDesc.numberOfLines = 0;
            desc1LabelDesc.textAlignment = NSTextAlignmentCenter;
            
            numberLabel.frame = CGRectZero;
            numberLabel.text = @"";
        }
        else if (type == 7)
        {
            forceUpdate = YES;
            desc1LabelDesc.frame = CGRectMake(20, 30, 240, 50);
            desc1LabelDesc.text = content;
            desc1LabelDesc.numberOfLines = 0;
            desc1LabelDesc.textAlignment = NSTextAlignmentCenter;
            
            numberLabel.frame = CGRectZero;
            numberLabel.text = @"";
        }
        
        
        if (type == 1 || type == 2)
        {
            [self addCancelBtn:@"取消" sureBtn:@"呼叫" onView:containerView withType:1];
        }
        else if (type == 3)
        {
            [self addCancelBtn:nil sureBtn:@"确定" onView:containerView withType:2];
        }
        else if (type == 4)
        {
            [self addCancelBtn:cancelTitle sureBtn:sureTitle onView:containerView withType:1];
        }
        else if (type == 5)
        {
            [self addCancelBtn:cancelTitle sureBtn:sureTitle onView:containerView withType:1];
        }
        else if (type == 6 || type == 7)
        {
            [self addCancelBtn:nil sureBtn:@"确定" onView:containerView withType:3];
        }
        self.delegate = _delegate;
    }
    self.frame = CGRectMake(0, 0, screenWidth, 172);
    return self;
}


- (void)addCancelBtn:(NSString *)cancelTitle sureBtn:(NSString *)sureTitle onView:(UIView *)view withType:(NSInteger)type
{
    UIView * line1 = [[UIView alloc] initWithFrame:CGRectMake(0, view.frame.size.height-56, 280, .5)];
    line1.backgroundColor = KColorHeader;
    [view addSubview:line1];
    
    UIButton * cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.tag = 0;
    [cancelBtn addTarget:self action:@selector(bottomBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.frame = CGRectMake(0, view.frame.size.height-55, 135, 54);
    cancelBtn.layer.masksToBounds = YES;
    cancelBtn.layer.cornerRadius = 5;
    [cancelBtn setTitle:cancelTitle forState:UIControlStateNormal];
    [cancelBtn setTitleColor:KFontNewColorA forState:UIControlStateNormal];
    [cancelBtn setBackgroundImage:[kFontColorA image] forState:UIControlStateNormal];
    [cancelBtn setBackgroundImage:[KColorHeader image] forState:UIControlStateSelected];
    [cancelBtn setBackgroundImage:[KColorHeader image] forState:UIControlStateHighlighted];
    cancelBtn.clipsToBounds = YES;
    [view addSubview:cancelBtn];
    
    UIView * line2 = [[UIView alloc] initWithFrame:CGRectMake(135, view.frame.size.height-56, .5, 56)];
    line2.backgroundColor = KColorHeader;
    [view addSubview:line2];
    
    UIButton * sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sureBtn.tag = 1;
    [sureBtn addTarget:self action:@selector(bottomBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    sureBtn.frame = CGRectMake(view.frame.size.width/2-4.5, view.frame.size.height-55, view.frame.size.width/2+4.5, 54);
    sureBtn.layer.cornerRadius = 5;
    sureBtn.layer.masksToBounds = YES;
    [sureBtn setTitle:sureTitle forState:UIControlStateNormal];
    [sureBtn setTitleColor:KFontNewColorD forState:UIControlStateNormal];
    [sureBtn setBackgroundImage:[kFontColorA image] forState:UIControlStateNormal];
    [sureBtn setBackgroundImage:[KColorHeader image] forState:UIControlStateSelected];
    [sureBtn setBackgroundImage:[KColorHeader image] forState:UIControlStateHighlighted];
    sureBtn.clipsToBounds = YES;
    [view addSubview:sureBtn];
    
    
    UILabel * lineLb3 = [[UILabel alloc] initWithFrame:CGRectMake(3, view.frame.size.height-1, 274, 0.5)];
    lineLb3.backgroundColor = KLineNewBGColor1;
    [view addSubview:lineLb3];
    
    UILabel * lineLb4 = [[UILabel alloc] initWithFrame:CGRectMake(3, view.frame.size.height-0.5, 274, 0.5)];
    lineLb4.backgroundColor = KLineNewBGColor2;
    [view addSubview:lineLb4];
    
    if (type == 1)
    {
        //左右两侧都有按钮
        cancelBtn.hidden = NO;
        line2.hidden =NO;
        sureBtn.frame = CGRectMake(view.frame.size.width/2-4.5, view.frame.size.height-55, view.frame.size.width/2+4.5, 54);
        [sureBtn setTitleColor:KFontNewColorD forState:UIControlStateNormal];
    }
    else if (type == 2)
    {
        //只有一个按钮 提示字体为红色
        sureBtn.hidden =YES;
        line2.hidden = YES;
        cancelBtn.frame = CGRectMake(0, view.frame.size.height-55, view.frame.size.width, 54);
        [cancelBtn setTitleColor:KFontNewColorD forState:UIControlStateNormal];
        [cancelBtn setTitle:@"确定" forState:UIControlStateNormal];
    }
    else if (type == 3)
    {
        //只有一个按钮  提示字体为黑色
        sureBtn.hidden =YES;
        line2.hidden = YES;
        cancelBtn.frame = CGRectMake(0, view.frame.size.height-55, view.frame.size.width, 54);
        [cancelBtn setTitleColor:KFontNewColorA forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = NormalFontWithSize(17);
        [cancelBtn setTitle:@"确定" forState:UIControlStateNormal];
    }
}

- (void)bottomBtnClicked:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(buttonClickedAtIndex:)])
    {
        UIButton * btn = (UIButton *)sender;
        [self.delegate buttonClickedAtIndex:btn.tag];
        [self dismiss];
    }
}



- (UIButton *)buttonWithTitle:(NSString *)aTitle associatedBlock:(AHAlertViewButtonBlock)block {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
    
    [button setTitle:aTitle forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
    objc_setAssociatedObject(button, kAHAlertViewButtonBlockKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    return button;
}

- (void)addButtonWithTitle:(NSString *)aTitle block:(AHAlertViewButtonBlock)block {
    if(!self.otherButtons)
        self.otherButtons = [NSMutableArray array];
    
    UIButton *otherButton = [self buttonWithTitle:aTitle associatedBlock:block];
    [self.otherButtons addObject:otherButton];
    [self addSubview:otherButton];
}

- (void)setDestructiveButtonTitle:(NSString *)aTitle block:(AHAlertViewButtonBlock)block {
    self.destructiveButton = [self buttonWithTitle:aTitle associatedBlock:block];
    [self addSubview:self.destructiveButton];
}

- (void)setCancelButtonTitle:(NSString *)aTitle block:(AHAlertViewButtonBlock)block {
    self.cancelButton = [self buttonWithTitle:aTitle associatedBlock:block];
    [self addSubview:self.cancelButton];
}

#pragma mark - Text field accessor

- (UITextField *)textFieldAtIndex:(NSInteger)textFieldIndex
{
    return nil;
}

#pragma mark - Appearance selectors

- (void)setButtonBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state
{
    if(!self.buttonBackgroundImagesForControlStates)
        self.buttonBackgroundImagesForControlStates = [NSMutableDictionary dictionary];
    
    [self.buttonBackgroundImagesForControlStates setObject:backgroundImage
                                                    forKey:[NSNumber numberWithInteger:state]];
}

- (UIImage *)buttonBackgroundImageForState:(UIControlState)state
{
    return [self.buttonBackgroundImagesForControlStates objectForKey:[NSNumber numberWithInteger:state]];
}

- (void)setCancelButtonBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state
{
    if(!self.cancelButtonBackgroundImagesForControlStates)
        self.cancelButtonBackgroundImagesForControlStates = [NSMutableDictionary dictionary];
    
    [self.cancelButtonBackgroundImagesForControlStates setObject:backgroundImage
                                                          forKey:[NSNumber numberWithInteger:state]];
}

- (UIImage *)cancelButtonBackgroundImageForState:(UIControlState)state
{
    return [self.cancelButtonBackgroundImagesForControlStates objectForKey:[NSNumber numberWithInteger:state]];
}

- (void)setDestructiveButtonBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state
{
    if(!self.destructiveButtonBackgroundImagesForControlStates)
        self.destructiveButtonBackgroundImagesForControlStates = [NSMutableDictionary dictionary];
    
    [self.destructiveButtonBackgroundImagesForControlStates setObject:backgroundImage
                                                               forKey:[NSNumber numberWithInteger:state]];
}

- (UIImage *)destructiveButtonBackgroundImageForState:(UIControlState)state
{
    return [self.destructiveButtonBackgroundImagesForControlStates objectForKey:[NSNumber numberWithInteger:state]];
}

#pragma mark - Presentation and dismissal methods

- (void)show
{
    if (!isAlert)
    {
        isAlert = YES;
        [self showWithStyle:self.presentationStyle];
    }
}

- (void)showWithStyle:(AHAlertViewPresentationStyle)style
{
    self.presentationStyle = style;
    
    [self setNeedsLayout];
    
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    
    UIImageView *dimView = [[UIImageView alloc] initWithFrame:keyWindow.bounds];
    
    UIButton * dismissBtn = [[UIButton alloc] initWithFrame:dimView.frame];
    [dismissBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [dimView addSubview:dismissBtn];
    
    dimView.image = [self backgroundGradientImageWithSize:keyWindow.bounds.size];
    dimView.userInteractionEnabled = YES;
    
    [keyWindow addSubview:dimView];
    [dimView addSubview:self];
    
    [self performPresentationAnimation];
}

- (void)showContent:(NSString *)content cancelTitle:(NSString *)cancelTitle sureTitle:(NSString *)sureTitle withDelegate:(id)_delegate withType:(NSInteger)type
{
    CHNAlertView *alertView = [[CHNAlertView defaultAlertView] initContent:content cancelTitle:cancelTitle sureTitle:sureTitle withDelegate:_delegate withType:type];
    [alertView show];
}

- (void)dismiss
{
    if (forceUpdate)
    {
        return;
    }
    isAlert = NO;
    [self dismissWithStyle:self.dismissalStyle];
}

- (void)dismissWithStyle:(AHAlertViewDismissalStyle)style {
    self.dismissalStyle = style;
    [self performDismissalAnimation];
}

- (void)buttonWasPressed:(UIButton *)sender {
    AHAlertViewButtonBlock block = objc_getAssociatedObject(sender, kAHAlertViewButtonBlockKey);
    if(block) block();
    
    [self dismissWithStyle:self.dismissalStyle];
}

#pragma mark - Presentation and dismissal animation utilities

- (void)performPresentationAnimation
{
    if(self.presentationStyle == AHAlertViewPresentationStylePop)
    {
        CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animation];
        bounceAnimation.duration = 0.3;
        bounceAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        bounceAnimation.values = [NSArray arrayWithObjects:
                                  [NSNumber numberWithFloat:0.01],
                                  [NSNumber numberWithFloat:1.1],
                                  [NSNumber numberWithFloat:0.9],
                                  [NSNumber numberWithFloat:1.0],
                                  nil];
        
        [self.layer addAnimation:bounceAnimation forKey:@"transform.scale"];
        
        CABasicAnimation *fadeInAnimation = [CABasicAnimation animation];
        fadeInAnimation.duration = 0.3;
        fadeInAnimation.fromValue = [NSNumber numberWithFloat:0];
        fadeInAnimation.toValue = [NSNumber numberWithFloat:1];
        [self.superview.layer addAnimation:fadeInAnimation forKey:@"opacity"];
    }
    else if(self.presentationStyle == AHAlertViewPresentationStyleFade)
    {
        self.superview.alpha = 0;
        
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^
         {
             self.superview.alpha = 1;
         }
                         completion:nil];
    }
    else
    {
        // Views appear immediately when added
    }
}

- (void)performDismissalAnimation {
    AHAnimationCompletionBlock completionBlock = ^(BOOL finished)
    {
        [self.superview removeFromSuperview];
        [self removeFromSuperview];
    };
    
    if(self.dismissalStyle == AHAlertViewDismissalStyleTumble)
    {
        [UIView animateWithDuration:0.7
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^
         {
             CGPoint offset = CGPointMake(0, self.superview.bounds.size.height * 1.5);
             offset = CGPointApplyAffineTransform(offset, self.transform);
             self.transform = CGAffineTransformConcat(self.transform, CGAffineTransformMakeRotation(-M_PI_4));
             self.center = CGPointMake(self.center.x + offset.x, self.center.y + offset.y);
             self.superview.alpha = 0;
         }
                         completion:completionBlock];
    }
    else if(self.dismissalStyle == AHAlertViewDismissalStyleFade)
    {
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^
         {
             self.superview.alpha = 0;
         }
                         completion:completionBlock];
    }
    else if(self.dismissalStyle == AHAlertViewDismissalStyleZoomDown)
    {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^
         {
             self.transform = CGAffineTransformConcat(self.transform, CGAffineTransformMakeScale(0.01, 0.01));
             self.superview.alpha = 0;
         }
                         completion:completionBlock];
    }
    else if(self.dismissalStyle == AHAlertViewDismissalStyleZoomOut)
    {
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^
         {
             self.transform = CGAffineTransformConcat(self.transform, CGAffineTransformMakeScale(10, 10));
             self.superview.alpha = 0;
         }
                         completion:completionBlock];
    }
    else
    {
        completionBlock(YES);
    }
}

#pragma mark - Layout calculation methods

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGAffineTransform baseTransform = [self transformForCurrentOrientation];
    
    CGFloat delta = CGAffineTransformGetAbsoluteRotationAngleDifference(self.transform, baseTransform);
    BOOL isDoubleRotation = (delta > M_PI);
    
    if(hasLayedOut)
    {
        CGFloat duration = [[UIApplication sharedApplication] statusBarOrientationAnimationDuration];
        if(isDoubleRotation)
            duration *= 2;
        
        [UIView animateWithDuration:duration animations:^{
            self.transform = baseTransform;
        }];
    }
    else
        self.transform = baseTransform;
    
    hasLayedOut = YES;
    
    CGRect boundingRect = self.bounds;
    boundingRect.size.height = FLT_MAX;
    boundingRect = UIEdgeInsetsInsetRect(boundingRect, self.contentInsets);
    
    CGRect newBounds = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    float y = 0;
    if (iPhone4s)
    {
        y = self.superview.bounds.size.height * 0.35;
    }
    else
    {
        y = self.superview.bounds.size.height * 0.5;
    }
    CGPoint newCenter = CGPointMake(self.superview.bounds.size.width * 0.5, y);
    self.bounds = newBounds;
    self.center = newCenter;
}

- (UILabel *)addLabelAsSubview
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    [self addSubview:label];
    
    return label;
}

- (void)applyTextAttributes:(NSDictionary *)attributes toLabel:(UILabel *)label {
    label.font = [attributes objectForKey:UITextAttributeFont];
    label.textColor = [attributes objectForKey:UITextAttributeTextColor];
    label.shadowColor = [attributes objectForKey:UITextAttributeTextShadowColor];
    label.shadowOffset = [[attributes objectForKey:UITextAttributeTextShadowOffset] CGSizeValue];
}

- (void)applyTextAttributes:(NSDictionary *)attributes toButton:(UIButton *)button {
    button.titleLabel.font = [attributes objectForKey:UITextAttributeFont];
    [button setTitleColor:[attributes objectForKey:UITextAttributeTextColor] forState:UIControlStateNormal];
    [button setTitleShadowColor:[attributes objectForKey:UITextAttributeTextShadowColor] forState:UIControlStateNormal];
    button.titleLabel.shadowOffset = [[attributes objectForKey:UITextAttributeTextShadowOffset] CGSizeValue];
}

- (void)v:(NSDictionary *)imagesForStates toButton:(UIButton *)button {
    [imagesForStates enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [button setBackgroundImage:obj forState:[key integerValue]];
    }];
}

#pragma mark - Orientation helpers

- (CGAffineTransform)transformForCurrentOrientation
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(orientation == UIInterfaceOrientationPortraitUpsideDown)
        transform = CGAffineTransformMakeRotation(M_PI);
    else if(orientation == UIInterfaceOrientationLandscapeLeft)
        transform = CGAffineTransformMakeRotation(-M_PI_2);
    else if(orientation == UIInterfaceOrientationLandscapeRight)
        transform = CGAffineTransformMakeRotation(M_PI_2);
    
    return transform;
}

- (void)deviceOrientationChanged:(NSNotification *)notification
{
    [self setNeedsLayout];
}

#pragma mark - Drawing utilities for implementing system control styles

- (UIImage *)backgroundGradientImageWithSize:(CGSize)size
{
    CGPoint center = CGPointMake(size.width * 0.5, size.height * 0.5);
    CGFloat innerRadius = 0;
    CGFloat outerRadius = sqrtf(size.width * size.width + size.height * size.height) * 0.5;
    
    BOOL opaque = NO;
    UIGraphicsBeginImageContextWithOptions(size, opaque, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[2 * 4] = {
        0.0, 0.0, 0.0, 0.1, // More transparent black
        0.0, 0.0, 0.0, 0.7  // More opaque black
    };
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace, components, locations, 2);
    
    CGContextDrawRadialGradient(context, gradient, center, innerRadius, center, outerRadius, 0);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGColorSpaceRelease(colorspace);
    CGGradientRelease(gradient);
    
    return image;
}

#pragma mark - Class drawing utilities for implementing system control styles

+ (UIImage *)alertBackgroundImage
{
    CGRect rect = CGRectMake(0, 0, AHAlertViewDefaultWidth, AHAlertViewMinimumHeight);
    const CGFloat lineWidth = 2;
    const CGFloat cornerRadius = 8;
    
    CGFloat shineWidth = rect.size.width * 1.33;
    CGFloat shineHeight = rect.size.width * 0.2;
    CGFloat shineOriginX = rect.size.width * 0.5 - shineWidth * 0.5;
    CGFloat shineOriginY = -shineHeight * 0.45;
    CGRect shineRect = CGRectMake(shineOriginX, shineOriginY, shineWidth, shineHeight);
    
    UIColor *fillColor = [UIColor colorWithRed:1/255.0 green:21/255.0 blue:54/255.0 alpha:0.9];
    UIColor *strokeColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    
    BOOL opaque = NO;
    UIGraphicsBeginImageContextWithOptions(rect.size, opaque, [[UIScreen mainScreen] scale]);
    
    CGRect fillRect = CGRectInset(rect, lineWidth, lineWidth);
    UIBezierPath *fillPath = [UIBezierPath bezierPathWithRoundedRect:fillRect cornerRadius:cornerRadius];
    [fillColor setFill];
    [fillPath fill];
    
    CGRect strokeRect = CGRectInset(rect, lineWidth * 0.5, lineWidth * 0.5);
    UIBezierPath *strokePath = [UIBezierPath bezierPathWithRoundedRect:strokeRect cornerRadius:cornerRadius];
    strokePath.lineWidth = lineWidth;
    [strokeColor setStroke];
    [strokePath stroke];
    
    UIBezierPath *shinePath = [UIBezierPath bezierPathWithOvalInRect:shineRect];
    [fillPath addClip];
    [shinePath addClip];
    
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[2 * 4] = {
        1, 1, 1, 0.75,  // Translucent white
        1, 1, 1, 0.05   // More translucent white
    };
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, 2);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGPoint startPoint = CGPointMake(CGRectGetMidX(shineRect), CGRectGetMinY(shineRect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(shineRect), CGRectGetMaxY(shineRect));
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGFloat capHeight = CGRectGetMaxY(shineRect);
    CGFloat capWidth = rect.size.width * 0.5;
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(capHeight, capWidth, rect.size.height - capHeight, capWidth)];
}

+ (UIImage *)normalButtonBackgroundImage
{
    const size_t locationCount = 4;
    CGFloat opacity = 1.0;
    CGFloat locations[4] = { 0.0, 0.5, 0.5 + 0.0001, 1.0 };
    CGFloat components[4 * 4] = {
        179/255.0, 185/255.0, 199/255.0, opacity,
        121/255.0, 132/255.0, 156/255.0, opacity,
        87/255.0, 100/255.0, 130/255.0, opacity,
        108/255.0, 120/255.0, 146/255.0, opacity,
    };
    return [self glassButtonBackgroundImageWithGradientLocations:locations
                                                      components:components
                                                   locationCount:locationCount];
}

+ (UIImage *)cancelButtonBackgroundImage
{
    const size_t locationCount = 4;
    CGFloat opacity = 1.0;
    CGFloat locations[4] = { 0.0, 0.5, 0.5 + 0.0001, 1.0 };
    CGFloat components[4 * 4] = {
        164/255.0, 169/255.0, 184/255.0, opacity,
        77/255.0, 87/255.0, 115/255.0, opacity,
        51/255.0, 63/255.0, 95/255.0, opacity,
        78/255.0, 88/255.0, 116/255.0, opacity,
    };
    return [self glassButtonBackgroundImageWithGradientLocations:locations
                                                      components:components
                                                   locationCount:locationCount];
}

+ (UIImage *)glassButtonBackgroundImageWithGradientLocations:(CGFloat *)locations
                                                  components:(CGFloat *)components
                                               locationCount:(NSInteger)locationCount
{
    const CGFloat lineWidth = 1;
    const CGFloat cornerRadius = 4;
    UIColor *strokeColor = [UIColor colorWithRed:1/255.0 green:11/255.0 blue:39/255.0 alpha:1.0];
    
    CGRect rect = CGRectMake(0, 0, cornerRadius * 2 + 1, AHAlertViewDefaultButtonHeight);
    
    BOOL opaque = NO;
    UIGraphicsBeginImageContextWithOptions(rect.size, opaque, [[UIScreen mainScreen] scale]);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, locationCount);
    
    CGRect strokeRect = CGRectInset(rect, lineWidth * 0.5, lineWidth * 0.5);
    UIBezierPath *strokePath = [UIBezierPath bezierPathWithRoundedRect:strokeRect cornerRadius:cornerRadius];
    strokePath.lineWidth = lineWidth;
    [strokeColor setStroke];
    [strokePath stroke];
    
    CGRect fillRect = CGRectInset(rect, lineWidth, lineWidth);
    UIBezierPath *fillPath = [UIBezierPath bezierPathWithRoundedRect:fillRect cornerRadius:cornerRadius];
    [fillPath addClip];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGFloat capHeight = floorf(rect.size.height * 0.5);
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(capHeight, cornerRadius, capHeight, cornerRadius)];
}

- (void)setButtonHorizontalSpacing:(CGFloat)buttonHorizontalSpacing {
    _buttonHorizontalSpacing = buttonHorizontalSpacing;
    [self setNeedsLayout];
}

- (void)setButtonBottomMargin:(CGFloat)buttonBottomMargin {
    _buttonBottomMargin = buttonBottomMargin;
    [self setNeedsLayout];
}

- (void)setTextFieldLeading:(CGFloat)textFieldLeading {
    _textFieldLeading = textFieldLeading;
    [self setNeedsLayout];
}

- (void)setTextFieldBottomMargin:(CGFloat)textFieldBottomMargin {
    _textFieldBottomMargin = textFieldBottomMargin;
    [self setNeedsLayout];
}

- (void)setMessageLabelBottomMargin:(CGFloat)messageLabelBottomMargin {
    _messageLabelBottomMargin = messageLabelBottomMargin;
    [self setNeedsLayout];
}

- (void)setTitleLabelBottomMargin:(CGFloat)titleLabelBottomMargin {
    _titleLabelBottomMargin = titleLabelBottomMargin;
    [self setNeedsLayout];
}

- (void)setTextFieldHeight:(CGFloat)textFieldHeight {
    _textFieldHeight = textFieldHeight;
    [self setNeedsLayout];
}

- (void)setButtonHeight:(CGFloat)buttonHeight {
    _buttonHeight = buttonHeight;
    [self setNeedsLayout];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImage = backgroundImage;
    [self setNeedsLayout];
}


@end
