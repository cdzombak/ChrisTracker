#import "CDZTracker.h"

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

        UIDevice *device = [UIDevice currentDevice];
        device.batteryMonitoringEnabled = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(batteryChanged:)
                                                     name:UIDeviceBatteryStateDidChangeNotification
                                                   object:device];
    }
    return self;
}

- (void)batteryChanged:(NSNotification *)notification
{
    [self configureLocationManagerForCurrentBatteryState];
}

- (void)startLocationTracking
{
    self.locationManager.delegate = self;
    [self configureLocationManagerForCurrentBatteryState];
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

- (void)configureLocationManagerForCurrentBatteryState
{
    UIDeviceBatteryState batteryState = [[UIDevice currentDevice] batteryState];
    if (batteryState == UIDeviceBatteryStateUnknown || batteryState == UIDeviceBatteryStateUnplugged) {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = 2*TENTH_MILE_IN_METERS;
    } else { // charging || full
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        self.locationManager.distanceFilter = TENTH_MILE_IN_METERS;
    }
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
