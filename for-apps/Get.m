#import "Extensions.h"

@implementation Get

#ifndef EXT_APP_EXTENSIONS
+ (UIViewController*)rootViewController
{
    return UIApplication.sharedApplication.keyWindow.rootViewController;
}

+ (UIViewController*)currentViewController
{
    UIViewController* topRootViewController = UIApplication.sharedApplication.keyWindow.rootViewController;
    while (topRootViewController.presentedViewController)
    {
        topRootViewController = topRootViewController.presentedViewController;
    }
    return topRootViewController;
}

+ (NSUInteger)currentStatusBarHeight
{
    return [UIApplication sharedApplication].statusBarFrame.size.height;
}
#endif

+ (unsigned long long)freeSpaceOnDisk
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [FileManager attributesOfFileSystemForPath:[paths lastObject] error: nil];
    
    if (dictionary)
    {
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        return [freeFileSystemSizeInBytes unsignedLongLongValue];
    }
    return 0;
}

@end
