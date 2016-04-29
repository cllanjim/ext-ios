#import "Extensions.h"
#import "SDWebImage/UIImageView+WebCache.h"

@implementation UIImageView (UIImageViewExtensions)

- (CGRect)imageFrame
{
    CGSize imageSize = self.image.size;
    CGRect viewBounds = self.bounds;
    CGAffineTransform inverseAffine = CGAffineTransformInvert(self.transform);
    CGRect viewFrame = CGRectApplyAffineTransform(self.frame, inverseAffine);
    CGRect imageFrame;
    
    if (self.contentMode == UIViewContentModeScaleAspectFill || self.contentMode == UIViewContentModeScaleToFill)
    {
        imageFrame = viewFrame;
    }
    else if (self.contentMode == UIViewContentModeScaleAspectFit)
    {
        CGFloat imageAspectRatio = imageSize.width / imageSize.height;
        CGFloat viewAspectRatio = viewBounds.size.width / viewBounds.size.height;
        if (imageAspectRatio > viewAspectRatio) // Image is wider than view
        {
            CGFloat imageWidth = viewBounds.size.width;
            CGFloat imageHeight = viewBounds.size.width / imageAspectRatio;
            imageFrame = CGRectMake(viewFrame.origin.x, viewFrame.origin.y + (viewBounds.size.height - imageHeight) / 2, imageWidth, imageHeight);
        }
        else // Image is taller than view
        {
            CGFloat imageWidth = viewBounds.size.height * imageAspectRatio;
            CGFloat imageHeight = viewBounds.size.height;
            imageFrame = CGRectMake(viewFrame.origin.x + (viewBounds.size.width - imageWidth) / 2, viewFrame.origin.y, imageWidth, imageHeight);
        }
    }
    
    CGRect transformedImageFrame = CGRectApplyAffineTransform(imageFrame, self.transform);
    
    return transformedImageFrame;
}

// TODO: discardingCache=YES leads to a memory leak!
- (void)setImageWithUrl:(NSURL *)imageUrl withFadeOnCompletion:(NSTimeInterval)fadeDuration discardingCache:(BOOL)discardingCache
{
    SDWebImageOptions options = SDWebImageRetryFailed;
    if (discardingCache)
        options = options | SDWebImageRefreshCached;
    
    __block BOOL imageAlreadySet = NO;
    
    Weaken(self);
    
    [self sd_setImageWithURL:imageUrl
            placeholderImage:nil
                     options:options
                   completed:^(UIImage* image, NSError* error, SDImageCacheType cacheType, NSURL* imageURL)
     {
         if (image == nil)
         {
             selfWeak.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
             selfWeak.alpha = 1.0;
             return;
         }
         
         if (cacheType == SDImageCacheTypeMemory || cacheType == SDImageCacheTypeDisk)
         {
             imageAlreadySet = YES;
             return;
         }
         
         if (imageAlreadySet)
             return;
         
         selfWeak.backgroundColor = UIColor.clearColor;
         selfWeak.alpha = 0.0;
         [UIView animateWithDuration:fadeDuration animations:^
          {
              selfWeak.alpha = 1.0;
          }];
     }];
}

@end
