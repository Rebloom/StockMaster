//
//  RealtimeDataEntity.m
//  StockMaster
//
//  Created by Johnny on 15/5/21.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import "RealtimeDataEntity.h"
#import "StockInfoEntity.h"


@implementation RealtimeDataEntity

@dynamic currentPrice;
@dynamic yesterdayEndPrice;
@dynamic todayOpen;
@dynamic todayMax;
@dynamic todayMin;
@dynamic swingRange;
@dynamic tradeVolume;
@dynamic tradeAmount;
@dynamic stockTurnover;
@dynamic priceEarningRatio;
@dynamic circulateMarketValue;
@dynamic dateTime;
@dynamic updownPrice;
@dynamic updownRange;
@dynamic updown;
@dynamic stockStatus;
@dynamic updownStatus;
@dynamic marketStatus;
@dynamic isHoldings;
@dynamic buyStatus;
@dynamic buyMessage;
@dynamic sellStatus;
@dynamic sellMessage;
@dynamic userTradeAmount;
@dynamic userSellableAmount;
@dynamic userTradePrice;
@dynamic userProfitMoney;
@dynamic userProfitRate;
@dynamic priceCompare;
@dynamic isSelected;
@dynamic isSetRemind;
@dynamic isTradable;
@dynamic stockFeeling;
@dynamic stockFeelingAdd;
@dynamic stockInfo;

#pragma mark - 做空
@dynamic shortIsHoldings;
@dynamic shortBuyStatus;
@dynamic shortBuyMessage;
@dynamic shortSellStatus;
@dynamic shortSellMessage;
@dynamic shortUserTradeAmount;
@dynamic shortUserTradePrice;
@dynamic shortUserProfitMoney;
@dynamic shortUserProfitRate;
@dynamic makingShortRate;
@dynamic makingLongRate;
@dynamic shortLongText;
@dynamic shortCardStatus;

@end
