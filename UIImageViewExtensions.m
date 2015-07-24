#import "Extensions.h"

@implementation UIImageView (UIImageViewExtensions)

- (CGRect)imageFrame
{
    CGFloat imageAspectRatio = self.image.size.width / self.image.size.height;
    CGFloat viewAspectRatio = self.bounds.size.width / self.bounds.size.height;
    /*NSLog(@"imageWidth  %f",self.image.size.width);
    NSLog(@"imageHeight  %f",self.image.size.height);
    NSLog(@"frameWidth  %f",self.bounds.size.width);
    NSLog(@"frameHeight  %f",self.bounds.size.height);*/
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

@end
