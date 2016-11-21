//
//  CalDay.m
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 itotemstudio. All rights reserved.
//

#import "ITTCalDay.h"
#import "CalendarDateUtil.h"

#define SECOND_OF_A_DAY 24*60*60

@interface ITTCalDay()
- (void)cacluateDate;
@end

@implementation ITTCalDay

@synthesize date;

- (void)cacluateDate
{
    unsigned unitFlags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit;
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    NSDateComponents *comps = [gregorian components:unitFlags fromDate:_date];
    _month = comps.month;
    _day = comps.day;
    _year = comps.year;
    _weekDay = comps.weekday;
}

- (id)initWithDate:(NSDate*)d
{
    self = [super init];
    if (self) {
        _date = [d retain];
        [self cacluateDate];
    }
    return self;
}

- (id)initWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)d
{
    self = [super init];
    if (self) {
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setYear:year];
        [comps setMonth:month];
        [comps setDay:d];
        [comps setHour:0];
        [comps setMinute:0];
        [comps setSecond:0];
        _date = [[[NSCalendar currentCalendar] dateFromComponents:comps] retain];
        [comps release];
        [self cacluateDate];
    }
    return self;    
}

- (void)dealloc
{
    [_date release];
    _date = nil;
    [super dealloc];
}

- (NSDate*)date
{
    return _date;
}

- (NSUInteger)getYear
{
    return _year;
}

- (NSUInteger)getMonth
{
    return _month;    
}

- (NSUInteger)getDay
{
    return _day;        
}

- (NSUInteger)getWeekDay
{
    return _weekDay;            
}

- (NSComparisonResult)compare:(ITTCalDay*)calDay
{
    NSComparisonResult result = NSOrderedSame;
    if([self getYear] < [calDay getYear]) {
        result = NSOrderedAscending;
    }
    else if([self getYear] == [calDay getYear]) {
        if([self getMonth] < [calDay getMonth]) {
            result = NSOrderedAscending;
        }
        else if([self getMonth] == [calDay getMonth]) {
            if([self getDay] < [calDay getDay]) {
                result = NSOrderedAscending;
            }
            else if([self getDay] == [calDay getDay]) {
                result = NSOrderedSame;
            }
            else {   
                result = NSOrderedDescending;        
            }  
        }
        else {    
            result = NSOrderedDescending;        
        }        
    }
    else {    
        result = NSOrderedDescending;        
    }
    return result;
}

- (ITTCalDay*)nextDay
{
    NSDate *nextDayDate = [_date dateByAddingTimeInterval:SECOND_OF_A_DAY];
    ITTCalDay *nextDay = [[ITTCalDay alloc] initWithDate:nextDayDate];
    return [nextDay autorelease];
}

- (ITTCalDay*)previousDay
{
    NSDate *previousDayDate = [_date dateByAddingTimeInterval:-1*SECOND_OF_A_DAY];
    ITTCalDay *previousDay = [[ITTCalDay alloc] initWithDate:previousDayDate];
    return [previousDay autorelease];
}

- (WeekDay)getMeaningfulWeekDay
{
    WeekDay wd = WeekDayKnown;
    switch (_weekDay) {
        case 1:
            wd = WeekDaySunday;
            break;
        case 2:
            wd = WeekDayMonday;            
            break;
        case 3:
            wd = WeekDayTuesday;                        
            break;
        case 4:
            wd = WeekDayWednesday;
            break;
        case 5:
            wd = WeekDayThurday;
            break;
        case 6:
            wd = WeekDayFriday;
            break;
        case 7:
            wd = WeekDaySaturday;
            break;
        default:
            break;
    }
    return wd;
}

- (NSString*)getWeekDayName
{
    NSString *name = @"KnownName";
    switch (_weekDay) {
        case 1:
            name = @"Sunday";
            break;
        case 2:
            name = @"Monday";            
            break;
        case 3:
            name = @"Tuesday";                        
            break;
        case 4:
            name = @"Wednesday";
            break;
        case 5:
            name = @"Thurday";
            break;
        case 6:
            name = @"Friday";
            break;
        case 7:
            name = @"Saturday";
            break;
        default:
            break;
    }    
    return name;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"year:%d month:%d day:%d week:%d %@", (int)_year, (int)_month, (int)_day, [self getMeaningfulWeekDay], [self getWeekDayName]];
}

- (BOOL)isToday
{
    return ([CalendarDateUtil getCurrentYear] == _year && 
            [CalendarDateUtil getCurrentMonth] == _month && 
            [CalendarDateUtil getCurrentDay] == _day);
}

- (BOOL)isEqualToDay:(ITTCalDay*)calDay
{
    BOOL equal = FALSE;
    if (calDay) {
        equal = ([calDay getYear] == _year && 
                 [calDay getMonth] == _month && 
                 [calDay getDay] == _day);    
    }
    return equal;
}

@end
