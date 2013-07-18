#import "CDZTrackerViewController.h"
#import <MapKit/MapKit.h>

typedef NS_ENUM(NSUInteger, CDZTrackerTableViewSections) {
    CDZTrackerTableViewSectionStatus = 0,  // displays "Start/Stop Logging" + secondary "currently logging"; then "last log date" + secondary "log now"
    CDZTrackerTableViewSectionInfo,        // displays current speed, heading, lat, lon. tapping any -> map.
    CDZTrackerTableViewNumSections
};

typedef NS_ENUM(NSUInteger, CDZTrackerTableViewStatusRows) {
    CDZTrackerTableViewStatusStartStopLogging = 0,
    CDZTrackerTableViewStatusForceLog,
    CDZTrackerTableViewStatusNumRows
};

typedef NS_ENUM(NSUInteger, CDZTrackerTableViewInfoRows) {
    CDZTrackerTableViewInfoLocation = 0,
    CDZTrackerTableViewInfoSpeed,
    CDZTrackerTableViewInfoHeading,
    CDZTrackerTableViewInfoAccuracy,
    CDZTrackerTableViewInfoNumRows
};

@interface CDZTrackerViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) CLLocation *lastLocation;
@property (nonatomic, strong) NSString *queuedMessageToPresent;

@end

@implementation CDZTrackerViewController

#pragma mark Initialization/lifecycle

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
#if !LAUNCH_IMAGE_MODE
        self.title = @"ChrisTracker";
#endif
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navBarDoubleTapped:)];
    gr.numberOfTapsRequired = 2;
    [self.navigationController.navigationBar addGestureRecognizer:gr];

#if LAUNCH_IMAGE_MODE
    UIImage *arrowImage = [UIImage imageNamed:@"arrow"];
    UIImageView *v = [[UIImageView alloc] initWithImage:arrowImage];
    [self.view addSubview:v];
    v.frame = CGRectMake(self.view.bounds.size.width/2-arrowImage.size.width/2-10, 70, arrowImage.size.width, arrowImage.size.height);
#endif
}

#pragma mark Tracker callbacks

- (void)tracker:(CDZTracker *)tracker didUpdateLocation:(CLLocation *)location
{
    NSParameterAssert(tracker == self.tracker);

    self.lastLocation = location;
    [self.tableView reloadData];
}

#pragma mark UI Actions

- (void)navBarDoubleTapped:(id)sender
{
    [self presentMessage:@"NavBar double-tapped" withAppInForeground:NO];
}

- (void)openMapForLocation:(CLLocation *)location
{
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:location.coordinate
                                                   addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];

    NSString *name = [NSDateFormatter localizedStringFromDate:location.timestamp
                                                    dateStyle:NSDateFormatterShortStyle
                                                    timeStyle:NSDateFormatterShortStyle];
    
    CGFloat speedMph = location.speed * ONE_METER_SECOND_IN_MPH;
    if (speedMph > 1) {
        name = [NSString stringWithFormat:@"%@: %d° at %d mph", name, (int)round(location.course), (int)round(speedMph)];
    }
    
    mapItem.name = name;

    [mapItem openInMapsWithLaunchOptions:nil];
}

#pragma mark Notification/Alert Management

- (void)presentMessage:(NSString *)message withAppInForeground:(BOOL)inForeground
{
    self.queuedMessageToPresent = message;
    
    if (inForeground) {
        [self presentQueuedMessage];
    } else {
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        if (localNotif) {
            localNotif.alertBody = message;
            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
        }
    }
}

- (void)presentQueuedMessage
{
    if (!self.queuedMessageToPresent) return;

    [[[UIAlertView alloc] initWithTitle:nil
                                message:self.queuedMessageToPresent
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil]
     show];

    self.queuedMessageToPresent = nil;
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSParameterAssert(tableView == self.tableView);
#if LAUNCH_IMAGE_MODE
    return 0;
#endif

    return CDZTrackerTableViewNumSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSParameterAssert(tableView == self.tableView);
#if LAUNCH_IMAGE_MODE
    return 0;
#endif

    switch(section) {
        case CDZTrackerTableViewSectionStatus:
            return (self.tracker.isLocationTracking) ? CDZTrackerTableViewStatusNumRows : 1; // hack
        case CDZTrackerTableViewSectionInfo:
            return CDZTrackerTableViewInfoNumRows;
        default:
            NSLog(@"Unknown section %d in %s", section, __PRETTY_FUNCTION__);
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSParameterAssert(tableView == self.tableView);

    static NSString * CellIdentifiers[CDZTrackerTableViewNumSections] = {
        @"UITableViewCellStyleSubtitle",
        @"UITableViewCellStyleValue2",
    };
    UITableViewCellStyle style = indexPath.section == CDZTrackerTableViewSectionStatus ? UITableViewCellStyleSubtitle : UITableViewCellStyleValue2;
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:CellIdentifiers[indexPath.section]];

    switch(indexPath.section) {
        case CDZTrackerTableViewSectionStatus:
            cell.accessoryType = UITableViewCellAccessoryNone;
            switch(indexPath.row) {
                case CDZTrackerTableViewStatusStartStopLogging: {
                    cell.textLabel.text = self.tracker.isLocationTracking ? @"Tracking Now…" : @"Start Tracking";
                    cell.detailTextLabel.text = self.tracker.isLocationTracking ? @"Tap to stop tracking" : @"";
                    break;
                }
                case CDZTrackerTableViewStatusForceLog: {
                    NSString *lastLogDate = @"";
                    if (self.lastLocation) lastLogDate = [NSString stringWithFormat:@"Last Track: %@",
                                                          [NSDateFormatter localizedStringFromDate:self.lastLocation.timestamp
                                                                                         dateStyle:NSDateFormatterShortStyle
                                                                                         timeStyle:NSDateFormatterShortStyle]
                                                          ];
                    cell.textLabel.text = lastLogDate;
                    cell.detailTextLabel.text = @"Tap to track now";
                    break;
                }
            }
            break;
        case CDZTrackerTableViewSectionInfo:
            cell.accessoryType = self.lastLocation ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;

            switch(indexPath.row) {
                case CDZTrackerTableViewInfoSpeed: {
                    cell.textLabel.text = @"Speed";
                    NSString *speedStr = @"";
                    if (self.lastLocation && !(self.lastLocation.speed < 0)) speedStr = [NSString stringWithFormat:@"%d mph", (int)(self.lastLocation.speed*ONE_METER_SECOND_IN_MPH)];
                    cell.detailTextLabel.text = speedStr;
                    break;
                }
                case CDZTrackerTableViewInfoHeading: {
                    cell.textLabel.text = @"Heading";
                    NSString *courseStr = @"";
                    if (self.lastLocation && !(self.lastLocation.course < 0)) courseStr = [NSString stringWithFormat:@"%d°", (int)self.lastLocation.course];
                    cell.detailTextLabel.text = courseStr;
                    break;
                }
                case CDZTrackerTableViewInfoLocation: {
                    cell.textLabel.text = @"Location";
                    NSString *locStr = @"";
                    if (self.lastLocation) locStr = [NSString stringWithFormat:@"%0.4f, %0.4f",
                                                     self.lastLocation.coordinate.latitude,
                                                     self.lastLocation.coordinate.longitude
                                                    ];
                    cell.detailTextLabel.text = locStr;
                    break;
                }
                case CDZTrackerTableViewInfoAccuracy: {
                    cell.textLabel.text = @"Accuracy";
                    NSString *accStr = @"";
                    if (self.lastLocation) accStr = [NSString stringWithFormat:@"%d m",
                                                     (int)round(self.lastLocation.horizontalAccuracy)];
                    cell.detailTextLabel.text = accStr;
                    break;
                }
            }
            break;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSParameterAssert(tableView == self.tableView);
    
    switch(section) {
        case CDZTrackerTableViewSectionStatus:
            return @"Control";
        case CDZTrackerTableViewSectionInfo:
            return @"Last Logged Track";
    }
    return nil;
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSParameterAssert(tableView == self.tableView);

    if (indexPath.section == CDZTrackerTableViewSectionInfo) {
        if (self.lastLocation) [self openMapForLocation:self.lastLocation];
    } else {
        switch (indexPath.row) {
            case CDZTrackerTableViewStatusStartStopLogging:
                if (self.tracker.isLocationTracking) [self.tracker stopLocationTracking];
                else [self.tracker startLocationTracking];
                [tableView reloadSections:[NSIndexSet indexSetWithIndex:CDZTrackerTableViewSectionStatus]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case CDZTrackerTableViewStatusForceLog:
                if (!self.tracker.isLocationTracking) [self.tracker startLocationTracking];
                else [self.tracker forceLogLatestInfo];
                break;
        }
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
