//
//  IndexQuotationEntity.h
//  StockMaster
//
//  Created by Johnny on 15/4/21.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BasicManagedObject.h"

@interface IndexQuotationEntity : BasicManagedObject

// 指数代码
@property (nonatomic, retain) NSString * code;
// 指数名称
@property (nonatomic, retain) NSString * name;
// 上证还是深证
@property (nonatomic, retain) NSString * exchange;
// 指数点数
@property (nonatomic, retain) NSString * currentPrice;
// 涨了还是跌了
@property (nonatomic, retain) NSString * updown;
// 涨跌幅数量
@property (nonatomic, retain) NSString * updownPrice;
// 涨跌幅比例
@property (nonatomic, retain) NSString * updownRange;
// 更新时间，用于排序
@property (nonatomic, retain) NSDate *updateTime;

@end
