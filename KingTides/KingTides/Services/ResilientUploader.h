#import <Foundation/Foundation.h>

@class Incident;
@class KingTidesService;
@class Upload;
@class UploadOperation;

@interface ResilientUploader : NSObject
+ (ResilientUploader *)sharedUploader;
- (void)save:(Upload *)upload;
- (void)queueSavedUploads;
@end