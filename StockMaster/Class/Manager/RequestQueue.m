//
//  RequestQueue.m
//  StockMaster
//
//  Created by Rebloom on 14-9-15.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "RequestQueue.h"

static RequestQueue * requestQueue;

@implementation RequestQueue

@synthesize requestList;

+ (RequestQueue *)instance
{
    if (requestQueue == nil)
    {
        requestQueue = [[self alloc] init];
    }
    return requestQueue;
}

- (id)init
{
    self = [super init];
    requestList = [[NSMutableArray alloc] init];
    return self;
}

- (void)dealloc
{
}

@end
