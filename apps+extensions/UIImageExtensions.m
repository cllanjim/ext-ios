#import "Extensions.h"

@implementation UIImage (UIImageExtensions)

- (UIImage *)rotateImage:(UIImageOrientation)imageOrientation
{
    UIImage* imageWithNormalizedOrientation = self.imageWithNormalizedOrientation;
    CGImageRef quartzImage = imageWithNormalizedOrientation.CGImage;
    UIImage* rotatedImage = [UIImage imageWithCGImage:quartzImage scale:1.0 orientation:imageOrientation];
    return rotatedImage;
}

- (UIImage *)imageWithNormalizedOrientation
{
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    [self drawInRect:(CGRect){0, 0, self.size}];
    UIImage* normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

- (CGSize)pixelSize
{
    return CGSizeMake(self.size.width * self.scale, self.size.height * self.scale);
}

- (void)saveToJpegWithFilePath:(NSString*)aPath withQuality:(CGFloat)aJpegQuality
{
    NSData* data = UIImageJPEGRepresentation(self, aJpegQuality);
    [data writeToFile:aPath atomically:YES];
}

- (void)saveToPngWithFilePath:(NSString*)aPath
{
    NSData* data = UIImagePNGRepresentation(self);
    [data writeToFile:aPath atomically:YES];
}

+ (UIImage*)imageWithColor:(UIColor*)color size:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    UIBezierPath* rPath = [UIBezierPath bezierPathWithRect:CGRectMake(0., 0., size.width, size.height)];
    [color setFill];
    [rPath fill];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (BOOL)isEqualToImage:(UIImage *)image2
{
    return [self differencesFromImage:image2 withRGBThreshold:0] == 0;
}

// Differences in the range [0,1]
- (double)differencesFromImage:(UIImage *)image2 withRGBThreshold:(NSUInteger)rgbThreshold
{
    if (!CGSizeEqualToSize(self.pixelSize, image2.pixelSize)) return 1;
    
    double differences = 0;
    
    CGImageRef image1Ref = self.CGImage;
    NSUInteger width = CGImageGetWidth(image1Ref);
    NSUInteger height = CGImageGetHeight(image1Ref);
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    
    unsigned char* image1RawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    CGColorSpaceRef image1ColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef image1Context = CGBitmapContextCreate(image1RawData, width, height,
                                                       bitsPerComponent, bytesPerRow, image1ColorSpace,
                                                       kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(image1ColorSpace);
    CGContextDrawImage(image1Context, CGRectMake(0, 0, width, height), image1Ref);
    CGContextRelease(image1Context);
    
    CGImageRef image2Ref = image2.CGImage;
    unsigned char* image2RawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    CGColorSpaceRef image2ColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef image2Context = CGBitmapContextCreate(image2RawData, width, height,
                                                       bitsPerComponent, bytesPerRow, image2ColorSpace,
                                                       kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(image2ColorSpace);
    CGContextDrawImage(image2Context, CGRectMake(0, 0, width, height), image2Ref);
    CGContextRelease(image2Context);
    
    for (NSUInteger row = 0; row < height; row++)
        for (NSUInteger col = 0; col < width; col++)
        {
            NSUInteger byteIndex = (bytesPerRow * row) + col * bytesPerPixel;
            
            int image1r   = image1RawData[byteIndex];
            int image1g = image1RawData[byteIndex + 1];
            int image1b  = image1RawData[byteIndex + 2];
            //int image1a = image1RawData[byteIndex + 3];
            
            int image2r   = image2RawData[byteIndex];
            int image2g = image2RawData[byteIndex + 1];
            int image2b  = image2RawData[byteIndex + 2];
            //int image2a = image2RawData[byteIndex + 3];
            
            if ((ABS(image1r - image2r) + ABS(image1g - image2g) + ABS(image1b - image2b)) > rgbThreshold)
            {
                differences++;
            }
        }
    
    differences /= (double)(width * height);
    
    free(image1RawData);
    free(image2RawData);
    return differences;
}


#pragma mark - Cropping

- (UIImage *)pasteToImageWithSize:(CGSize)aSize usingRect:(CGRect)aRect
{
    CGSize intSize = CGSizeMake(roundf(aSize.width), roundf(aSize.height));
    CGRect intRect = CGRectMake(roundf(aRect.origin.x), roundf(aRect.origin.y), roundf(aRect.size.width), roundf(aRect.size.height));
    
    UIGraphicsBeginImageContext(intSize);
    [self drawInRect:intRect];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


#pragma mark - Scale

- (UIImage *)scaleToFillSize:(CGSize)aSize
{
    return [self pasteToImageWithSize:aSize usingRect:CGRectMake(0, 0, aSize.width, aSize.height)];
}

- (UIImage *)scaleToAspectFitSizeWithoutMargin:(CGSize)aSize
{
    CGSize oldSize = self.pixelSize;
    CGFloat scaleFactor = (oldSize.width > oldSize.height) ? aSize.width / oldSize.width : aSize.height / oldSize.height;
    CGSize newSize = CGSizeMake(oldSize.width * scaleFactor, oldSize.height * scaleFactor);
    return [self scaleToFillSize:newSize];
}

- (UIImage *)scaleToAspectFillSize:(CGSize)aSize
{
    CGSize oldSize = self.pixelSize;
    CGFloat scaleFactor = MAX(aSize.width / oldSize.width, aSize.height / oldSize.height);
    CGSize newSize = CGSizeMake(oldSize.width * scaleFactor, oldSize.height * scaleFactor);
    CGRect pasteRect = CGRectMake((aSize.width - newSize.width) / 2, (aSize.height - newSize.height) / 2, newSize.width, newSize.height);
    return [self pasteToImageWithSize:aSize usingRect:pasteRect];
}


@end
