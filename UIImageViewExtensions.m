#import "Extensions.h"
#import "SDWebImage+ExtensionSupport/UIImageView+WebCache.h"

@implementation UIImageView (UIImageViewExtensions)

- (CGRect)imageFrame
{
    CGFloat imageAspectRatio = self.image.size.width / self.image.size.height;
    CGFloat viewAspectRatio = self.bounds.size.width / self.bounds.size.height;
    if (imageAspectRatio > viewAspectRatio) // Image is wider than view
    {
        CGFloat imageWidth = self.bounds.size.width;
        CGFloat imageHeight = self.bounds.size.width / imageAspectRatio;
        return CGRectMake(self.frame.origin.x, self.frame.origin.y + (self.bounds.size.height - imageHeight) / 2, imageWidth, imageHeight);
    }
    
    // Image is taller than view
    CGFloat imageWidth = self.bounds.size.height * imageAspectRatio;
    CGFloat imageHeight = self.bounds.size.height;
    return CGRectMake(self.frame.origin.x + (self.bounds.size.width - imageWidth) / 2, self.frame.origin.y, imageWidth, imageHeight);
}

- (void)setImageWithUrl:(NSURL *)imageUrl withFadeOnCompletion:(NSTimeInterval)fadeDuration discardingCache:(BOOL)discardingCache
{
    SDWebImageOptions options = SDWebImageRetryFailed;
    if (discardingCache) options = options | SDWebImageRefreshCached;
    
    __block BOOL imageAlreadySet = NO;
    
    [self sd_setImageWithURL:imageUrl
            placeholderImage:nil
                     options:options
                   completed:^(UIImage* image, NSError* error, SDImageCacheType cacheType, NSURL* imageURL)
     {
         if (image == nil)
         {
             self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.4];
             self.alpha = 1.0;
             return;
         }
         
         if (cacheType == SDImageCacheTypeMemory || cacheType == SDImageCacheTypeDisk)
         {
             imageAlreadySet = YES;
             return;
         }
         
         if (imageAlreadySet) return;
         
         self.backgroundColor = UIColor.clearColor;
         self.alpha = 0.0;
         [UIView animateWithDuration:fadeDuration animations:^
          {
              self.alpha = 1.0;
          }];
     }];
}

@end
