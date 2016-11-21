//
//  StockInfoEntity.m
//  StockMaster
//
//  Created by Johnny on 15/4/10.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import "StockInfoEntity.h"
#import "DayLineEntity.h"
#import "MinuteLineEntity.h"
#import "MonthLineEntity.h"
#import "PlateInfoEntity.h"
#import "WeekLineEntity.h"


@implementation StockInfoEntity

@dynamic code;
@dynamic exchange;
@dynamic name;
@dynamic pinyin;
@dynamic jianpin;
@dynamic type;
@dynamic delisted;
@dynamic listingDate;
@dynamic updateTime;
@dynamic minuteLine;
@dynamic dayLine;
@dynamic weekLine;
@dynamic monthLine;

@end
