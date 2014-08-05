#import <CoreLocation/CoreLocation.h>
#import "KingTidesService.h"
#import "NSDate+Formatting.h"
#import "AFURLRequestSerialization.h"
#import "AFHTTPSessionManager.h"
#import "NSData+Base64.h"
#import "Upload.h"
#import "FBTweakInline.h"


#define statusCode_sucess 200
#define statusCode_resouceNotFind 404
#define tenM 10*1024*1024
#define fiveM 5*1024*1024

@interface KingTidesService()
@property(nonatomic, strong) AFHTTPSessionManager *manager;
@property(nonatomic, strong) NSString *endPoint;
@end

@implementation KingTidesService

- (id)init {
  if (self = [super init])
  {
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.endPoint = FBTweakValue(@"Serverside", @"Endpoints", @"WKT", @"http://kingtides-api-env-fubbpjhd29.elasticbeanstalk.com");
    NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:tenM
                                                        diskCapacity:fiveM
                                                            diskPath:nil];
      
    [config setURLCache:cache];
    self.manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:self.endPoint] sessionConfiguration:config];
    self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
      
      
    
  }
  return self;
}

+ (KingTidesService *)sharedService {
  static KingTidesService *_sharedClient = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedClient = [[KingTidesService alloc] init];
  });

  return _sharedClient;
}

- (void) uploadPhoto:(Upload *)upload
             success:(UploadSuccessBlock)success
             failure:(FailureBlock)failure
{
  NSDictionary *JSONDictionary = [MTLJSONAdapter JSONDictionaryFromModel:upload];
  [self.manager POST:@"upload" parameters:JSONDictionary
             success:^(NSURLSessionDataTask *operation, id responseObject)
            {
                NSLog(@"JSON: %@", responseObject);
                
                success();
            }
             failure:^(NSURLSessionDataTask *operation, NSError *error)
            {
                NSLog(@"Error: %@", error);
                failure(error);
            }
   ];
}

- (void)retrieveTideData:(void (^)(id retrievedData))success failure: (void (^)(NSError *error))failure
{
    
  [self.manager GET:@"tides" parameters:nil
            success:^(NSURLSessionDataTask *operation, id responseObject)
            {
                NSLog(@"suceessfully downloaded JSON data: %@", responseObject);
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
                if (httpResponse.statusCode == statusCode_sucess)
                {
                    
                    if (responseObject!=nil)
                    {
                        success(responseObject);
                    }
                }
            }
            failure:^(NSURLSessionDataTask *operation, NSError *error)
            {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
                NSLog(@"Error: %@", [error localizedDescription]);
                NSLog(@"status code returned is %ld",(long)httpResponse.statusCode);
                failure(error);
                
                
            }
   ];
    
    
}

- (BOOL)isReachable
{
  return self.manager.reachabilityManager.isReachable;
}

- (void)setReachabilityStatusChangeBlock:(void (^)(AFNetworkReachabilityStatus status))block
{
  [self.manager.reachabilityManager setReachabilityStatusChangeBlock:block];
}

@end