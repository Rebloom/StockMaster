//
//  RequestQueue.h
//  StockMaster
//
//  Created by Rebloom on 14-9-15.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CHNMacro.h"

@interface RequestQueue : NSObject

@property (nonatomic, strong) NSMutableArray * requestList;

+ (RequestQueue *)instance;

@end
