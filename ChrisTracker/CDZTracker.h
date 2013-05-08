#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol CDZTrackerDelegate;

@interface CDZTracker : NSObject

@property (nonatomic, strong) id<CDZTrackerDelegate> delegate;
@property (nonatomic, readonly) BOOL isLocationTracking;

- (void)startLocationTracking;
- (void)stopLocationTracking;
- (void)forceLogLatestInfo;

@end

@protocol CDZTrackerDelegate <NSObject>

- (void)tracker:(CDZTracker *)tracker didUpdateLocation:(CLLocation *)location;

@optional

- (void)tracker:(CDZTracker *)tracker didEncounterError:(NSError *)error;

@end
