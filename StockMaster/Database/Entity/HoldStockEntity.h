//
//  HoldStockEntity.h
//  StockMaster
//
//  Created by Johnny on 15/4/10.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BasicManagedObject.h"

typedef enum StockHoldType
{
    StockHoldTypeLong = 0,
    StockHoldTypeShort = 1
}StockHoldType;

@class StockInfoEntity;

//持仓股票
@interface HoldStockEntity : BasicManagedObject

// 用户uid
@property (nonatomic, retain) NSString *uid;
// 股票状态，0正常、1停牌、2退市
@property (nonatomic, assign) int16_t status;
// 成本价格
@property (nonatomic, retain) NSString *tradePrice;
// 购买数量
@property (nonatomic, retain) NSString *buyAmount;
// 可卖数量
@property (nonatomic, retain) NSString *sellableAmount;
// 盈亏率
@property (nonatomic, retain) NSString *profitRate;
// 盈利金额
@property (nonatomic, retain) NSString *profitMoney;
// 当前价格
@property (nonatomic, retain) NSString *currentPrice;
// 是否可买，0为否，1为是
@property (nonatomic, assign) int16_t isBuyable;
// 是否可卖，0为否，1为是
@property (nonatomic, assign) int16_t isSellable;
// 不可买入提示信息
@property (nonatomic, retain) NSString *buyMessage;
// 不可卖出提示信息
@property (nonatomic, retain) NSString *sellMessage;
// 持仓类型，Long：做多持仓 Short：做空持仓
@property (nonatomic, assign) int16_t holdType;
// 更新时间，用于排序
@property (nonatomic, retain) NSDate *updateTime;
// 股票信息
@property (nonatomic, retain) StockInfoEntity *stockInfo;

@end




