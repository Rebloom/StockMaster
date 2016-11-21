//
//  GFTextField.m
//  StockMaster
//
//  Created by Rebloom on 14-8-21.
//  Copyright (c) 2014年 Rebloom. All rights reserved.
//

#import "GFTextField.h"
#import "CHNMacro.h"
#import "NSString+UIColor.h"

@implementation GFTextField
@synthesize placeHolderColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(CGRect)placeholderRectForBounds:(CGRect)bounds
{
    CGRect inset = CGRectZero;
    if(placeHolderColor)
    {
        inset = CGRectMake(bounds.origin.x+20, bounds.origin.y+bounds.size.height/2-7, bounds.size.width-20 , bounds.size.height);
    }
    else
    {
        inset = CGRectMake(bounds.origin.x, bounds.origin.y+beginX, bounds.size.width, bounds.size.height);
    }
    return inset;
}

-(CGRect)textRectForBounds:(CGRect)bounds
{
    CGRect inset = CGRectZero;
    if (placeHolderColor)
    {
        inset = CGRectMake(bounds.origin.x+20, bounds.origin.y, bounds.size.width-20 , bounds.size.height);
    }
    else
    {
        inset = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width , bounds.size.height);
    }
    return inset;
}

-(CGRect)editingRectForBounds:(CGRect)bounds
{
    CGRect inset = CGRectZero;
    if (placeHolderColor)
    {
        inset = CGRectMake(bounds.origin.x+20, bounds.origin.y, bounds.size.width-20 , bounds.size.height);
    }
    else
    {
        inset = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
    }
    return inset;
}

- (void)drawPlaceholderInRect:(CGRect)rect
{
    if (placeHolderColor)
    {
        [kFontColorC setFill];
    }
    else
    {
        [[UIColor whiteColor] setFill];
    }
    [self.placeholder drawInRect:rect withFont:NormalFontWithSize(14)];

}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
