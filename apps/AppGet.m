#import "AppExtensions.h"

@implementation AppGet

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

@end
