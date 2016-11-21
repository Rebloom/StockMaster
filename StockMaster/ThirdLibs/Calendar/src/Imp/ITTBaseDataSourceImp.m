//
//  ITTBaseDataSourceImp.m
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 itotemstudio. All rights reserved.
//

#import "ITTBaseDataSourceImp.h"
#import "ITTBaseCalendarGridView.h"
#import "ITTBaseCalendarDisableGridView.h"
#import "ITTBaseCalendarViewHeaderView.h"
#import "ITTBaseCalendarViewFooterView.h"
#import "ITTCalMonth.h"

@implementation ITTBaseDataSourceImp

- (ITTCalendarGridView*)calendarView:(ITTCalendarView*)calendarView calendarGridViewForRow:(NSInteger)row column:(NSInteger)column calDay:(ITTCalDay*)calDay
{
    static NSString *identifier = @"BaseCalendarGridView";
    ITTCalendarGridView *gridView = [calendarView dequeueCalendarGridViewWithIdentifier:identifier];
    if (!gridView) {
        gridView = [ITTBaseCalendarGridView viewFromNibWithIdentifier:identifier];        
    }
    return gridView;
}

- (ITTCalendarGridView*)calendarView:(ITTCalendarView*)calendarView calendarDisableGridViewForRow:(NSInteger)row column:(NSInteger)column calDay:(ITTCalDay*)calDay
{
    static NSString *identifier = @"ITTBaseCalendarDisableGridView";    
    ITTCalendarGridView *gridView = [calendarView dequeueCalendarGridViewWithIdentifier:identifier];
    if (!gridView) {
        gridView = [ITTBaseCalendarDisableGridView viewFromNibWithIdentifier:identifier];
    }
    return gridView;
}

- (ITTCalendarViewHeaderView*)headerViewForCalendarView:(ITTCalendarView*)calendarView
{
    return [ITTBaseCalendarViewHeaderView viewFromNib];
}

- (ITTCalendarViewFooterView*)footerViewForCalendarView:(ITTCalendarView*)calendarView
{
//    return [ITTBaseCalendarViewFooterView viewFromNib];
    return nil;
}

//- (NSArray*)weekTitlesForCalendarView:(ITTCalendarView*)calendarView
//{
//    return [NSArray arrayWithObjects:@"星期日", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", nil];
//}

//- (NSString*)calendarView:(CalendarView*)calendarView titleForMonth:(ITTCalMonth*)calMonth
//{
//    NSString *title = [NSString stringWithFormat:@"%d年-%d月", [calMonth getYear], [calMonth getMonth]];
//    return title;
//}

@end
