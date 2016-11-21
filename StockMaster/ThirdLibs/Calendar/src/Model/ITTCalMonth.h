//
//  ITTCalMonth.h
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 itotemstudio. All rights reserved.
//

#import <UIKit/UIKit.h>

#define NUMBER_OF_DAYS_IN_WEEK  7

@class ITTCalDay;

@interface ITTCalMonth : NSObject
{
@private
    NSUInteger      _month;
    NSUInteger      _year;
    NSUInteger      _numberOfDays;
    ITTCalDay       *_today;
    NSMutableArray  *daysOfMonth;
}

@property (nonatomic, readonly) NSUInteger days;;

- (id)initWithDate:(NSDate*)date;
- (id)initWithMonth:(NSUInteger)month;
- (id)initWithMonth:(NSUInteger)month year:(NSUInteger)year;
- (id)initWithMonth:(NSUInteger)month year:(NSUInteger)year day:(NSUInteger)day;

- (NSUInteger)getYear;
- (NSUInteger)getMonth;

- (ITTCalDay*)calDayAtDay:(NSUInteger)day;
- (ITTCalDay*)firstDay;
- (ITTCalDay*)lastDay;

- (ITTCalMonth*)nextMonth;
- (ITTCalMonth*)previousMonth;

@end
