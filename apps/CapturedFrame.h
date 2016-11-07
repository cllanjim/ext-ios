#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, FrameFormat)
{
    FrameFormatBGRA = 1,
    FrameFormatYUV = 2
};

@interface CapturedFrame : NSObject

- (instancetype)initWithBuffer:(CMSampleBufferRef)aCapturedBuffer withFrameFormat:(FrameFormat)frameFormat withDevicePosition:(AVCaptureDevicePosition)aCameraDevicePosition;

- (void)fillYuvFrame:(uint8_t **)yuvDestinationPlanesArray;

- (UIImage *)getImageWithRotation:(UIInterfaceOrientation)cameraOrientation;

@end
