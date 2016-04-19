#import "ExtCamera.h"

@implementation ExtCamera
{
    __weak id<ExtCameraDelegate> _delegate;
    __weak CameraView* _cameraView;
    
    AVCaptureSession* _session;
    dispatch_queue_t _sessionQueue;
    NSArray* _devices;
    AVCaptureDeviceInput* _videoDeviceInput;
    AVCaptureVideoDataOutput* _output;
    AVCaptureDevicePosition _cameraDevicePosition;
    NSString* _captureSessionPreset;
}

#pragma mark - Public

- (instancetype)init:(CameraView *)aCameraView withCaptureSessionPreset:(NSString *)aCaptureSessionPreset withDelegate:(id<ExtCameraDelegate>)delegate
{
    if (self = [super init])
    {
        _cameraView = aCameraView;
        _captureSessionPreset = aCaptureSessionPreset;
        _delegate = delegate;
        _cameraDevicePosition = AVCaptureDevicePositionBack;
    }
    return self;
}

- (void)setupCaptureSession:(VoidBlock)gotSession
{
    _session = AVCaptureSession.new;
    [_session setSessionPreset:_captureSessionPreset];
    [_cameraView setSession:_session];
    _sessionQueue = dispatch_queue_create("camera session queue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(_sessionQueue, ^{
        _devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        AVCaptureDevice* videoDevice = self.currentCaptureDevice;
        _videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
        if ([_session canAddInput:_videoDeviceInput])
        {
            [_session addInput:_videoDeviceInput];
        }
        _output = AVCaptureVideoDataOutput.new;
        [_session addOutput:_output];
        
        [self setFramesOrientation:AVCaptureVideoOrientationPortrait];
        
        dispatch_queue_t queue = dispatch_queue_create("camera frames queue", NULL);
        [_output setSampleBufferDelegate:self queue:queue];
        _output.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
        [_session startRunning];
        CallBlockOnMainQueue(gotSession);
    });
}

- (void)teardown:(void (^)())onDone
{
    _delegate = nil;
    dispatch_async(_sessionQueue, ^
                   {
                       [_session stopRunning];
                       CallBlock(onDone);
                   });
}

- (void)switchCamera:(VoidBlock)onSwitched
{
    dispatch_async(_sessionQueue, ^
                   {
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
                       
                       AVCaptureDevice* videoDevice = self.currentCaptureDevice;
                       AVCaptureDeviceInput* videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
                       
                       [_session beginConfiguration];
                       
                       [_session removeInput:_videoDeviceInput];
                       if ([_session canAddInput:videoDeviceInput])
                       {
                           [_session addInput:videoDeviceInput];
                           _videoDeviceInput = videoDeviceInput;
                       }
                       else
                       {
                           [_session addInput:_videoDeviceInput];
                       }
                       [self setFramesOrientation:AVCaptureVideoOrientationPortrait];
                       
                       [_session commitConfiguration];
                       CallBlockOnMainQueue(onSwitched);
                   });
}

- (void)focusNowAt:(CGPoint)aPoint
{
    dispatch_async(_sessionQueue, ^
                   {
                       AVCaptureDevice* videoDevice = self.currentCaptureDevice;
                       if ([videoDevice lockForConfiguration:nil])
                       {
                           if ([videoDevice isExposurePointOfInterestSupported] && [videoDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose])
                           {
                               [videoDevice setExposurePointOfInterest:aPoint];
                               [videoDevice setExposureMode:AVCaptureExposureModeAutoExpose];
                           }
                           if ([videoDevice isFocusPointOfInterestSupported] && [videoDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus])
                           {
                               [videoDevice setFocusPointOfInterest:aPoint];
                               [videoDevice setFocusMode:AVCaptureFocusModeAutoFocus];
                           }
                           [videoDevice unlockForConfiguration];
                       }
                   });
}

- (void)focusLock
{
    dispatch_async(_sessionQueue, ^
                   {
                       AVCaptureDevice* videoDevice = self.currentCaptureDevice;
                       if ([videoDevice lockForConfiguration:nil])
                       {
                           if ([videoDevice isFocusPointOfInterestSupported] && [videoDevice isFocusModeSupported:AVCaptureFocusModeLocked])
                           {
                               [videoDevice setFocusMode:AVCaptureFocusModeLocked];
                           }
                           [videoDevice unlockForConfiguration];
                       }
                   });
}

- (void)focusContinuously
{
    dispatch_async(_sessionQueue, ^
                   {
                       AVCaptureDevice* videoDevice = self.currentCaptureDevice;
                       if ([videoDevice lockForConfiguration:nil])
                       {
                           if ([videoDevice isExposurePointOfInterestSupported] && [videoDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose])
                           {
                               [videoDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
                           }
                           if ([videoDevice isFocusPointOfInterestSupported] && [videoDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
                           {
                               [videoDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
                           }
                           [videoDevice unlockForConfiguration];
                       }
                   });
}

- (void)switchTorch:(void (^)(void))aCallback
{
    dispatch_async(_sessionQueue, ^
                   {
                       AVCaptureDevice* videoDevice = self.currentCaptureDevice;
                       if (videoDevice.hasTorch && [videoDevice isTorchModeSupported:AVCaptureTorchModeOn])
                       {
                           if ([videoDevice lockForConfiguration:nil])
                           {
                               if (videoDevice.torchMode != AVCaptureTorchModeOn)
                               {
                                   [videoDevice setTorchMode:AVCaptureTorchModeOn];
                               }
                               else
                               {
                                   [videoDevice setTorchMode:AVCaptureTorchModeOff];
                               }
                               [videoDevice unlockForConfiguration];
                           }
                       }
                       CallBlockOnMainQueue(aCallback);
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

- (BOOL)canSwitchCamera
{
    return _devices.count > 1;
}

- (BOOL)hasTorch
{
    AVCaptureDevice* videoDevice = self.currentCaptureDevice;
    return videoDevice.hasTorch && [videoDevice isTorchModeSupported:AVCaptureTorchModeOn];
}

- (BOOL)isTorchActive
{
    AVCaptureDevice* videoDevice = self.currentCaptureDevice;
    return videoDevice.hasTorch && videoDevice.isTorchActive;
}


#pragma mark - Private

- (AVCaptureDevice *)currentCaptureDevice
{
    return [self deviceWithMediaType:_cameraDevicePosition];
}

- (void)setFramesOrientation:(AVCaptureVideoOrientation)anOrientation
{
    AVCaptureConnection* captureConnection;
    captureConnection = [_output connectionWithMediaType:AVMediaTypeVideo];
    if (captureConnection.isVideoOrientationSupported)
    {
        [captureConnection setVideoOrientation:anOrientation];
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    [_delegate frameCaptured:[CapturedFrame.alloc initWithBuffer:sampleBuffer withDevicePosition:_cameraDevicePosition]];
}

- (AVCaptureDevice *)deviceWithMediaType:(AVCaptureDevicePosition)position
{
    AVCaptureDevice* captureDevice = _devices.firstObject;
    for (AVCaptureDevice* device in _devices)
    {
        if (device.position == position)
        {
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}

@end