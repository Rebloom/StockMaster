#import "LineChartView.h"
#import "NSString+UIColor.h"
#import "CHNMacro.h"
@interface LineChartView()
{
    CALayer *linesLayer;
    UIView *popView;
    UILabel *disLabel;
}
@end
@implementation LineChartView
@synthesize array;
@synthesize flag;
-(void)dealloc
{
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        linesLayer = [[CALayer alloc] init];
        linesLayer.masksToBounds = YES;
        linesLayer.contentsGravity = kCAGravityLeft;
        linesLayer.backgroundColor = [[UIColor whiteColor] CGColor];
        [self.layer addSublayer:linesLayer];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [self setClearsContextBeforeDrawing: YES];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth (context, 0.5f);
    if (flag == 1 ||flag ==3 )
    {
        CGContextSetStrokeColorWithColor(context, kRedColor.CGColor);
        [KNewColorRed2 setFill];
    }
    else if (flag == 2)
    {
        CGContextSetStrokeColorWithColor(context, kGreenColor.CGColor);
        [KNewColorGreen2 setFill];
    }
    CGContextMoveToPoint(context, -5, 350);
    if (array.count > 3)
    {
        for (int i = 0; i < array.count; i++)
        {
            NSValue *pointValue = array[i];
            CGPoint  point      = [pointValue CGPointValue];
            CGContextAddLineToPoint(context, point.x,point.y);
        }
        CGContextAddLineToPoint(context, 321, screenWidth);
        CGContextAddLineToPoint(context, -5, screenWidth);
        
        CGContextDrawPath(context, kCGPathFillStroke);
    }
    
}
@end
