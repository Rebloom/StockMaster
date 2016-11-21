//
//  ITTCalendarGridView.h
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 itotemstudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ITTCalDay.h"

@protocol ITTCalendarGridViewDelegate;

@interface ITTCalendarGridView : UIView
{
    BOOL        _selected;
    BOOL        _selectedEanable;
    
    NSUInteger  _row;
    NSUInteger  _column;
    
    NSString    *_identifier;
    
    ITTCalDay   *_calDay;
    
    id<ITTCalendarGridViewDelegate> _delegate;
}

@property (nonatomic, assign) id<ITTCalendarGridViewDelegate> delegate;

@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) BOOL selectedEanable;

@property (nonatomic, assign) NSUInteger row;
@property (nonatomic, assign) NSUInteger column;

@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) ITTCalDay *calDay;

- (void)select;
- (void)deselect;

+ (ITTCalendarGridView*) viewFromNib; 

+ (ITTCalendarGridView*) viewFromNibWithIdentifier:(NSString*)identifier; 

@end

@protocol ITTCalendarGridViewDelegate <NSObject>
@optional
- (void)ittCalendarGridViewDidSelectGrid:(ITTCalendarGridView*)gridView;
@end
