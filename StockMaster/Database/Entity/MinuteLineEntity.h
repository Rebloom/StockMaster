//
//  MinuteLineEntity.h
//  StockMaster
//
//  Created by Johnny on 15/4/10.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BasicManagedObject.h"

@class StockInfoEntity;
// 分时线
@interface MinuteLineEntity : BasicManagedObject

// 时间
@property (nonatomic, retain) NSString * time;
// 价格
@property (nonatomic, retain) NSString * price;
// 涨跌符
@property (nonatomic, retain) NSString * updownRange;
// 成交量
@property (nonatomic, retain) NSString * volume;
// 均价
@property (nonatomic, retain) NSString * avgPrice;
// 成交总量
@property (nonatomic, retain) NSString * allVolume;
// 相对上一分钟价格的涨跌
@property (nonatomic, retain) NSString * updown;
// 股票信息
@property (nonatomic, retain) StockInfoEntity *stockInfo;

@end
