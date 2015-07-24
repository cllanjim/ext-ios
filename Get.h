@interface Get : NSObject

#ifndef EXT_APP_EXTENSIONS
+ (UIViewController*)rootViewController;

+ (UIViewController*)currentViewController;

+ (NSUInteger)currentStatusBarHeight;
#endif

+ (unsigned long long)freeSpaceOnDisk;

@end
