//
//  StockGradeEntity.h
//  StockMaster
//
//  Created by Johnny on 15/5/25.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BasicManagedObject.h"

@class StockInfoEntity;

@interface StockGradeEntity : BasicManagedObject

// 股票评级
@property (nonatomic, retain) NSString * grade;
// 股票质地
@property (nonatomic, retain) NSString * quality;
// 股票走势
@property (nonatomic, retain) NSString * tendency;
// 评价建议
@property (nonatomic, retain) NSString * suggest;
// 股票信息
@property (nonatomic, retain) StockInfoEntity *stockInfo;

@end
