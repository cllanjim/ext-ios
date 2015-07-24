#import "Extensions.h"

@implementation Run

+ (void)onMainQueue:(void (^)(void))block
{
    if (NSThread.isMainThread)
    {
        block();
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

+ (void)onGlobalQueue:(void (^)(void))block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), block);
}

@end
