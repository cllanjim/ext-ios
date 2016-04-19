#import "CameraView.h"
#import <AVFoundation/AVFoundation.h>

@implementation CameraView

+ (Class)layerClass
{
	return AVCaptureVideoPreviewLayer.class;
}

- (AVCaptureVideoPreviewLayer *)videoPreviewLayer
{
    return (AVCaptureVideoPreviewLayer *)self.layer;
}

- (AVCaptureSession *)session
{
	return self.videoPreviewLayer.session;
}

- (void)setSession:(AVCaptureSession *)session
{
	[self.videoPreviewLayer setSession:session];
}

@end
