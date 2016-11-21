//
//  SearchHistoryEntity.h
//  StockMaster
//
//  Created by Johnny on 15/4/22.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BasicManagedObject.h"

@class StockInfoEntity;

@interface SearchHistoryEntity : BasicManagedObject

@property (nonatomic, retain) NSDate * updateTime;
@property (nonatomic, retain) StockInfoEntity *stockInfo;

@end
