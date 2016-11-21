//
//  BasicManagedObject.m
//  StockMaster
//
//  Created by Johnny on 15-1-7.
//  Copyright (c) 2015年 aizhangzhang. All rights reserved.
//

#import "BasicManagedObject.h"


@implementation BasicManagedObject

+ (NSString *)entityName
{
    NSString *className = NSStringFromClass([self class]);
    NSString *suffix = @"Entity";
    
    if ([className hasSuffix:suffix] && ([className length] > [suffix length])) {
        return [className substringToIndex:([className length] - [suffix length])];
    }
    else {
        return className;
    }
}

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc
{
    NSParameterAssert(moc);
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:moc];
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc
{
    NSParameterAssert(moc);
    return [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:moc];
}

@end
