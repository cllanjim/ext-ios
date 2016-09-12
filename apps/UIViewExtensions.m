#import "Extensions.h"

@implementation UIView (UIViewExtensions)

- (void)setCornersRounded:(BOOL)cornersRounded withRasterization:(BOOL)shouldRasterize
{
    CGColorRef backgroudColor = self.backgroundColor.CGColor;
    self.backgroundColor = UIColor.clearColor;
    self.layer.backgroundColor = backgroudColor;
    self.layer.cornerRadius = cornersRounded ? self.bounds.size.width / 2 : 0;
    self.layer.masksToBounds = YES;
    if (shouldRasterize)
    {
        self.superview.layer.shouldRasterize = YES;
        self.superview.layer.rasterizationScale = UIScreen.mainScreen.scale;
    }
}

- (BOOL)hasRegularSizeClasses
{
    return self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular && self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular;
}

- (void)setHidden:(BOOL)hidden withDuration:(CGFloat)fadeDuration
{
    if (self.hidden == hidden) return;
    if (self.superview == nil)
    {
        self.hidden = hidden;
        return;
    }
    
    self.alpha = self.hidden ? 0 : 1;
    self.hidden = NO;
    [UIView animateWithDuration:fadeDuration animations:^
     {
         self.alpha = hidden ? 0 : 1;
     } completion:^(BOOL finished)
     {
         self.alpha = 1;
         self.hidden = hidden;
     }];
}

@end
