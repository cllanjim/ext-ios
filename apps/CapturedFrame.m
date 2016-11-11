#import "CapturedFrame.h"
#import "Extensions.h"

@implementation CapturedFrame
{
    CMSampleBufferRef _capturedBuffer;
    AVCaptureDevicePosition _cameraDevicePosition;
}

# pragma mark - Public

- (instancetype)initWithBuffer:(CMSampleBufferRef)aCapturedBuffer withDevicePosition:(AVCaptureDevicePosition)aCameraDevicePosition
{
    if (self = [super init])
    {
        _cameraDevicePosition = aCameraDevicePosition;
    }
    return self;
}

- (uint8_t **)allocateYuvPlanes
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(_capturedBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    size_t yPlaneSize = [self yPlaneSize:imageBuffer];
    size_t uvPlaneSize = [self uvPlaneSize:imageBuffer];
    uint8_t* yuvPlanes[3] = {malloc(yPlaneSize), malloc(uvPlaneSize / 2), malloc(uvPlaneSize / 2)};
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    return yuvPlanes;
}

- (void)freeYuvPlanes:(uint8_t **)yuvPlanesArray
{
    free(yuvPlanesArray[0]);
    free(yuvPlanesArray[1]);
    free(yuvPlanesArray[2]);
}

- (void)fillYuvPlanes:(uint8_t **)yuvPlanesArray withPlanesSizes:(NSUInteger *)yuvPlanesSizes
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(_capturedBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    size_t yPlaneSize = [self yPlaneSize:imageBuffer];
    void * ySourcePlanePointer = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    memcpy(yuvPlanesArray[0], ySourcePlanePointer, yPlaneSize);
    
    size_t uvPlaneSize = [self uvPlaneSize:imageBuffer];
    uint8_t* uvSourcePlanePointer = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 1);
    size_t uDestinationIndex = 0;
    size_t vDestinationIndex = 0;
    for (size_t uvPixelId = 0; uvPixelId < uvPlaneSize; uvPixelId += 2)
    {
        yuvPlanesArray[1][uDestinationIndex++] = uvSourcePlanePointer[uvPixelId];
        yuvPlanesArray[2][vDestinationIndex++] = uvSourcePlanePointer[uvPixelId + 1];
    }
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    yuvPlanesSizes[0] = yPlaneSize;
    yuvPlanesSizes[1] = uvPlaneSize / 2;
    yuvPlanesSizes[2] = uvPlaneSize / 2;
}

- (UIImage *)getRgbImageWithRotation:(UIInterfaceOrientation)cameraOrientation
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(_capturedBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    size_t inputBytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t inputWidth = CVPixelBufferGetWidth(imageBuffer);
    size_t inputHeight = CVPixelBufferGetHeight(imageBuffer);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void* inputBaseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    UIImageOrientation imageOrientation;
    switch (cameraOrientation)
    {
        case UIInterfaceOrientationPortrait:
            imageOrientation = UIImageOrientationUp;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            imageOrientation = UIImageOrientationDown;
            break;
        case UIInterfaceOrientationLandscapeRight:
            imageOrientation = UIImageOrientationLeft;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            imageOrientation = UIImageOrientationRight;
            break;
        default:
            imageOrientation = UIImageOrientationUp;
    }
    
    CGContextRef context = CGBitmapContextCreate(inputBaseAddress, inputWidth, inputHeight, 8, inputBytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    UIImage* image = [UIImage imageWithCGImage:cgImage scale:1.0 orientation:imageOrientation];
    CGImageRelease(cgImage);
    
    if (_cameraDevicePosition == AVCaptureDevicePositionFront)
    {
        if (cameraOrientation == UIInterfaceOrientationLandscapeRight)
        {
            image = [image rotateImage:UIImageOrientationDown].finalizeRotation;
            image = [image rotateImage:UIImageOrientationLeft];
        }
        else if (cameraOrientation == UIInterfaceOrientationLandscapeLeft)
        {
            image = [image rotateImage:UIImageOrientationDown].finalizeRotation;
            image = [image rotateImage:UIImageOrientationRight];
        }
    }
    return (image);
}

#pragma mark - Private

- (size_t)yPlaneSize:(CVImageBufferRef)imageBuffer
{
    size_t yPlaneWidth = CVPixelBufferGetWidthOfPlane(imageBuffer, 0);
    size_t yPlaneHeight = CVPixelBufferGetHeightOfPlane(imageBuffer, 0);
    return yPlaneWidth * yPlaneHeight;
}

- (size_t)uvPlaneSize:(CVImageBufferRef)imageBuffer
{
    size_t uvPlaneWidth = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 1);
    size_t uvPlaneHeight = CVPixelBufferGetHeightOfPlane(imageBuffer, 1);
    return uvPlaneWidth * uvPlaneHeight;
}

@end
