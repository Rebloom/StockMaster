//
//  SelectStockEntity.h
//  StockMaster
//
//  Created by Johnny on 15/4/10.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BasicManagedObject.h"

@class StockInfoEntity;

// 自选股票
@interface SelectStockEntity : BasicManagedObject

// 用户uid
@property (nonatomic, retain) NSString *uid;
// 盈利率(涨幅)
@property (nonatomic, retain) NSString *profitRate;
// 涨跌点数
@property (nonatomic, retain) NSString *profitAmount;
// 当前价格
@property (nonatomic, retain) NSString *currentPrice;
// 是否持仓，0为否，1为是
@property (nonatomic, assign) int16_t isPortfolio;
// 是否可买，0为否，1为是
@property (nonatomic, assign) int16_t isBuyable;
// 股票状态，0正常，1停牌
@property (nonatomic, assign) int16_t status;
// 买入提示信息
@property (nonatomic, retain) NSString *buyMessage;
// 创建时间
@property (nonatomic, assign) NSTimeInterval createTime;
// 更新时间
@property (nonatomic, assign) NSTimeInterval updateTime;
// 股票信息
@property (nonatomic, retain) StockInfoEntity *stockInfo;

@end
