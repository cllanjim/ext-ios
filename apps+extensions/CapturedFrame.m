#import "CapturedFrame.h"

@implementation CapturedFrame
{
    CMSampleBufferRef _capturedBuffer;
    AVCaptureDevicePosition _cameraDevicePosition;
}

- (instancetype)initWithBuffer:(CMSampleBufferRef)aCapturedBuffer withDevicePosition:(AVCaptureDevicePosition)aCameraDevicePosition
{
    if (self = [super init])
    {
        _capturedBuffer = aCapturedBuffer;
        _cameraDevicePosition = aCameraDevicePosition;
    }
    return self;
}

- (UIImage *)getImageWithDeviceRotation:(UIDeviceOrientation)deviceRotation
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(_capturedBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    size_t inputBytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t inputWidth = CVPixelBufferGetWidth(imageBuffer);
    size_t inputHeight = CVPixelBufferGetHeight(imageBuffer);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void* inputBaseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    UIImageOrientation imageOrientation;
    switch (deviceRotation)
    {
        case UIDeviceOrientationPortrait:
            imageOrientation = UIImageOrientationUp;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            imageOrientation = UIImageOrientationDown;
            break;
        case UIDeviceOrientationLandscapeRight:
            imageOrientation = (_cameraDevicePosition == AVCaptureDevicePositionFront ? UIImageOrientationLeft : UIImageOrientationRight);
            break;
        case UIDeviceOrientationLandscapeLeft:
            imageOrientation = (_cameraDevicePosition == AVCaptureDevicePositionFront ? UIImageOrientationRight : UIImageOrientationLeft);
            break;
        default:
            imageOrientation = UIImageOrientationUp;
    }
    
    CGContextRef context = CGBitmapContextCreate(inputBaseAddress, inputWidth, inputHeight, 8, inputBytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    UIImage* image = [UIImage imageWithCGImage:quartzImage scale:1.0 orientation:imageOrientation];
    CGImageRelease(quartzImage);
    return (image);
}

@end
