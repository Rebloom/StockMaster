//
//  StockInfoEntity.h
//  StockMaster
//
//  Created by Johnny on 15/4/10.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BasicManagedObject.h"

@class PlateInfoEntity, MinuteLineEntity, DayLineEntity, WeekLineEntity, MonthLineEntity;
// 股票信息
@interface StockInfoEntity : BasicManagedObject

// 股票代码
@property (nonatomic, retain) NSString *code;
// 交易所
@property (nonatomic, retain) NSString *exchange;
// 股票名称
@property (nonatomic, retain) NSString *name;
// 全拼
@property (nonatomic, retain) NSString *pinyin;
// 简拼
@property (nonatomic, retain) NSString *jianpin;
// 股票类别，0：指数，1：A股
@property (nonatomic, assign) int16_t type;
// 是否退市，0:未退市；1:已退市
@property (nonatomic, assign) int16_t delisted;
// 上市时间
@property (nonatomic, assign) NSTimeInterval listingDate;
// 更新的时间戳
@property (nonatomic, assign) NSTimeInterval updateTime;
// 分时
@property (nonatomic, retain) NSSet *minuteLine;
// 日线
@property (nonatomic, retain) NSSet *dayLine;
// 周线
@property (nonatomic, retain) NSSet *weekLine;
// 月线
@property (nonatomic, retain) NSSet *monthLine;

@end

@interface StockInfoEntity (CoreDataGeneratedAccessors)

- (void)addPlateInfoObject:(PlateInfoEntity *)value;
- (void)removePlateInfoObject:(PlateInfoEntity *)value;
- (void)addPlateInfo:(NSSet *)values;
- (void)removePlateInfo:(NSSet *)values;

- (void)addMinuteLineObject:(MinuteLineEntity *)value;
- (void)removeMinuteLineObject:(MinuteLineEntity *)value;
- (void)addMinuteLine:(NSSet *)values;
- (void)removeMinuteLine:(NSSet *)values;

- (void)addDayLineObject:(DayLineEntity *)value;
- (void)removeDayLineObject:(DayLineEntity *)value;
- (void)addDayLine:(NSSet *)values;
- (void)removeDayLine:(NSSet *)values;

- (void)addWeekLineObject:(WeekLineEntity *)value;
- (void)removeWeekLineObject:(WeekLineEntity *)value;
- (void)addWeekLine:(NSSet *)values;
- (void)removeWeekLine:(NSSet *)values;

- (void)addMonthLineObject:(MonthLineEntity *)value;
- (void)removeMonthLineObject:(MonthLineEntity *)value;
- (void)addMonthLine:(NSSet *)values;
- (void)removeMonthLine:(NSSet *)values;

@end
