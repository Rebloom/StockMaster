//
//  StockPoint.h
//  StockMaster
//
//  Created by Rebloom on 14-9-10.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StockPoint : NSObject

@property (nonatomic, copy) NSString * date;
@property (nonatomic, copy) NSString * high;
@property (nonatomic, copy) NSString * low;
@property (nonatomic, copy) NSString * open;
@property (nonatomic, copy) NSString * close;
@property (nonatomic, copy) NSString * volume;
@property (nonatomic, copy) NSString * ma5;
@property (nonatomic, copy) NSString * ma10;
@property (nonatomic, copy) NSString * ma20;

// 分时线用的
@property (nonatomic, copy) NSString * price;
@property (nonatomic, copy) NSString * avgPrice;
@property (nonatomic, copy) NSString * updown_range;
@property (nonatomic, copy) NSString * updown;

@end
