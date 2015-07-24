#import "CameraView.h"
#import "CapturedFrame.h"

@protocol ExtCameraDelegate

@required

- (void)frameCaptured:(CapturedFrame*)capturedFrame;

@end

@interface ExtCamera : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    id <ExtCameraDelegate> _delegate;
}
@property (nonatomic,strong) id delegate;

@property AVCaptureSession *session;
@property AVCaptureDevice *videoDevice;
@property AVCaptureDeviceInput *videoDeviceInput;
@property dispatch_queue_t sessionQueue;
@property AVCaptureVideoDataOutput *output;
@property CameraView *cameraView;
@property AVCaptureDevicePosition cameraDevicePosition;
@property NSString *captureSessionPreset;
@property NSArray *devices;

- (instancetype)init:(CameraView *)aCameraView captureSessionPreset:(NSString *)aCaptureSessionPreset;

- (void)setupCaptureSession:(void (^)(BOOL isTorchAvailable, BOOL isCameraSwitchable))aCallback;

- (void)teardown;

- (void)switchCamera:(void (^)(BOOL isTorchAvailable))aCallback;

- (void)focusNowAt:(CGPoint)aPoint;

- (void)focusLock;

- (void)focusContinuously;

- (void)switchTorch:(void (^)(void))aCallback;

- (void)checkCameraPermissions:(void (^)(BOOL cameraGranted))cameraPermissionsCallback;

@end
