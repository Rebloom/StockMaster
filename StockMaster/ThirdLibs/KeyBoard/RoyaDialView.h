//
//  RoyaDialView.h
//  Test
//
//  Created by royasoft on 12-12-5.
//  Copyright (c) 2012年 royasoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TAG_KEY_UNDO        10
#define TAG_KEY_SYSTEM      11
#define TAG_KEY_ABC         12
#define TAG_KEY_600         600
#define TAG_KEY_601         601
#define TAG_KEY_001         111
#define TAG_KEY_002         222
#define TAG_KEY_300         300
#define TAG_KEY_000         999
#define TAG_KEY_0           0

@protocol RoyaDialViewDelegate;

@interface RoyaDialView : UIView<UITextFieldDelegate>{
    
    BOOL  mIsLayOn;
    UIButton *btnOffOn;
    UITextField *txtNumber;
    UIButton *btn0;
    UIButton *btn1;
    UIButton *btn2;
    UIButton *btn3;
    UIButton *btn4;
    UIButton *btn5;
    UIButton *btn6;
    UIButton *btn7;
    UIButton *btn8;
    UIButton *btn9;
    UIButton *btnUndo;
    UIButton *btn600;
    UIButton *btn601;
    UIButton *btn000;
    UIButton *btn002;
    UIButton *btn300;
    UIButton *btnABC;
}

@property(weak,nonatomic) id<RoyaDialViewDelegate> delegate;

@property(strong,nonatomic) UIButton *btnOffOn;

@property(strong,nonatomic) UITextField *txtNumber;

@property(strong,nonatomic) UIButton *btn0;

@property(strong,nonatomic) UIButton *btn1;

@property(strong,nonatomic) UIButton *btn2;

@property(strong,nonatomic) UIButton *btn3;

@property(strong,nonatomic) UIButton *btn4;

@property(strong,nonatomic) UIButton *btn5;

@property(strong,nonatomic) UIButton *btn6;

@property(strong,nonatomic) UIButton *btn7;

@property(strong,nonatomic) UIButton *btn8;

@property(strong,nonatomic) UIButton *btn9;

@property(strong,nonatomic) UIButton *btnUndo;

@property(strong,nonatomic) UIButton *btn600;

@property(strong,nonatomic) UIButton *btn601;

@property(strong,nonatomic) UIButton *btn000;

@property(strong,nonatomic) UIButton *btn002;

@property(strong,nonatomic) UIButton *btn300;

@property(strong,nonatomic) UIButton *btnABC;

@property (nonatomic, assign) NSInteger keyBoardType;

-(void)showInView:(UIView *)view;

- (id)initWithKeyBoardType:(NSInteger)type;

@end
