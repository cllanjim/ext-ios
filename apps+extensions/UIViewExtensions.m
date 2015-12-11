#import "Extensions.h"

@implementation UIView (UIViewExtensions)

- (void)roundTheCorners:(BOOL)shouldRasterize
{
    CGColorRef backgroudColor = self.backgroundColor.CGColor;
    self.backgroundColor = UIColor.clearColor;
    self.layer.backgroundColor = backgroudColor;
    self.layer.cornerRadius = self.bounds.size.width / 2;
    self.layer.masksToBounds = YES;
    if (shouldRasterize)
    {
        self.superview.layer.shouldRasterize = YES;
        self.superview.layer.rasterizationScale = UIScreen.mainScreen.scale;
    }
}

- (BOOL)hasRegularSizeClasses
{
    return self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular &&
    self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular;
}

@end
