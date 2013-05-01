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
    CDZTrackerTableViewInfoSpeed = 0,
    CDZTrackerTableViewInfoHeading,
    CDZTrackerTableViewInfoLat,
    CDZTrackerTableViewInfoLon,
    CDZTrackerTableViewInfoNumRows
};

@interface CDZTrackerViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation CDZTrackerViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"ChrisTracker";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // TODO
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

    switch(indexPath.section) {
        case CDZTrackerTableViewSectionStatus:
            switch(indexPath.row) {
                case CDZTrackerTableViewStatusStartStopLogging:
                    cell.textLabel.text = @"Start/Stop Logging"; // TODO
                    cell.detailTextLabel.text = @"Last log date"; // TODO
                    break;
                case CDZTrackerTableViewStatusForceLog:
                    cell.textLabel.text = @"last log date"; // TODO
                    cell.detailTextLabel.text = @"Tap to track & log now";
                    break;
            }
            break;
        case CDZTrackerTableViewSectionInfo:
            switch(indexPath.row) {
                case CDZTrackerTableViewInfoSpeed:
                    cell.textLabel.text = @"mph";
                    cell.detailTextLabel.text = @"todo"; // TODO
                    break;
                case CDZTrackerTableViewInfoHeading:
                    cell.textLabel.text = @"Heading";
                    cell.detailTextLabel.text = @"todo"; // TODO
                    break;
                case CDZTrackerTableViewInfoLat:
                    cell.textLabel.text = @"Latitude";
                    cell.detailTextLabel.text = @"todo"; // TODO
                    break;
                case CDZTrackerTableViewInfoLon:
                    cell.textLabel.text = @"Longitude";
                    cell.detailTextLabel.text = @"todo"; // TODO
                    break;
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
            return @"Last Logged";
    }
    return nil;
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO
}

@end
