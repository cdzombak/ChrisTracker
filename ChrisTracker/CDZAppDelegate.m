#import "CDZAppDelegate.h"
#import "CDZTracker.h"
#import "CDZTrackerViewController.h"
#import "CDZWhereIsChrisAPIClient.h"
#import "AFNetworkActivityIndicatorManager.h"

@interface CDZAppDelegate () <CDZTrackerDelegate>

@property (nonatomic, strong) CDZTrackerViewController *viewController;
@property (nonatomic, assign, readwrite) BOOL appIsInForeground;

@property (nonatomic, strong) CDZTracker *tracker;
@property (nonatomic, strong) CLLocation *lastLocationUpdate;
@property (nonatomic, strong) NSTimer *minimumUpdateTimer;

@property (nonatomic, readonly) NSArray *ignoredErrorCodes;

@property (nonatomic, readonly) NSTimeInterval forceUpdateInterval;

@end

@implementation CDZAppDelegate

@synthesize ignoredErrorCodes = _ignoredErrorCodes;

#pragma mark Lifecycle/callbacks/notifications

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[CDZTrackerViewController alloc] init];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    [self.window makeKeyAndVisible];
    self.appIsInForeground = YES;

    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];

    [self setupTracker];
    [self setupUpdateTimer];

    UIDevice *device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(batteryLevelChanged:)
                                                 name:UIDeviceBatteryLevelDidChangeNotification
                                               object:device];

    return YES;
}

- (void)batteryLevelChanged:(NSNotification *)notification
{
    CGFloat batterylevel = [UIDevice currentDevice].batteryLevel;
    if (batterylevel <= 0.2 && batterylevel >= 0) {
        [self.tracker stopLocationTracking];
        [self displayBatteryWarning];
    }
}

- (void)updateTimerFired:(id)sender
{
    NSParameterAssert(sender == self.minimumUpdateTimer);

    if (!self.lastLocationUpdate || [self.lastLocationUpdate.timestamp timeIntervalSinceNow] < -self.forceUpdateInterval) {
        if (self.tracker.isLocationTracking) [self.tracker forceLogLatestInfo];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for
    // certain types of temporary interruptions (such as an incoming phone call or SMS message) or
    // when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates.
    // Games should use this method to pause the game.

    self.appIsInForeground = NO;

    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store
    // enough application state information to restore your application to its current state in
    // case it is terminated later.
    // If your application supports background execution, this method is called instead of
    // applicationWillTerminate: when the user quits.

    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

    NSLog(@"%s", __PRETTY_FUNCTION__);

    if (self.tracker.isLocationTracking) {
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        if (localNotif) {
            localNotif.alertBody = @"ChrisTracker has died and is no longer tracking you.";
            localNotif.alertAction = @"Reopen ChrisTracker to restart tracking";
            [application presentLocalNotificationNow:localNotif];
        }
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo
    // many of the changes made on entering the background.

    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive.
    // If the application was previously in the background, optionally refresh the user interface.

    self.appIsInForeground = YES;
    [self.viewController presentQueuedMessage];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];

    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [self.viewController presentMessage:@"Memory warning received"
                    withAppInForeground:self.appIsInForeground];

    NSLog(@"%s", __PRETTY_FUNCTION__);
}

#pragma mark Initialization

- (void)setupTracker
{
    self.tracker = [[CDZTracker alloc] init];
    self.tracker.delegate = self;

    CGFloat batterylevel = [UIDevice currentDevice].batteryLevel;
    if (batterylevel <= 0.2 && batterylevel >= 0) {
        [self displayBatteryWarning];
    }

    self.viewController.tracker = self.tracker;
}

- (void)setupUpdateTimer
{
    // ensure location is updated at least every 3 minutes while tracking
    if (!self.minimumUpdateTimer) {
        self.minimumUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:self.forceUpdateInterval
                                                                   target:self
                                                                 selector:@selector(updateTimerFired:)
                                                                 userInfo:nil
                                                                  repeats:YES
                                   ];
    }
}

#pragma mark UI and Notifications

- (void)displayBatteryWarning
{
    [self.viewController presentMessage:@"Tracking is disabled while battery < 20%"
                    withAppInForeground:self.appIsInForeground];
}

#pragma mark CDZTrackerDelegate methods

- (void)tracker:(CDZTracker *)tracker didUpdateLocation:(CLLocation *)location
{
    NSParameterAssert(tracker == self.tracker);
    
    [[CDZWhereIsChrisAPIClient sharedClient] track:location
                                           success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                               [self.viewController tracker:tracker didUpdateLocation:location];
                                               self.lastLocationUpdate = location;
                                           }
                                           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                               if ([self.ignoredErrorCodes containsObject:@(error.code)]) return; // really should check domain and code but #YOLO
                                               [self.viewController presentMessage:[error localizedDescription]
                                                               withAppInForeground:self.appIsInForeground];
                                           }
     ];
}

#pragma mark Property overrides

- (NSArray *)ignoredErrorCodes
{
    // no data when call is active:
    // kCFURLErrorCallIsActive = -1019,

    if (!_ignoredErrorCodes) {
        _ignoredErrorCodes = @[ @(-1019) ];
    }
    return _ignoredErrorCodes;
}

- (NSTimeInterval)forceUpdateInterval
{
    return 3.0 * 60.0; // 3 minutes
}

@end
