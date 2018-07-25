//
//  NLScannerViewController.m
//  NewLeads
//
//  Created by idevs.com on 20/06/2013.
//  Copyright (c) 2013 idevs.com. All rights reserved.
//

#import "NLScannerViewController.h"
#import "NLDeviceController.h"



@interface NLScannerViewController ()

//
// UI:
@property (nonatomic, readwrite, assign) IBOutlet UINavigationBar	* navBar;
@property (nonatomic, readwrite, assign) IBOutlet UIView			* viewBrowser;
@property (nonatomic, readwrite, assign) IBOutlet UIView			* viewToolbar;


- (void) deviceSetup;
- (void) deviceConnect;
//


@end



@implementation NLScannerViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if( nil != (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) )
	{
		self.modalPresentationStyle = UIModalPresentationFormSheet;
		self.modalTransitionStyle	= UIModalTransitionStyleCoverVertical;
	}
	return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];

	self.navBar.topItem.title = @"Scanner";
	self.navBar.topItem.leftBarButtonItem	= [NLUtils buttonBarWithBackground:@"btn-default-black" title:@"Done" forTarget:self withAction:@selector(onButtonDone:)];
	self.navBar.topItem.rightBarButtonItem	= [NLUtils buttonBarWithBackground:@"btn-default-black" title:@"Info" forTarget:self withAction:@selector(onButtonInfo:)];

	
	[self showToolbar:NO animated:NO];
	
	[self deviceSetup];
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self deviceConnect];
}



#pragma mark - Actions
//
- (void) onButtonInfo:(id) sender
{
	if( self.viewToolbar.hidden )
	{
		[self showToolbar:YES animated:YES];
		
		self.navBar.topItem.rightBarButtonItem = [NLUtils buttonBarWithBackground:@"btn-default-black" title:@"Close" forTarget:self withAction:@selector(onButtonInfo:)];
	}
	else
	{
		[self showToolbar:NO animated:YES];

		self.navBar.topItem.rightBarButtonItem = [NLUtils buttonBarWithBackground:@"btn-default-black" title:@"Info" forTarget:self withAction:@selector(onButtonInfo:)];
	}
}

- (void) onButtonDone:(id) sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) onButtonTest:(id)sender
{
	[[NLDeviceController device] sendTestData];
}



#pragma mark - Core logic
//
- (void) deviceSetup
{
	NLDeviceStateBlock actionBlock = ^(NLDeviceController * device, kDeviceState state)
	{
		switch( state )
		{
			case kDeviceStateUnknown:
			{
				[NLAlertView showError:@"Device not detected."];
			}
				break;
			case kDeviceStateDisconnected:
			{
				NSError * error = [NLDeviceController device].error;
				
				[NLAlertView showError:[error localizedDescription]];
			}
				break;
			case kDeviceStateConnecting:
			{
				// TODO: Update UI with appopriate message...
			}
				break;
			case kDeviceStateConnected:
			{
				// TODO: Update UI with appopriate info...
			}
				break;
			case kDeviceStateDataGathering:
			{
				// TODO: Update UI with appopriate info...
			}
				break;
			case kDeviceStateDataReady:
			{
				// T0D0: Ready data and send to the server...
				if( self.actionBlock )
				{
					self.actionBlock(self, device.data, nil);
				}
			}
				break;
			case kDeviceStateDataFailed:
			{
				NSError * error = [NLDeviceController device].error;
				
				[NLAlertView showError:[error localizedDescription]];
			}
				break;
		}
	};
	[NLDeviceController device].stateBlock = actionBlock;
}

- (void) deviceConnect
{
	[[NLDeviceController device] connect];
}

- (void) showToolbar:(BOOL)isShow animated:(BOOL)isAnimated
{
	// Already hidden:
	if( self.viewToolbar.hidden && !isShow )
		return;
	
	// Already showed:
	if( !self.viewToolbar.hidden && isShow )
		return;
	
	CGRect rcToolbar= self.viewToolbar.bounds;
	CGRect rcTable	= self.viewBrowser.frame;
	
	if( isShow )
	{
		self.viewToolbar.hidden = NO;
		rcToolbar.origin.y	= self.view.bounds.size.height - rcToolbar.size.height;
		rcTable.size.height = self.view.bounds.size.height - self.navBar.frame.size.height - rcToolbar.size.height;
	}
	else
	{
		rcToolbar.origin.y = self.view.bounds.size.height;
		rcTable.size.height= self.view.bounds.size.height - self.navBar.frame.size.height;
	}
	
	if( isAnimated )
	{
		[UIView animateWithDuration:0.4
							  delay:0.2
							options:(UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut)
						 animations:^(void)
		 {
			 self.viewToolbar.frame	= rcToolbar;
			 self.viewBrowser.frame	= rcTable;
		 }
						 completion:^(BOOL finished)
		 {
			 self.viewToolbar.hidden = !isShow;
		 }];
	}
	else
	{
		self.viewBrowser.frame	= rcTable;
		self.viewToolbar.frame	= rcToolbar;
		self.viewToolbar.hidden	= !isShow;
	}
}

@end
