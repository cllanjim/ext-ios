#import "ExtCamera.h"
#import "Extensions.h"

@implementation ExtCamera

- (instancetype)init:(CameraView *)aCameraView captureSessionPreset:(NSString *)aCaptureSessionPreset
{
    if (self = [super init])
    {
        _cameraView = aCameraView;
        _captureSessionPreset = aCaptureSessionPreset;
        _cameraDevicePosition = AVCaptureDevicePositionBack;
    }
    return self;
}

- (void)teardown
{
    dispatch_async(_sessionQueue, ^{
        [_session stopRunning];
    });
}

- (void)setupCaptureSession:(void (^)(BOOL isTorchAvailable, BOOL isCameraSwitchable))aCallback
{
    _session = AVCaptureSession.new;
    [_session setSessionPreset:_captureSessionPreset];
    [self setSession:_session];
    [_cameraView setSession:_session];
    _sessionQueue = dispatch_queue_create("camera session queue", DISPATCH_QUEUE_SERIAL);
    [self setSessionQueue:_sessionQueue];
    dispatch_async(_sessionQueue, ^{
        _devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        _videoDevice = [self deviceWithMediaType:_cameraDevicePosition];
        _videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_videoDevice error:nil];
        if ([_session canAddInput:_videoDeviceInput])
        {
            [_session addInput:_videoDeviceInput];
            [self setVideoDeviceInput:_videoDeviceInput];
        }
        _output = AVCaptureVideoDataOutput.new;
        [_session addOutput:_output];
        
        [self setFramesOrientation:AVCaptureVideoOrientationPortrait];
        
        dispatch_queue_t queue = dispatch_queue_create("camera frames queue", NULL);
        [_output setSampleBufferDelegate:self queue:queue];
        _output.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
        [_session startRunning];
        CallBlockOnMainQueue(aCallback, _videoDevice.hasTorch && [_videoDevice isTorchModeSupported:AVCaptureTorchModeOn], _devices.count > 1);
    });
}

- (void)setFramesOrientation:(AVCaptureVideoOrientation)anOrientation
{
    AVCaptureConnection *captureConnection;
    captureConnection = [_output connectionWithMediaType:AVMediaTypeVideo];
    if ([captureConnection isVideoOrientationSupported])
    {
        [captureConnection setVideoOrientation:anOrientation];
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    [self.delegate frameCaptured:[CapturedFrame.alloc initWithBuffer:sampleBuffer withDevicePosition:_cameraDevicePosition]];
}

- (void)switchTorch:(void (^)(void))aCallback
{
    dispatch_async(self.sessionQueue, ^{
        if (_videoDevice.hasTorch && [_videoDevice isTorchModeSupported:AVCaptureTorchModeOn])
        {
            if ([_videoDevice lockForConfiguration:nil])
            {
                if (_videoDevice.torchMode != AVCaptureTorchModeOn)
                {
                    [_videoDevice setTorchMode:AVCaptureTorchModeOn];
                }
                else
                {
                    [_videoDevice setTorchMode:AVCaptureTorchModeOff];
                }
                [_videoDevice unlockForConfiguration];
            }
        }
        CallBlockOnMainQueue(aCallback);
    });
}

- (void)switchCamera:(void (^)(BOOL isTorchAvailable))aCallback
{
    dispatch_async(self.sessionQueue, ^{
        switch (_cameraDevicePosition)
        {
            case AVCaptureDevicePositionBack:
                _cameraDevicePosition = AVCaptureDevicePositionFront;
                break;
            case AVCaptureDevicePositionFront:
                _cameraDevicePosition = AVCaptureDevicePositionBack;
                break;
            case AVCaptureDevicePositionUnspecified:
                _cameraDevicePosition = AVCaptureDevicePositionBack;
                break;
        }
        
        AVCaptureDevice *videoDevice = [self deviceWithMediaType:_cameraDevicePosition];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
        
        [self.session beginConfiguration];
        
        [self.session removeInput:_videoDeviceInput];
        if ([self.session canAddInput:videoDeviceInput])
        {
            [self.session addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];
            _videoDevice = videoDevice;
            _videoDeviceInput = videoDeviceInput;
        }
        else
        {
            [self.session addInput:[self videoDeviceInput]];
        }
        [self setFramesOrientation:AVCaptureVideoOrientationPortrait];
        
        [self.session commitConfiguration];
        CallBlockOnMainQueue(aCallback, _videoDevice.hasTorch && [_videoDevice isTorchModeSupported:AVCaptureTorchModeOn]);
    });
}

- (AVCaptureDevice *)deviceWithMediaType:(AVCaptureDevicePosition)position
{
    AVCaptureDevice *captureDevice = [_devices firstObject];
    for (AVCaptureDevice *device in _devices)
    {
        if (device.position == position)
        {
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}

#pragma mark Focus Configuration

- (void)focusNowAt:(CGPoint)aPoint
{
    dispatch_async(_sessionQueue, ^{
        if ([_videoDevice lockForConfiguration:nil])
        {
            if ([_videoDevice isExposurePointOfInterestSupported] && [_videoDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose])
            {
                [_videoDevice setExposurePointOfInterest:aPoint];
                [_videoDevice setExposureMode:AVCaptureExposureModeAutoExpose];
            }
            if ([_videoDevice isFocusPointOfInterestSupported] && [_videoDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus])
            {
                [_videoDevice setFocusPointOfInterest:aPoint];
                [_videoDevice setFocusMode:AVCaptureFocusModeAutoFocus];
            }
            [_videoDevice unlockForConfiguration];
        }
    });
}

- (void)focusContinuously
{
    dispatch_async(_sessionQueue, ^{
        if ([_videoDevice lockForConfiguration:nil])
        {
            if ([_videoDevice isExposurePointOfInterestSupported] && [_videoDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose])
            {
                [_videoDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            }
            if ([_videoDevice isFocusPointOfInterestSupported] && [_videoDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
            {
                [_videoDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            }
            [_videoDevice unlockForConfiguration];
        }
    });
}

- (void)focusLock
{
    dispatch_async(_sessionQueue, ^{
        if ([_videoDevice lockForConfiguration:nil])
        {
            if ([_videoDevice isFocusPointOfInterestSupported] && [_videoDevice isFocusModeSupported:AVCaptureFocusModeLocked])
            {
                [_videoDevice setFocusMode:AVCaptureFocusModeLocked];
            }
            [_videoDevice unlockForConfiguration];
        }
    });
}

- (void)checkCameraPermissions:(void (^)(BOOL cameraGranted))cameraPermissionsCallback
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusAuthorized)
    {
        CallBlockOnMainQueue(cameraPermissionsCallback, YES);
    }
    else if(authStatus == AVAuthorizationStatusDenied)
    {
        CallBlockOnMainQueue(cameraPermissionsCallback, NO);
    }
    else if(authStatus == AVAuthorizationStatusRestricted)
    {
        CallBlockOnMainQueue(cameraPermissionsCallback, NO);
    }
    else if(authStatus == AVAuthorizationStatusNotDetermined)
    {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^
         (BOOL granted) {
             CallBlockOnMainQueue(cameraPermissionsCallback, granted);
         }];
    } else
    {
        CallBlockOnMainQueue(cameraPermissionsCallback, NO);
    }
}

@end