#import "CDZTrackerViewController.h"

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
@property (nonatomic, assign) BOOL currentlyTracking;

@end

@implementation CDZTrackerViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"ChrisTracker";
        self.currentlyTracking = NO;
    }
    return self;
}

- (void)tracker:(CDZTracker *)tracker didUpdateLocation:(CLLocation *)location
{
    NSParameterAssert(tracker == self.tracker);

    self.lastLocation = location;
    self.currentlyTracking = tracker.isLocationTracking;
    [self updateUi];
}

- (void)updateUi
{
    [self.tableView reloadData];
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSParameterAssert(tableView == self.tableView);
    return CDZTrackerTableViewNumSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSParameterAssert(tableView == self.tableView);
    switch(section) {
        case CDZTrackerTableViewSectionStatus:
            return CDZTrackerTableViewStatusNumRows;
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
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    switch(indexPath.section) {
        case CDZTrackerTableViewSectionStatus:
            switch(indexPath.row) {
                case CDZTrackerTableViewStatusStartStopLogging: {
                    cell.textLabel.text = self.currentlyTracking ? @"Tracking Now…" : @"Start Tracking";
                    cell.detailTextLabel.text = self.currentlyTracking ? @"Tap to stop tracking" : @"";
                    break;
                }
                case CDZTrackerTableViewStatusForceLog: {
                    NSString *lastLogDate = @"";
                    if (self.lastLocation) lastLogDate = [NSString stringWithFormat:@"Updated %@",
                                                          [NSDateFormatter localizedStringFromDate:self.lastLocation.timestamp
                                                                                         dateStyle:NSDateFormatterShortStyle
                                                                                         timeStyle:NSDateFormatterShortStyle]
                                                          ];
                    cell.textLabel.text = lastLogDate;
                    cell.detailTextLabel.text = @"Tap to track & log now";
                    break;
                }
            }
            break;
        case CDZTrackerTableViewSectionInfo:
            switch(indexPath.row) {
                case CDZTrackerTableViewInfoSpeed: {
                    cell.textLabel.text = @"Speed";
                    NSString *speedStr = @"";
                    if (self.lastLocation && !self.lastLocation.speed < 0) speedStr = [NSString stringWithFormat:@"%d mph", (int)self.lastLocation.speed];
                    cell.detailTextLabel.text = speedStr;
                    break;
                }
                case CDZTrackerTableViewInfoHeading: {
                    cell.textLabel.text = @"Heading";
                    NSString *courseStr = @"";
                    if (self.lastLocation && !self.lastLocation.course < 0) courseStr = [NSString stringWithFormat:@"%d°", (int)self.lastLocation.course];
                    cell.detailTextLabel.text = courseStr;
                    break;
                }
                case CDZTrackerTableViewInfoLocation: {
                    cell.textLabel.text = @"Location";
                    NSString *locStr = @"";
                    if (self.lastLocation) locStr = [NSString stringWithFormat:@"%0.3f, %0.3f",
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
            return nil;
        case CDZTrackerTableViewSectionInfo:
            return @"Last Logged Track";
    }
    return nil;
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO
}

#pragma mark Property overrides

- (void)setTracker:(CDZTracker *)tracker
{
    _tracker = tracker;
    self.currentlyTracking = tracker.isLocationTracking;
}

@end
