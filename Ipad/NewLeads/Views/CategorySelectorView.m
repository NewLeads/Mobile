//
//  CategorySelectorView.m
//  NewLeads
//
//  Created by idevs.com on 27/06/2011.
//  Copyright 2011 idevs.com. All rights reserved.
//

#import "CategorySelectorView.h"
#import "GradientView.h"
#import "GridControl.h"
#import "SelectorGridItem.h"
#import "NLAdminViewController.h"
#import <QuartzCore/QuartzCore.h>




#pragma mark -
#pragma mark Configuration
//
const CGFloat	buttonMarginTop			= 20.f;
const CGFloat	buttonMarginSide		= 20.f;
//
const CGFloat	controlGridMarginTop	= 0.f;
const CGFloat	controlGridMarginSide	= 8.f;



@interface CategorySelectorView ()

//
// UI:
@property (nonatomic, readwrite, assign) IBOutlet UIButton		* btnNewTour;
@property (nonatomic, readwrite, assign) IBOutlet UIButton		* btnEndTour;
@property (nonatomic, readwrite, assign) IBOutlet UIButton		* btnScan;
@property (nonatomic, readwrite, assign) IBOutlet UIButton		* btnSettings;
@property (nonatomic, readwrite, assign) IBOutlet UIView		* viewSettings;
@property (nonatomic, readwrite, assign) IBOutlet UIButton		* btnIntermec;
@property (nonatomic, readwrite, assign) IBOutlet UIButton		* btnBarCode;
@property (nonatomic, readwrite, assign) IBOutlet UIButton		* btnBusinessCard;
@property (nonatomic, readwrite, assign) IBOutlet GridControl	* controlGrid;
@property (nonatomic, readwrite, assign) IBOutlet UILabel		* labelScannerState;


- (void) setup;
- (void) updateBG;

- (BOOL) hasCollateral;

- (IBAction) onViewSettings;

@end



@implementation CategorySelectorView

@synthesize controlGrid;


- (id) initWithFrame:(CGRect) frame 
{
	if( nil != (self = [super initWithFrame: frame]) )
	{
		[self setup];
	}
	return self;
}

- (id) initWithCoder:(NSCoder *) aDecoder
{
	if( nil != (self = [super initWithCoder:aDecoder]) )
	{
		[self setup];
	}
	return self;
}

- (void) dealloc
{
	if( viewBG )
	{
		[viewBG release];
		viewBG = nil;
	}
	
    [super dealloc];
}

- (IBAction) onViewSettings
{
    self.viewSettings.hidden = YES;
    self.btnSettings.hidden = NO;
}

- (void) hideSettings
{
    self.viewSettings.hidden = NO;
    self.btnSettings.hidden = YES;
}

- (void) refreshScanButtons
{
    //BOOL bizCardAvail = [NLContext shared].isBizCardActivated;
    BOOL cameraAvail = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    
    self.btnIntermec.hidden = YES;//!(bizCardAvail && [NLContext shared].isIntermecAvail);
    self.btnBusinessCard.hidden = !(/*bizCardAvail && */cameraAvail && [NLContext shared].isBizCardAvail);
    self.btnBarCode.hidden = !(/*bizCardAvail &&*/ cameraAvail && [NLContext shared].isBarCodeAvail);
}

- (BOOL) hasCollateral
{
    NSArray* content = [[NLContext shared].contentDict objectForKey:@"content"];
    for (NSDictionary* dict in content)
    {
        NSDictionary* dictContentTab = dict[@"content_tab"];
        if ([dictContentTab isKindOfClass:[NSDictionary class]])
        {
            //NSString* tabid = dictContentTab[@"tabid"];
            //if (tabid && !([tabid isEqualToString:kSketchFolderID]) & !([tabid isEqualToString:kSignatureFolderID]) )
			return YES;
        }
    }
    return NO;
}

- (void) setup
{
	if( !viewBG )
	{		
		/*
		viewBG = [[GradientView alloc] initWithFrame: self.bounds];
		
		viewBG.type = kLinearGradient;
		NSArray * newArr =[NSArray arrayWithObjects:
						   (id)[[UIColor colorWithRed:0.33 green:0.33 blue:0.33 alpha:0.5] CGColor],
						   (id)[[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.5] CGColor],
						   nil];
		
		[viewBG setColorArray: newArr];
		[self insertSubview:viewBG atIndex: 0]; // <~~~ Add below all views...		
		 */
		
		viewBG = [[UIImageView alloc] initWithFrame:self.bounds];
		viewBG.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		
		[self updateBG];
		[self insertSubview:viewBG atIndex: 0];
	}
}

- (void) layoutSubviews
{
	[super layoutSubviews];
	
	if( !isInited )
	{
		//
		// Setup buttons:
		self.btnEndTour.hidden = YES;
		self.btnNewTour.hidden = [self hasCollateral]?NO:YES;
        
		self.btnSettings.hidden = NO;
        self.btnBusinessCard.hidden = NO;
        [self refreshScanButtons];
		
		controlGrid.isHorizontal = YES;
		
		UIImage * imgNormalBG = [NLUtils stretchedImageNamed:@"btn-red" width:CGRectMake(0, 0, 6, 0)];
		[self.btnScan setBackgroundImage:imgNormalBG forState:UIControlStateNormal];
		[self.btnNewTour setBackgroundImage:imgNormalBG forState:UIControlStateNormal];
		
		imgNormalBG = [NLUtils stretchedImageNamed:@"btn-blue" width:CGRectMake(0, 0, 6, 0)];
		[self.btnSettings setBackgroundImage:imgNormalBG forState:UIControlStateNormal];
		[self.btnBusinessCard setBackgroundImage:imgNormalBG forState:UIControlStateNormal];
		[self.btnIntermec setBackgroundImage:imgNormalBG forState:UIControlStateNormal];
 		[self.btnBarCode setBackgroundImage:imgNormalBG forState:UIControlStateNormal];
		
		imgNormalBG = [NLUtils stretchedImageNamed:@"btn-default-black" width:CGRectMake(0, 0, 6, 0)];
		[self.btnEndTour setBackgroundImage:imgNormalBG forState:UIControlStateNormal];
	
        imgNormalBG = [NLUtils stretchedImageNamed:@"btn-gray" width:CGRectMake(0, 0, 6, 0)];
        [self.btnBusinessCard setBackgroundImage:imgNormalBG forState:UIControlStateDisabled];
        [self.btnIntermec setBackgroundImage:imgNormalBG forState:UIControlStateDisabled];
        [self.btnBarCode setBackgroundImage:imgNormalBG forState:UIControlStateDisabled];
	
#if DEBUG_SCANNER_MODE == 1
		self.labelScannerState.hidden = NO;
		self.btnScan.hidden = NO;
#else
		self.labelScannerState.hidden = YES;
		self.btnScan.hidden = YES;
#endif
		isInited = YES;
	}
	
	//
	// BG:
	//viewBG.frame = self.bounds;
	[self updateBG];
	
	//
	// Buttons:
	// Do nothing...
	
	//
	// Grid control:
	controlGrid.frame = CGRectMake(buttonMarginSide + self.btnNewTour.frame.size.width + controlGridMarginSide,
								   controlGridMarginTop, 
								   self.bounds.size.width - controlGridMarginSide - self.btnNewTour.frame.size.width - buttonMarginSide,
								   controlGrid.frame.size.height);
}



#pragma mark -
#pragma mark Core logic
//
- (void) startTour:(BOOL) aFlag
{
	if( aFlag )
	{
		self.btnEndTour.hidden = NO;
		self.btnNewTour.hidden = YES;
		self.btnSettings.hidden = YES;
        self.viewSettings.hidden = YES;
        self.btnIntermec.hidden = YES;
        self.btnBusinessCard.hidden = YES;
        self.btnBarCode.hidden = YES;
	}
	else
	{
		self.btnEndTour.hidden = YES;
		self.btnNewTour.hidden = NO;
		self.btnSettings.hidden = NO;
        self.btnBusinessCard.hidden = NO;
        [self refreshScanButtons];

		}
}

- (void) enableTabs:(BOOL) aFlag
{
	[controlGrid enableItems: aFlag];	
}

- (void) selectTab:(BOOL) anFlag atIndex:(NSInteger) anIndex
{
	if( NSNotFound != anIndex && 0 <= anIndex && anIndex < (NSInteger)[controlGrid.items count] )
	{
 		if( oldSelection != NSNotFound && oldSelection < (NSUInteger)[controlGrid.items count])
		{
			((SelectorGridItem*)[controlGrid.items objectAtIndex: oldSelection]).isSelected = NO;
		}
		
		oldSelection = anIndex;
		((SelectorGridItem*)[controlGrid.items objectAtIndex: anIndex]).isSelected = anFlag;
		
		if( !anFlag )
		{
			oldSelection = NSNotFound;
		}
	}
}

- (void) unSelectAll
{
	[controlGrid unSelectAll];
}

- (void) unHighlightAll
{
	[controlGrid unHighlightAll];
}

- (void) hideAll:(BOOL) anFlag
{
	[controlGrid hideAll: anFlag];
}

#pragma >>> button visual appearance
//
- (void) enableButtonTour:(BOOL) anFlag
{
	self.btnNewTour.enabled = anFlag;
}

- (void) setAnonymousMode
{
	UIImage * imgNormalBG = [NLUtils stretchedImageNamed:@"btn-red" width:CGRectMake(0, 0, 6, 0)];
	[self.btnNewTour setBackgroundImage:imgNormalBG forState:UIControlStateNormal];
	[self.btnNewTour setTitle:@"Anonymous Tour" forState:UIControlStateNormal];
}

- (void) setLeadMode
{
	UIImage * imgNormalBG = [NLUtils stretchedImageNamed:@"btn-red" width:CGRectMake(0, 0, 6, 0)];
	[self.btnNewTour setBackgroundImage:imgNormalBG forState:UIControlStateNormal];
	[self.btnNewTour setTitle:@"Lit/Videos" forState:UIControlStateNormal];
}

- (void) setRestartMode
{
	UIImage * imgNormalBG = [NLUtils stretchedImageNamed:@"btn-blue" width:CGRectMake(0, 0, 6, 0)];
	[self.btnNewTour setBackgroundImage:imgNormalBG forState:UIControlStateNormal];
	[self.btnNewTour setTitle:@"Lit/Videos" forState:UIControlStateNormal];
}

- (void) setScannerLabelText:(NSString *) anText
{
	NSLog(@"Label text: %@", anText);
	self.labelScannerState.text = anText;
}

- (void) resetInit
{
    isInited = NO;
}

#pragma mark -
#pragma mark Private
//
- (void) updateBG
{
	viewBG.image = [NLUtils stretchedImageNamed:@"bg-cat-bar" width:CGRectMake(0, 1, 0, 0)];
	viewBG.frame = self.bounds;
//	viewBG.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height + 10);
}



#pragma mark -
#pragma mark UIScrollView delegate
//
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	[self unHighlightAll];
}

@end
