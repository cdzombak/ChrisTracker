#import "CDZTracker.h"

#define TENTH_MILE_IN_METERS ((CLLocationDistance) 160.934)

@interface CDZTracker () <CLLocationManagerDelegate>

@property (nonatomic, readonly, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSDate *lastUpdateReceived;
@property (nonatomic, readwrite, assign) BOOL isLocationTracking;

@end

@implementation CDZTracker

@synthesize locationManager = _locationManager;

- (id)init
{
    self = [super init];
    if (self) {
        self.isLocationTracking = NO;
    }
    return self;
}


- (void)startLocationTracking
{
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation; // TODO change on batt to kCLLocationAccuracyBest
    self.locationManager.distanceFilter = TENTH_MILE_IN_METERS; // TODO change on batt to 2 tenth mile
    [self.locationManager startUpdatingLocation];
    self.isLocationTracking = YES;
}

- (void)stopLocationTracking
{
    [self.locationManager stopUpdatingLocation];
    self.isLocationTracking = NO;
    self.lastUpdateReceived = nil;
}

- (void)forceLogLatestInfo
{
    [self.locationManager stopUpdatingLocation];
    [self.locationManager startUpdatingLocation];
}

#pragma mark CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];

    NSDate *eventDate = location.timestamp;
    if ([eventDate compare:self.lastUpdateReceived] != NSOrderedDescending) return;

    [self.delegate tracker:self didUpdateLocation:location];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(tracker:didEncounterError:)]) {
        [self.delegate tracker:self didEncounterError:error];
    }
}

#pragma mark Property overrides

- (CLLocationManager *)locationManager
{
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    return _locationManager;
}

- (NSDate *)lastUpdateReceived
{
    if (_lastUpdateReceived == nil) {
        _lastUpdateReceived = [NSDate distantPast];
    }
    return _lastUpdateReceived;
}

@end
