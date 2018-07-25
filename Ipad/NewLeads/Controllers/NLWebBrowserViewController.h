//
//  NLWebBrowserViewController.h
//  NewLeads
//
//  Created by Karnyenka Andrew on 19/04/2012.
//  Copyright (c) 2012 idevs.com. All rights reserved.
//

#import "NLCommonViewController.h"

@interface NLWebBrowserViewController : NLCommonViewController
<
	UIWebViewDelegate
>
{
@private
	//
	// Logic:
	BOOL			isCleanup;
	NSURLRequest	* latestRequest;
	
	//
	// UI:
	IBOutlet UIWebView	* viewWeb;
	IBOutlet UINavigationBar	* navBar;
	IBOutlet UIToolbar			* toolBar;
	IBOutlet UIBarButtonItem	* btnStopReload;
}

@property (nonatomic, readwrite, retain) NSURLRequest * latestRequest;

- (IBAction) onButtonBack:(id)sender;
- (IBAction) onButtonForward:(id)sender;
- (IBAction) onButtonStopReload:(id)sender;
- (IBAction) onButtonClose:(id)sender;

@end
