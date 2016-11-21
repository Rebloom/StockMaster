//
//  CalendarView.h
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 itotemstudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Enum.h"
#import "ITTCalendarViewDataSource.h"
#import "ITTCalendarViewDelegate.h"
#import "ITTCalendarGridView.h"
#import "ITTCalendarViewHeaderView.h"
#import "ITTCalendarViewFooterView.h"
#import "ITTCalendarScrollView.h"

#define CALENDAR_VIEW_HEIGHT_WITHOUT_FOOTER_VIEW 255
#define CALENDAR_VIEW_HEIGHT                     301

@class CalDay;
@class ITTCalMonth;

@interface ITTCalendarView : UIView<ITTCalendarGridViewDelegate, 
ITTCalendarViewHeaderViewDelegate, ITTCalendarViewFooterViewDelegate, ITTCalendarScrollViewDelegate>
{
    BOOL                    _moved;
    BOOL                    _firstLayout;
    
    PeriodType              _selectedPeriod;    
    GridIndex               _previousSelectedIndex;
    
    CGSize                  _gridSize;
    
    NSDate                  *_date;
    NSDate                  *_minimumDate;
    NSDate                  *_maximumDate;
    
    ITTCalDay               *_minimumDay;
    ITTCalDay               *_maximumDay;
    ITTCalDay               *_selectedDay;
    
    ITTCalMonth                *_calMonth;
    
    ITTCalendarViewHeaderView  *_calendarHeaderView;
    ITTCalendarViewFooterView  *_calendarFooterView;
    
    UIView                  *_parentView;
    
    NSMutableArray          *_gridViewsArray;                   //two-dimensional array
    NSMutableArray          *_monthGridViewsArray;
    NSMutableDictionary     *_recyledGridSetDic;
    NSMutableDictionary     *_selectedGridViewIndicesDic;
    NSMutableDictionary     *_selectedDayDic;
    
    id<ITTCalendarViewDataSource>  _dataSource;
    id<ITTCalendarViewDelegate>    _delegate;
}
@property (nonatomic, retain) id<ITTCalendarViewDataSource> dataSource;
@property (nonatomic, assign) id<ITTCalendarViewDelegate>   delegate;

@property (nonatomic, assign) PeriodType selectedPeriod;
/*
 * default is FALSE
 */
@property (nonatomic, assign) BOOL appear;

@property (nonatomic, assign) CGSize gridSize;

/*
 * default date is current date
 */
@property (nonatomic, retain) NSDate *date;              
/*
 * The minimum date that a date calendar view can show
 */
@property (nonatomic, retain) NSDate *minimumDate;          
/*
 * The maximum date that a date calendar view can show
 */
@property (nonatomic, retain) NSDate *maximumDate;
/*
 * The selected calyday on calendar view
 */
@property (retain, nonatomic, readonly) ITTCalDay *selectedDay;
/*
 * The selected date on calendar view
 */
@property (retain, nonatomic, readonly) NSDate *selectedDate;
/*
 * nil will be returned is allowsMultipleSelection is FALSE. 
 * Otherwise, an autorelease array of NSDate will be returned.
 */
@property (retain, nonatomic, readonly) NSArray *selectedDateArray;

- (void)nextMonth;
- (void)previousMonth;
- (void)addToView:(UIView *)view;
- (void)showInView:(UIView*)view;
- (void)hide;

- (ITTCalendarGridView*)dequeueCalendarGridViewWithIdentifier:(NSString*)identifier;

+ (id)viewFromNib;

@end
