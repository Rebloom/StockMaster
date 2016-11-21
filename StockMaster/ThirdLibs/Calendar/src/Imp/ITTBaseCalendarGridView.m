//
//  BaseCalendarGridView.m
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 itotemstudio. All rights reserved.
//

#import "ITTBaseCalendarGridView.h"
#import "CHNMacro.h"

@interface ITTBaseCalendarGridView()

@property (retain, nonatomic) IBOutlet UIButton *gridButton;

@end

@implementation ITTBaseCalendarGridView

@synthesize gridButton;

-(void)calendarGridViewDidSelectGrid:(id)sender
{
    
}

- (IBAction)onGridButtonTouched:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(calendarGridViewDidSelectGrid:)]) {
        [_delegate ittCalendarGridViewDidSelectGrid:self];
    }
}

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
- (void)select
{
    self.selected = TRUE;
    self.gridButton.selected = TRUE; 
    self.gridButton.userInteractionEnabled = FALSE;
}

- (void)deselect
{
    self.selected = FALSE;
    self.gridButton.selected = FALSE;
    self.gridButton.userInteractionEnabled = TRUE;    
}

- (void)layoutSubviews
{
    NSString *title = [NSString stringWithFormat:@"%d", (int)[_calDay getDay]];
    if (_selectedEanable) {
        self.gridButton.selected = self.selected;              
        [self.gridButton setTitleColor:MY_COLOR(122, 199, 122, 1) forState:UIControlStateNormal];
    }
    else {
        self.gridButton.selected = FALSE;
        [self.gridButton setTitleColor:MY_COLOR(233, 232, 231, 1) forState:UIControlStateNormal];
    }
    [self.gridButton setTitle:title forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    [self setNeedsLayout];
}

- (void)dealloc 
{
    [gridButton release];
    [super dealloc];
}
@end
