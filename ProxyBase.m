#import "ProxyBase.h"
#import "JSONModel+networking.h"
#import "Extensions.h"

@implementation ProxyBase
{
    NSUInteger _numberOfRetrials;
    AFHTTPRequestOperationManager* _operationManager;
    AFURLSessionManager* _urlSessionManager;
    NSString* _userAgentString;
}

- (instancetype)init
{
    return [self initWithNumberOfRetrials:3];
}

- (instancetype)initWithNumberOfRetrials:(NSUInteger)retrials
{
    if (self = [super init])
    {
        _numberOfRetrials = retrials;
        _userAgentString = nil;
        _operationManager = AFHTTPRequestOperationManager.manager;
        _urlSessionManager = [AFURLSessionManager.alloc initWithSessionConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration];
    }
    return self;
}

- (void)setUserAgent:(NSString*)userAgentString
{
    if (_userAgentString == nil)
    {
        _userAgentString = userAgentString;
    }
}

- (void)setRequestAgent:(NSMutableURLRequest*)request
{
    [request setValue:_userAgentString forHTTPHeaderField:@"User-Agent"];
}

- (void)doNetworkTask:(NetworkJobBlock)networkJob withErrorCallback:(GotErrorBlock)onError
{
    [self doNetworkTaskRecursive:networkJob retryCount:_numberOfRetrials-1 withErrorCallback:onError withRetryHint:nil];
}

- (void)doNetworkTaskRecursive:(NetworkJobBlock)networkJob retryCount:(NSUInteger)retryNumber withErrorCallback:(GotErrorBlock)onError withRetryHint:(id)aRetryHint
{
    NSString* networkErrorDescription = @"Function failed too many times for a network error";
    NetJobRetryAgainBlock onJobRetryAgainBlock = ^(StatusCodes statusCode, id retryHint)
    {
        if (retryNumber == 0 || statusCode == StatusCodesBadRequest)
        {
            CallBlock(onError, statusCode, networkErrorDescription);
        }
        else if (statusCode == StatusCodesGone)
        {
            [self apiIsDeprecated];
        }
        else
        {
            [self doNetworkTaskRecursive:networkJob retryCount:retryNumber-1 withErrorCallback:onError withRetryHint:aRetryHint];
        }
    };
    
    NetJobRetryRedoingLoginBlock onJobRetryRedoingLoginBlock = ^(StatusCodes statusCode, id retryHint)
    {
        if (statusCode == StatusCodesForbidden)
        {
            if (retryNumber == 0 || statusCode == StatusCodesBadRequest)
            {
                CallBlock(onError, statusCode, networkErrorDescription);
            }
            else
            {
                [self retryRedoingLogin:
                 ^{
                     [self doNetworkTaskRecursive:networkJob retryCount:retryNumber-1 withErrorCallback:onError withRetryHint:aRetryHint];
                 } withErrorCallback:^
                 {
                     CallBlock(onError, statusCode, networkErrorDescription);
                 }];
            }
        }
        else if (statusCode == StatusCodesGone)
        {
            [self apiIsDeprecated];
        }
        else
        {
            onJobRetryAgainBlock(statusCode, retryHint);
        }
    };
    CallBlock(networkJob, onJobRetryAgainBlock, onJobRetryRedoingLoginBlock, aRetryHint);
}

- (void)callErrorCallback:(GotErrorBlock)errorCallback causedByJsonError:(JSONModelError *)jsonError
{
    NSInteger statusCode = 500;
    if(jsonError != nil && [jsonError isKindOfClass:JSONModelError.class])
    {
        statusCode = [jsonError.httpResponse statusCode];
    }
    CallBlock(errorCallback, statusCode, [jsonError localizedDescription]);
}

- (AFHTTPRequestOperation *)getRequest:(Route *)route withCallback:(GotJsonBlock)gotJson withErrorCallback:(GotErrorBlock)gotError
{
    return [_operationManager GET:route.path parameters:route.parameters success:^(AFHTTPRequestOperation* operation, id responseObject)
            {
                CallBlock(gotJson, responseObject);
            } failure:^(AFHTTPRequestOperation* operation, NSError* error) {
                CallBlock(gotError, operation.response.statusCode, error.localizedDescription);
            }];
}

- (AFHTTPRequestOperation *)postRequest:(Route *)route withBody:(NSString *)aBody withCallback:(GotJsonBlock)gotJson withErrorCallback:(GotErrorBlock)gotError
{
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:route.getUrl]];
    [request setHTTPMethod:@"POST"];
    [request setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody: [aBody dataUsingEncoding:NSUTF8StringEncoding]];
    [self setRequestAgent:request];
    
    AFHTTPRequestOperation* operation = [AFHTTPRequestOperation.alloc initWithRequest:request];
    operation.responseSerializer = AFJSONResponseSerializer.serializer;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation* op, id responseObject)
     {
         CallBlock(gotJson, responseObject);
     } failure:^(AFHTTPRequestOperation* op, NSError* error)
     {
         CallBlock(gotError, op.response.statusCode, [error localizedDescription]);
     }];
    [operation start];
    return operation;
}

- (AFHTTPRequestOperation *)postRequest:(Route *)route withMultipartBuilder:(void (^)(id <AFMultipartFormData> formData))aBuilderFunction withCallback:(GotJsonBlock)gotJson withErrorCallback:(GotErrorBlock)gotError
{
    NSMutableURLRequest* request = [_operationManager.requestSerializer
                                    multipartFormRequestWithMethod:@"POST"
                                    URLString:route.getUrl
                                    parameters:nil
                                    constructingBodyWithBlock:aBuilderFunction
                                    error:nil];
    [self setRequestAgent:request];
    
    AFHTTPRequestOperation* operation = [_operationManager
                                         HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation* operation, id responseObject)
                                         {
                                             CallBlock(gotJson, responseObject);
                                         }
                                         failure:^(AFHTTPRequestOperation* operation, NSError* error) {
                                             CallBlock(gotError, operation.response.statusCode, [error localizedDescription]);
                                         }];
    
    [_operationManager.operationQueue addOperation:operation];
    return operation;
}

- (void)uploadRequest:(Route *)route withMultipartBuilder:(void (^)(id <AFMultipartFormData> formData))aBuilderFunction withCallback:(GotJsonBlock)gotJson withSessionCallback:(GotUploadSessionBlock)gotSession withErrorCallback:(GotErrorBlock)gotError
{
    NSMutableURLRequest* request = [AFHTTPRequestSerializer.serializer multipartFormRequestWithMethod:@"POST" URLString:route.getUrl parameters:nil constructingBodyWithBlock:aBuilderFunction error:nil];
    [self setRequestAgent:request];
    
    NSProgress* progress = nil;
    NSURLSessionUploadTask* uploadTask = [_urlSessionManager uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError* error) {
        if (error) {
            NSUInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
            CallBlock(gotError, statusCode, error.localizedDescription);
        } else {
            CallBlock(gotJson, responseObject);
        }
    }];
    [uploadTask resume];
    CallBlock(gotSession, uploadTask, progress);
}

- (void)downloadData:(Route *)route toFile:(NSString*)filePath withCallback:(void (^)(void))downloadDone withSessionCallback:(GotDownloadSessionBlock)gotSession withErrorCallback:(DownloadGotErrorBlock)gotError
{
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:route.getUrl]];
    [self setRequestAgent:request];
    
    NSProgress* progress = nil;
    NSURLSessionDownloadTask* downloadTask = [_urlSessionManager downloadTaskWithRequest:request progress:&progress destination:^NSURL* (NSURL* targetPath, NSURLResponse* response) {
        NSURL* targetFileUrl = [NSURL fileURLWithPath:filePath isDirectory:NO];
        return targetFileUrl;
    } completionHandler:^(NSURLResponse* response, NSURL* filePath, NSError* error) {
        if (error)
        {
            if (error.code == NSURLErrorCancelled) return; // Download programmatically cancelled
            NSData* resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
            NSUInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
            CallBlock(gotError, statusCode, [error localizedDescription], resumeData);
        }
        else
        {
            CallBlock(downloadDone);
        }
    }];
    [downloadTask resume];
    CallBlock(gotSession, downloadTask, progress);
}

- (void)downloadWithResumeData:(NSData *)resumeData toFile:(NSString *)filePath withCallback:(void (^)(void))downloadDone withSessionCallback:(GotDownloadSessionBlock)gotSession withErrorCallback:(DownloadGotErrorBlock)gotError
{
    NSProgress* progress = nil;
    
    NSURLSessionDownloadTask* downloadTask = [_urlSessionManager downloadTaskWithResumeData:resumeData progress:&progress destination:^NSURL* (NSURL* targetPath, NSURLResponse* response) {
        NSURL* targetFileUrl = [NSURL fileURLWithPath:filePath isDirectory:NO];
        return targetFileUrl;
    } completionHandler:^(NSURLResponse* response, NSURL* filePath, NSError* error) {
        if (error)
        {
            if (error.code == NSURLErrorCancelled) return; // Download programmatically cancelled
            NSData* resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
            NSUInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
            CallBlock(gotError, statusCode, [error localizedDescription], resumeData);
        } else {
            CallBlock(downloadDone);
        }
    }];
    [downloadTask resume];
    CallBlock(gotSession, downloadTask, progress);
}

- (void)apiIsDeprecated { /* Override is not mandatory */ }

- (void)retryRedoingLogin:(void(^)(void))onLoginRedone withErrorCallback:(void(^)(void))onLoginFailed { NotImplemented; }

@end
