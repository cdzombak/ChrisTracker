#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CDZTracker.h"

@interface CDZTrackerViewController : UITableViewController

@property (nonatomic, strong) CDZTracker *tracker;

// Designated initializer
- (id)init;

// called by somebody when the given location has been posted to the server
- (void)tracker:(CDZTracker *)tracker didUpdateLocation:(CLLocation *)location;

- (void)presentQueuedMessage;
- (void)presentMessage:(NSString *)message withAppInForeground:(BOOL)inForeground;

@end
