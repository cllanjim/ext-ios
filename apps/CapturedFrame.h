#import <AVFoundation/AVFoundation.h>

@interface CapturedFrame : NSObject

- (instancetype)initWithBuffer:(CMSampleBufferRef)aCapturedBuffer withDevicePosition:(AVCaptureDevicePosition)aCameraDevicePosition;

- (uint8_t **)allocateYuvPlanes;

- (void)freeYuvPlanes:(uint8_t **)yuvPlanesArray;

- (void)fillYuvPlanes:(uint8_t **)yuvPlanesArray withPlanesSizes:(NSUInteger *)yuvPlanesSizes;

- (UIImage *)getRgbImageWithRotation:(UIInterfaceOrientation)cameraOrientation;

@end
