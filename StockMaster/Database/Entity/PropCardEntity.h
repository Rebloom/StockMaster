//
//  PropCardEntity.h
//  StockMaster
//
//  Created by Johnny on 15/7/13.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BasicManagedObject.h"

enum PropCardStatus {
    PropCardStatusEnable = 1,
    PropCardStatusDisable = 2,
    PropCardStatusDevelop = 3
};

#define PropCardCardIDRebirth100    @"1"
#define PropCardCardIDRebirth90     @"2"
#define PropCardCardIDMakeShort     @"3"

@interface PropCardEntity : BasicManagedObject

// 用户uid
@property (nonatomic, retain) NSString * uid;
// 道具卡id
@property (nonatomic, retain) NSString * cardID;
// 道具卡名字
@property (nonatomic, retain) NSString * name;
// 道具卡数量
@property (nonatomic, retain) NSString * num;
// 道具卡图片
@property (nonatomic, retain) NSString * image;
// 道具卡功能描述
@property (nonatomic, retain) NSString * desc;
// 道具卡功能状态，1为可用，2为不可用，3为开发中
@property (nonatomic, assign) int16_t status;
// 道具列表按钮文案
@property (nonatomic, retain) NSString * buttonDesc;
// 是否是持续性卡，1是，2不是
@property (nonatomic, assign) int16_t isDuration;
// 道具卡失效日期文案
@property (nonatomic, retain) NSString * expireTime;
// 是否是系统赠送，1为是，2为否
@property (nonatomic, assign) int16_t isSystemGive;
// 系统赠送的文案
@property (nonatomic, retain) NSString * systemGiveDesc;
// 购买按钮的文案
@property (nonatomic, retain) NSString * buyDesc;
// 原价
@property (nonatomic, retain) NSString * oldPrice;
// 现价，不能以new开头
@property (nonatomic, retain) NSString * currentPrice;
// 更新时间，用于排序
@property (nonatomic, retain) NSDate *updateTime;

@end
