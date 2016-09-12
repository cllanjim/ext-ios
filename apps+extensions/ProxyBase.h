#import "Route.h"
#import "AFNetworking.h"

typedef NS_ENUM(NSInteger, StatusCodes)
{
    StatusCodesOk = 200,
    StatusCodesBadRequest = 400,
    StatusCodesUnauthorized = 401,
    StatusCodesForbidden = 403,
    StatusCodesNotFound = 404,
    StatusCodesGone = 410,
    StatusCodesInternalServerError = 500,
};

typedef void (^GotJsonBlock)(NSDictionary* json);
typedef void (^GotErrorBlock)(StatusCodes statusCode, NSString* errorDescription);
typedef void (^DownloadGotErrorBlock)(StatusCodes statusCode, NSString* errorDescription, NSData* resumeData);
typedef void (^NetJobRetryAgainBlock)(StatusCodes statusCode, id retryHint);
typedef void (^NetworkJobBlock)(NetJobRetryAgainBlock onJobRetryAgain, NetJobRetryAgainBlock onJobRetryRedoingLoginBlock, id retryHint);
typedef void (^ProgressBlock)(double fractionCompleted);


@interface ProxyBase : NSObject

#pragma mark - Abstract

- (void)retryRedoingLogin:(void(^)(void))onLoginRedone withErrorCallback:(void(^)(void))onLoginFailed;

- (void)apiIsDeprecated;


#pragma mark - Public

- (instancetype)initWithNumberOfRetrials:(NSUInteger)retrials;

- (void)setUserAgent:(NSString*)userAgentString;

- (void)doNetworkTask:(NetworkJobBlock)networkJob withErrorCallback:(GotErrorBlock)onError;

- (NSURLSessionDataTask *)getRequest:(Route *)route withCallback:(GotJsonBlock)gotJson withErrorCallback:(GotErrorBlock)gotError;

- (NSURLSessionDataTask *)postRequest:(Route *)route withBody:(NSString *)aBody withCallback:(GotJsonBlock)gotJson withErrorCallback:(GotErrorBlock)gotError;

- (NSURLSessionDataTask *)postRequest:(Route *)route withMultipartBuilder:(void (^)(id <AFMultipartFormData> formData))aBuilderFunction withCallback:(GotJsonBlock)gotJson withErrorCallback:(GotErrorBlock)gotError;

- (NSURLSessionUploadTask *)uploadRequest:(Route *)route withMultipartBuilder:(void (^)(id <AFMultipartFormData> formData))aBuilderFunction withCallback:(GotJsonBlock)gotJson withProgressCallback:(ProgressBlock)progressCallback withErrorCallback:(GotErrorBlock)gotError;

- (NSURLSessionDownloadTask *)downloadData:(Route *)route toFile:(NSString*)filePath withCallback:(void (^)(void))downloadDone withProgressCallback:(ProgressBlock)progressCallback withErrorCallback:(DownloadGotErrorBlock)gotError;

- (NSURLSessionDownloadTask *)downloadWithResumeData:(NSData *)resumeData toFile:(NSString *)filePath withCallback:(void (^)(void))downloadDone withProgressCallback:(ProgressBlock)progressCallback withErrorCallback:(DownloadGotErrorBlock)gotError;

- (BOOL)isReachable;

- (void)onNextReachabilityStatusChange:(void(^)(BOOL isReachable))newReachability;

- (NSProgress *)getProgressForTask:(NSURLSessionTask *)sessionTask;


@end
