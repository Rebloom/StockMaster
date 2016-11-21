//
//  CalendarDelegate.h
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 itotemstudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ITTCalendarView;
@class CalDay;

@protocol ITTCalendarViewDelegate <NSObject>
@optional
- (void)calendarViewDidSelectDay:(ITTCalendarView*)calendarView calDay:(ITTCalDay*)calDay;
- (void)calendarViewDidSelectPeriodType:(ITTCalendarView*)calendarView periodType:(PeriodType)periodType;
@end
