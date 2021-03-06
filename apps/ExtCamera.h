#import "CameraView.h"
#import "CapturedFrame.h"
#import "Extensions.h"

typedef NS_ENUM(NSInteger, FrameFormat)
{
    FrameFormatBGRA = 1,
    FrameFormatYUV = 2
};

@protocol ExtCameraDelegate

@required

- (void)frameCaptured:(CapturedFrame *)capturedFrame;

@end

@interface ExtCamera : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>

- (instancetype)init:(CameraView *)aCameraView withCaptureSessionPreset:(NSString *)aCaptureSessionPreset withFrameFormat:(FrameFormat)frameFormat withDelegate:(id<ExtCameraDelegate>)delegate;

- (void)setupCaptureSession:(VoidBlock)gotSession withDefaultCameraPosition:(AVCaptureDevicePosition)cameraPosition;

- (void)teardown:(void (^)())onDone;

- (void)switchCamera:(VoidBlock)onSwitched;

- (void)focusNowAt:(CGPoint)aPoint;

- (void)focusLock;

- (void)focusContinuously;

- (void)switchTorch:(void (^)(void))aCallback;

- (void)checkCameraPermissions:(void (^)(BOOL cameraGranted))cameraPermissionsCallback;

- (BOOL)canSwitchCamera;

- (AVCaptureDevicePosition)cameraPosition;

- (BOOL)hasTorch;

- (BOOL)isTorchActive;

- (BOOL)isFrontalCamera;

@end
