//
//  CalendarScrollView.h
//  ZHJCalendar
//
//  Created by huajian zhou on 12-5-21.
//  Copyright (c) 2012年 itotemstudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ITTCalendarScrollViewDelegate;

@interface ITTCalendarScrollView : UIScrollView
{
    id<ITTCalendarScrollViewDelegate> _calendarDelegate;
}

@property (nonatomic, assign) id<ITTCalendarScrollViewDelegate> calendarDelegate;

@end

@protocol ITTCalendarScrollViewDelegate <NSObject>

@optional
- (void)calendarSrollViewTouchesBegan:(ITTCalendarScrollView*)calendarScrollView touches:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)calendarSrollViewTouchesMoved:(ITTCalendarScrollView*)calendarScrollView touches:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)calendarSrollViewTouchesEnded:(ITTCalendarScrollView*)calendarScrollView touches:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)calendarSrollViewTouchesCancelled:(ITTCalendarScrollView*)calendarScrollView touches:(NSSet *)touches withEvent:(UIEvent *)event;

@end
