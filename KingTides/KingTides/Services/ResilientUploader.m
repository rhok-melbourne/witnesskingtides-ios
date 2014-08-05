#import "ResilientUploader.h"
#import "UploadOperation.h"
#import "AFNetworkReachabilityManager.h"
#import "KingTidesService.h"
#import "Upload.h"
#import "Notifications.h"

@interface ResilientUploader () <UploadOperationProtocol>
@property(nonatomic, strong) NSOperationQueue *operationQueue;
@end

@implementation ResilientUploader

+ (ResilientUploader *)sharedUploader {
  static ResilientUploader *_sharedClient = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedClient = [[ResilientUploader alloc] initWithClient:[KingTidesService sharedService]];
  });

  return _sharedClient;
}

- (id)initWithClient:(KingTidesService *)client {
  if (self = [super init]) {
    self.operationQueue = [[NSOperationQueue alloc] init];
    self.operationQueue.maxConcurrentOperationCount = 1;
    [self.operationQueue setSuspended:client.isReachable];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(queueSavedUploads)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];

    __weak typeof (self) weakSelf = self;
    [client setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
      if (status == AFNetworkReachabilityStatusNotReachable) {
        [weakSelf.operationQueue setSuspended:YES];
      } else {
        [weakSelf.operationQueue setSuspended:NO];
      }
    }];
  }
  return self;
}

- (void)save:(Upload *)upload {
  [upload saveToDisk];
  [self enqueForUpload:upload];
}

- (void)enqueForUpload:(Upload *)upload {
  UploadOperation *operation = [[UploadOperation alloc] initWithUpload:upload];
  operation.delegate = self;
  if(self.operationQueue.isSuspended) {
    [[NSNotificationCenter defaultCenter] postNotificationName:kUploadedSuccessfully object:self userInfo:@{@"upload" : upload}];
  }
  [self.operationQueue addOperation:operation];
}

- (void)queueSavedUploads {
  NSArray *queuedUploads = [Upload loadUnsaved];

  for(Upload *upload in queuedUploads) {
    [self enqueForUpload:upload];
  }
}

#pragma mark - UploadOperationProtocol methods
- (void)uploadSuccessful:(UploadOperation *)operation upload:(Upload *)upload
{
  [[NSNotificationCenter defaultCenter] postNotificationName:kUploadedSuccessfully object:self userInfo:@{@"upload" : upload}];
}

- (void)uploadFailed:(UploadOperation *)operation error:(NSError *)error upload:(Upload *)upload {
  [[NSNotificationCenter defaultCenter] postNotificationName:kUploadFailed object:self userInfo:@{@"upload" : upload}];
  NSLog(@"Failed to upload '%@', description: %@", upload.description, error.localizedDescription);
  if(self.operationQueue.isSuspended) {
    [self enqueForUpload:upload]; // retry the upload later.
  }
}

@end