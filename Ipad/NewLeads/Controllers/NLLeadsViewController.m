//
//  NewLeadsVC.m
//  NewLeads
//
//  Created by idevs.com on 27/06/2011.
//  Copyright 2011 idevs.com. All rights reserved.
//

#import "NLLeadsViewController.h"
#import "NLAppDelegate.h"
#import "NLNavigationController.h"
#import "NLStartPageVC.h"
#import "NLStatistics.h"
#import "NLSettingsVC.h"
//
#import "NLDeviceController.h"
#import "NLHandledVC.h"
#import "NLCropViewController.h"
#import "NLCaptureViewController.h"
#import "NLImagePreviewViewController.h"
#import "NLSocketScannerController.h"
//
// Assets:
#import "MWScannerViewController.h"
#import "AJDMasterViewController.h"
#import "MWResult.h"
//
// Categories:
#import "UIImage+Alpha.h"
#import "UIImage+Resize.h"
//


typedef NS_ENUM(NSInteger, NLScreens)
{
	kScreenLeads = 0,
};


@interface NLLeadsViewController ()
<
	NLCaptureViewControllerDelegate,
	UIActionSheetDelegate,
	UIImagePickerControllerDelegate,
	UINavigationControllerDelegate,
	UIGestureRecognizerDelegate,
    AJDMasterViewControllerDelegate
>
//
// UI - XIB:
@property (nonatomic, assign) IBOutlet UIView				* viewContainer;
@property (nonatomic, assign) IBOutlet UIImageView			* viewBG;
@property (nonatomic, assign) IBOutlet UIToolbar			* viewToolbar;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint	* constraintToolbarTop;
@property (nonatomic, assign) IBOutlet UISegmentedControl	* viewSegments;
@property (nonatomic, strong) IBOutlet UIBarButtonItem		* btnSettings;
//
// UI:
@property (nonatomic, retain) UIActionSheet			* actionSheetMediaSource;
@property (nonatomic, retain) UIActionSheet			* sheetScanSource;
@property (nonatomic, retain) UIPopoverController	* popoverImagePicker;
//
// Logic:
@property (nonatomic, retain) NLStatistics			* stat;
//
//
// Hierarchy:
@property (nonatomic, retain) NSMutableDictionary	* dicScreens;
@property (nonatomic, assign) UIViewController		* currentVC;
@property (nonatomic, assign) NSInteger				currentScreenIdx;

@property (nonatomic, retain) ACRAudioJackReader    * reader;


- (void) deviceSetup;

- (void) nfcReaderSetup;

@end



@implementation NLLeadsViewController

- (void) viewDidLoad 
{
    [super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifications:) name:kNLNotifLogoutWasSuccessful object:nil];
	
	[NLStatistics enableDebug: NO];
	self.stat = [[NLStatistics alloc] init];
	
	[self onHideSettings:nil];
	
	[self toggleScreen:kScreenLeads];
	
	[self deviceSetup];
    
    [self nfcReaderSetup];
	
	[self socketScannerSetup];
	
	[self updateUI];
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	self.navigationItem.rightBarButtonItem = self.barLogo;

	//if( !IOS8_OR_HIGHER )
	{
		self.constraintToolbarTop.constant = 1;

		[self.view updateConstraints];
	}
	
    [self updateScanner];
	[self updateUI];
	
	if( [self.currentVC isKindOfClass:[NLStartPageVC class]] && !((NLStartPageVC *)self.currentVC).isLoaded )
	{
		[(NLStartPageVC *)self.currentVC goHome:NO];
	}
}

- (void) cleanup
{
    if (self.actionSheetMediaSource && self.actionSheetMediaSource.isVisible)
    {
        [self.actionSheetMediaSource dismissWithClickedButtonIndex:-1 animated:NO];
    }
    self.actionSheetMediaSource = nil;

	//
	// Clean lead:
	[[NLContext shared] cleanLeadData];
	
	self.stat = nil;
	
	[self updateUI];
}



#pragma mark - Notifications
//
- (void) notifications:(NSNotification *)anNotif
{
	[super notifications:anNotif];
	
	NSString * name = anNotif.name;
	
	if( [name isEqualToString:DecoderResultNotification] ) // Bar code scanner
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self name:DecoderResultNotification object:nil];
		
		DecoderResult * obj = (DecoderResult *)anNotif.object;
		if(obj.succeeded)
		{
            NSString * decodeResult = [[NSString alloc] initWithBytes:obj.result.bytes length:obj.result.bytesLength encoding:NSUTF8StringEncoding];
			
			if( 0 != decodeResult.length )
			{
				[self uploadScannedData:[decodeResult dataUsingEncoding:NSUTF8StringEncoding]];
			}
		}
		[self dismissViewControllerAnimated:YES completion:^(void)
		{
			self.sheetScanSource = nil;
		}];
	}
	else if( [kNLNotifLogoutWasSuccessful isEqualToString:name] )
	{
		// Do something useful...
	}
}



#pragma mark - Actions
//
- (IBAction) onButtonSettings:(id)sender
{
	NLSettingsVC * svc = [NLSettingsVC new];
	
	[svc setupChangesBlock:[self settingsChangesBlock]];
	
	[self.navigationController pushViewController:svc animated:YES];
	
	[self onHideSettings:nil];
}

- (IBAction) onSegment:(id)sender
{
	NSInteger idx = self.viewSegments.selectedSegmentIndex;
	
	if( ![self.viewSegments isEnabledForSegmentAtIndex:idx] )
	{
		return;
	}
	
	if( 0 == idx ) // BizCard
	{
		[self showCaptureController];
	}
	else if( 1 == idx ) // Barcode
	{
		[self showBarcodeController];
	}
//	else if( 2 == idx ) // Intermec
//	{
//		[self showHandletController];
//	}
}

- (IBAction) onShowSettings:(id)sender
{
	if( [[self.viewToolbar items] containsObject:self.btnSettings] )
	{
		return;
	}
	
	NSMutableArray * items = [[self.viewToolbar items] mutableCopy];
	
	[items addObject:self.btnSettings];
	
	[self.viewToolbar setItems:items animated:NO];
}

- (IBAction) onHideSettings:(id)sender
{
	NSMutableArray * items = [[self.viewToolbar items] mutableCopy];
	
	[items removeObject:self.btnSettings];
	
	[self.viewToolbar setItems:items animated:NO];
}

- (void) onCloseBarcodeController:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void) onCloseHandledController:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - Core logic
//
- (void) toggleScreen:(NLScreens) screenIndex
{
	NSString * screenKey = [NSString stringWithFormat:@"screen%ld", (long)screenIndex];
	
	if( !self.dicScreens )
	{
		self.dicScreens = [NSMutableDictionary dictionary];
	}
	
	UIViewController * nextVC = (UIViewController *)[self.dicScreens valueForKey:screenKey];
	
	if( !nextVC )
	{
		if( kScreenLeads == screenIndex )
		{
			nextVC = [NLStartPageVC new];
			((NLStartPageVC *)nextVC).leadsVC = self;
		}
		
		[self.dicScreens setValue:nextVC forKey:screenKey];

		NSInteger topPos = self.constraintToolbarTop.constant;
		
		nextVC.view.frame = CGRectMake(0, topPos, CGRectGetWidth(self.viewContainer.frame), CGRectGetHeight(self.viewContainer.frame));
		
		[self addChildViewController:nextVC];
		if( self.isViewLoaded )
		{
			[self.viewContainer addSubview:nextVC.view];
		}
		[nextVC didMoveToParentViewController:self];
	}
	else
	{
		[nextVC viewDidAppear:YES];
	}
	
	if( kScreenLeads == screenIndex )
	{
		[(NLStartPageVC *)nextVC goHome:NO];
	}
	
	[self.viewContainer bringSubviewToFront:nextVC.view];
	
	self.currentVC = nextVC;
	self.currentScreenIdx = screenIndex;
}

- (void) updateUI
{
    CGRect frame= self.viewSegments.frame;
    [self.viewSegments setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 72)];
    
	[self.viewSegments setEnabled:[NLContext shared].isBizCardAvail forSegmentAtIndex:0];
	[self.viewSegments setEnabled:[NLContext shared].isBarCodeAvail forSegmentAtIndex:1];
	//[self.viewSegments setEnabled:[NLContext shared].isIntermecAvail forSegmentAtIndex:2];
	
	//
	// Update client logo:
	self.navigationItem.leftBarButtonItem = nil;
}

- (void) updateScanner
{
// refreshing scanner availability when play with scan and go switch and stay on the web page at the same time
//    NSString* myLink = [NLContext shared].scanPage;
//    if( NSNotFound != [myLink rangeOfString:kPageRecentLink].location || NSNotFound != [myLink rangeOfString:kPageClickToBeginLink].location)
//    {
//        [self initScanner:[NLContext shared].isScanAndGo];
//        [self initSocketScanner:[NLContext shared].isScanAndGo];
//    }
//    else
//        if (NSNotFound != [myLink rangeOfString:kPageEditleadName].location)
//        {
//            [self initScanner:![NLContext shared].isScanAndGo];
//            [self initSocketScanner:![NLContext shared].isScanAndGo];
//        }
//        else
//        {
//            [self initScanner:NO];
//            [self initSocketScanner:NO];
//        }
//    [self initScanner:NO];
//    [self initSocketScanner:NO];
}

- (void) initScanner:(BOOL) anFlag
{
	self.viewSegments.enabled	= anFlag;
    // ?! Ask BA for proper docs
	//self.btnSettings.enabled	= anFlag;
	
	if( anFlag )
	{
		[[NLDeviceController device] connect];
	}
	else
	{
		[[NLDeviceController device] disconnect];
	}
}

- (void) deviceSetup
{
	NLDeviceStateBlock stateBlock = ^(NLDeviceController * device, kDeviceState state)
	{
		switch( state )
		{
			case kDeviceStateUnknown:
			{
				[NLAlertView showError:@"Device not detected."];
//				[selectorView setScannerLabelText:@"No scanner detected"];
			}
				break;
			case kDeviceStateDisconnected:
			{
//				[selectorView setScannerLabelText:@"Disconnected"];
				NSError * error = [NLDeviceController device].error;
				
				if( error )
				{
					[NLAlertView showError:[error localizedDescription]];
				}

				NSLog(@"State \"kDeviceStateDisconnected\": %@", error);
			}
				break;
			case kDeviceStateConnecting:
			{
//				[selectorView setScannerLabelText:@"Connecting..."];
			}
				break;
			case kDeviceStateConnected:
			{
//				[selectorView setScannerLabelText:@"Ready"];
			}
				break;
			case kDeviceStateDataGathering:
			{
//				[selectorView setScannerLabelText:@"Reading..."];
			}
				break;
			case kDeviceStateDataReady:
			{
//TODO:				[selectorView setScannerLabelText:@"Data sending..."];
				[self uploadScannedData:device.data];
//TODO:				[selectorView setScannerLabelText:@"Ready"];
			}
				break;
			case kDeviceStateDataFailed:
			{
				NSError * error = [NLDeviceController device].error;
				
				if( error )
				{
					[NLAlertView showError:[error localizedDescription]];
				}
				
				NSLog(@"State \"kDeviceStateDataFailed\": %@", error);
			}
				break;
		}
	};
	
	NLDeviceInfoBlock infoBlock = ^(NLDeviceController * device, NSString * info)
	{
//		[selectorView setScannerLabelText:info];
	};
	
	[NLDeviceController device].stateBlock = stateBlock;
	[NLDeviceController device].infoBlock = infoBlock;
}

- (NLSettingsDidChangedBlock) settingsChangesBlock
{
	return [^(NLSettingsVC * settings)
	{
		[self updateUI];
        
        if (settings.urlChanged)
        {
            if( [self.currentVC isKindOfClass:[NLStartPageVC class]])
            {
                [(NLStartPageVC *)self.currentVC goHome:YES];
                settings.urlChanged = NO;
            }
        }
  	} copy];
}

- (void) uploadImageData:(NSData *) anData
{
	if( [self.currentVC isKindOfClass:[NLStartPageVC class]] )
	{
		[(NLStartPageVC *)self.currentVC uploadImageData:anData];
	}
}

- (void) uploadScannedData:(NSData *) anData
{
	if( [self.currentVC isKindOfClass:[NLStartPageVC class]] )
	{
		[(NLStartPageVC *)self.currentVC sendScannedData:anData forStation:[NLContext shared].stationID];
	}
}

#pragma mark - Socket Scanner
//
- (void) initSocketScanner:(BOOL) anFlag
{
	if( anFlag )
	{
		[[NLSocketScannerController device] connect];
	}
	else
	{
		[[NLSocketScannerController device] disconnect];
	}
}

- (void) socketScannerSetup
{
	NLSocketScannerStateBlock stateBlock = ^(NLSocketScannerController * ssController, int state)
	{
		switch(state)
		{
			case 0: // Error
			{
			}
				break;
			case 1: // OK
			{
				[self uploadScannedData:[ssController data]];
			}
				break;
		}
	};
	
	[NLSocketScannerController device].stateBlock = stateBlock;
}


#pragma mark - NFC reader

-(void) nfcReaderSetup
{
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted) {
            NSLog(@"Mic permission granted");
            // Listen the audio route change.
            
            if (!self.reader)
              self.reader = [[ACRAudioJackReader alloc] initWithMute:YES];
            
            AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, NLAudioRouteChangeListener, (__bridge void *) self);
        }
        else {
            NSLog(@"Mic permission denied");
        }
    }];
}

static BOOL AJDIsReaderPlugged() {
    
    BOOL plugged = NO;
    CFStringRef route = NULL;
    UInt32 routeSize = sizeof(route);
    
    if (AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &routeSize, &route) == kAudioSessionNoError) {
        if (CFStringCompare(route, CFSTR("Headphone"), kCFCompareCaseInsensitive) == kCFCompareEqualTo ||
            (CFStringCompare(route, CFSTR("HeadsetInOut"), kCFCompareCaseInsensitive) == kCFCompareEqualTo))
        {
            plugged = YES;
        }
    }
    
    return plugged;
}

static void NLAudioRouteChangeListener(void *inClientData, AudioSessionPropertyID inID, UInt32 inDataSize, const void *inData) {
    
    NLLeadsViewController *viewController = (__bridge NLLeadsViewController *) inClientData;
    
    if( [viewController.currentVC isKindOfClass:[NLStartPageVC class]] )
    {
    if (AJDIsReaderPlugged())
    {
        // show NFC controller
        NSLog(@"Show NFC VC");
        
        if (!viewController.presentedViewController)
        {
            AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_AudioRouteChange, NLAudioRouteChangeListener, (__bridge void *)(viewController));
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NFC" bundle: nil];
            
            UINavigationController* navMasterViewController = [storyboard instantiateInitialViewController];
            
            [(AJDMasterViewController*)(navMasterViewController.topViewController) setMasterDelegate:viewController andReader:viewController.reader];
            
            [viewController presentViewController:navMasterViewController animated:YES completion:nil];
        }
    }
    }
}

- (void) didFinishedAJDMasterViewController
{
    // hide NFC controller
    NSLog(@"Hide NFC VC");
    
    if (self.presentedViewController)
    {
        [self dismissViewControllerAnimated:YES completion:
         ^
         {
             [self nfcReaderSetup];
         }
         ];
    }
}

- (void) didReceivedRawData:(NSString *)aRawData
{
    if ([NLDeviceController device].cardMode)
    {
        NSData * scanData = [aRawData dataUsingEncoding:NSUTF8StringEncoding];
        [self uploadScannedData:scanData];
    }
}

- (void) didReceivedEncodedData:(NSString *)aEncodedData
{
    if (![NLDeviceController device].cardMode)
    {
        NSData * scanData = [aEncodedData dataUsingEncoding:NSUTF8StringEncoding];
        [self uploadScannedData:scanData];
    }
}


#pragma mark - UIActionSheet delegate
//
- (void) actionSheet:(UIActionSheet*)action_sheet clickedButtonAtIndex:(NSInteger)button_index
{
	// Override me in the subclass
}

- (void) imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
	UIImage* image = info[UIImagePickerControllerOriginalImage];
	if (!image || image.size.height<=0 || image.size.width<=0)
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Bad image" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		return;
		
	}
	
	if(self.popoverImagePicker)
	{
		[self.popoverImagePicker dismissPopoverAnimated:YES];
		self.popoverImagePicker = nil;
		
		[self performSelector:@selector(showCropControllerWithImage:) withObject:image afterDelay:0.4];
	}
	else
	{
		[picker dismissViewControllerAnimated:YES completion:^(void)
		 {
			 //[self performSelector:@selector(showCropControllerWithImage:) withObject:image afterDelay:0.1];
		 }];
	}
	
	
	
	
	// work with image
	
	/*UIImageWriteToSavedPhotosAlbum(image,
	 self, // send the message to 'self' when calling the callback
	 nil,
	 NULL); // you gen*/
	
	NSLog(@"src img size = %@", NSStringFromCGSize(image.size));
	
	UIImage *imageToDisplay = [image fixrotation];
	
	
	
	// CGSize origSize = image.size;
	
	UIImage* croppedImage1 = [imageToDisplay croppedImage:CGRectMake(104, 180, image.size.width-104*2, image.size.height-46*2-180*2)];
	
	
	UIImage* croppedImage = [croppedImage1 aspectFillWithSize:CGSizeMake(1400, 800)];
	NSLog(@"cropped img size = %@", NSStringFromCGSize(croppedImage.size));
	UIImage* grayScaledImage = [croppedImage grayscaledImage];
	
	NSLog(@"grayScaledImage img size = %@", NSStringFromCGSize(imageToDisplay.size));
	NSData *imageData = UIImageJPEGRepresentation(grayScaledImage, 0.85f);
	
	/*UIImageWriteToSavedPhotosAlbum(grayScaledImage,
	 self, // send the message to 'self' when calling the callback
	 nil,
	 NULL); // you gen*/
	
//TODO:	[selectorView setScannerLabelText:@"Uploading image..."];

	[self uploadImageData:imageData];
	
//TODO:	[selectorView setScannerLabelText:@"Ready"];
	
	/*
	 // Create paths to output images
	 NSString  *pngPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test111.png"];
	 
	 // Write image to PNG
	 [UIImagePNGRepresentation(grayScaledImage) writeToFile:pngPath atomically:YES];
	 
	 // Let's check to see if files were successfully written...
	 
	 // Create file manager
	 NSError *error;
	 NSFileManager *fileMgr = [NSFileManager defaultManager];
	 
	 // Point to Document directory
	 NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
	 
	 // Write out the contents of home directory to console
	 NSLog(@"Documents directory:%@, %@", documentsDirectory, [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
	 */
}

- (void) showImagePickerPopover
{
	UIImagePickerController * ipvc = [UIImagePickerController new];
	ipvc.delegate	= self;
	ipvc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	
	[self presentViewController:ipvc animated:YES completion:nil];
}

- (void) showCaptureController
{
	NLCaptureViewController * nlc = [NLCaptureViewController new];
		
	nlc.delegate = self;
	
	[self presentViewController:nlc animated:YES completion:nil];
}

- (void) showCameraWithOverlay
{
	UIImagePickerController * ipvc = [[UIImagePickerController alloc] init];
	ipvc.delegate	= self;
	ipvc.sourceType = UIImagePickerControllerSourceTypeCamera;
	
	// CGFloat height = controller.navigationBar.frame.size.height;
	// NSLog(@"h=%f",height);
	//Create camera overlay
	CGRect f = CGRectMake(0, 0, 768, 1024-52);
	CGSize s = CGSizeMake(1400, 800);
	CGRect o = CGRectMake((f.size.width-s.width/2)/2, (f.size.height-s.height/2)/2, s.width/2, s.height/2);
	
	UIGraphicsBeginImageContext(f.size);
	[[UIColor colorWithWhite:0 alpha:.5] set];
	UIRectFillUsingBlendMode(CGRectMake(0, 0, f.size.width, f.size.height), kCGBlendModeNormal);
	[[UIColor colorWithWhite:0 alpha:0] set];
	UIRectFillUsingBlendMode(CGRectMake(o.origin.x, o.origin.y, o.size.width, o.size.height), kCGBlendModeClear);
	[[UIColor redColor] set];
	UIRectFrame(CGRectMake(o.origin.x, o.origin.y, o.size.width, o.size.height));
	UIImage *overlayImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	UIImageView *overlayIV = [[UIImageView alloc] initWithFrame:f];
	//overlayIV.center = CGPointMake(f.size.width/2, f.size.height/2);
	overlayIV.image = overlayImage;
	overlayIV.contentMode = UIViewContentModeScaleAspectFill;
	overlayIV.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

	[ipvc.cameraOverlayView addSubview:overlayIV];
	ipvc.cameraOverlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	
	[self presentViewController:ipvc animated:YES completion:nil];
	
//	NSLog(@"bounds=%@",NSStringFromCGRect(overlayIV.bounds));
//	NSLog(@"frame=%@",NSStringFromCGRect(overlayIV.frame));
}

- (void) showCropControllerWithImage:(UIImage *)anImage
{
	NLCropViewController * cropVC = [NLCropViewController new];
	cropVC.sourceImage	= anImage;
	cropVC.previewImage	= anImage;
	cropVC.cropSize		= CGSizeMake(896, 512);
	cropVC.outputWidth	= 896;
	cropVC.minimumScale = 0.2;
	cropVC.maximumScale = 2;
	
	[cropVC reset:NO];
	
	cropVC.doneCallback = ^(UIImage *editedImage, BOOL canceled)
	{
		if( !canceled )
		{
			UIImage* grayScaledImage = [editedImage grayscaledImage];

#if DEBUG == 1
			 UIImageWriteToSavedPhotosAlbum(grayScaledImage, self, nil, NULL);
			 NSLog(@"image size: %@", NSStringFromCGSize(grayScaledImage.size));
#endif

//TODO:			[selectorView setScannerLabelText:@"Uploading image..."];
			[self uploadImageData:UIImageJPEGRepresentation(grayScaledImage, 0.85f)];
		}

		[self dismissViewControllerAnimated:YES completion:nil];
	};
	
	[self presentViewController:cropVC animated:YES completion:nil];
}

- (void) showBarcodeController
{
	MWScannerViewController * svc = [[MWScannerViewController alloc] initWithNibName:@"MWScannerViewController" bundle:nil];
	
	svc.navigationItem.title = @"Place code in the middle of the screen";
	svc.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onCloseBarcodeController:)];
	
	NLNavigationController *navController = [[NLNavigationController alloc] initWithRootViewController:svc];
	
	[self presentViewController:navController animated:YES completion:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifications:) name:DecoderResultNotification object:nil];
}

- (void) showHandletController
{
	NLHandledVC * hvc = [NLHandledVC new];
	hvc.navigationItem.title = @"Intermec Scanner";
	hvc.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onCloseHandledController:)];
	
	[hvc setupDataHandler:^(NLHandledVC *vc, NSString *strData)
	{
		NSData * scanData = [strData dataUsingEncoding:NSUTF8StringEncoding];
		
		[self uploadScannedData:scanData];
		
		[self onCloseHandledController:nil];
	}];

	NLNavigationController *navController = [[NLNavigationController alloc] initWithRootViewController:hvc];
	
	[self presentViewController:navController animated:YES completion:nil];
}



#pragma mark - NLCaptureViewControllerDelegate
//
- (void) didFinishedCaptureWithData:(NSData *)imgData cropRect:(CGRect)rcCrop
{
	UIImage * image = [UIImage imageWithData:imgData];
	
	image = [image fixrotation];
	//NSLog(@"size orig: %@", NSStringFromCGSize(image.size));
	
	UIImage* resultImage = nil;
	
	if (image.size.width>image.size.height)
	{
		UIImage* croppedImageL = [image croppedImage:CGRectMake(((1024-700)/2)*(image.size.width/1024), ((768-400)/2)*(image.size.height/768), 700*(image.size.width/1024), 400*(image.size.height/768))];
		
		UIImage* resizedImageL = [croppedImageL resizedImage:CGSizeMake(1792, 1024)
										interpolationQuality:kCGInterpolationDefault];
		
		resultImage = [resizedImageL grayscaledImage];
	}
	else
	{
		CGRect rcCropImage = CGRectMake(ceilf((rcCrop.origin.x)*(image.size.width/rcCrop.size.width)),
										ceilf((rcCrop.origin.y)*(image.size.height/rcCrop.size.height)),
										floorf((rcCrop.size.width)*(image.size.width/rcCrop.size.width)),
										floorf((rcCrop.size.height)*(image.size.height/rcCrop.size.height)));
		
		UIImage* croppedImageP = [image croppedImage:rcCropImage];
		
		
		CGSize szResize = CGSizeMake(rcCropImage.size.width/4, rcCropImage.size.height/4);
		
		UIImage* resizedImageP = [croppedImageP resizedImage:szResize//CGSizeMake(1024, 1792)
										interpolationQuality:kCGInterpolationDefault];
		
		resultImage= [resizedImageP grayscaledImage];
		
		//NSLog(@"size gray: %@", NSStringFromCGSize(resultImage.size));
	}
	
	NLImagePreviewViewController * imageVC = [NLImagePreviewViewController new];
	imageVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	imageVC.img = resultImage;
	
	typeof(self)weakSelf = self;
	typeof(imageVC)weakImageVC = imageVC;
	
	imageVC.doneCallback = ^(UIImage *editedImage, BOOL canceled)
	{
		if( !canceled )
		{
			NSData *imageData = UIImageJPEGRepresentation(resultImage, 0.85f);
			
			/*UIImageWriteToSavedPhotosAlbum(grayScaledImage,
			 self, // send the message to 'self' when calling the callback
			 nil,
			 NULL); // you gen*/
			
//TODO:			[selectorView setScannerLabelText:@"Uploading image..."];
			[weakSelf uploadImageData:imageData];
			
//TODO:			[selectorView setScannerLabelText:@"Ready"];
			[weakSelf dismissViewControllerAnimated:YES completion:nil];
			
		}
		else
		{
			[weakImageVC dismissViewControllerAnimated:YES completion:nil];
		}
	};
	
	[self.presentedViewController presentViewController:imageVC animated:YES completion:nil];
}

@end



@implementation UIImage(DisableRotation)

- (UIImage *)fixrotation
{
	if (self.imageOrientation == UIImageOrientationUp) return self;
	CGAffineTransform transform = CGAffineTransformIdentity;
	
	switch (self.imageOrientation) {
		case UIImageOrientationDown:
		case UIImageOrientationDownMirrored:
			transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationLeft:
		case UIImageOrientationLeftMirrored:
			transform = CGAffineTransformTranslate(transform, self.size.width, 0);
			transform = CGAffineTransformRotate(transform, M_PI_2);
			break;
			
		case UIImageOrientationRight:
		case UIImageOrientationRightMirrored:
			transform = CGAffineTransformTranslate(transform, 0, self.size.height);
			transform = CGAffineTransformRotate(transform, -M_PI_2);
			break;
		case UIImageOrientationUp:
		case UIImageOrientationUpMirrored:
			break;
	}
	
	switch (self.imageOrientation) {
		case UIImageOrientationUpMirrored:
		case UIImageOrientationDownMirrored:
			transform = CGAffineTransformTranslate(transform, self.size.width, 0);
			transform = CGAffineTransformScale(transform, -1, 1);
			break;
			
		case UIImageOrientationLeftMirrored:
		case UIImageOrientationRightMirrored:
			transform = CGAffineTransformTranslate(transform, self.size.height, 0);
			transform = CGAffineTransformScale(transform, -1, 1);
			break;
		case UIImageOrientationUp:
		case UIImageOrientationDown:
		case UIImageOrientationLeft:
		case UIImageOrientationRight:
			break;
	}
	
	// Now we draw the underlying CGImage into a new context, applying the transform
	// calculated above.
	CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
											 CGImageGetBitsPerComponent(self.CGImage), 0,
											 CGImageGetColorSpace(self.CGImage),
											 CGImageGetBitmapInfo(self.CGImage));
	CGContextConcatCTM(ctx, transform);
	switch (self.imageOrientation) {
		case UIImageOrientationLeft:
		case UIImageOrientationLeftMirrored:
		case UIImageOrientationRight:
		case UIImageOrientationRightMirrored:
			// Grr...
			CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
			break;
			
		default:
			CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
			break;
	}
	
	// And now we just create a new UIImage from the drawing context
	CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
	UIImage *img = [UIImage imageWithCGImage:cgimg];
	CGContextRelease(ctx);
	CGImageRelease(cgimg);
	return img;
}

- (UIImage *)fixrotationForInitalOrientation:(UIImageOrientation)imageOrientation
{
	if (imageOrientation == UIImageOrientationUp) return self;
	CGAffineTransform transform = CGAffineTransformIdentity;
	
	switch (imageOrientation) {
		case UIImageOrientationDown:
		case UIImageOrientationDownMirrored:
			transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationLeft:
		case UIImageOrientationLeftMirrored:
			transform = CGAffineTransformTranslate(transform, self.size.width, 0);
			transform = CGAffineTransformRotate(transform, M_PI_2);
			break;
			
		case UIImageOrientationRight:
		case UIImageOrientationRightMirrored:
			transform = CGAffineTransformTranslate(transform, 0, self.size.height);
			transform = CGAffineTransformRotate(transform, -M_PI_2);
			break;
		case UIImageOrientationUp:
		case UIImageOrientationUpMirrored:
			break;
	}
	
	switch (imageOrientation) {
		case UIImageOrientationUpMirrored:
		case UIImageOrientationDownMirrored:
			transform = CGAffineTransformTranslate(transform, self.size.width, 0);
			transform = CGAffineTransformScale(transform, -1, 1);
			break;
			
		case UIImageOrientationLeftMirrored:
		case UIImageOrientationRightMirrored:
			transform = CGAffineTransformTranslate(transform, self.size.height, 0);
			transform = CGAffineTransformScale(transform, -1, 1);
			break;
		case UIImageOrientationUp:
		case UIImageOrientationDown:
		case UIImageOrientationLeft:
		case UIImageOrientationRight:
			break;
	}
	
	// Now we draw the underlying CGImage into a new context, applying the transform
	// calculated above.
	CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
											 CGImageGetBitsPerComponent(self.CGImage), 0,
											 CGImageGetColorSpace(self.CGImage),
											 CGImageGetBitmapInfo(self.CGImage));
	CGContextConcatCTM(ctx, transform);
	switch (imageOrientation) {
		case UIImageOrientationLeft:
		case UIImageOrientationLeftMirrored:
		case UIImageOrientationRight:
		case UIImageOrientationRightMirrored:
			// Grr...
			CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
			break;
			
		default:
			CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
			break;
	}
	
	// And now we just create a new UIImage from the drawing context
	CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
	UIImage *img = [UIImage imageWithCGImage:cgimg];
	CGContextRelease(ctx);
	CGImageRelease(cgimg);
	return img;
}

@end
