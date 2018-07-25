//
//  NLCommonViewController.m
//  NewLeads
//
//  Created by idevs.com on 25/09/2013.
//  Copyright (c) 2013 idevs.com. All rights reserved.
//

#import "NLCommonViewController.h"
//
// Assets:
#import "MBProgressHUD.h"



@interface NLCommonViewController ()

@property (nonatomic, readwrite, retain) UIBarButtonItem * barLogo;
@property (nonatomic, readwrite, retain) MBProgressHUD * hud;


@end



@implementation NLCommonViewController

- (void) dealloc
{
	[self cleanup];
}

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	self.edgesForExtendedLayout = UIRectEdgeNone;
	
	if( !self.barLogo )
	{
		UIImage * img = [UIImage imageNamed:@"bar-logo"];
		UIImageView * customV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
		customV.image = img;
		self.barLogo = [[UIBarButtonItem alloc] initWithCustomView:customV];
	}
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL) shouldAutorotate
{
    return YES;
}

- (NSUInteger) supportedInterfaceOrientations
{
	return (UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskPortraitUpsideDown);
}

- (void) cleanup
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}



#pragma mark - Notifications
//
- (void) notifications:(NSNotification *)anNotif
{
	// Do something in childs...
}



#pragma mark - Core logic
//
- (void) showHUD:(BOOL) isShow
{
	[self showHUD:isShow animated:NO];
}

- (void) showHUD:(BOOL) isShow animated:(BOOL) isAnimated
{
	[self showHUD:isShow animated:isAnimated withText:nil];
}

- (void) showHUD:(BOOL) isShow animated:(BOOL) isAnimated withText:(NSString *) anText
{
	dispatch_async(dispatch_get_main_queue(), ^(void)
	{
		if( !self.hud && !isShow )
		{
			return;
		}
		
		if( !self.hud )
		{
			self.hud = [[MBProgressHUD alloc] initWithView:self.view];
			self.hud.mode			= MBProgressHUDModeIndeterminate;
			self.hud.animationType	= MBProgressHUDAnimationFade;
			
			[self.view addSubview:self.hud];
			[self.view bringSubviewToFront:self.hud];
		}
		
		if( isShow )
		{
			[self.hud show:isAnimated];
			self.hud.labelText = anText;
		}
		else
		{
			if( !isAnimated )
			{
				[self.hud hide:NO];
				
				self.hud = nil;
			}
			else
			{
				[self.hud hide:isAnimated];
			}
		}
	});
}

@end
