//
//  HotStockEntity.h
//  StockMaster
//
//  Created by Johnny on 15/4/10.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BasicManagedObject.h"

@class StockInfoEntity;
// 热门股票
@interface HotStockEntity : BasicManagedObject

// 推荐理由1
@property (nonatomic, retain) NSString * reason1;
// 推荐理由2
@property (nonatomic, retain) NSString * reason2;
// 按钮状态，1.买入，2添加自选，3.取消自选
@property (nonatomic, assign) int16_t buttonStatus;
// 更新时间，用于排序
@property (nonatomic, retain) NSDate *updateTime;
@property (nonatomic, retain) StockInfoEntity *stockInfo;

@end
