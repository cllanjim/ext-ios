#import "MRProgress.h"

@interface MRProgressOverlayView (MRProgressOverlayViewCustomExt)

+ (MRProgressOverlayView *)showIndeterminateTransparentWithTitle:(NSString *)title;

- (void)showCheckmarkAndDismissWithNewTitle:(NSString *)title;

@end
