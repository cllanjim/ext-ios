#import "Extensions.h"
#import "AppGet.h"
#import "UIViewControllerAppExtensions.h"
#import "MRProgressOverlayViewCustomExt.h"

#import "UIViewControllerExtensions.h"
#import "UIImageViewExtensions.h"
#import "UIViewExtensions.h"
#import "UISearchBarExtensions.h"

#define StatusBarSize                       UIApplication.sharedApplication.statusBarFrame.size
#define StatusBarHeight                     MIN(StatusBarSize.width, StatusBarSize.height)
#define StatusBarPlusNavigationBarHeight    (StatusBarHeight + NavigationBarHeight)