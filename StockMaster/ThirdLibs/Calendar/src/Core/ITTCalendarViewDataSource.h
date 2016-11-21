//
//  CalendarDataSource.h
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 itotemstudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ITTCalendarViewHeaderView;
@class ITTCalendarViewFooterView;
@class ITTCalendarGridView;
@class ITTCalendarView;
@class ITTCalMonth;
@class ITTCalDay;

@protocol ITTCalendarViewDataSource <NSObject>
@optional
- (NSArray*)weekTitlesForCalendarView:(ITTCalendarView*)calendarView;

- (NSString*)calendarView:(ITTCalendarView*)calendarView titleForMonth:(ITTCalMonth*)calMonth;

- (ITTCalendarGridView*)calendarView:(ITTCalendarView*)calendarView calendarGridViewForRow:(NSInteger)row column:(NSInteger)column calDay:(ITTCalDay*)calDay;

- (ITTCalendarGridView*)calendarView:(ITTCalendarView*)calendarView calendarDisableGridViewForRow:(NSInteger)row column:(NSInteger)column calDay:(ITTCalDay*)calDay;

- (ITTCalendarViewHeaderView*)headerViewForCalendarView:(ITTCalendarView*)calendarView;
- (ITTCalendarViewFooterView*)footerViewForCalendarView:(ITTCalendarView*)calendarView;

@end
