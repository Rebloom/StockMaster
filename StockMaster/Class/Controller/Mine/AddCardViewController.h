//
//  AddCardViewController.h
//  StockMaster
//
//  Created by Rebloom on 14-7-29.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "BasicViewController.h"
#import "CHNAlertView.h"
#import "DrawCashViewController.h"
#import "GFTextField.h"
#import "SearchBankViewController.h"

@interface AddCardViewController : BasicViewController<UITextFieldDelegate,UIScrollViewDelegate,CHNAlertViewDelegate,SearchBankVCDelegate>
{
    UIView * tipView;
    UIButton * backgroundBtn;
    UIButton * bankBtn;
    UIButton * submitBtn;
    UIImageView * bgView;
    UIScrollView * scrollView;
    
    UIButton * changeBtn;
    
    NSMutableDictionary * manageDic;
    NSMutableArray * bankArr;
    NSInteger selectedIndex;

    BOOL isFirst;
    BOOL isClose;
    BOOL isName;
    BOOL isCardId;
    BOOL isIdentify;
    BOOL isMobile;
    
    NSString * bankID;
    NSString * bankName;
    NSString * branchBankID;
    NSString * branchName;
}

@property (nonatomic, assign) NSInteger cardType;//
@property (nonatomic, assign) NSInteger modelType;//修改还是添加
@property (nonatomic, copy) NSString * drawCashNum;
@property (nonatomic, assign)  BOOL isFirst;//判断是否有银行卡（或第一次添加银行卡）
@property (nonatomic, copy) NSDictionary * transInfo;
@end
