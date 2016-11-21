#import "TKAlertCenter.h"
#import "UIView+TKCategory.h"
#import "CHNMacro.h"

#define kTagAlertViewFrame  CGRectMake(25, screenHeight/2-40, 270, 80)

@interface TKAlertCenter()
@property (nonatomic, copy) NSString * message;
@property (nonatomic, assign) NSInteger type;
@end


@interface TKAlertView : UIView {
    UILabel * textLabel;
    UIImageView * backImage;
}

- (id) init;
- (void) setMessageText:(NSString*)str withType:(NSInteger)type;

@end



@implementation TKAlertCenter
@synthesize message;
@synthesize type;

+ (TKAlertCenter*) defaultCenter {
    static TKAlertCenter *defaultCenter = nil;
    if (!defaultCenter) {
        defaultCenter = [[TKAlertCenter alloc] init];
    }
    return defaultCenter;
}

- (void)cancelAlertView
{
    alertView.hidden = YES;
}

- (id) init
{
    if(!(self=[super init])) return nil;
    alertView = [[TKAlertView alloc] init];
    active = NO;
    alertFrame = CGRectMake((screenWidth-120)/2, screenHeight/2-60, 120, 120);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationWillChange:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    
    return self;
}

- (void) showAlerts
{
    active = YES;
    
    alertView.transform = CGAffineTransformIdentity;
    alertView.alpha = 0;
    [[UIApplication sharedApplication].keyWindow addSubview:alertView];
    
    [alertView setMessageText:self.message withType:self.type];
    
    alertView.center = CGPointMake(alertFrame.origin.x+alertFrame.size.width/2, alertFrame.origin.y+alertFrame.size.height/2);
    
    UIInterfaceOrientation o = [UIApplication sharedApplication].statusBarOrientation;
    CGFloat degrees = 0;
    if(o == UIInterfaceOrientationLandscapeLeft ) degrees = -90;
    else if(o == UIInterfaceOrientationLandscapeRight ) degrees = 90;
    else if(o == UIInterfaceOrientationPortraitUpsideDown) degrees = 180;
    alertView.transform = CGAffineTransformMakeRotation(degrees * M_PI / 180);
    alertView.transform = CGAffineTransformScale(alertView.transform, 2, 2);
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.15];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationStep2)];
    
    alertView.backgroundColor = [UIColor clearColor];
    alertView.transform = CGAffineTransformMakeRotation(degrees * M_PI / 180);
    alertView.frame = CGRectMake((screenWidth -alertView.frame.size.width)/2, (int)alertView.frame.origin.y, alertView.frame.size.width, alertView.frame.size.height);
    alertView.alpha = 1;
    
    [UIView commitAnimations];
}

- (void) animationStep2
{
    [UIView beginAnimations:nil context:nil];
    double duration = 1.50;
    [UIView setAnimationDelay:duration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationStep3)];
    
    UIInterfaceOrientation o = [UIApplication sharedApplication].statusBarOrientation;
    CGFloat degrees = 0;
    if(o == UIInterfaceOrientationLandscapeLeft ) degrees = -90;
    else if(o == UIInterfaceOrientationLandscapeRight ) degrees = 90;
    else if(o == UIInterfaceOrientationPortraitUpsideDown) degrees = 180;
    alertView.transform = CGAffineTransformMakeRotation(degrees * M_PI / 180);
    alertView.transform = CGAffineTransformScale(alertView.transform, 0.5, 0.5);
    
    alertView.alpha = 0;
    [UIView commitAnimations];
}

- (void) animationStep3
{
    [alertView removeFromSuperview];
    active = NO;
}

- (void)postAlertWithMessage:(NSString *)_message withType:(NSInteger)_type
{
    if (active)
    {
        return;
    }
    self.message = _message;
    self.type = _type;
    [self showAlerts];
}

CGRect subtractRect(CGRect wf,CGRect kf){
    if(!CGPointEqualToPoint(CGPointZero,kf.origin)){
        
        if(kf.origin.x>0) kf.size.width = kf.origin.x;
        if(kf.origin.y>0) kf.size.height = kf.origin.y;
        kf.origin = CGPointZero;
        
    }else{

        kf.origin.x = fabs(kf.size.width - wf.size.width);
        kf.origin.y = fabs(kf.size.height -  wf.size.height);

        if(kf.origin.x > 0){
            CGFloat temp = kf.origin.x;
            kf.origin.x = kf.size.width;
            kf.size.width = temp;
        }else if(kf.origin.y > 0){
            CGFloat temp = kf.origin.y;
            kf.origin.y = kf.size.height;
            kf.size.height = temp;
        }
        
    }
    return CGRectIntersection(wf, kf);
}

- (void) keyboardWillAppear:(NSNotification *)notification {
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 3.2) {
        NSDictionary *userInfo = [notification userInfo];
        NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect kf = [aValue CGRectValue];
        CGRect wf = [UIApplication sharedApplication].keyWindow.bounds;
        
        [UIView beginAnimations:nil context:nil];
        alertFrame = subtractRect(wf,kf);
        alertView.center = CGPointMake(alertFrame.origin.x+alertFrame.size.width/2, alertFrame.origin.y+alertFrame.size.height/2);
        
        [UIView commitAnimations];
    }
}
- (void) keyboardWillDisappear:(NSNotification *) notification
{
    alertFrame = kTagAlertViewFrame;
}
- (void) orientationWillChange:(NSNotification *) notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSNumber *v = [userInfo objectForKey:UIApplicationStatusBarOrientationUserInfoKey];
    UIInterfaceOrientation o = [v intValue];
    
    CGFloat degrees = 0;
    if(o == UIInterfaceOrientationLandscapeLeft ) degrees = -90;
    else if(o == UIInterfaceOrientationLandscapeRight ) degrees = 90;
    else if(o == UIInterfaceOrientationPortraitUpsideDown) degrees = 180;
    
    [UIView beginAnimations:nil context:nil];
    alertView.transform = CGAffineTransformMakeRotation(degrees * M_PI / 180);
    alertView.frame = CGRectMake((int)alertView.frame.origin.x, (int)alertView.frame.origin.y, (int)alertView.frame.size.width, (int)alertView.frame.size.height);
    [UIView commitAnimations];
    
}

@end

@implementation TKAlertView

- (id) init
{
    if(!(self = [super initWithFrame:kTagAlertViewFrame]))
        return nil;
    
    backImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
    backImage.image = [UIImage imageNamed:@"icon_alert_right"];
    [self addSubview:backImage];
    
    textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 120, 80)];
    textLabel.numberOfLines = 2;
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.font = NormalFontWithSize(14);
    textLabel.textColor = [UIColor whiteColor];
    [self addSubview:textLabel];
    
    return self;
}

- (void)adjust
{
    self.bounds = CGRectMake(0, 0, 120, 120);
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void) setMessageText:(NSString*)str withType:(NSInteger)type
{
    textLabel.text = str;
    if (type == ALERTTYPESUCCESS)
    {
        textLabel.textColor = [UIColor whiteColor];
    }
    [self adjust];
}




@end