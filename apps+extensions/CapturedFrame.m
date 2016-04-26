#import "CapturedFrame.h"
#import "Extensions.h"

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

- (UIImage *)getImageWithRotation:(UIInterfaceOrientation)cameraOrientation
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

@end
