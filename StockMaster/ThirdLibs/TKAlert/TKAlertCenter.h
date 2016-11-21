
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum ALERTTYPE
{
    ALERTTYPESUCCESS = 1,
    ALERTTYPEERROR
}_ALERTTYPE;

@class TKAlertView;

@interface TKAlertCenter : NSObject {
    NSString * message;
	BOOL active;
	TKAlertView *alertView;
	CGRect alertFrame;
    NSInteger type;
}

+ (TKAlertCenter*) defaultCenter;

- (void)postAlertWithMessage:(NSString *)message withType:(NSInteger)type;

-(void)cancelAlertView;

@end





