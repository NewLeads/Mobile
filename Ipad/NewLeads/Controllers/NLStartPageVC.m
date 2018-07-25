//
//  NLStartPageVC.m
//  NewLeads
//
//  Created by idevs.com on 17/03/2015.
//  Copyright (c) 2015 idevs.com. All rights reserved.
//

#import "NLStartPageVC.h"
#import "NLLeadsViewController.h"
#import "CategorySelectorView.h"
// Assets:
#import "MBProgressHUD.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"



#pragma mark -
#pragma mark Configuration
//
//NSString * const kPageDefaultLink		= @"http://demo.newleads.com/recent.asp";
//NSString * const kPageDefaultGetLeadLink= @"http://demo.newleads.com/getselectedLeadid.asp";
//NSString * const kPageDefaultUploadLink	= @"http://demo.newleads.com/updateiPadData.asp";
NSString * const kPageRecentLink		= @"recent.asp";
NSString * const kPageClickToBeginLink	= @"clicktobegin.asp";
NSString * const kPageGetLeadLink		= @"getselectedLeadid.asp";
NSString * const kPageUploadLink		= @"updateiPadData.asp";
NSString * const kPageScannerInputLink	= @"scannerinput.asp";
NSString * const kPageScannerHomeLink	= @"http://demo.newleads.com";

NSString * const kPageLoginName			= @"login.asp";
NSString * const kPageDefaultName		= @"default.asp";
NSString * const kPageCusteditName		= @"custedit.asp";
NSString * const kPageEdittabName		= @"edittab.asp";
NSString * const kPageEditleadName		= @"editlead.asp";
NSString * const kPageKeywordName		= @"Selected Lead";
NSString * const kPageKeywordValueName	= @"value=";
//
NSString * const kRequestGetLeadInfoKey			= @"GetLeadInfo";
NSString * const kRequestUploadLeadInfoKey		= @"UploadLeadInfo";
NSString * const kRequestUploadDataKey			= @"iPadData";
NSString * const kRequestUploadScannedDataKey	= @"UploadScannedData";



@interface NLStartPageVC ()
<
	UIWebViewDelegate,
	ASIHTTPRequestDelegate
>

//
// UI - XIB:
@property (nonatomic, assign) IBOutlet UIWebView * viewWeb;
//
//
//
// Logic:
@property (nonatomic, assign) BOOL		isFirstStart;
@property (nonatomic, assign) BOOL		leadFirstStart;
@property (nonatomic, assign) BOOL		leadWasFound;
@property (nonatomic, assign) BOOL		leadMode;
@property (nonatomic, assign) BOOL		scanMode;

@end



@implementation NLStartPageVC

- (void) dealloc
{
    [NLContext shared].scanPage = nil;
}

- (void) viewDidLoad
{
    [super viewDidLoad];

	self.isLoaded		= NO;
	self.isFirstStart	= YES;
	self.leadWasFound	= NO;
	self.leadFirstStart	= YES;
	
	self.viewWeb.scalesPageToFit = YES;
}



#pragma mark - Core logic
//
- (void) goHome:(BOOL) force
{
	if( !force && self.leadMode )
	{
		if( !self.leadFirstStart )
		{
			// ???
		}
		return;
	}
    
    [self.leadsVC initScanner:NO];
    [self.leadsVC initSocketScanner:NO];
	NSString * strPath = [NSString stringWithFormat:@"%@/%@", [NLContext shared].clientURL, kPageDefaultName];
	if (strPath && ![strPath hasPrefix:@"http"])
	{
		strPath = [NSString stringWithFormat:@"http://%@", strPath];
	}
	NSURL * url = [NSURL URLWithString:strPath relativeToURL:nil];
	if( url )
	{
		NSURLRequest *request = [NSURLRequest requestWithURL:url];
		if( request )
		{
			[self.viewWeb loadRequest: request];
		}
	}
}

- (void) stopLoading
{
	self.isLoaded = NO;
	
	[self.viewWeb stopLoading];
}

- (void) getCurrentLead
{
	NSString * strURL = [NSString stringWithFormat:@"%@/%@", [NLContext shared].clientURL, kPageGetLeadLink];
	NSURL * url = [NSURL URLWithString:strURL relativeToURL:nil];
	if( url )
	{
		ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL: url];
		if( request )
		{
			request.userInfo = [NSDictionary dictionaryWithObject:kRequestGetLeadInfoKey forKey:kRequestGetLeadInfoKey];
			request.delegate = self;
			[request startAsynchronous];
			
//			[parent.selectorView enableButtonTour:NO];
			
			MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].delegate window] animated:NO];
			hud.labelText = @"Loading...";
		}
	}
}

- (void) sendStatData:(NSString *) anDataString
{
	if( anDataString )
	{
		NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?ID=%ld", [NLContext shared].clientURL, kPageUploadLink, (unsigned long)[NLContext shared].leadID]];
		if( url )
		{
			ASIFormDataRequest * request = [ASIFormDataRequest requestWithURL: url];
			if( request )
			{
				[request setPostValue:[anDataString dataUsingEncoding:NSUTF8StringEncoding] forKey: kRequestUploadDataKey];
				request.userInfo = [NSDictionary dictionaryWithObject:kRequestUploadLeadInfoKey forKey:kRequestUploadLeadInfoKey];
				request.delegate = self;
				[request startAsynchronous];
			}
		}
	}
}

- (void) sendScannedData:(NSData *) anData forStation:(NSString *) anStationID
{
	if( anData && [anStationID length]>0)
	{
		NSString * convertedString = [[NSString alloc] initWithData:anData encoding:NSUTF8StringEncoding];
		//
		// Use variant from nlScannerDemo:
		//
        NSString *urlAddress = [NSString stringWithFormat:@"%@/scannerinput.asp?rawdata=%@&stationid=%@&silent=%@",[NLContext shared].clientURL, convertedString, anStationID, [NLContext shared].isScanAndGo?@"True":@"False"];
		NSString *strURL = [urlAddress stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		
		NSLog(@"Post string = %@", strURL);
		NSURL *url = [NSURL URLWithString:strURL];
		NSLog(@"Post url = %@", url);
		
		NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
		[self.viewWeb loadRequest:requestObj];
	}
	else
	{
		NSLog(@"Can't send scanned data. stationID = %@, Data = %@", anStationID, anData);
	}
}

- (void) uploadImageData:(NSData *) imgData
{
	NSLog(@"Post data size = %ld", (unsigned long)[imgData length]);
	NSString *urlAddress = [NSString stringWithFormat:@"%@/bizcard.asp?",[NLContext shared].clientURL];
	NSString *strURL = [urlAddress stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL URLWithString:strURL];
	NSLog(@"Post url = %@", url);
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
	[request setHTTPMethod: @"POST"];
	NSString *boundary = @"---------------------------14737809831466499882746641449";
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
	[request addValue:contentType forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:imgData];
	
	[self.viewWeb loadRequest:request];
}



#pragma mark - UIWebViewDelegate
//
- (BOOL) webView:(UIWebView*)anWebView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
	return YES;
}

- (void) webViewDidStartLoad:(UIWebView*) anWebView
{
//	NSURL * loadedURL = [webView.request URL];
//	NSString * myLink = [loadedURL absoluteString];
//	if( NSNotFound != [myLink rangeOfString:kPageRecentLink].location )
//	{
//		[parent.selectorView showOnlyTourButton:NO];
//	}
//	else if( NSNotFound != [myLink rangeOfString:strClientURL].location )
//	{
//		[parent.selectorView showOnlyTourButton:NO];
//	}
//	else
//	{
//		if( !scanMode )
//		{
//			[parent.selectorView showOnlyTourButton:YES];
//		}
//	}
	
	MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].delegate window] animated:NO];
	hud.dimBackground = YES;
	hud.labelText = @"Loading...";
}

- (void) webViewDidFinishLoad:(UIWebView*)anWebView
{
	self.isLoaded = YES;
	
	[MBProgressHUD hideHUDForView:[[UIApplication sharedApplication].delegate window] animated:NO];
	
//	NSLog(@"Did finished - %@", self.webView.request);
//	NSLog(@"Body: %@", [self.webView.request HTTPBody]);
//	NSString *html = [self.webView stringByEvaluatingJavaScriptFromString:
//					  @"document.body.innerHTML"];
//
//	NSLog(@"\nBody 2: %@", html);
	
	NSURL * loadedURL = [anWebView.request URL];
	NSString * myLink = [[loadedURL absoluteString] lowercaseString];
#if DEBUG
    NSLog(@"url=%@", myLink);
#endif
	
    [NLContext shared].scanPage = myLink;
    
	if( NSNotFound != [myLink rangeOfString:kPageEdittabName].location || NSNotFound != [myLink rangeOfString:kPageCusteditName].location || NSNotFound != [myLink rangeOfString:kPageLoginName].location)
	{
		[self getCurrentLead];
		
		self.leadMode = YES;
		
		if( self.leadFirstStart )
		{
			self.leadFirstStart = NO;
		}
		
		[self.leadsVC initScanner:NO];
		[self.leadsVC initSocketScanner:NO];
	}
	else if( NSNotFound != [myLink rangeOfString:kPageRecentLink].location || NSNotFound != [myLink rangeOfString:kPageClickToBeginLink].location || NSNotFound != [myLink rangeOfString:kPageEditleadName].location)
	{
        BOOL editLeadPage = YES;
        // don't touch old logic
        if (NSNotFound != [myLink rangeOfString:kPageEditleadName].location)
        {
            editLeadPage = NO;
            if( self.isFirstStart )
            {
                self.isFirstStart = NO;
            }
            else
            {
                // ???
            }
            
            if( self.scanMode )
            {
                self.scanMode = NO;
            }
            self.leadMode = NO;
            self.leadFirstStart = YES;
            //
            // Clean lead:
            // Upd. Nov 16 - move this code from LeadsViewController.
            [[NLContext shared] cleanLeadData];
        }
        
        [self.leadsVC initScanner:editLeadPage];
        [self.leadsVC initSocketScanner:editLeadPage];

	}
	else
	{
        [self.leadsVC initScanner:NO];
        [self.leadsVC initSocketScanner:NO];
		self.isLoaded = NO;		
	}
	
//	{
//		[anWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat: @"document.getElementsByName('UserName')[0].value = '%@'", @"Test"]];
//		[anWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat: @"document.getElementsByName('Password')[0].value = '%@'", @"test"]];
//	}
}

- (void) webView:(UIWebView *)anWebView didFailLoadWithError:(NSError*)error
{
	[MBProgressHUD hideHUDForView:[[UIApplication sharedApplication].delegate window] animated:NO];
	
	if([error code] == NSURLErrorCancelled)
		return;
	
	self.isLoaded = NO;

	[NLAlertView show:@"Cannot open page" message:@"Browser cannot open this page"];
}



#pragma mark -
#pragma mark ASIHTTPRequestDelegate
//
- (void) requestFinished:(ASIHTTPRequest *) anRequest
{
	[MBProgressHUD hideHUDForView:[[UIApplication sharedApplication].delegate window] animated:NO];
	
	if( [kRequestGetLeadInfoKey isEqualToString:[anRequest.userInfo objectForKey:kRequestGetLeadInfoKey]] )
	{
		NSData * dt = [anRequest responseData];
		
		NSError * error = nil;
		NSDictionary * dataSource = [XMLReader dictionaryForXMLData: dt error: &error];
		if( !error )
		{
			// Get root object:
			NSDictionary * dicRoot = [dataSource dictForName: @"SelectedLead"];
			if( dicRoot )
			{
				BOOL isSuccess = NO;
				[NLContext shared].leadFirstName = [dicRoot stringForName:@"FirstName"];
				[NLContext shared].leadLastName	= [dicRoot stringForName:@"LastName"];
				[NLContext shared].leadID		= [dicRoot intForName:@"LeadID" success:&isSuccess];
			}
		}
		else
		{
			// TODO: No lead info rceived here...
//			NSLog(@"Get lead info response: %@", [anRequest responseString]);
		}
	}
	else if( [kRequestUploadLeadInfoKey isEqualToString:[anRequest.userInfo objectForKey:kRequestUploadLeadInfoKey]] )
	{
		// Do nothing here...
//		NSLog(@"Upload stat response: %@", [anRequest responseString]);
	}
	else if([anRequest.userInfo objectForKey:kRequestUploadScannedDataKey] )
	{
		NSString * dt = [anRequest responseString];
		if( dt )
		{
			dt = [dt stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
			
			[self.viewWeb loadHTMLString:dt baseURL:anRequest.url];
		}
	}
}

- (void) requestFailed:(ASIHTTPRequest *) anRequest
{
//	NSLog(@"Request error response: %@", [anRequest responseString]);
	
	[MBProgressHUD hideHUDForView:[[UIApplication sharedApplication].delegate window] animated:NO];

	if( self.scanMode )
	{
		self.scanMode = NO;
	}
}

@end
