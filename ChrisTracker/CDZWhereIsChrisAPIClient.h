#import "AFHTTPClient.h"
#import <CoreLocation/CoreLocation.h>

@interface CDZWhereIsChrisAPIClient : AFHTTPClient

+ (CDZWhereIsChrisAPIClient *)sharedClient;

- (void)track:(CLLocation *)location
      success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
