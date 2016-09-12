#import "ChameleonController.h"
#import "Extensions.h"

@implementation ChameleonController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView* viewToCopy = self.viewToCopy;
    UIGraphicsBeginImageContext(viewToCopy.bounds.size);
    [viewToCopy.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageView* snapshotView = UIImageView.new;
    snapshotView.image = image;
    snapshotView.frame = self.view.frame;
    snapshotView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:snapshotView];
    [self.view sendSubviewToBack:snapshotView];
}

- (UIView *)viewToCopy NotImplementedRet;

@end
