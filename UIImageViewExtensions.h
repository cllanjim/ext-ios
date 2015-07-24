@interface UIImageView (UIImageViewExtensions)

- (CGRect)imageFrame;

- (void)setImageWithUrl:(NSURL *)imageUrl withFadeOnCompletion:(NSTimeInterval)fadeDuration discardingCache:(BOOL)discardingCache;

@end
