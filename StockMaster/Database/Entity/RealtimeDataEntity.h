//
//  RealtimeDataEntity.h
//  StockMaster
//
//  Created by Johnny on 15/5/21.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BasicManagedObject.h"

enum ShortCardStatus
{
    ShortCardStatusNoCardNoUse = 0,
    ShortCardStatusHasCardNoUse = 1,
    ShortCardStatusHasCardHasUse = 2
};

@class StockInfoEntity;
// 股票实时数据
@interface RealtimeDataEntity : BasicManagedObject

// 当前价格
@property (nonatomic, retain) NSString * currentPrice;
// 昨日收盘价
@property (nonatomic, retain) NSString * yesterdayEndPrice;
// 今日开盘价
@property (nonatomic, retain) NSString * todayOpen;
// 今日最高价
@property (nonatomic, retain) NSString * todayMax;
// 今日最低价
@property (nonatomic, retain) NSString * todayMin;
// 振幅 单位：%
@property (nonatomic, retain) NSString * swingRange;
// 成交量 单位：手
@property (nonatomic, retain) NSString * tradeVolume;
// 成交金额 单位：万
@property (nonatomic, retain) NSString * tradeAmount;
// 换手率 单位：%
@property (nonatomic, retain) NSString * stockTurnover;
// 市盈率
@property (nonatomic, retain) NSString * priceEarningRatio;
// 流通市值 单位：亿
@property (nonatomic, retain) NSString * circulateMarketValue;
// 日期时间 05-21 11:13:52
@property (nonatomic, retain) NSString * dateTime;
// 涨跌额
@property (nonatomic, retain) NSString * updownPrice;
// 涨跌幅
@property (nonatomic, retain) NSString * updownRange;
// 涨了或跌了 "up"或"down"
@property (nonatomic, retain) NSString * updown;
// 股票状态 0：正常 1：停牌 2：退市 3：新股
@property (nonatomic, assign) int16_t stockStatus;
// 股票涨跌停状态 0:正常 1:涨停 2:跌停
@property (nonatomic, assign) int16_t updownStatus;
// 市场状态 0：交易中 1：已休市 2: 已收盘
@property (nonatomic, assign) int16_t marketStatus;
// 是否持仓 0：没有持仓 1：有持仓
@property (nonatomic, assign) int16_t isHoldings;
// 买入按钮状态 0：不可买 1：可买
@property (nonatomic, assign) int16_t buyStatus;
// 买入提示消息
@property (nonatomic, retain) NSString * buyMessage;
// 卖出按钮状态 0：不可卖 1：可卖
@property (nonatomic, assign) int16_t sellStatus;
// 卖出提示消息
@property (nonatomic, retain) NSString * sellMessage;
// 用户总持仓数量
@property (nonatomic, retain) NSString * userTradeAmount;
// 用户可卖股票数量
@property (nonatomic, retain) NSString * userSellableAmount;
// 用户的成本价格
@property (nonatomic, retain) NSString * userTradePrice;
// 用户盈利金额
@property (nonatomic, retain) NSString * userProfitMoney;
// 用户盈利比例
@property (nonatomic, retain) NSString * userProfitRate;
// 用户购买价格对比
@property (nonatomic, retain) NSString * priceCompare;
// 是否已经被加自选，0否，1是
@property (nonatomic, assign) int16_t isSelected;
// 是否添加股票提醒，1为启用，2为关闭
@property (nonatomic, assign) int16_t isSetRemind;
// 是否在交易时间
@property (nonatomic, assign) int16_t isTradable;
// 股票感情度
@property (nonatomic, retain) NSString * stockFeeling;
// 今日新增感情度
@property (nonatomic, retain) NSString * stockFeelingAdd;
// 股票信息
@property (nonatomic, retain) StockInfoEntity *stockInfo;
#pragma mark - 做空
// 做空，是否持仓 0：没有持仓 1：有持仓
@property (nonatomic, assign) int16_t shortIsHoldings;
// 做空，买入按钮状态 0：不可买 1：可买
@property (nonatomic, assign) int16_t shortBuyStatus;
// 做空，买入提示消息
@property (nonatomic, retain) NSString * shortBuyMessage;
// 做空，卖出按钮状态 0：不可卖 1：可卖
@property (nonatomic, assign) int16_t shortSellStatus;
// 做空，卖出提示消息
@property (nonatomic, retain) NSString * shortSellMessage;
// 做空，用户总持仓数量
@property (nonatomic, retain) NSString * shortUserTradeAmount;
// 做空，用户的成本价格
@property (nonatomic, retain) NSString * shortUserTradePrice;
// 做空，用户盈利金额
@property (nonatomic, retain) NSString * shortUserProfitMoney;
// 做空，用户盈利比例
@property (nonatomic, retain) NSString * shortUserProfitRate;
// 做空比率
@property (nonatomic, retain) NSString * makingShortRate;
// 做多比率
@property (nonatomic, retain) NSString * makingLongRate;
// 多空对比文案
@property (nonatomic, retain) NSString * shortLongText;
// 买跌通行证状态，0无卡未使用，1有卡未使用，2有卡已使用
@property (nonatomic, assign) int16_t shortCardStatus;

@end
