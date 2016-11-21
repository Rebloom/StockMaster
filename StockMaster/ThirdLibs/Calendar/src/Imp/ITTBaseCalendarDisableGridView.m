//
//  BaseCalendarDisableGridView.m
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 itotemstudio. All rights reserved.
//

#import "ITTBaseCalendarDisableGridView.h"

@interface ITTBaseCalendarDisableGridView()

@property (retain, nonatomic) IBOutlet UIButton *gridButton;

@end

@implementation ITTBaseCalendarDisableGridView

@synthesize gridButton;

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.gridButton.userInteractionEnabled = NO;
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
}

- (void)deselect
{
    self.selected = FALSE;
    self.gridButton.selected = FALSE;
}

- (void)layoutSubviews
{
    NSString *title = [NSString stringWithFormat:@"%d", (int)[_calDay getDay]];
    [self.gridButton setTitle:title forState:UIControlStateNormal];
    self.gridButton.selected = self.selected;    
}

- (void)dealloc 
{
    [gridButton release];
    [super dealloc];
}
@end
