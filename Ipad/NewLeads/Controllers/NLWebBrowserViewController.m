//
//  NLWebBrowserViewController.m
//  NewLeads
//
//  Created by Karnyenka Andrew on 19/04/2012.
//  Copyright (c) 2012 idevs.com. All rights reserved.
//

#import "NLWebBrowserViewController.h"



#pragma mark - Configuration
//



@interface NLWebBrowserViewController ()

- (void) showReloadButton;
- (void) showStopButton;
- (void) delayedClose;

@end



@implementation NLWebBrowserViewController

@synthesize latestRequest;


#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
	
	if( self.latestRequest )
	{
		[viewWeb loadRequest:self.latestRequest];
	}
}

- (void) didReceiveMemoryWarning
{
#if DEBUG == 1
	NSLog(@"%@ - %@", [self class], NSStringFromSelector(_cmd));
#endif
	
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
	[viewWeb loadHTMLString:@"<html><body></body></html>" baseURL:nil];
	[viewWeb loadRequest:self.latestRequest];
}



#pragma mark - Actions
//
- (IBAction) onButtonClose:(id)sender
{
#if DEBUG == 1
//	NSLog(@"%@ - %@", [self class], NSStringFromSelector(_cmd));
#endif
	
	[self showHUD:NO];
	
	self.latestRequest = nil;
	
	isCleanup = YES;
	[viewWeb loadHTMLString:@"<html><body></body></html>" baseURL:nil];
	
	[self performSelector:@selector(delayedClose) withObject:nil afterDelay:0.6];
}

- (IBAction) onButtonBack:(id)sender
{
#if DEBUG == 1
//	NSLog(@"%@ - %@", [self class], NSStringFromSelector(_cmd));
#endif
	
	[viewWeb goBack];
}

- (IBAction) onButtonForward:(id)sender
{
#if DEBUG == 1
//	NSLog(@"%@ - %@", [self class], NSStringFromSelector(_cmd));
#endif
	
	[viewWeb goForward];
}

- (IBAction) onButtonStopReload:(id)sender
{
#if DEBUG == 1
//	NSLog(@"%@ - %@", [self class], NSStringFromSelector(_cmd));
#endif
	
	if( viewWeb.isLoading )
	{
		[self showHUD:NO];
		
		[self showReloadButton];
		
		[viewWeb stopLoading];
	}
	else
	{
		[self showStopButton];

		[viewWeb reload];
	}
}



#pragma mark - Core logic
//
- (void) showReloadButton
{
	UIBarButtonItem * btnReload = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
																				target:self
																				action:@selector(onButtonStopReload:)];
	
	NSMutableArray * items = [[toolBar items] mutableCopy];
	NSInteger idx = [items indexOfObject:btnStopReload];
	
	[items replaceObjectAtIndex:idx withObject:btnReload];
	[toolBar setItems:items];

	btnStopReload = btnReload;
}

- (void) showStopButton
{
	UIBarButtonItem * btnStop = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
																			  target:self
																			  action:@selector(onButtonStopReload:)];
	
	NSMutableArray * items = [[toolBar items] mutableCopy];
	NSInteger idx = [items indexOfObject:btnStopReload];
	
	[items replaceObjectAtIndex:idx withObject:btnStop];
	[toolBar setItems:items];
	
	btnStopReload = btnStop;
}

- (void) delayedClose
{
	[self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - UIWebViewDelegate
//
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
#if DEBUG == 1
//	NSLog(@"%@ - %@. %@", [self class], NSStringFromSelector(_cmd), request.URL);
#endif
	
	if( isCleanup )
	{
		return YES;
	}
	
	if( [[request.URL scheme] isEqualToString:@"http"] )
	{		
		self.latestRequest = request;
		
		[self showHUD:YES animated:NO withText:@"Loading..."];
		
		[self showStopButton];
		
		return YES;
	}
	else
	{
		return NO;
	}
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
#if DEBUG == 1
//	NSLog(@"%@ - %@", [self class], NSStringFromSelector(_cmd));	
//	NSLog(@"mainDocumentURL = %@", latestRequest.mainDocumentURL);
//	NSLog(@"HTTHeadersFields = %@", latestRequest.allHTTPHeaderFields);
#endif
	if( isCleanup )
	{
		return;
	}
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
#if DEBUG == 1
//	NSLog(@"%@ - %@", [self class], NSStringFromSelector(_cmd));
#endif
	
	if( isCleanup )
	{
		return;
	}
	
	NSString *theTitle=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
	navBar.topItem.title = theTitle;
	
	[self showHUD:NO];
	
	[self showReloadButton];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
#if DEBUG == 1
//	NSLog(@"%@ - %@. %@", [self class], NSStringFromSelector(_cmd), error);
#endif
	if( isCleanup )
	{
		return;
	}
	
	navBar.topItem.title = @"";
	
	[self showHUD:NO];
	
	[self showReloadButton];
	
	if([error code] == NSURLErrorCancelled)
		return;
	
	if([error code] == 204) // <~~~ ignore Domain=WebKitErrorDomain Code=204 "Plug-in handled load"
		return;
	
#if DEBUG == 1
	[NLAlertView show:[error domain] message:[error localizedDescription]];
#else
	[NLAlertView show:@"Loading Error" message:[error localizedDescription]];
#endif
}

@end
