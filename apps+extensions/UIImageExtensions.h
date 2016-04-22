@interface UIImage (UIImageExtensions)

- (UIImage *)rotateImage:(UIImageOrientation)imageOrientation;

- (UIImage *)finalizeRotation;

- (CGSize)pixelSize;

- (void)saveToJpegWithFilePath:(NSString*)aPath withQuality:(CGFloat)aJpegQuality;

- (void)saveToPngWithFilePath:(NSString*)aPath;

+ (UIImage*)imageWithColor:(UIColor*)color size:(CGSize)size;

+ (UIImage *)imageWithColor:(UIColor *)color;

- (BOOL)isEqualToImage:(UIImage *)image2;

// Differences in the range [0,1]
- (double)differencesFromImage:(UIImage *)image2 withRGBThreshold:(NSUInteger)rgbThreshold;

- (UIImage *)pasteToImageWithSize:(CGSize)aSize usingRect:(CGRect)aRect;

- (UIImage *)scaleToFillSize:(CGSize)aSize;

- (UIImage *)scaleToAspectFitSizeWithoutMargin:(CGSize)aSize;

- (UIImage *)scaleToAspectFillSize:(CGSize)aSize;

- (UIColor *)averageColor;

@end
