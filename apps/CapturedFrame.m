#import "CapturedFrame.h"
#import "Extensions.h"

@implementation CapturedFrame
{
    CMSampleBufferRef _capturedBuffer;
    FrameFormat _frameFormat;
    AVCaptureDevicePosition _cameraDevicePosition;
}

- (instancetype)initWithBuffer:(CMSampleBufferRef)aCapturedBuffer withFrameFormat:(FrameFormat)frameFormat withDevicePosition:(AVCaptureDevicePosition)aCameraDevicePosition
{
    if (self = [super init])
    {
        _capturedBuffer = aCapturedBuffer;
        _frameFormat = frameFormat;
        _cameraDevicePosition = aCameraDevicePosition;
    }
    return self;
}

- (void)fillYuvFrame:(uint8_t **)yuvDestinationPlanesArray
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(_capturedBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    size_t yPlaneWidth = CVPixelBufferGetWidthOfPlane(imageBuffer, 0);
    size_t yPlaneHeight = CVPixelBufferGetHeightOfPlane(imageBuffer, 0);
    unsigned int yPlaneSize = yPlaneWidth * yPlaneHeight;
    void * ySourcePlanePointer = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    memcpy(yuvDestinationPlanesArray[0], ySourcePlanePointer, yPlaneSize);
    
    size_t uvPlaneWidth = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 1);
    size_t uvPlaneHeight = CVPixelBufferGetHeightOfPlane(imageBuffer, 1);
    size_t uvPlaneSize = uvPlaneWidth * uvPlaneHeight;
    uint8_t* uvSourcePlanePointer = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 1);
    unsigned int uDestinationIndex = 0;
    unsigned int vDestinationIndex = 0;
    for (unsigned int uvPixelId = 0; uvPixelId < uvPlaneSize; uvPixelId += 2)
    {
        yuvDestinationPlanesArray[1][uDestinationIndex++] = uvSourcePlanePointer[uvPixelId];
        yuvDestinationPlanesArray[2][vDestinationIndex++] = uvSourcePlanePointer[uvPixelId + 1];
    }
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
}

- (void)saveToFile:(NSString *)filePath
{
    
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
