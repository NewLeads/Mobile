/*
 * Copyright (C) 2012  Manatee Works, Inc.
 * v1.4
 */

/*
 
 Changes in v1.4:
 - Added ITF-14 support
 - Added Code 11 support
 - Added MSI Plessey support
 - GS1 support
 
 Changes in v1.3:
 - Added Dotcode support
 - Fixed iOS 8 issues
 - Added zoom functionality. Set USE_TOUCH_TO_ZOOM to 'true' to toggle zoom on screen touch instead of flash toggling
 
 Changes in v1.2:
 - Added MWOverlay class to show current viewfinder dynamically (will change in real-time as you are changing scanning params
 - Automatic handling of view controller orientation - scanner will adjust itself to current orientation
 
 */

#define USE_MWOVERLAY true

#include <mach/mach_host.h>
#import "MWScannerViewController.h"
#import "BarcodeScanner.h"
#if USE_MWOVERLAY
    #import "MWOverlay.h"
#endif
#import "MWResult.h"

#import "NLBarcodeDatasource.h"

#define PDF_OPTIMIZED false  

#define USE_TOUCH_TO_ZOOM false

#define MAX_THREADS 2

// !!! Rects are in format: x, y, width, height !!!
#define RECT_LANDSCAPE_1D       4, 20, 92, 60
#define RECT_LANDSCAPE_2D       20, 5, 60, 90
#define RECT_PORTRAIT_1D        20, 4, 60, 92
#define RECT_PORTRAIT_2D        20, 5, 60, 90
#define RECT_FULL_1D            4, 4, 92, 92
#define RECT_FULL_2D            20, 5, 60, 90
#define RECT_DOTCODE            30, 20, 40, 60

NSString * const DecoderResultNotification = @"DecoderResultNotification";

@implementation MWScannerViewController
{
    AVCaptureSession *_captureSession;
	AVCaptureDevice *_device;
	AVCaptureVideoPreviewLayer *_prevLayer;
	bool running;
    int activeThreads;
    int availableThreads;
    NSString * lastFormat;
	
	MainScreenState state;
	
	CGImageRef	decodeImage;
	NSString *	decodeResult;
	int width;
	int height;
	int bytesPerRow;
	unsigned char *baseAddress;
    NSTimer *focusTimer;
    
    int param_ZoomLevel1;
    int param_ZoomLevel2;
    int zoomLevel;
    bool videoZoomSupported;
    float firstZoom;
    float secondZoom;
    
}



@synthesize captureSession = _captureSession;
@synthesize prevLayer = _prevLayer;
@synthesize device = _device;
@synthesize state;
@synthesize focusTimer;

#pragma mark -
#pragma mark Initialization

- (void)initDecoder
{
    //register your copy of library with givern user/password
    MWB_registerCode(MWB_CODE_MASK_QR,"NewLeads.QR.iOS.EDL", "AC8352C55901F4012CB70D6CE8BED64E1C0389D4C19A2BBFA887A96AA4B41C59");
    MWB_registerCode(MWB_CODE_MASK_39,"NewLeads.C39.iOS.EDL", "F94D0446948E8B024F7589BD0E61FD5448557D032D21D713BE6775E64F620443");
    MWB_registerCode(MWB_CODE_MASK_93,"NewLeads.C93.iOS.EDL", "FDC90830C6EC2354BA1392E8978B33B3BF218F552A42E5BA6B273BC87D933E80");
    MWB_registerCode(MWB_CODE_MASK_CODABAR,"NewLeads.CB.iOS.EDL", "0995AB59342A9BA0F0896B1C762A78196DF9E6880AA8EE3D38204F97ECD2A7FF");
    MWB_registerCode(MWB_CODE_MASK_DM,"NewLeads.DM.iOS.EDL", "56A8F7D76D325F3DF9A9DFFA46FB95891F4EF6779B11DE4E60D9F624396EC94A");
    MWB_registerCode(MWB_CODE_MASK_128,"NewLeads.C128.iOS.EDL", "D01D04B480C4F95345F9790AF8934D65E37679BF3CACD1E3AAE70DBF359DD441");
    MWB_registerCode(MWB_CODE_MASK_25,"NewLeads.C25.iOS.EDL", "3739C3F00F59145CC689ECF4E502A6991E83BF2B4565ADC8CB87876D69227FA9");
    MWB_registerCode(MWB_CODE_MASK_PDF,"NewLeads.PDF.iOS.EDL", "101772F5343A6775773FF6ACF8100E141E6F0590B83CEB7D262C3C641DC43512");
    MWB_registerCode(MWB_CODE_MASK_AZTEC,"NewLeads.AZTEC.iOS.EDL", "73DEAE7BEA7DE1F5B7FB2323E1467A958B40DE15D15F9A0F2A24D503EBBF1DC4");
    MWB_registerCode(MWB_CODE_MASK_11,"NewLeads.C11.iOS.EDL", "F53F6E6913C11B2C3389F631E72C9450F687B7E87C0B6CE870BA6EC69CF0F237");
    MWB_registerCode(MWB_CODE_MASK_MSI,"NewLeads.MSI.iOS.EDL", "E2D610031BA3BEDCE3C64D4A3A5E2DF92AAE7BD8D5E78D51E4731E8D10EBDCA7");
    
    // choose code type or types you want to search for
    
    if (PDF_OPTIMIZED){
        MWB_setActiveCodes(MWB_CODE_MASK_PDF);
        MWB_setDirection(MWB_SCANDIRECTION_HORIZONTAL);
        MWB_setScanningRect(MWB_CODE_MASK_PDF,    RECT_LANDSCAPE_1D);
    }
	else
	{
		uint32_t codeMask = 0;
		NLBarcodeDatasource * datasource = [NLBarcodeDatasource new];
		
		if( [datasource hasCodeEnabled:MWB_CODE_MASK_25] )
		{
			codeMask |= MWB_CODE_MASK_25;
			MWB_setScanningRect(MWB_CODE_MASK_25,     RECT_FULL_1D);
		}
		
		if( [datasource hasCodeEnabled:MWB_CODE_MASK_39] )
		{
			codeMask |= MWB_CODE_MASK_39;
			MWB_setScanningRect(MWB_CODE_MASK_39,     RECT_FULL_1D);
		}
		
		if( [datasource hasCodeEnabled:MWB_CODE_MASK_93] )
		{
			codeMask |= MWB_CODE_MASK_93;
			MWB_setScanningRect(MWB_CODE_MASK_93,     RECT_FULL_1D);
		}
		
		if( [datasource hasCodeEnabled:MWB_CODE_MASK_128] )
		{
			codeMask |= MWB_CODE_MASK_128;
			MWB_setScanningRect(MWB_CODE_MASK_128,    RECT_FULL_1D);
		}
		
		if( [datasource hasCodeEnabled:MWB_CODE_MASK_AZTEC] )
		{
			codeMask |= MWB_CODE_MASK_AZTEC;
			MWB_setScanningRect(MWB_CODE_MASK_AZTEC,  RECT_FULL_2D);
		}
		
		if( [datasource hasCodeEnabled:MWB_CODE_MASK_DM] )
		{
			codeMask |= MWB_CODE_MASK_DM;
			MWB_setScanningRect(MWB_CODE_MASK_DM,     RECT_FULL_2D);
		}
		
		if( [datasource hasCodeEnabled:MWB_CODE_MASK_EANUPC] )
		{
			codeMask |= MWB_CODE_MASK_EANUPC;
			MWB_setScanningRect(MWB_CODE_MASK_EANUPC, RECT_FULL_1D);
		}
		
		if( [datasource hasCodeEnabled:MWB_CODE_MASK_PDF] )
		{
			codeMask |= MWB_CODE_MASK_PDF;
			MWB_setScanningRect(MWB_CODE_MASK_PDF,    RECT_FULL_1D);
		}
		
		if( [datasource hasCodeEnabled:MWB_CODE_MASK_QR] )
		{
			codeMask |= MWB_CODE_MASK_QR;
			MWB_setScanningRect(MWB_CODE_MASK_QR,     RECT_FULL_2D);
		}
		
		if( [datasource hasCodeEnabled:MWB_CODE_MASK_CODABAR] )
		{
			codeMask |= MWB_CODE_MASK_CODABAR;
			MWB_setScanningRect(MWB_CODE_MASK_CODABAR,RECT_FULL_1D);
		}
		
		if( [datasource hasCodeEnabled:MWB_CODE_MASK_11] )
		{
			codeMask |= MWB_CODE_MASK_11;
			MWB_setScanningRect(MWB_CODE_MASK_11,     RECT_FULL_1D);
		}
		
		if( [datasource hasCodeEnabled:MWB_CODE_MASK_MSI] )
		{
			codeMask |= MWB_CODE_MASK_MSI;
			MWB_setScanningRect(MWB_CODE_MASK_MSI,    RECT_FULL_1D);
		}
		
//		if( [datasource hasCodeEnabled:MWB_CODE_MASK_RSS] )
//		{
//			codeMask |= MWB_CODE_MASK_RSS;
//			MWB_setScanningRect(MWB_CODE_MASK_RSS,    RECT_FULL_1D);
//		}
		
		MWB_setActiveCodes(codeMask);
		
		// Our sample app is configured by default to search both directions...
		MWB_setDirection(MWB_SCANDIRECTION_HORIZONTAL | MWB_SCANDIRECTION_VERTICAL);

		datasource = nil;
		
		/*
        // Our sample app is configured by default to search all supported barcodes...
        MWB_setActiveCodes(MWB_CODE_MASK_25    |
                           MWB_CODE_MASK_39     |
                           MWB_CODE_MASK_93     |
                           MWB_CODE_MASK_128    |
                           MWB_CODE_MASK_AZTEC  |
                           MWB_CODE_MASK_DM     |
                           MWB_CODE_MASK_EANUPC |
                           MWB_CODE_MASK_PDF    |
                           MWB_CODE_MASK_QR     |
                           MWB_CODE_MASK_CODABAR|
                           MWB_CODE_MASK_11     |
                           MWB_CODE_MASK_MSI    |
                           MWB_CODE_MASK_RSS);
        
        // Our sample app is configured by default to search both directions...
        MWB_setDirection(MWB_SCANDIRECTION_HORIZONTAL | MWB_SCANDIRECTION_VERTICAL);
        // set the scanning rectangle based on scan direction(format in pct: x, y, width, height)
        MWB_setScanningRect(MWB_CODE_MASK_25,     RECT_FULL_1D);
        MWB_setScanningRect(MWB_CODE_MASK_39,     RECT_FULL_1D);
        MWB_setScanningRect(MWB_CODE_MASK_93,     RECT_FULL_1D);
        MWB_setScanningRect(MWB_CODE_MASK_128,    RECT_FULL_1D);
        MWB_setScanningRect(MWB_CODE_MASK_AZTEC,  RECT_FULL_2D);
        MWB_setScanningRect(MWB_CODE_MASK_DM,     RECT_FULL_2D);
        MWB_setScanningRect(MWB_CODE_MASK_EANUPC, RECT_FULL_1D);
        MWB_setScanningRect(MWB_CODE_MASK_PDF,    RECT_FULL_1D);
        MWB_setScanningRect(MWB_CODE_MASK_QR,     RECT_FULL_2D);
        MWB_setScanningRect(MWB_CODE_MASK_RSS,    RECT_FULL_1D);
        MWB_setScanningRect(MWB_CODE_MASK_CODABAR,RECT_FULL_1D);
        MWB_setScanningRect(MWB_CODE_MASK_DOTCODE,RECT_DOTCODE);
        MWB_setScanningRect(MWB_CODE_MASK_11,     RECT_FULL_1D);
        MWB_setScanningRect(MWB_CODE_MASK_MSI,    RECT_FULL_1D);
        */
    }
    
   
    // But for better performance, only activate the symbologies your application requires...
    // MWB_setActiveCodes( MWB_CODE_MASK_25 );
    // MWB_setActiveCodes( MWB_CODE_MASK_39 );
    // MWB_setActiveCodes( MWB_CODE_MASK_93 );
    // MWB_setActiveCodes( MWB_CODE_MASK_128 );
    // MWB_setActiveCodes( MWB_CODE_MASK_AZTEC );
    // MWB_setActiveCodes( MWB_CODE_MASK_DM );
    // MWB_setActiveCodes( MWB_CODE_MASK_EANUPC );
    // MWB_setActiveCodes( MWB_CODE_MASK_PDF );
    // MWB_setActiveCodes( MWB_CODE_MASK_QR );
    // MWB_setActiveCodes( MWB_CODE_MASK_RSS );
    // MWB_setActiveCodes( MWB_CODE_MASK_CODABAR );
    // MWB_setActiveCodes( MWB_CODE_MASK_DOTCODE );
    // MWB_setActiveCodes( MWB_CODE_MASK_11 );
    // MWB_setActiveCodes( MWB_CODE_MASK_MSI );
    
    
    // But for better performance, set like this for PORTRAIT scanning...
    // MWB_setDirection(MWB_SCANDIRECTION_VERTICAL);
    // set the scanning rectangle based on scan direction(format in pct: x, y, width, height)
    // MWB_setScanningRect(MWB_CODE_MASK_25,     RECT_PORTRAIT_1D);
    // MWB_setScanningRect(MWB_CODE_MASK_39,     RECT_PORTRAIT_1D);
    // MWB_setScanningRect(MWB_CODE_MASK_93,     RECT_PORTRAIT_1D);
    // MWB_setScanningRect(MWB_CODE_MASK_128,    RECT_PORTRAIT_1D);
    // MWB_setScanningRect(MWB_CODE_MASK_AZTEC,  RECT_PORTRAIT_2D);
    // MWB_setScanningRect(MWB_CODE_MASK_DM,     RECT_PORTRAIT_2D);
    // MWB_setScanningRect(MWB_CODE_MASK_EANUPC, RECT_PORTRAIT_1D);
    // MWB_setScanningRect(MWB_CODE_MASK_PDF,    RECT_PORTRAIT_1D);
    // MWB_setScanningRect(MWB_CODE_MASK_QR,     RECT_PORTRAIT_2D);
    // MWB_setScanningRect(MWB_CODE_MASK_RSS,    RECT_PORTRAIT_1D);
    // MWB_setScanningRect(MWB_CODE_MASK_CODABAR,RECT_PORTRAIT_1D);
    // MWB_setScanningRect(MWB_CODE_MASK_DOTCODE,RECT_DOTCODE);
    // MWB_setScanningRect(MWB_CODE_MASK_11,     RECT_PORTRAIT_1D);
    // MWB_setScanningRect(MWB_CODE_MASK_MSI,    RECT_PORTRAIT_1D);
    
    // or like this for LANDSCAPE scanning - Preferred for dense or wide codes...
    // MWB_setDirection(MWB_SCANDIRECTION_HORIZONTAL);
    // set the scanning rectangle based on scan direction(format in pct: x, y, width, height)
    // MWB_setScanningRect(MWB_CODE_MASK_25,     RECT_LANDSCAPE_1D);
    // MWB_setScanningRect(MWB_CODE_MASK_39,     RECT_LANDSCAPE_1D);
    // MWB_setScanningRect(MWB_CODE_MASK_93,     RECT_LANDSCAPE_1D);
    // MWB_setScanningRect(MWB_CODE_MASK_128,    RECT_LANDSCAPE_1D);
    // MWB_setScanningRect(MWB_CODE_MASK_AZTEC,  RECT_LANDSCAPE_2D);
    // MWB_setScanningRect(MWB_CODE_MASK_DM,     RECT_LANDSCAPE_2D);
    // MWB_setScanningRect(MWB_CODE_MASK_EANUPC, RECT_LANDSCAPE_1D);
    // MWB_setScanningRect(MWB_CODE_MASK_PDF,    RECT_LANDSCAPE_1D);
    // MWB_setScanningRect(MWB_CODE_MASK_QR,     RECT_LANDSCAPE_2D);
    // MWB_setScanningRect(MWB_CODE_MASK_RSS,    RECT_LANDSCAPE_1D);
    // MWB_setScanningRect(MWB_CODE_MASK_CODABAR,RECT_LANDSCAPE_1D);
    // MWB_setScanningRect(MWB_CODE_MASK_DOTCODE,RECT_DOTCODE);
    // MWB_setScanningRect(MWB_CODE_MASK_11,     RECT_LANDSCAPE_1D);
    // MWB_setScanningRect(MWB_CODE_MASK_MSI,    RECT_LANDSCAPE_1D);
    
    
    // set decoder effort level (1 - 5)
    // for live scanning scenarios, a setting between 1 to 3 will suffice
    // levels 4 and 5 are typically reserved for batch scanning
    MWB_setLevel(2);
    
    //Set minimum result length for low-protected barcode types
    MWB_setMinLength(MWB_CODE_MASK_25, 1);
    MWB_setMinLength(MWB_CODE_MASK_MSI, 1);
    MWB_setMinLength(MWB_CODE_MASK_39, 1);
    MWB_setMinLength(MWB_CODE_MASK_CODABAR, 1);
    MWB_setMinLength(MWB_CODE_MASK_11, 1);
    
    //Use MWResult class instead of barcode raw byte array as result
    MWB_setResultType(MWB_RESULT_TYPE_MW);
    
    //get and print Library version
    int ver = MWB_getLibVersion();
    int v1 = (ver >> 16);
    int v2 = (ver >> 8) & 0xff;
    int v3 = (ver & 0xff);
    NSString *libVersion = [NSString stringWithFormat:@"%d.%d.%d", v1, v2, v3];
    NSLog(@"Lib version: %@", libVersion);
    
    
}

- (void)dealloc
{
#if !__has_feature(objc_arc)
	[super dealloc];
#endif
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.prevLayer = nil;
//	[[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(decodeResultNotification:) name: DecoderResultNotification object: nil];
	
	param_ZoomLevel1 = 0; //set non-automatic
	param_ZoomLevel2 = 0; //set non-automatic
	zoomLevel = 1;
	
	[self initDecoder];
	
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
#if TARGET_IPHONE_SIMULATOR
    NSLog(@"On iOS simulator camera is not Supported");
#else
	[self initCapture];
#endif
    [self startScanning];
}

- (void)viewWillDisappear:(BOOL) animated
{
    [super viewWillDisappear:animated];
    [self stopScanning];
    [self deinitCapture];
}

- (void)viewDidUnload
{
	[self stopScanning];
	
	self.prevLayer = nil;
	[super viewDidUnload];
}

// IOS 7 statusbar hide
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
	/*
	UIInterfaceOrientation interfaceOrientation =[[UIApplication sharedApplication] statusBarOrientation];
	
	switch (interfaceOrientation) {
		case UIInterfaceOrientationPortrait:
			return UIInterfaceOrientationMaskPortrait;
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			return UIInterfaceOrientationMaskPortraitUpsideDown;
			break;
		case UIInterfaceOrientationLandscapeLeft:
			return UIInterfaceOrientationMaskLandscapeLeft;
			break;
		case UIInterfaceOrientationLandscapeRight:
			return UIInterfaceOrientationMaskLandscapeRight;
			break;
			
		default:
			break;
	}
	*/
	return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
	return UIInterfaceOrientationPortrait;
}

- (BOOL) shouldAutorotate
{
	
	return YES;
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft){
		self.prevLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
		self.prevLayer.frame = CGRectMake(0, 0, MAX(self.view.frame.size.width,self.view.frame.size.height), MIN(self.view.frame.size.width,self.view.frame.size.height));
	}
	if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight){
		self.prevLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
		self.prevLayer.frame = CGRectMake(0, 0, MAX(self.view.frame.size.width,self.view.frame.size.height), MIN(self.view.frame.size.width,self.view.frame.size.height));
	}
	
	
	if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
		self.prevLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
		self.prevLayer.frame = CGRectMake(0, 0, MIN(self.view.frame.size.width,self.view.frame.size.height), MAX(self.view.frame.size.width,self.view.frame.size.height));
	}
	if (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		self.prevLayer.connection.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
		self.prevLayer.frame = CGRectMake(0, 0, MIN(self.view.frame.size.width,self.view.frame.size.height), MAX(self.view.frame.size.width,self.view.frame.size.height));
	}
#if USE_MWOVERLAY
	[MWOverlay updateOverlay];
#endif
}

/*
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];

	if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft){
		self.prevLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
		self.prevLayer.frame = CGRectMake(0, 0, MAX(self.view.frame.size.width,self.view.frame.size.height), MIN(self.view.frame.size.width,self.view.frame.size.height));
	}
	if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight){
		self.prevLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
		self.prevLayer.frame = CGRectMake(0, 0, MAX(self.view.frame.size.width,self.view.frame.size.height), MIN(self.view.frame.size.width,self.view.frame.size.height));
	}
	
	
	if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
		self.prevLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
		self.prevLayer.frame = CGRectMake(0, 0, MIN(self.view.frame.size.width,self.view.frame.size.height), MAX(self.view.frame.size.width,self.view.frame.size.height));
	}
	if (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		self.prevLayer.connection.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
		self.prevLayer.frame = CGRectMake(0, 0, MIN(self.view.frame.size.width,self.view.frame.size.height), MAX(self.view.frame.size.width,self.view.frame.size.height));
	}
	
	[MWOverlay updateOverlay];

}
*/

#pragma mark - Notifications
//
- (void) onVideoStart: (NSNotification*) note
{
	if(running)
		return;
	running = YES;
	
	// lock device and set focus mode
	NSError *error = nil;
	if([self.device lockForConfiguration: &error])
	{
		if([self.device isFocusModeSupported: AVCaptureFocusModeContinuousAutoFocus])
			self.device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
	}
}

- (void) onVideoStop: (NSNotification*) note
{
	if(!running)
		return;
	[self.device unlockForConfiguration];
	running = NO;
}

- (void)decodeResultNotification: (NSNotification *)notification
{
	
	if ([notification.object isKindOfClass:[DecoderResult class]])
	{
		DecoderResult *obj = (DecoderResult*)notification.object;
		if (obj.succeeded)
		{
			decodeResult = [[NSString alloc] initWithString:obj.result.text];
			UIAlertView * messageDlg = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Format: %@",lastFormat] message:decodeResult
																 delegate:self cancelButtonTitle:nil otherButtonTitles:@"Close", nil];
			[messageDlg show];
		}
	}
}



#pragma mark - Actions
//
- (void)doZoomToggle:(id)sender
{
	zoomLevel++;
	if (zoomLevel > 2){
		zoomLevel = 0;
	}
	
	[self updateDigitalZoom];
	
}



#pragma mark - Core logic
//
- (void) initCapture
{
	/*We setup the input*/
	self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	
	AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
	
	
	if (captureInput == nil){
		NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
		[[[UIAlertView alloc] initWithTitle:@"Camera Unavailable" message:[NSString stringWithFormat:@"The %@ has not been given a permission to your camera. Please check the Privacy Settings: Settings -> %@ -> Privacy -> Camera", appName, appName] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
		
		return;
	}
	
	
	/*We setupt the output*/
	AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
	captureOutput.alwaysDiscardsLateVideoFrames = YES;
	//captureOutput.minFrameDuration = CMTimeMake(1, 10); Uncomment it to specify a minimum duration for each video frame
	[captureOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
	// Set the video output to store frame in BGRA (It is supposed to be faster)
	
	NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
	// Set the video output to store frame in 422YpCbCr8(It is supposed to be faster)
	
	//************************Note this line
	NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange];
	
	NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
	[captureOutput setVideoSettings:videoSettings];
	
	//And we create a capture session
	self.captureSession = [[AVCaptureSession alloc] init];
	//We add input and output
	[self.captureSession addInput:captureInput];
	[self.captureSession addOutput:captureOutput];
	
	
	
//	if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720])
//	{
//		NSLog(@"Set preview port to 1280X720");
//		self.captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
//	} else
		//set to 640x480 if 1280x720 not supported on device
		if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset640x480])
		{
			NSLog(@"Set preview port to 640X480");
			self.captureSession.sessionPreset = AVCaptureSessionPreset640x480;
		}
	
	
	// Limit camera FPS to 15 for single core devices (iPhone 4 and older) so more CPU power is available for decoder
	host_basic_info_data_t hostInfo;
	mach_msg_type_number_t infoCount;
	infoCount = HOST_BASIC_INFO_COUNT;
	host_info( mach_host_self(), HOST_BASIC_INFO, (host_info_t)&hostInfo, &infoCount ) ;
	
	if (hostInfo.max_cpus < 2){
		if ([self.device respondsToSelector:@selector(setActiveVideoMinFrameDuration:)]){
			[self.device lockForConfiguration:nil];
			[self.device setActiveVideoMinFrameDuration:CMTimeMake(1, 15)];
			[self.device unlockForConfiguration];
		} else {
			AVCaptureConnection *conn = [captureOutput connectionWithMediaType:AVMediaTypeVideo];
			[conn setVideoMinFrameDuration:CMTimeMake(1, 15)];
		}
	}
	
    NSLog(@"hostInfo.max_cpus %d",hostInfo.max_cpus);
    availableThreads = MIN(MAX_THREADS, hostInfo.max_cpus);
    activeThreads = 0;
	
	/*We add the preview layer*/
	
	self.prevLayer = [AVCaptureVideoPreviewLayer layerWithSession: self.captureSession];
	
	
	if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft){
		self.prevLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
		self.prevLayer.frame = CGRectMake(0, 0, MAX(self.view.frame.size.width,self.view.frame.size.height), MIN(self.view.frame.size.width,self.view.frame.size.height));
	}
	if (self.interfaceOrientation == UIInterfaceOrientationLandscapeRight){
		self.prevLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
		self.prevLayer.frame = CGRectMake(0, 0, MAX(self.view.frame.size.width,self.view.frame.size.height), MIN(self.view.frame.size.width,self.view.frame.size.height));
	}
	
	
	if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
		self.prevLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
		self.prevLayer.frame = CGRectMake(0, 0, MIN(self.view.frame.size.width,self.view.frame.size.height), MAX(self.view.frame.size.width,self.view.frame.size.height));
	}
	if (self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		self.prevLayer.connection.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
		self.prevLayer.frame = CGRectMake(0, 0, MIN(self.view.frame.size.width,self.view.frame.size.height), MAX(self.view.frame.size.width,self.view.frame.size.height));
	}
	
	
	self.prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	[self.view.layer addSublayer: self.prevLayer];
#if USE_MWOVERLAY
	[MWOverlay addToPreviewLayer:self.prevLayer];
#endif
	
	
	videoZoomSupported = false;
	
	if ([self.device respondsToSelector:@selector(setActiveFormat:)] &&
		[self.device.activeFormat respondsToSelector:@selector(videoMaxZoomFactor)] &&
		[self.device respondsToSelector:@selector(setVideoZoomFactor:)]){
		
		float maxZoom = 0;
		if ([self.device.activeFormat respondsToSelector:@selector(videoZoomFactorUpscaleThreshold)]){
			maxZoom = self.device.activeFormat.videoZoomFactorUpscaleThreshold;
		} else {
			maxZoom = self.device.activeFormat.videoMaxZoomFactor;
		}
		
		float maxZoomTotal = self.device.activeFormat.videoMaxZoomFactor;
		
		if ([self.device respondsToSelector:@selector(setVideoZoomFactor:)] && maxZoomTotal > 1.1){
			videoZoomSupported = true;
			
			
			
			if (param_ZoomLevel1 != 0 && param_ZoomLevel2 != 0){
				
				if (param_ZoomLevel1 > maxZoomTotal * 100){
					param_ZoomLevel1 = (int)(maxZoomTotal * 100);
				}
				if (param_ZoomLevel2 > maxZoomTotal * 100){
					param_ZoomLevel2 = (int)(maxZoomTotal * 100);
				}
				
				firstZoom = 0.01 * param_ZoomLevel1;
				secondZoom = 0.01 * param_ZoomLevel2;
				
				
			} else {
				
				if (maxZoomTotal > 2){
					
					if (maxZoom > 1.0 && maxZoom <= 2.0){
						firstZoom = maxZoom;
						secondZoom = maxZoom * 2;
					} else
						if (maxZoom > 2.0){
							firstZoom = 2.0;
							secondZoom = 4.0;
						}
					
				}
			}
			
			
		} else {
			
		}
		
		
		
		
	}
    
    [self updateDigitalZoom];
	
	self.focusTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(reFocus) userInfo:nil repeats:YES];
}

- (void) reFocus
{
   //NSLog(@"refocus");

    NSError *error;
    if ([self.device lockForConfiguration:&error]) {
		
        if ([self.device isFocusPointOfInterestSupported]){
            [self.device setFocusPointOfInterest:CGPointMake(0.49,0.49)];
            [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        [self.device unlockForConfiguration];
		
    }
}

- (void) toggleTorch
{
    if ([self.device isTorchModeSupported:AVCaptureTorchModeOn]) {
        NSError *error;
		
        if ([self.device lockForConfiguration:&error]) {
            if ([self.device torchMode] == AVCaptureTorchModeOn)
                [self.device setTorchMode:AVCaptureTorchModeOff];
            else
                [self.device setTorchMode:AVCaptureTorchModeOn];
			
            if([self.device isFocusModeSupported: AVCaptureFocusModeContinuousAutoFocus])
                self.device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
            
            [self.device unlockForConfiguration];
        } else {
            
        }
    }
}

- (void) startScanning
{
	self.state = LAUNCHING_CAMERA;
	[self.captureSession startRunning];
	self.prevLayer.hidden = NO;
	self.state = CAMERA;
}

- (void) stopScanning
{
	[self.captureSession stopRunning];
	self.state = NORMAL;
	self.prevLayer.hidden = YES;
	
	
}

- (void) deinitCapture
{
	if (self.focusTimer){
		[self.focusTimer invalidate];
		self.focusTimer = nil;
	}
	
	if (self.captureSession != nil){
#if USE_MWOVERLAY
		[MWOverlay removeFromPreviewLayer];
#endif
		
#if !__has_feature(objc_arc)
		[self.captureSession release];
#endif
		self.captureSession=nil;
		
		[self.prevLayer removeFromSuperlayer];
		self.prevLayer = nil;
	}
}

- (void) updateDigitalZoom
{
	
	if (videoZoomSupported){
		
		[self.device lockForConfiguration:nil];
		
		[self.device setVideoZoomFactor:1 /*rampToVideoZoomFactor:1 withRate:4*/];

/* Remove zooming at all - use default value = 1 */
//
//		switch (zoomLevel) {
//			case 0:
//				[self.device setVideoZoomFactor:1 /*rampToVideoZoomFactor:1 withRate:4*/];
//				break;
//			case 1:
//				[self.device setVideoZoomFactor:firstZoom /*rampToVideoZoomFactor:firstZooom withRate:4*/];
//				break;
//			case 2:
//				[self.device setVideoZoomFactor:secondZoom /*rampToVideoZoomFactor:secondZoom withRate:4*/];
//				break;
//				
//			default:
//				break;
//		}
		[self.device unlockForConfiguration];
		
	}
}



#pragma mark - AVCaptureSession delegate
//
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    if (state != CAMERA && state != CAMERA_DECODING) {
        return;
    }
    
    if (activeThreads >= availableThreads){
        return;
    }
    
    if (self.state != CAMERA_DECODING)
    {
        self.state = CAMERA_DECODING;
    }
    
    activeThreads++;
    
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    //Lock the image buffer
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    //Get information about the image
    baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer,0);
    int pixelFormat = CVPixelBufferGetPixelFormatType(imageBuffer);
    switch (pixelFormat) {
        case kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange:
            //NSLog(@"Capture pixel format=NV12");
            bytesPerRow = (int) CVPixelBufferGetBytesPerRowOfPlane(imageBuffer,0);
            width = bytesPerRow;//CVPixelBufferGetWidthOfPlane(imageBuffer,0);
            height = (int) CVPixelBufferGetHeightOfPlane(imageBuffer,0);
            break;
        case kCVPixelFormatType_422YpCbCr8:
            //NSLog(@"Capture pixel format=UYUY422");
            bytesPerRow = (int) CVPixelBufferGetBytesPerRowOfPlane(imageBuffer,0);
            width = (int) CVPixelBufferGetWidth(imageBuffer);
            height = (int) CVPixelBufferGetHeight(imageBuffer);
            int len = width*height;
            int dstpos=1;
            for (int i=0;i<len;i++){
                baseAddress[i]=baseAddress[dstpos];
                dstpos+=2;
            }
            
            break;
        default:
            //	NSLog(@"Capture pixel format=RGB32");
            break;
    }
    
    
    unsigned char *frameBuffer = malloc(width * height);
    memcpy(frameBuffer, baseAddress, width * height);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        
        unsigned char *pResult=NULL;
        
        int resLength = MWB_scanGrayscaleImage(frameBuffer,width,height, &pResult);
        
        
        free(frameBuffer);
        
        
        NSLog(@"Frame decoded. Active threads: %d", activeThreads);
        
        MWResults *mwResults = nil;
        MWResult *mwResult = nil;
        if (resLength > 0){
            
            if (self.state == NORMAL){
                resLength = 0;
                free(pResult);
                
            } else {
                mwResults = [[MWResults alloc] initWithBuffer:pResult];
                if (mwResults && mwResults.count > 0){
                    mwResult = [mwResults resultAtIntex:0];
                }
                
                free(pResult);
            }
        }
        
        //CVPixelBufferUnlockBaseAddress(imageBuffer,0);
        
        //ignore results less than 4 characters - probably false detection
        if (mwResult)
        {
            
            self.state = NORMAL;
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self.captureSession stopRunning];
#if USE_MWOVERLAY
//                [MWOverlay showLocation:mwResult.locationPoints.points imageWidth:mwResult.imageWidth imageHeight:mwResult.imageHeight];
#endif
                NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
                DecoderResult *notificationResult = [DecoderResult createSuccess:mwResult];
                [center postNotificationName:DecoderResultNotification object: notificationResult];
            });
            
        }
        else
        {
            self.state = CAMERA;
        }
        
        
        activeThreads --;
        
    });
}

#pragma mark - UIAlertViewDelegate
//
- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self startScanning];
    }
}



- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
#if USE_TOUCH_TO_ZOOM
    [self doZoomToggle:nil];
#else
    [self toggleTorch];
#endif
}

@end



/*
 *  Implementation of the object that returns decoder results (via the notification
 *	process)
 */

@implementation DecoderResult

@synthesize succeeded;
@synthesize result;

+(DecoderResult *)createSuccess:(MWResult *)result {
	DecoderResult *obj = [[DecoderResult alloc] init];
	if (obj != nil) {
		obj.succeeded = YES;
		obj.result = result;
	}
	return obj;
}

+(DecoderResult *)createFailure {
	DecoderResult *obj = [[DecoderResult alloc] init];
	if (obj != nil) {
		obj.succeeded = NO;
		obj.result = nil;
	}
	return obj;
}

- (void)dealloc {
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
	self.result = nil;
}



@end
