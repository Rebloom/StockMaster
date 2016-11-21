//
//  CalDay.h
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c)2012年 itotemstudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Enum.h"

@interface ITTCalDay : NSObject
{
@private    
    NSDate      *_date;
    NSInteger   _month;
    NSInteger   _day;
    NSInteger   _year;
    NSInteger   _weekDay;
}

- (id)initWithDate:(NSDate*)d;
- (id)initWithYear:(NSInteger)year month:(NSInteger)year day:(NSInteger)day;

@property (nonatomic, retain, readonly)NSDate *date;

- (NSUInteger)getYear;
- (NSUInteger)getMonth;
- (NSUInteger)getDay;
- (NSUInteger)getWeekDay;
- (NSComparisonResult)compare:(ITTCalDay*)calDay;

- (NSString*)getWeekDayName;

- (ITTCalDay*)nextDay;
- (ITTCalDay*)previousDay;
- (WeekDay)getMeaningfulWeekDay;

- (BOOL)isToday;
- (BOOL)isEqualToDay:(ITTCalDay*)calDay;

@end
