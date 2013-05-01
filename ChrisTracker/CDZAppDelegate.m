#import "CDZAppDelegate.h"
#import "CDZTracker.h"
#import "CDZTrackerViewController.h"
#import "CDZWhereIsChrisAPIClient.h"
#import "AFNetworkActivityIndicatorManager.h"

@interface CDZAppDelegate () <CDZTrackerDelegate>

@property (strong, nonatomic) CDZTrackerViewController *viewController;
@property (strong, nonatomic) CDZTracker *tracker;

@end

@implementation CDZAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[CDZTrackerViewController alloc] init];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    [self.window makeKeyAndVisible];

    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];

    [self setupTracker];

    NSLog(@"%s", __PRETTY_FUNCTION__);
    return YES;
}

- (void)setupTracker
{
    self.tracker = [[CDZTracker alloc] init];
    self.tracker.delegate = self;
    [self.tracker startLocationTracking];
    self.viewController.tracker = self.tracker;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for
    // certain types of temporary interruptions (such as an incoming phone call or SMS message) or
    // when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates.
    // Games should use this method to pause the game.

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
            localNotif.alertAction = @"Open ChrisTracker to restart tracking";
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

    NSLog(@"%s", __PRETTY_FUNCTION__);
}

#pragma mark CDZTrackerDelegate methods

- (void)tracker:(CDZTracker *)tracker didUpdateLocation:(CLLocation *)location
{
    NSParameterAssert(tracker == self.tracker);
    
    [[CDZWhereIsChrisAPIClient sharedClient] track:location success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.viewController tracker:tracker didUpdateLocation:location];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // TODO handle error
        NSLog(@"%@", [error localizedDescription]);
    }];
}

@end
