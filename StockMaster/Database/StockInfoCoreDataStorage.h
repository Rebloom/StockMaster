//
//  StockInfoCoreDataStorage.h
//  StockMaster
//
//  Created by Johnny on 15/4/7.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import "BasicCoreDataStorage.h"
#import "StockInfoEntity.h"
#import "HotStockEntity.h"
#import "HoldStockEntity.h"
#import "SelectStockEntity.h"
#import "RealtimeDataEntity.h"
#import "StockGradeEntity.h"
#import "MinuteLineEntity.h"
#import "IndexQuotationEntity.h"
#import "SearchHistoryEntity.h"
#import "PlateInfoEntity.h"
#import "HotPlateEntity.h"
#import "StockPlateEntity.h"
#import "VersionInfoEntity.h"

@interface StockInfoCoreDataStorage : BasicCoreDataStorage

+ (StockInfoCoreDataStorage *)sharedInstance;

#pragma mark - 股票数据
/**
 * 保存所有股票信息，参数传入服务端返回的NSDictionary的数组
 */
- (void)saveStockInfo:(NSArray *)stockArray;
/**
 * 通过股票代码得到股票信息
 */
- (StockInfoEntity *)getStockInfoWithCode:(NSString *)code exchange:(NSString *)exchange;
/**
 * 查找股票信息，返回StockInfoEntity的数组
 */
- (NSArray *)searchStockInfo:(NSString *)search;

/**
 * 保存热门股票信息，参数传入服务端返回的NSDictionary的数组
 */
- (void)saveHotStock:(NSArray *)stockArray;
/**
 * 得到热门股票信息，返回HotStockEntity的数组
 */
- (NSArray *)getHotStock;

#pragma mark -
/**
 * 保存持仓股票信息，参数传入服务端返回的NSDictionary的数组
 */
- (void)saveHoldStockWithLong:(NSArray *)longArray andShort:(NSArray *)shortArray;
/**
 * 得到持仓股票信息，返回HoldStockEntity的数组
 */
- (NSArray *)getHoldStockWithType:(StockHoldType)type;

#pragma mark -
/**
 * 保存自选股票信息，参数传入服务端返回的NSDictionary的数组
 */
- (void)saveSelectStock:(NSArray *)stockArray;
/**
 * 增加自选股票，参数传入股票代码，交易所
 */
- (void)addSelectStockWithCode:(NSString *)code exchange:(NSString *)exchange;
/**
 * 删除自选股票，参数传入股票代码，交易所
 */
- (void)delSelectStockWithCode:(NSString *)code exchange:(NSString *)exchange;
/**
 * 得到自选股票信息，返回SelectStockEntity的数组
 */
- (NSArray *)getSelectStock;
/**
 * 判断是否加入自选，参数传入股票代码
 */
- (BOOL)isSelectStockWithCode:(NSString *)code exchange:(NSString *)exchange;

#pragma mark -
/**
 * 保存股票实时数据，参数传入服务端返回的NSDictionary
 */
- (RealtimeDataEntity *)saveStockRealtimeData:(NSDictionary *)dataDict;
/**
 * 得到股票时实数据，参数传入股票代码，交易所
 */
- (RealtimeDataEntity *)getStockRealtimeDataWithCode:(NSString *)code exchange:(NSString *)exchange;

- (void)addStockRealtimeDataSelectedWithCode:(NSString *)code exchange:(NSString *)exchange;
- (void)delStockRealtimeDataSelectedWithCode:(NSString *)code exchange:(NSString *)exchange;

#pragma mark -
/**
 * 保存股票评级，参数传入服务端返回的NSDictionary
 */
- (StockGradeEntity *)saveStockGrade:(NSDictionary *)gradeDict;
/**
 * 得到股票评级，参数传入股票代码，交易所
 */
- (StockGradeEntity *)getStockGradeWithCode:(NSString *)code exchange:(NSString *)exchange;

#pragma mark -
/**
 * 保存股票分时图，参数传入服务端返回的NSDictionary的数组
 */
- (NSArray *)saveStockMinuteLine:(NSArray *)lineArray code:(NSString *)code exchange:(NSString *)exchange;
/**
 * 得到股票分时图，参数传入股票代码，交易所
 */
- (NSArray *)getStockMinuteLineWithCode:(NSString *)code exchange:(NSString *)exchange;

#pragma mark -
/**
 * 保存指数基本行情，参数传入服务端返回的NSDictionary的数组
 */
- (void)saveIndexQuotation:(NSArray *)indexArray;
/**
 * 得到指数基本行情，返回IndexQuotationEntity的数组
 */
- (NSArray *)getIndexQuotation;
/**
 * 添加搜索股票历史，参数传入股票代码，交易所
 **/
- (void)addSearchHistoryWithCode:(NSString *)code exchange:(NSString *)exchange;
/**
 * 得到搜索股票历史，返回SearchHistoryEntity的数组
 */
- (NSArray *)getSearchHistory;
/**
 * 得到搜索股票历史
 **/
- (void)clearSearchHistory;

#pragma mark - 板块数据
- (void)savePlateInfo:(NSArray *)plateArray;
- (NSArray *)getPlateInfo;

- (void)saveHotPlate:(NSArray *)plateArray;
- (NSArray *)getHotPlate;

- (void)saveStockPlate:(NSArray *)plateArray code:(NSString *)code exchange:(NSString *)exchange;
- (NSArray *)getStockPlateWithCode:(NSString *)code exchange:(NSString *)exchange;

#pragma mark - 数据更新版本（时间戳）
- (void)saveStockInfoUpdateTime:(NSString *)time;
- (NSString *)getStockInfoUpdateTime;

@end
