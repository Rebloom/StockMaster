//
//  CalendarScrollView.m
//  ZHJCalendar
//
//  Created by huajian zhou on 12-5-21.
//  Copyright (c) 2012年 itotemstudio. All rights reserved.
//

#import "ITTCalendarScrollView.h"

@implementation ITTCalendarScrollView

@synthesize calendarDelegate = _calendarDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.multipleTouchEnabled = TRUE;           
}

- (void)dealloc
{
    _calendarDelegate = nil;
    [super dealloc];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    if (_calendarDelegate && [_calendarDelegate respondsToSelector:@selector(calendarSrollViewTouchesBegan:touches:withEvent:)]) {
        [_calendarDelegate calendarSrollViewTouchesBegan:self touches:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    if (_calendarDelegate && [_calendarDelegate respondsToSelector:@selector(calendarSrollViewTouchesMoved:touches:withEvent:)]) {
        [_calendarDelegate calendarSrollViewTouchesMoved:self touches:touches withEvent:event];
    }    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    if (_calendarDelegate && [_calendarDelegate respondsToSelector:@selector(calendarSrollViewTouchesEnded:touches:withEvent:)]) {
        [_calendarDelegate calendarSrollViewTouchesEnded:self touches:touches withEvent:event];
    }    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];   
    if (_calendarDelegate && [_calendarDelegate respondsToSelector:@selector(calendarSrollViewTouchesCancelled:touches:withEvent:)]) {
        [_calendarDelegate calendarSrollViewTouchesCancelled:self touches:touches withEvent:event];
    }    
}
@end
