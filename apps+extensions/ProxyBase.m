#import "ProxyBase.h"
#import "JSONModel+networking.h"
#import "Extensions.h"

@implementation ProxyBase
{
    NSUInteger _numberOfRetrials;
    AFHTTPSessionManager* _sessionManager;
    NSURLSessionConfiguration* _sessionManagerConfiguration;
}


#pragma mark - Overrides

- (instancetype)init
{
    return [self initWithNumberOfRetrials:3];
}


#pragma mark - Abstract

- (void)retryRedoingLogin:(void(^)(void))onLoginRedone withErrorCallback:(void(^)(void))onLoginFailed NotImplemented

- (void)apiIsDeprecated { /* Override is not mandatory */ }


#pragma mark - Public

- (instancetype)initWithNumberOfRetrials:(NSUInteger)retrials
{
    if (self = [super init])
    {
        _numberOfRetrials = retrials;
        _sessionManagerConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration;
        _sessionManager = [AFHTTPSessionManager.alloc initWithBaseURL:nil sessionConfiguration:nil];
        
        //_urlSessionManager = [AFURLSessionManager.alloc initWithSessionConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration]; // backgroundSessionConfigurationWithIdentifier
    }
    return self;
}

- (void)setUserAgent:(NSString*)userAgentString
{
    [_sessionManagerConfiguration setHTTPAdditionalHeaders:@{@"User-Agent": userAgentString}];
}

- (void)doNetworkTask:(NetworkJobBlock)networkJob withErrorCallback:(GotErrorBlock)onError
{
    [self doNetworkTaskRecursive:networkJob retryCount:_numberOfRetrials-1 withErrorCallback:onError withRetryHint:nil];
}

- (NSURLSessionDataTask *)getRequest:(Route *)route withCallback:(GotJsonBlock)gotJson withErrorCallback:(GotErrorBlock)gotError
{
    return [_sessionManager GET:route.path parameters:route.parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
            {
                CallBlock(gotJson, responseObject);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
            {
                NSHTTPURLResponse* response = (NSHTTPURLResponse*)task.response;
                CallBlock(gotError, response.statusCode, error.localizedDescription);
            }];
    
    
    /*
     return [_sessionManager GET:route.path parameters:route.parameters success:^(AFHTTPRequestOperation* operation, id responseObject)
     {
     CallBlock(gotJson, responseObject);
     } failure:^(AFHTTPRequestOperation* operation, NSError* error) {
     CallBlock(gotError, operation.response.statusCode, error.localizedDescription);
     }];*/
}

- (NSURLSessionDataTask *)postRequest:(Route *)route withBody:(NSString *)aBody withCallback:(GotJsonBlock)gotJson withErrorCallback:(GotErrorBlock)gotError
{
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:route.getUrl]];
    [request setHTTPMethod:@"POST"];
    [request setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[aBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask* postTask = [_sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error)
    {
        if (error)
        {
            NSUInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
            CallBlock(gotError, statusCode, error.localizedDescription);
        }
        else
        {
            CallBlock(gotJson, responseObject);
        }
    }];
    [postTask resume];
}

- (NSURLSessionDataTask *)postRequest:(Route *)route withMultipartBuilder:(void (^)(id <AFMultipartFormData> formData))aBuilderFunction withCallback:(GotJsonBlock)gotJson withErrorCallback:(GotErrorBlock)gotError
{
    return [_sessionManager POST:route.path parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData)
            {
                CallBlock(aBuilderFunction, formData);
            } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
            {
                CallBlock(gotJson, responseObject);
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
            {
                NSHTTPURLResponse* response = (NSHTTPURLResponse*)task.response;
                CallBlock(gotError, response.statusCode, error.localizedDescription);
            }];
    
    
    /*NSMutableURLRequest* request = [_operationManager.requestSerializer
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
     return operation;*/
}

- (NSURLSessionUploadTask *)uploadRequest:(Route *)route withMultipartBuilder:(void (^)(id <AFMultipartFormData> formData))aBuilderFunction withCallback:(GotJsonBlock)gotJson withProgressCallback:(ProgressBlock)progressCallback withErrorCallback:(GotErrorBlock)gotError
{
    NSMutableURLRequest* request = [AFHTTPRequestSerializer.serializer multipartFormRequestWithMethod:@"POST" URLString:route.getUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
                                    {
                                        CallBlock(aBuilderFunction, formData);
                                    } error:nil];
    
    NSURLSessionUploadTask* uploadTask = [_sessionManager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress)
                                          {
                                              CallBlockOnMainQueue(progressCallback, uploadProgress.fractionCompleted);
                                              
                                          } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error)
                                          {
                                              if (error)
                                              {
                                                  NSUInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
                                                  CallBlock(gotError, statusCode, error.localizedDescription);
                                              }
                                              else
                                              {
                                                  CallBlock(gotJson, responseObject);
                                              }
                                          }];
    [uploadTask resume];
    return uploadTask;
    
    /*NSMutableURLRequest* request = [AFHTTPRequestSerializer.serializer multipartFormRequestWithMethod:@"POST" URLString:route.getUrl parameters:nil constructingBodyWithBlock:aBuilderFunction error:nil];
     [self setRequestAgent:request];
     
     NSProgress* progress = nil;
     NSURLSessionUploadTask* uploadTask = [_sessionManager uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError* error) {
     if (error) {
     NSUInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
     CallBlock(gotError, statusCode, error.localizedDescription);
     } else {
     CallBlock(gotJson, responseObject);
     }
     }];
     [uploadTask resume];
     CallBlock(gotSession, uploadTask, progress);*/
}

- (NSURLSessionDownloadTask *)downloadData:(Route *)route toFile:(NSString*)filePath withCallback:(void (^)(void))downloadDone withProgressCallback:(ProgressBlock)progressCallback withErrorCallback:(DownloadGotErrorBlock)gotError
{
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:route.getUrl]];
    NSURLSessionDownloadTask* downloadTask = [_sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress)
                                              {
                                                  CallBlockOnMainQueue(progressCallback, downloadProgress.fractionCompleted);
                                                  
                                              } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response)
                                              {
                                                  return [NSURL fileURLWithPath:filePath];
                                                  
                                              } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error)
                                              {
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
    return downloadTask;
    
    /*NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:route.getUrl]];
     [self setRequestAgent:request];
     
     NSProgress* progress = nil;
     NSURLSessionDownloadTask* downloadTask = [_sessionManager downloadTaskWithRequest:request progress:&progress destination:^NSURL* (NSURL* targetPath, NSURLResponse* response) {
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
     CallBlock(gotSession, downloadTask, progress);*/
}

- (NSURLSessionDownloadTask *)downloadWithResumeData:(NSData *)resumeData toFile:(NSString *)filePath withCallback:(void (^)(void))downloadDone withProgressCallback:(ProgressBlock)progressCallback withErrorCallback:(DownloadGotErrorBlock)gotError
{
    NSURLSessionDownloadTask* downloadTask = [_sessionManager downloadTaskWithResumeData:resumeData progress:^(NSProgress * _Nonnull downloadProgress)
                                              {
                                                  CallBlockOnMainQueue(progressCallback, downloadProgress.fractionCompleted);
                                              } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response)
                                              {
                                                  return [NSURL fileURLWithPath:filePath];
                                              } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error)
                                              {
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
    return downloadTask;
    
    /*
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
     CallBlock(gotSession, downloadTask, progress);*/
}

- (BOOL)isReachable
{
    return AFNetworkReachabilityManager.sharedManager.reachable;
}

- (void)onNextReachabilityStatusChange:(void(^)(BOOL isReachable))newReachability
{
    [AFNetworkReachabilityManager.sharedManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status)
     {
         [AFNetworkReachabilityManager.sharedManager setReachabilityStatusChangeBlock:nil];
         CallBlock(newReachability, status != AFNetworkReachabilityStatusNotReachable && status != AFNetworkReachabilityStatusUnknown);
     }];
}



#pragma mark - Private

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
            [Run onGlobalQueue:^
             {
                 int timeToWait = pow(_numberOfRetrials - retryNumber, 2); // Wait for 1^2=1, 2^2=4, 3^2=9, ... seconds each trial...
                 Pause(timeToWait);
                 [self doNetworkTaskRecursive:networkJob retryCount:retryNumber-1 withErrorCallback:onError withRetryHint:aRetryHint];
             }];
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

@end
