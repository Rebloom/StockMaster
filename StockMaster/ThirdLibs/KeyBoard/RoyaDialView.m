//
//  RoyaDialView.m
//  Test
//
//  Created by royasoft on 12-12-5.
//  Copyright (c) 2012年 royasoft. All rights reserved.
//

#import "RoyaDialView.h"
#import "RoyaDialViewDelegate.h"
#import "NSString+UIColor.h"
#import "CHNMacro.h"

#define COLOUR_NUM           @"#494949".color
#define COLOUR_FUNC           @"#393939".color

#define KeyboardWithFuncSize [UIFont fontWithName:@"HelveticaNeue-Light" size:20]
#define KeyboardWithNumSize [UIFont fontWithName:@"HelveticaNeue-Light" size:25]

#define CONFIGURE_BUTTON(BTN,X,Y,WIDTH,HIGHT,TITLE,KEYBOARD_IMAGE,COLOR,TAG,SIZE) {\
                                    self.BTN = [UIButton buttonWithType:UIButtonTypeCustom];\
                                    [self.BTN setFrame:CGRectMake(X, Y, WIDTH, HIGHT)];\
                                    [self.BTN setShowsTouchWhenHighlighted:YES];\
                                    [self.BTN setTitle:TITLE forState:UIControlStateNormal];\
                                     [self.BTN setImage:[UIImage imageNamed:KEYBOARD_IMAGE] forState:UIControlStateNormal]     ;\
                                    [self.BTN setTintColor:[UIColor whiteColor]];\
                                    self.BTN.backgroundColor = COLOR ;\
                                    [self.BTN setTag:TAG];\
                                    [self.BTN addTarget:self action:@selector(onKeyPressed:) \
                                                forControlEvents:UIControlEventTouchUpInside];\
                                    [self addSubview:self.BTN];\
                                    self.BTN.titleLabel.font=SIZE;\
                                   }
#define PULL_DOWN_OFFSET 5.0

#define KEYBOARD_GAP    64  //第一行两个按钮之间的宽度
#define KEYBOARD_WHITH  106  //按钮宽度
#define KEYBOARD_HIGHT  53  //按钮高度


//private
@interface RoyaDialView(private)

-(void)setLayOn:(BOOL) isLayOn;

-(void)handleCall:(NSString *) phoneNum;

@end

@implementation RoyaDialView(private)

-(void)setLayOn:(BOOL)isLayOn
{
    CGFloat adjustOffset = (self.frame.size.height - self.txtNumber.frame.size.height)/0.7 + PULL_DOWN_OFFSET;
    if (isLayOn == YES) {
        adjustOffset *= -1;
    }
    CGPoint center = self.center;
    center.y += adjustOffset;
    self.center = center;
}


-(void)handleCall:(NSString *) phoneNum
{

}

@end

//public
@implementation RoyaDialView
@synthesize btnUndo,btnOffOn,btnABC,btn601,btn600,btn300,btn002,btn000,btn9,btn8,btn7,btn6,btn5,btn4,btn3,btn2,btn1,btn0,txtNumber;
@synthesize keyBoardType;

-(void)createKeyboard
{
    //configure the number key
    CONFIGURE_BUTTON(btn600,0, 0, KEYBOARD_GAP,KEYBOARD_HIGHT,@"600",nil,COLOUR_NUM,TAG_KEY_600,KeyboardWithFuncSize);
    
    CONFIGURE_BUTTON(btn601,KEYBOARD_GAP, 0, KEYBOARD_GAP,KEYBOARD_HIGHT,@"601",nil,COLOUR_NUM,TAG_KEY_601,KeyboardWithFuncSize);

    CONFIGURE_BUTTON(btn000,2*KEYBOARD_GAP,0,KEYBOARD_GAP,KEYBOARD_HIGHT,@"000",nil,COLOUR_NUM,TAG_KEY_000,KeyboardWithFuncSize);

    CONFIGURE_BUTTON(btn002,3*KEYBOARD_GAP, 0, KEYBOARD_GAP,KEYBOARD_HIGHT,@"002",nil,COLOUR_NUM,TAG_KEY_002,KeyboardWithFuncSize);

    CONFIGURE_BUTTON(btn300,4*KEYBOARD_GAP,0,KEYBOARD_GAP,KEYBOARD_HIGHT, @"300",nil,COLOUR_NUM,TAG_KEY_300,KeyboardWithFuncSize);

    CONFIGURE_BUTTON(btn1,0, KEYBOARD_HIGHT  ,KEYBOARD_WHITH,KEYBOARD_HIGHT, @"1",nil,COLOUR_NUM,1,KeyboardWithNumSize);
    
    CONFIGURE_BUTTON(btn2, KEYBOARD_WHITH, KEYBOARD_HIGHT ,KEYBOARD_WHITH,KEYBOARD_HIGHT,@"2",nil,COLOUR_NUM,2,KeyboardWithNumSize);
    
    CONFIGURE_BUTTON(btn3,2*KEYBOARD_WHITH, KEYBOARD_HIGHT ,KEYBOARD_WHITH,KEYBOARD_HIGHT,@"3",nil,COLOUR_NUM,3,KeyboardWithNumSize);
    
    CONFIGURE_BUTTON(btn4, 0, 2*KEYBOARD_HIGHT, KEYBOARD_WHITH,KEYBOARD_HIGHT,@"4",nil,COLOUR_NUM,4,KeyboardWithNumSize);
    
    CONFIGURE_BUTTON(btn5,KEYBOARD_WHITH, 2*KEYBOARD_HIGHT, KEYBOARD_WHITH,KEYBOARD_HIGHT,@"5",nil,COLOUR_NUM,5,KeyboardWithNumSize);
    
    CONFIGURE_BUTTON(btn6, 2*KEYBOARD_WHITH, 2*KEYBOARD_HIGHT, KEYBOARD_WHITH,KEYBOARD_HIGHT,@"6",nil,COLOUR_NUM,6,KeyboardWithNumSize);
    
    CONFIGURE_BUTTON(btn7,0,3*KEYBOARD_HIGHT,KEYBOARD_WHITH,KEYBOARD_HIGHT, @"7",nil,COLOUR_NUM,7,KeyboardWithNumSize);
    
    CONFIGURE_BUTTON(btn8,KEYBOARD_WHITH,3*KEYBOARD_HIGHT,KEYBOARD_WHITH,KEYBOARD_HIGHT, @"8",nil,COLOUR_NUM,8,KeyboardWithNumSize);
    
    CONFIGURE_BUTTON(btn9, 2*KEYBOARD_WHITH,3*KEYBOARD_HIGHT,KEYBOARD_WHITH,KEYBOARD_HIGHT, @"9",nil,COLOUR_NUM,9,KeyboardWithNumSize);
    
    if (self.keyBoardType == 1)
    {
        CONFIGURE_BUTTON(btnABC,0,4*KEYBOARD_HIGHT,KEYBOARD_WHITH,KEYBOARD_HIGHT, @"清空",nil,@"#393939".color,TAG_KEY_ABC,NormalFontWithSize(15));
    }
    else
    {
        CONFIGURE_BUTTON(btnABC,0,4*KEYBOARD_HIGHT,KEYBOARD_WHITH,KEYBOARD_HIGHT, @"abc",nil,COLOUR_FUNC,TAG_KEY_ABC,KeyboardWithNumSize);
    }
    
    CONFIGURE_BUTTON(btn0,KEYBOARD_WHITH,4*KEYBOARD_HIGHT,KEYBOARD_WHITH,KEYBOARD_HIGHT,@"0",nil,COLOUR_NUM,TAG_KEY_0,KeyboardWithNumSize);
    
    CONFIGURE_BUTTON(btnUndo, 2*KEYBOARD_WHITH, 4*KEYBOARD_HIGHT  ,KEYBOARD_WHITH,KEYBOARD_HIGHT,nil,@"icon_jianpan_delete",COLOUR_FUNC,TAG_KEY_UNDO,KeyboardWithNumSize);
    

    for (int i = 0; i<4; i++)
    {
        UILabel * hengLineLabel = [[UILabel alloc]  init];
        hengLineLabel.frame = CGRectMake(0, 53*(i+1), screenWidth, 0.5);
        hengLineLabel.backgroundColor = @"#585859".color;
        [self addSubview:hengLineLabel];
    }
    for (int j = 0; j<3; j++)
    {
        UILabel * shuLineLabel = [[UILabel alloc]  init];
        shuLineLabel.frame = CGRectMake(106*j, 53,0.5, 212);
        shuLineLabel.backgroundColor = @"#585859".color;
        [self addSubview:shuLineLabel];
    }
}

-(id)init
{
    CGRect frame =CGRectMake(0, 0, screenWidth,265);
    self = [super initWithFrame:frame];
    if (self)
    {
        [self createKeyboard];
        self.backgroundColor = COLOUR_NUM;
    }
    return self;
}

- (id)initWithKeyBoardType:(NSInteger)type
{
    self.keyBoardType = type;
    
    CGRect frame =CGRectMake(0, 0, screenWidth,265);
    self = [super initWithFrame:frame];
    if (self)
    {
        [self createKeyboard];
        self.backgroundColor = COLOUR_NUM;
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}



- (UIView *)findKeyboard
{
    UIView *keyboardView = nil;
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for (UIWindow *window in [windows reverseObjectEnumerator])//逆序效率更高，因为键盘总在上方
    {
        keyboardView = [self findKeyboardInView:window];
        if (keyboardView)
        {
            return keyboardView;
        }
    }
    return nil;
}
- (UIView *)findKeyboardInView:(UIView *)view
{
    for (UIView *subView in [view subviews])
    {
        if (strstr(object_getClassName(subView), "UIKeyboard"))
        {
            return subView;
        }
        else
        {
            UIView *tempView = [self findKeyboardInView:subView];
            if (tempView)
            {
                return tempView;
            }
        }
    }
    return nil;
}

-(void)showInView:(UIView *)view
{
    CGPoint center = self.center;
    center.y += view.frame.size.height * 0.0000005;
//    center.y+=view.frame.size.height;
    self.center = center;
    [view addSubview:self];
}


#pragma mark 键盘点击事件
-(void)onKeyPressed:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    if ([self.delegate respondsToSelector:@selector(onDialViewClickedIndex:)])
    {
        [self.delegate onDialViewClickedIndex:btn.tag];
    }
}

-(void)dealloc
{
}

@end