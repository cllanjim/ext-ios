#import "AppExtensions.h"

@implementation MRProgressOverlayView (MRProgressOverlayViewCustomExt)

+ (MRProgressOverlayView *)showIndeterminateTransparentWithTitle:(NSString *)title
{
    MRProgressOverlayView* progressView = [MRProgressOverlayView showOverlayAddedTo:UIApplication.sharedApplication.keyWindow title:title mode:MRProgressOverlayViewModeIndeterminate animated:YES];
    progressView.backgroundColor = UIColor.clearColor;
    return progressView;
}

- (void)showCheckmarkAndDismissWithNewTitle:(NSString *)title
{
    [Run onGlobalQueue:^{
        [Run onMainQueue:^{
            [self setTitleLabelText:title];
            [self setMode:MRProgressOverlayViewModeCheckmark];
        }];
        Pause(1);
        [Run onMainQueue:^{
            [self dismiss:YES];
        }];
    }];
}

@end
