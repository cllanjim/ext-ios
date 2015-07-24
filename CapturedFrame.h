#import <AVFoundation/AVFoundation.h>

@interface CapturedFrame : NSObject

- (instancetype)initWithBuffer:(CMSampleBufferRef)aCapturedBuffer withDevicePosition:(AVCaptureDevicePosition)aCameraDevicePosition;

- (UIImage *)getImageWithDeviceRotation:(UIDeviceOrientation)deviceRotation;

@end
