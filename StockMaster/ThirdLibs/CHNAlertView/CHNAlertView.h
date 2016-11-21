//
//  CHNAlertView.h
//  StockMaster
//
//  Created by Rebloom on 14-10-12.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Utility.h"

typedef enum {
    AHAlertViewStyleDefault = 0,
    AHAlertViewStyleSecureTextInput,
    AHAlertViewStylePlainTextInput,
    AHAlertViewStyleLoginAndPasswordInput,
} AHAlertViewStyle;

typedef enum {
    AHAlertViewPresentationStyleNone = 0,
    AHAlertViewPresentationStylePop,
    AHAlertViewPresentationStyleFade,
    
    AHAlertViewPresentationStyleDefault = AHAlertViewPresentationStylePop
} AHAlertViewPresentationStyle;

typedef enum {
    AHAlertViewDismissalStyleNone = 0,
    AHAlertViewDismissalStyleZoomDown,
    AHAlertViewDismissalStyleZoomOut,
    AHAlertViewDismissalStyleFade,
    AHAlertViewDismissalStyleTumble,
    
    AHAlertViewDismissalStyleDefault = AHAlertViewDismissalStyleFade
} AHAlertViewDismissalStyle;

typedef void (^AHAlertViewButtonBlock)();

@protocol CHNAlertViewDelegate <NSObject>
@required

- (void)buttonClickedAtIndex:(NSInteger)index;

@end

@interface CHNAlertView : UIView
{
    BOOL hasLayedOut;
    BOOL isAlert;
    BOOL forceUpdate;
}
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *message;
@property(nonatomic, weak) id <CHNAlertViewDelegate> delegate;

@property(nonatomic, readonly, assign, getter = isVisible) BOOL visible;
@property(nonatomic, assign) AHAlertViewStyle alertViewStyle;
@property(nonatomic, assign) AHAlertViewPresentationStyle presentationStyle;
@property(nonatomic, assign) AHAlertViewDismissalStyle dismissalStyle;

// use these properties for fine-grained control of alert layout
@property(nonatomic, assign) CGFloat buttonHeight UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) CGFloat textFieldHeight UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) CGFloat titleLabelBottomMargin UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) CGFloat messageLabelBottomMargin UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) CGFloat textFieldBottomMargin UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) CGFloat textFieldLeading UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) CGFloat buttonBottomMargin UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) CGFloat buttonHorizontalSpacing UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UITextField *plainTextField;
@property (nonatomic, strong) UITextField *secureTextField;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *destructiveButton;
@property (nonatomic, strong) NSMutableArray *otherButtons;
@property (nonatomic, strong) NSMutableDictionary *buttonBackgroundImagesForControlStates;
@property (nonatomic, strong) NSMutableDictionary *cancelButtonBackgroundImagesForControlStates;
@property (nonatomic, strong) NSMutableDictionary *destructiveButtonBackgroundImagesForControlStates;

+ (CHNAlertView *) defaultAlertView;

- (id)initWithAwardText:(NSString *)text desc1:(NSString *)desc1 desc2:(NSString *)desc2 buttonDesc:(NSString *)desc delegate:(id)_delegate;

- (id)initWithNormalType:(NSString *)title content:(NSString *)content cancelTitle:(NSString *)cancelTitle sureTitle:(NSString *)sureTitle withDelegate:(id)_delegate;

- (id)initWithTitle:(NSString *)title withDelegate:(id)_delegate;

- (id)initContent:(NSString *)content cancelTitle:(NSString *)cancelTitle sureTitle:(NSString *)sureTitle withDelegate:(id)_delegate withType:(NSInteger)type;

- (id)initWithAwardStockName:(NSString *)name amount:(NSString *)amount price:(NSString *)price message:(NSString *)message delegate:(id)_delegate;

- (id)initWithAwardFinished:(NSString *)_messageL delegate:(id)_delegate;

+ (void)applySystemAlertAppearance;
- (void)addButtonWithTitle:(NSString *)title block:(AHAlertViewButtonBlock)block;
- (void)setDestructiveButtonTitle:(NSString *)title block:(AHAlertViewButtonBlock)block;
- (void)setCancelButtonTitle:(NSString *)title block:(AHAlertViewButtonBlock)block;
- (void)show;
- (void)showWithStyle:(AHAlertViewPresentationStyle)presentationStyle;
- (void)showContent:(NSString *)content cancelTitle:(NSString *)cancelTitle sureTitle:(NSString *)sureTitle withDelegate:(id)_delegate withType:(NSInteger)type;
- (void)dismiss;
- (void)dismissWithStyle:(AHAlertViewDismissalStyle)dismissalStyle;

- (UITextField *)textFieldAtIndex:(NSInteger)textFieldIndex;

@property(nonatomic, strong) UIImage *backgroundImage UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) UIEdgeInsets contentInsets UI_APPEARANCE_SELECTOR;

@property(nonatomic, copy) NSDictionary *titleTextAttributes UI_APPEARANCE_SELECTOR;
@property(nonatomic, copy) NSDictionary *messageTextAttributes UI_APPEARANCE_SELECTOR;
@property(nonatomic, copy) NSDictionary *buttonTitleTextAttributes UI_APPEARANCE_SELECTOR;

- (void)setButtonBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (UIImage *)buttonBackgroundImageForState:(UIControlState)state UI_APPEARANCE_SELECTOR;

- (void)setCancelButtonBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (UIImage *)cancelButtonBackgroundImageForState:(UIControlState)state UI_APPEARANCE_SELECTOR;

- (void)setDestructiveButtonBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (UIImage *)destructiveButtonBackgroundImageForState:(UIControlState)state UI_APPEARANCE_SELECTOR;

@end
