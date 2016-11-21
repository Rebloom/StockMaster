//
//  NSString+UIColor.h
//  UBoxOnline
//
//  Created by ubox on 13-3-21.
//  Copyright (c) 2013年 ubox. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kBackgroundColor    @"#f1f0ef".color
#define kFontColorA         @"#ffffff".color
#define kFontColorB         @"#f0f0f0".color
#define kFontColorC         @"#cbcbcb".color
#define kFontColorD         @"#31302f".color
#define KFontColorE         @"#979797".color
#define KFontColorF         @"#9f7f2a".color
#define KFontColorG         @"#c7930f".color
#define KFontColorH         @"#ec3236".color


#define kButtonColorA       @"#ffe001".color
#define kTitleColorA        @"#31302f".color
#define kHighColor          @"#ec3236".color
#define kLowColor           @"#338111".color

#define kBtnBgColor         @"#eb5255".color

#define kDefaultBarColor    @"#eb5255".color
#define kSelectBarColor     @"#db484b".color
#define kLineBGColor1       @"#31302f".color
#define kLineBGColor2       @"#cbcbcb".color

#define kLineDeepBlue       @"#6783b0".color
#define kLineLightBlue      @"#cbdaf2".color
#define kLineGoldColor      @"#ffd700".color
#define kLineBgColor3       @"#f1f0ef".color
#define kLineBgColor4       @"#e0e0e0".color

#define kRedColor           @"#df5d57".color
#define kGreenColor         @"#42ad8b".color
#define KBlueColor          @"#4778dd".color

//2.0版颜色
#define KColorHeader            @"#e2e5e8".color //NavigationBar  背景灰
#define KLineNewBGColor1        @"#e3e3e3".color //线色1
#define KLineNewBGColor2        @"#eeeeee".color //线色2
#define KLineNewBGColor3        @"#d0d0d0".color //线色3
#define KLineNewBGColor4        @"#e9e9e9".color //线色4
#define KLineNewBGColor5        @"#404040".color //二维码边线
#define KLineNewBGColor6        @"#f1f1f1".color
#define KLineNewBGColor7        @"#eaedef".color

#define KSelectNewColor         @"#f5f5f5".color //点击颜色
#define KSelectNewColor1        @"#cdd1d6".color //可点击灰色
#define KSelectNewColor2        @"#cccccc".color //可点击灰色
#define KSelectNewColor3        @"#d0d3d6".color //选中后得深灰色

#define KFontNewColorA          @"#494949".color //NavigationBar  文字黑
#define KFontNewColorB          @"#929292".color
#define KFontNewColorC          @"#dcdcdc".color
#define KFontNewColorD          @"#df5d57".color
#define KFontNewColorE          @"#c2c5c8".color
#define KFontNewColorF          @"#e26e68".color
#define KFontNewColorG          @"#4bb190".color
#define KFontNewColorH          @"#55b597".color
#define KFontNewColorI          @"#e57d79".color
#define KFontNewColorJ          @"#dfdfdf".color
#define KFontNewColorK          @"#ffc2c1".color
#define KFontNewColorL          @"#42ad8b".color
#define KFontNewColorM          @"#e2e2e2".color

#define KBtnSelectNewColorA     @"#a62d27".color
#define KNewColorGreen2         @"#a0d6c5".color
#define KNewColorRed2           @"#efaeab".color
#define KNewColorPink           @"#f6d3d1".color
#define KNewColorLightGreen     @"#d0ebe2".color
#define KNewColorOrange         @"#ea7548".color



// 用于扩展NSString,转换UIColor
@interface NSString (UIColor)

// 获取由当前的NSString转换来的UIColor
- (UIColor*)color;

@end
