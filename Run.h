@interface Run : NSObject

+ (void)onMainQueue:(void (^)(void))block;

+ (void)onGlobalQueue:(void (^)(void))block;

@end
