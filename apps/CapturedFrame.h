#import <AVFoundation/AVFoundation.h>
#import "YuvFrame.h"

@interface CapturedFrame : NSObject

- (instancetype)initWithBuffer:(CMSampleBufferRef)capturedBuffer withDevicePosition:(AVCaptureDevicePosition)cameraDevicePosition;

- (YuvFrame *)allocateYuvFame;

- (void)fillYuvFrame:(YuvFrame *)yuvFrame;

- (UIImage *)getRgbImageWithRotation:(UIInterfaceOrientation)cameraOrientation;

@end
