#import "AppExtensions.h"

@implementation UIViewController (UIViewControllerAppExtensions)

- (CGRect)viewFrameUnderNavigationBar
{
    CGRect viewFrame = CGRectMake(0, StatusBarPlusNavigationBarHeight, self.view.frame.size.width, self.view.frame.size.height - StatusBarPlusNavigationBarHeight);
    return viewFrame;
}

@end
