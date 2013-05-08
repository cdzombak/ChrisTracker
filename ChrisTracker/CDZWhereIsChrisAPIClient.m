#import "CDZWhereIsChrisAPIClient.h"

@interface CDZWhereIsChrisAPIClient ()

@property (nonatomic, strong) NSString *apiKey;

@end

@implementation CDZWhereIsChrisAPIClient

+ (CDZWhereIsChrisAPIClient *)sharedClient
{
    static CDZWhereIsChrisAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[CDZWhereIsChrisAPIClient alloc] init];
    });

    return _sharedClient;
}

- (id)init
{
    self = [super initWithBaseURL:[NSURL URLWithString:@"http://whereischris.me"]];
    if (self) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"apikey" ofType:@"plist"];
        NSDictionary *keyDict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        self.apiKey = keyDict[@"key"];
    }
    return self;
}


- (void)track:(CLLocation *)location
      success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    double measuredSpeedMph = location.speed * ONE_METER_SECOND_IN_MPH;

    NSDictionary *params =
    @{
        @"key": self.apiKey,
        @"lat": @(location.coordinate.latitude),
        @"lon": @(location.coordinate.longitude),
        @"speed": @(measuredSpeedMph),
        @"speed_unit": @"mph",
        @"heading": @(location.course)
    };
    
    [self postPath:@"post.php" parameters:params success:success failure:failure];
}

@end
