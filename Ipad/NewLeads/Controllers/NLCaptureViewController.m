//
//  NLCaptureViewController.m
//  NewLeads
//
//  Created by Arseniy Astapenko on 8/20/13.
//  Copyright (c) 2013 idevs.com. All rights reserved.
//

#import "NLCaptureViewController.h"



@interface NLCaptureViewController () 
<
	PBJVisionDelegate,
	UIGestureRecognizerDelegate
>

//
// UI - XIB:
@property (nonatomic, assign) IBOutlet UINavigationBar	* navBar;
@property (nonatomic, assign) IBOutlet UIView			* viewCam;
@property (nonatomic, assign) IBOutlet UIButton			* btnShoot;
//
// UI:
@property (nonatomic, retain) UIImageView				* focusImageView;
@property (nonatomic, retain) UIImageView				* overlayV;
//
@property (nonatomic, assign) UIInterfaceOrientation	currentOrientation;
@property (nonatomic, assign) CGRect					rcCrop;

- (void) updateOverlays;
- (PBJCameraOrientation) viewCameraOrientation;

@end



@implementation NLCaptureViewController

- (void) dealloc
{
    self.focusImageView = nil;
  
	[super dealloc];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
	
	self.navBar.topItem.title = @"BizCard";
	
	self.currentOrientation = UIDeviceOrientationPortrait;//[NLRootViewController rootInterfaceOrientation];
	
	//
    // Setup viewCam:
	//
	PBJVision *vision = [PBJVision sharedInstance];
    vision.delegate = self;
    [vision setCameraMode:PBJCameraModePhoto];
    [vision setCameraDevice:PBJCameraDeviceBack];
	[vision setCameraOrientation:[self viewCameraOrientation]];
    [vision setFocusMode:PBJFocusModeContinuousAutoFocus];
    [vision setOutputFormat:PBJOutputFormatPreset];

	AVCaptureVideoPreviewLayer * _previewLayer = [[PBJVision sharedInstance] previewLayer];
    _previewLayer.frame = self.viewCam.bounds;
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.viewCam.layer addSublayer:_previewLayer];
	
	UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusAtTap:)];

	[self.view addGestureRecognizer:tap];
	
	// Tap to focus indicator
	// -------------------------------------
	UIImage *defaultImage		= [UIImage imageNamed:@"focus_indicator"];
	self.focusImageView         = [[[UIImageView alloc] initWithImage:defaultImage] autorelease];
	self.focusImageView.frame   = CGRectMake(0, 0, defaultImage.size.width, defaultImage.size.height);
	self.focusImageView.hidden	= YES;
	[self.viewCam addSubview:self.focusImageView];
	
	[self createOverlaysView];
	
	[self.view addSubview:self.btnShoot];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
//	self.currentOrientation = [NLRootViewController rootInterfaceOrientation];

	self.overlayV.hidden = YES;
    self.btnShoot.hidden = YES;

	self.navBar.topItem.rightBarButtonItem.enabled = YES;
    self.btnShoot.userInteractionEnabled = YES;
	
	PBJVision *vision = [PBJVision sharedInstance];
	[vision setCameraOrientation:[self viewCameraOrientation]];
	[vision setFocusMode:PBJFocusModeContinuousAutoFocus];
	[vision startPreview];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	
    [self updateOverlays];
}

- (void) viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[[PBJVision sharedInstance] stopPreview];
}

- (void) viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];
	
	PBJVision *vision = [PBJVision sharedInstance];
	vision.previewLayer.frame = self.viewCam.bounds;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	self.currentOrientation = toInterfaceOrientation;
	
	self.overlayV.hidden = YES;
    self.btnShoot.hidden = YES;
	
	PBJVision *vision = [PBJVision sharedInstance];
	
	[vision stopPreview];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	
	[self updateOverlays];
	
	
	PBJVision *vision = [PBJVision sharedInstance];
	
	[vision setCameraOrientation:[self viewCameraOrientation]];
	
	[vision startPreview];
}



#pragma mark - Actions
//
- (IBAction) onButtonCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) onButtonTake:(id)sender
{
    self.navBar.topItem.rightBarButtonItem.enabled = NO;
    self.btnShoot.userInteractionEnabled = NO;

	[[PBJVision sharedInstance] capturePhoto];
}



#pragma mark - Core logic
//
- (PBJCameraOrientation) viewCameraOrientation
{
	if( UIInterfaceOrientationIsPortrait(self.currentOrientation) )
	{
		return (UIInterfaceOrientationPortrait == self.currentOrientation ? PBJCameraOrientationPortrait : PBJCameraOrientationPortraitUpsideDown);
	}
	else
	{
		return (UIInterfaceOrientationLandscapeLeft == self.currentOrientation ? PBJCameraOrientationLandscapeLeft : PBJCameraOrientationLandscapeRight);
	}
}

- (void) createOverlaysView
{
	[self.overlayV removeFromSuperview];
	
	CGSize p = self.viewCam.frame.size;//(IS_IPHONE_5 ? CGSizeMake(320, 568) : CGSizeMake(320, 480));
	CGSize s = CGSizeMake(p.width - 22, p.height - 22);//CGSizeMake(166, 326);
	
	CGRect o = CGRectMake((p.width-s.width)/2, (p.height-s.height)/2, s.width, s.height);
	
	UIGraphicsBeginImageContext(p);
	[[UIColor colorWithWhite:0 alpha:.5] set];
	UIRectFillUsingBlendMode(CGRectMake(0, 0, p.width, p.height), kCGBlendModeNormal);
	[[UIColor colorWithWhite:0 alpha:0] set];
	UIRectFillUsingBlendMode(CGRectMake(o.origin.x, o.origin.y, o.size.width, o.size.height), kCGBlendModeClear);
	[[UIColor redColor] set];
	UIRectFrame(CGRectMake(o.origin.x, o.origin.y, o.size.width, o.size.height));
	UIImage *overlayImageV = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	self.overlayV = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, p.width, p.height)] autorelease];
	self.overlayV.center = CGPointMake(p.width/2, p.height/2);
	self.overlayV.image = overlayImageV;
	
	self.rcCrop = o;//CGRectMake(0, 0, s.width, s.height);
	
	[self.viewCam insertSubview:self.overlayV belowSubview:self.navBar];
	
}

- (void) updateOverlays
{
	if (self.view.bounds.size.height>self.view.bounds.size.width)
	{
		self.overlayV.hidden = NO;
	}
	else
	{
		self.overlayV.hidden = YES;
	}
	self.btnShoot.hidden = NO;
	
	[self.view bringSubviewToFront:self.focusImageView];
}



#pragma mark - PBJVisionDelegate
//
- (void)vision:(PBJVision *)vision capturedPhoto:(NSDictionary *)photoDict error:(NSError *)error
{
	dispatch_async(dispatch_get_main_queue(), ^(void)
	{
		if(self.delegate && photoDict && [self.delegate respondsToSelector:@selector(didFinishedCaptureWithData:cropRect:)] )
		{
			[self.delegate didFinishedCaptureWithData:photoDict[PBJVisionPhotoJPEGKey] cropRect:self.rcCrop];
		}
		else
		{
			NSLog(@"Fail capture");
			self.navBar.topItem.rightBarButtonItem.enabled = YES;
			self.btnShoot.userInteractionEnabled = YES;
		}
	});
}



#pragma mark - UIGesture

- (void)focusAtTap:(UIGestureRecognizer *)gestureRecognizer
{
	if( UIGestureRecognizerStateRecognized != gestureRecognizer.state )
		return;
	
    //self.focusImageView.center = [gestureRecognizer locationInView:self.viewCam];
    //[self animateFocusImage];
	
	PBJVision *vision = [PBJVision sharedInstance];
	
	CGPoint focus = [gestureRecognizer locationInView:self.viewCam];

	[vision focusAtAdjustedPoint:focus];
}

#pragma mark - Focus reticle

- (void)animateFocusImage
{
    self.focusImageView.alpha = 0.0;
    self.focusImageView.hidden = false;
    
    [UIView animateWithDuration:0.2 animations:^(void)
	{
        self.focusImageView.alpha = 1.0;
    }
					 completion:^(BOOL finished)
	{
		[UIView animateWithDuration:0.2 animations:^(void)
		{
            self.focusImageView.alpha = 0.0;
        }
						 completion:^(BOOL secondFinished)
		{
            self.focusImageView.hidden = true;
        }];
    }];
}

#pragma mark - UIGestureRecognizer Delegate
//
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return true;
}

@end
