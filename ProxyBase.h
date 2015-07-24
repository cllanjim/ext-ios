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
typedef void (^NetJobRetryRedoingLoginBlock)(StatusCodes statusCode, id retryHint);
typedef void (^NetworkJobBlock)(NetJobRetryAgainBlock onJobRetryAgain, NetJobRetryRedoingLoginBlock onJobRetryRedoingLoginBlock, id retryHint);
typedef void (^GotUploadSessionBlock)(NSURLSessionUploadTask* session, NSProgress* progress);
typedef void (^GotDownloadSessionBlock)(NSURLSessionDownloadTask* session, NSProgress* progress);


@interface ProxyBase : NSObject

- (instancetype)initWithNumberOfRetrials:(NSUInteger)retrials;

- (void)setUserAgent:(NSString*)userAgentString;

- (void)doNetworkTask:(NetworkJobBlock)networkJob withErrorCallback:(GotErrorBlock)onError;

- (void)retryRedoingLogin:(void(^)(void))onLoginRedone withErrorCallback:(void(^)(void))onLoginFailed;

- (void)apiIsDeprecated;

- (AFHTTPRequestOperation *)getRequest:(Route *)route withCallback:(GotJsonBlock)gotJson withErrorCallback:(GotErrorBlock)gotError;

- (AFHTTPRequestOperation *)postRequest:(Route *)route withBody:(NSString *)aBody withCallback:(GotJsonBlock)gotJson withErrorCallback:(GotErrorBlock)gotError;

- (AFHTTPRequestOperation *)postRequest:(Route *)route withMultipartBuilder:(void (^)(id <AFMultipartFormData> formData))aBuilderFunction withCallback:(GotJsonBlock)gotJson withErrorCallback:(GotErrorBlock)gotError;

- (void)uploadRequest:(Route *)route withMultipartBuilder:(void (^)(id <AFMultipartFormData> formData))aBuilderFunction withCallback:(GotJsonBlock)gotJson withSessionCallback:(GotUploadSessionBlock)gotSession withErrorCallback:(GotErrorBlock)gotError;

- (void)downloadData:(Route *)route toFile:(NSString*)filePath withCallback:(void (^)(void))downloadDone withSessionCallback:(GotDownloadSessionBlock)gotSession withErrorCallback:(DownloadGotErrorBlock)gotError;

- (void)downloadWithResumeData:(NSData *)resumeData toFile:(NSString*)filePath withCallback:(void (^)(void))downloadDone withSessionCallback:(GotDownloadSessionBlock)gotSession withErrorCallback:(DownloadGotErrorBlock)gotError;

@end
