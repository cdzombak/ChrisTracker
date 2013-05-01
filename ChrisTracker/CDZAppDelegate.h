#import <UIKit/UIKit.h>

@interface CDZAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, assign, readonly) BOOL appIsInForeground;

@end
