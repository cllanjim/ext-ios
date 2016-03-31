#import "Extensions.h"
#import "UIImageViewExtensions.h"
#import "AppGet.h"
#import "UIViewControllerAppExtensions.h"
#import "MRProgressOverlayViewCustomExt.h"

#define StatusBarSize                       UIApplication.sharedApplication.statusBarFrame.size
#define StatusBarHeight                     MIN(StatusBarSize.width, StatusBarSize.height)
#define StatusBarPlusNavigationBarHeight    (StatusBarHeight + NavigationBarHeight)