//
//  NLAppDelegate.m
//  NewLeads
//
//  Created by idevs.com on 27/06/2011.
//  Copyright 2011 idevs.com. All rights reserved.
//

#import "NLAppDelegate.h"
#import "NLNavigationController.h"
#import "NLAdminViewController.h"
#import "NLLeadsViewController.h"



@implementation NLAppDelegate


- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	//
	// Update window size with actual value:
	//
	self.window.frame = [[UIScreen mainScreen] bounds];
	
	[self setupAppearance];
	
    [NLContext shared];
	
#if DEBUG == 1
	//
	// Ignore device type under debug
	//
	if( [NLContext shared].isFirstLaunch )
	{
		[self showAdmin];
	}
	else if([NLContext shared].isTimeToDie )
	{
		[self destroyContent];
		[self showAdmin];
	}
	else
	{
		[self showLeads];
	}
#else
	//
	// Guard from too "smart" customer ^_^
	//
	if( IS_IPAD )
	{
		[self showPhoneOnly];
	}
	else
	{
		if( [NLContext shared].isFirstLaunch )
		{
			[self showAdmin];
		}
		else if([NLContext shared].isTimeToDie )
		{
			[self destroyContent];
			[self showAdmin];
		}
		else
		{
			[self showLeads];
		}
	}
#endif
	
	[self.window makeKeyAndVisible];
	
	return YES;
}

- (void) applicationWillResignActive:(UIApplication *)application 
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void) applicationWillTerminate:(UIApplication *)application 
{
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
	
	[[NLContext shared] saveAppSettings];
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
	return (UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskPortraitUpsideDown);
}



#pragma mark - Core logic
//
+ (NLAppDelegate *) shared
{
	return (NLAppDelegate *)[UIApplication sharedApplication].delegate;
}

- (void) setRootViewController:(UIViewController *) controller withOptions:(UIViewAnimationOptions)options additionalActions:(void (^)(void))actions
{
	[UIView transitionWithView:self.window
					  duration:0.5
					   options:options
					animations:
	 ^
	 {
		 /*
		  Fix for statusbar glitches problem, similar to described here:
		  http://stackoverflow.com/questions/8053832/rootviewcontroller-animation-transition-initial-orientation-is-wrong
		  */
		 BOOL oldState = [UIView areAnimationsEnabled];
		 [UIView setAnimationsEnabled:NO];
		 
		 self.window.rootViewController = controller;
		 
		 [UIView setAnimationsEnabled:oldState];
	 }
					completion:^(BOOL finished)
	 {
		 if(finished)
			 if(actions)
				 actions();
	 }];
}

- (void) showPhoneOnly
{
	UIViewController * vc = [UIViewController new];

	vc.view.backgroundColor = [UIColor whiteColor];
	
	[self setRootViewController:vc
					withOptions:UIViewAnimationOptionTransitionNone
			  additionalActions:^(void)
	 {
		 [NLAlertView show:@"Error"
				   message:@"This application was designed for iPhone usage only."
				   buttons:@[@"Close"]
					 block:^(NLAlertView *alertView, NSInteger buttonIndex)
		 {
			 exit(0);
		 }];
	 }];
	
	[vc autorelease];
}

- (void) showAdmin
{
	NLAdminViewController * avc = [NLAdminViewController new];
	NLNavigationController * nvc = [[NLNavigationController alloc] initWithRootViewController:avc];
	
//	NLAppDelegate* __weak weakSelf = self;
	[self setRootViewController:nvc
					withOptions:UIViewAnimationOptionTransitionFlipFromLeft
			  additionalActions:^(void)
	 {
		 // ???
	 }];
    
    [avc autorelease];
}

- (void) showLeads
{
	NLLeadsViewController * lvc = [NLLeadsViewController new];
	NLNavigationController * nvc = [[NLNavigationController alloc] initWithRootViewController:lvc];
	
//	NLAppDelegate* __weak weakSelf = self;
	[self setRootViewController:nvc
					withOptions:UIViewAnimationOptionTransitionFlipFromRight
			  additionalActions:^(void)
	 {
		 // ???
	 }];
    
    [lvc autorelease];
}

- (void) logout
{
	[NLContext shared].isTimeToDie = YES;
	
	[self destroyContent];
	
	NSString * cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	[[NSFileManager defaultManager]removeItemAtPath:cacheDir error:nil];
	
	[self showAdmin];
}

- (void) destroyContent
{
	if( [NLContext shared].isTimeToDie )
	{
		NSArray	* arrHome	= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString* homePath	= [arrHome objectAtIndex: 0];
		NSString* pathToContentDir	= [homePath stringByAppendingPathComponent: [NLContext shared].datasourceFolder];
		
		NSError * error = nil;
		if( ![[NSFileManager defaultManager] removeItemAtPath: pathToContentDir error: &error] )
		{
			if( error )
			{
				NSLog(@"Trying to remove content was failed: %@", [error localizedDescription]);
			}
		}
		
		[[NLContext shared] reset];
	}
}



#pragma mark - Appearance
//
- (void) setupAppearance
{
	//
	// UINavigationBar:
	//
	[[UINavigationBar appearance] setBarTintColor:[UIColor darkTextColor]];
	NSDictionary * dicNavBarAttr = @{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:14], NSForegroundColorAttributeName : [UIColor whiteColor]};
	[[UINavigationBar appearance] setTitleTextAttributes:dicNavBarAttr];
	
	//
	// UIBarButtonItem:
	//
	NSDictionary * dicBarButtonAttr = @{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:14], NSForegroundColorAttributeName: [UIColor whiteColor]};
	[[UIBarButtonItem appearance] setTitleTextAttributes:dicBarButtonAttr forState:UIControlStateNormal];
	
	//
	// UIToolbar:
	//
	[[UIToolbar appearance] setTintColor:[UIColor whiteColor]];
	[[UIToolbar appearance] setBarTintColor:[UIColor darkGrayColor]];
	
	//
	// Segmented control:
	//
	NSDictionary * dicSegmentedAttr = @{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:14], NSForegroundColorAttributeName: [UIColor whiteColor]};
	[[UISegmentedControl appearance] setTitleTextAttributes:dicSegmentedAttr forState:UIControlStateNormal];
	
	dicSegmentedAttr = @{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:14], NSForegroundColorAttributeName: [UIColor lightGrayColor]};
	[[UISegmentedControl appearance] setTitleTextAttributes:dicSegmentedAttr forState:UIControlStateDisabled];
}

@end
