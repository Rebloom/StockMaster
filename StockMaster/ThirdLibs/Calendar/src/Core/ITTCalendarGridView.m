//
//  ITTCalendarGridView.m
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 itotemstudio. All rights reserved.
//

#import "ITTCalendarGridView.h"

@implementation ITTCalendarGridView

@synthesize row = _row;
@synthesize column = _column;
@synthesize selected = _selected;
@synthesize calDay = _calDay;
@synthesize delegate = _delegate;
@synthesize identifier = _identifier;
@synthesize selectedEanable = _selectedEanable;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
    [_identifier release];
    _identifier = nil;
    _delegate = nil;
    [_calDay release];
    _calDay = nil;
    [super dealloc];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    _selected = FALSE;
    _selectedEanable = TRUE;
}

- (void)select
{
}

- (void)deselect
{
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */
+ (ITTCalendarGridView*) viewFromNib
{
    return [[[[[NSBundle mainBundle] loadNibNamed:[[self class] description] owner:self options:nil] objectAtIndex:0] retain] autorelease];
}

+ (ITTCalendarGridView*) viewFromNibWithIdentifier:(NSString*)identifier
{
    ITTCalendarGridView *gridView = [[[[[NSBundle mainBundle] loadNibNamed:[[self class] description] owner:self options:nil] objectAtIndex:0] retain] autorelease];
    gridView.identifier = identifier;
    return gridView;
}
@end
