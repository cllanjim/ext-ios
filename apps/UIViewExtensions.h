@interface UIView (UIViewExtensions)

- (void)setCornersRounded:(BOOL)cornersRounded withRasterization:(BOOL)shouldRasterize;

- (BOOL)hasRegularSizeClasses;

- (void)setHidden:(BOOL)hidden withDuration:(CGFloat)fadeDuration;

@end
