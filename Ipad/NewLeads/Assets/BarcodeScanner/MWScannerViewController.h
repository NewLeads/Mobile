/*
 * Copyright (C) 2012  Manatee Works, Inc.
 *
 */

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import "MWResult.h"


extern NSString * const DecoderResultNotification;


@interface DecoderResult : NSObject {
	BOOL succeeded;
	MWResult *result;
}

@property (nonatomic, assign) BOOL succeeded;
@property (nonatomic, retain) MWResult *result;

+(DecoderResult *)createSuccess:(MWResult *)result;
+(DecoderResult *)createFailure;

@end



typedef enum eMainScreenState {
	NORMAL,
	LAUNCHING_CAMERA,
	CAMERA,
	CAMERA_DECODING,
	DECODE_DISPLAY,
	CANCELLING
} MainScreenState;


@interface MWScannerViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate,UINavigationControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, assign) MainScreenState state;

@property (nonatomic, retain) AVCaptureSession *captureSession;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *prevLayer;
@property (nonatomic, retain) AVCaptureDevice *device;
@property (nonatomic, retain) NSTimer *focusTimer;

- (void)decodeResultNotification: (NSNotification *)notification;
- (void)initCapture;
- (void) startScanning;
- (void) stopScanning;
- (void) toggleTorch;

@end