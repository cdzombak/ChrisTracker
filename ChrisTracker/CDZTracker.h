#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol CDZTrackerDelegate;

@interface CDZTracker : NSObject

@property (nonatomic, strong) id<CDZTrackerDelegate> delegate;
@property (nonatomic, readonly) BOOL isLocationTracking;

- (void)startLocationTracking;
- (void)stopLocationTracking;
- (void)forceLogLatestInfo;

// TODO battery monitoring callbacks

@end

@protocol CDZTrackerDelegate <NSObject>

- (void)tracker:(CDZTracker *)tracker didUpdateLocation:(CLLocation *)location;

@end
