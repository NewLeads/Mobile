//
//  NLDownloadingVC.m
//  NewLeads
//
//  Created by idevs.com on 18/03/2015.
//  Copyright (c) 2015 idevs.com. All rights reserved.
//

#import "NLDownloadingVC.h"
#import "AdminLogger.h"
#import "ASIHTTPRequestDelegate.h"
#import "URLConnectionWrapper.h"
//
// Assets:
#import "ASIHTTPRequest.h"
#import "NSDictionary+XMLReader.h"
#import "XMLReader.h"
#import "URLConnectionWrapper.h"
//
#import <QuartzCore/CALayer.h>



@interface NLDownloadingVC ()
{
	@protected
	//
	// Logic:
	BOOL	keyboardActionOccur;
	BOOL	reDownloadOccur;
	BOOL	isInitialLayout;

	//
	// Storage:
	NSArray					* contentTreeArr;
	NSMutableArray			* contentToDownloadArr;

	//
	// Helpers:
	NSString				* pathToShowFolder;

	//
	// Downloading logic:
	NSInteger				itemsInWork;
	NSInteger				itemsToDownload;
	NSInteger				itemsPassed;
	NSMutableArray			* failedDownloadsArr;
	NSMutableDictionary		* requestPoolDic;
	AdminLogger				* logger;
}
//
// UI - XIB:
@property (nonatomic, readwrite, assign) IBOutlet UILabel			* labelProgress;
@property (nonatomic, readwrite, assign) IBOutlet UILabel			* labelFileName;
@property (nonatomic, readwrite, assign) IBOutlet UILabel			* labelFileStatus;
@property (nonatomic, readwrite, assign) IBOutlet UIProgressView	* viewProgress;
@property (nonatomic, readwrite, assign) IBOutlet UIActivityIndicatorView	* viewActivity;

@property (nonatomic, readwrite, retain) NSArray			* contentTreeArr;
@property (nonatomic, readwrite, retain) NSMutableArray		* contentToDownloadArr;
@property (nonatomic, readwrite, retain) NSMutableArray		* failedDownloadsArr;
@property (nonatomic, readwrite, retain) NSMutableDictionary* requestPoolDic;
//
@property (nonatomic, readwrite, copy) NSString				* pathToShowFolder;

@end

@implementation NLDownloadingVC

- (void) viewDidLoad
{
    [super viewDidLoad];
	
	self.requestPoolDic		= [[NSMutableDictionary alloc] init];
	self.failedDownloadsArr	= [[NSMutableArray alloc] init];
	
	[self uiShowWaitIndicator: NO];
	
	[URLConnectionWrapper enableDebug: NO];
}

- (void) cleanup
{
	logger = nil;
	
	self.contentToDownloadArr	= nil;
	self.failedDownloadsArr		= nil;
	self.contentTreeArr			= nil;
	self.pathToShowFolder		= nil;
	
	if( self.requestPoolDic )
	{
		self.requestPoolDic = nil;
	}
	
	[super cleanup];
}



#pragma mark - Actions
//
- (void) onButtonCloseLog:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
	
	[self finishDownloadingContent];
}



#pragma mark - Core logic
//
- (NSString *) kbFromBytes:(NSUInteger) anBytes
{
	return [NSString stringWithFormat:@"%0.2f", (anBytes / 1024.f)];
}

- (NSString *) mbFromBytes:(NSUInteger) anBytes
{
	return [NSString stringWithFormat:@"%0.2f", ((anBytes / 1024.f) / 1024.f)];
}

- (void) updatePathToShowFolder
{
	NSFileManager * fm = [NSFileManager defaultManager];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	if ([paths count] > 0)
	{
		NSString * userDocumentsPath = [paths objectAtIndex:0];
		
		NSString * fullDirPath = [userDocumentsPath stringByAppendingPathComponent: [NLContext shared].datasourceFolder];
		NSError * error = nil;
		if( [fm createDirectoryAtPath: fullDirPath
		  withIntermediateDirectories: YES
						   attributes: nil
								error: &error] )
		{
			self.pathToShowFolder = fullDirPath;
		}
		else
		{
			self.pathToShowFolder = nil;
		}
	}
}

- (NSString *) folderPathForItem:(NSString *) itemName
{
	NSFileManager * fm = [NSFileManager defaultManager];
	
	NSString * fullDirPath = [self.pathToShowFolder stringByAppendingPathComponent: itemName];
	
	BOOL isDirectory = YES;
	if( ![fm fileExistsAtPath:fullDirPath isDirectory: &isDirectory] )
	{
		NSError * error = nil;
		if( ![fm createDirectoryAtPath: fullDirPath
		   withIntermediateDirectories: YES
							attributes: nil
								 error: &error] )
		{
			NSLog(@"%@. \nCan't create directory at path: %@ \n with error: %@", [self class] , fullDirPath, [error localizedDescription]);
			fullDirPath = nil;
		}
	}
	
	return fullDirPath;
}

- (NSString *) tempFolderPathForItem:(NSString *) itemName
{
	NSFileManager * fm = [NSFileManager defaultManager];
	NSString * tempDir = NSTemporaryDirectory();
	//NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	//if ([paths count] > 0)
	{
		//NSString * userDocumentsPath = [[paths objectAtIndex:0] stringByAppendingPathComponent: [NLContext shared].datasourceFolder];
		NSString * userDocumentsPath = [tempDir stringByAppendingPathComponent: [NLContext shared].datasourceFolder];
		
		NSString * fullDirPath = [userDocumentsPath stringByAppendingPathComponent: itemName];
		
		BOOL isDirectory = YES;
		if( ![fm fileExistsAtPath:fullDirPath isDirectory: &isDirectory] )
		{
			NSError * error = nil;
			if( ![fm createDirectoryAtPath: fullDirPath
			   withIntermediateDirectories: YES
								attributes: nil
									 error: &error] )
			{
				NSLog(@"%@. \nCan't create directory at path: %@ \n with error: %@", [self class] , fullDirPath, [error localizedDescription]);
				fullDirPath = nil;
			}
		}
		return fullDirPath;
	}
	return self.pathToShowFolder;
}

- (void) uiShowWaitIndicator:(BOOL) anFlag
{
	if( anFlag )
	{
		[self.viewActivity startAnimating];
	}
	else
	{
		[self.viewActivity stopAnimating];
	}
}

- (void) uiUpdateProgressString:(NSString *) anText
{
	self.labelProgress.text = anText;
}

- (void) uiUpdateFileNameString:(NSString *) anText
{
	self.labelFileName.text = anText;
}

- (void) uiUpdateFileStatusString:(NSString *) anText
{
	self.labelFileStatus.text = anText;
}

- (void) uiShowLog
{
	UIViewController * logController = [UIViewController new];
	logController.modalPresentationStyle= UIModalPresentationFormSheet;
	logController.modalTransitionStyle	= UIModalTransitionStyleCoverVertical;
	
	NSArray * arrNib = [[NSBundle mainBundle] loadNibNamed:@"AdminLogView" owner:self options:nil];
	AdminLogView * logView = [arrNib objectAtIndex: 0];
	
	[logView.textView setText: [logger logContent]];
	[logView.btnClose addTarget: self
						 action: @selector(onButtonCloseLog:)
			   forControlEvents: UIControlEventTouchUpInside];
	
	[logController setView: logView];
	
	//[self presentModalViewController:logController animated:YES];
	[self presentViewController:logController animated:YES completion:nil];
}

- (void) uiShowLoginForm:(BOOL) anFlag
{
	if( anFlag )
	{
		if( ![self.viewForm superview] )
		{
			[self.viewScroll addSubview:self.viewForm];
			
			CGRect rcForm = self.viewForm.frame;
			
			rcForm.size.width = self.view.bounds.size.width;
			rcForm.size.height= self.view.bounds.size.height - self.navigationController.navigationBar.frame.size.height;
			self.viewForm.frame = rcForm;
			
			self.viewScroll.contentSize = self.viewForm.frame.size;
			
			self.viewCurrent = self.viewForm;
		}
	}
	else
	{
		[self.viewForm removeFromSuperview];
	}
}

- (void) uiShowDownloadingForm:(BOOL) anFlag
{
	if( anFlag )
	{
		if( ![self.viewDownloading superview] )
		{
			[self.viewScroll addSubview:self.viewDownloading];
			
			CGRect rcForm = self.viewDownloading.frame;
			
			rcForm.size.width = self.view.bounds.size.width;
			rcForm.size.height= self.view.bounds.size.height - self.navigationController.navigationBar.frame.size.height;
			self.viewDownloading.frame = rcForm;
			
			self.viewScroll.contentSize = self.viewDownloading.frame.size;
			
			self.viewCurrent = self.viewDownloading;
		}
	}
	else
	{
		[self.viewDownloading removeFromSuperview];
	}
}

- (CGFloat) minViewCurrentH
{
	CGFloat end = self.btnLogin.frame.origin.y + self.btnLogin.frame.size.height + 8;
	
	return end;
}

#pragma mark >>> Downloading content:
//
- (void) startDownloading
{
	[UIView transitionWithView:self.view
					  duration:0.2
					   options:UIViewAnimationCurveLinear|UIViewAnimationOptionTransitionFlipFromRight
					animations:^(void)
	 {
		 [self uiShowLoginForm:NO];
		 [self uiShowDownloadingForm:YES];
	 }
					completion:^(BOOL finished)
	 {
		 [self downloadContentFile];
	 }];
}

- (void) stopDownloading
{
	[UIView transitionWithView:self.view
					  duration:0.2
					   options:UIViewAnimationCurveLinear|UIViewAnimationOptionTransitionFlipFromRight
					animations:^(void)
	 {
		 [self uiShowLoginForm:YES];
		 [self uiShowDownloadingForm:NO];
	 }
					completion:^(BOOL finished)
	 {
	 }];
}

- (void) downloadContentFile
{
	NSURL * contentFileURL = [NSURL URLWithString:
							  [NSString stringWithFormat:@"%@%@:%@@%@/%@/%@",
							   //[NSString stringWithFormat:@"%@%@:%@@%@",
							   kAVCDefaultFTPPrefix,
							   [NLContext shared].userLogin,
							   [NLContext shared].userPassword,
							   [NLContext shared].datasourceAddress,
							   [NLContext shared].datasourceFolder,
							   kAVCContentFileName]];
	if( contentFileURL )
	{
		//ASIHTTPRequest * r = [ASIHTTPRequest requestWithURL: contentFileURL];
		URLConnectionWrapper * r = [URLConnectionWrapper connectionWithURL: contentFileURL];
		if( r )
		{
			r.delegate	= self;
			r.userInfo	= [NSDictionary dictionaryWithObject:kAVCDownloadContentFileKey forKey: kAVCDownloadContentFileKey];
			[r startConnection];
			
			[self addConnectionToPool: r];
			
			
			[self uiUpdateProgressString:@"Downloading content file..."];
			[self uiUpdateFileNameString:kAVCContentFileName];
			[self uiShowWaitIndicator: YES];
			
			[logger log:@"Downloading %@\n", contentFileURL];
		}
	}
}

- (void) finishDownloadingContent
{
	[logger flush];
	
	[self uiShowWaitIndicator: NO];
	
	//
	// If all downloads are good = just go to leads screen,
	// overwise - prompt user to trying re-dowload wrong content.
	//
	//	if( 0 == [failedDownloadsArr count] )
	//	{
	[self saveContentFile];
	
	[[NLContext shared] loadContentDict];
	
	[NLContext shared].isFirstLaunch = NO;
	[[NLContext shared] saveAppSettings];
	
	[self switchToController: @"NLLeadsViewController"];
	//	}
	//	else
	//	{
	//		[self uiShowLoginForm:NO];
	//		[self uiShowDownloadingForm:NO];
	//
	//		[[NLContext shared] showAlertWithTitle: @"Warning"
	//									   andText: [NSString stringWithFormat:@"The downloading not completed properly.\nThere are %d files not loaded.\nDo you want to re-download it?", [failedDownloadsArr count]]
	//								   andDelegate: self
	//							  andButtonsTitles:[NSArray arrayWithObjects:@"Continue", @"View Log", @"Re-download", nil]];
	//	}
}

- (void) saveContentFile
{
	//
	// Local content dic:
	NSMutableDictionary	* tempDic = [[NSMutableDictionary alloc] init];
	
	////////////////////////////////////////////////////////////////////
	// Add field in local dic:
	//
	NSMutableArray * tempContentArr = [[NSMutableArray alloc] init];
	
	// Add expiration date field dic:
	//
	[tempDic setValue:[NLContext shared].expirationDate
			   forKey:@"expdate"];
	
	
	// Add clientURL date field dic:
	//
	[tempDic setValue:[NLContext shared].clientURL
			   forKey:@"serverurl"];
	
	[tempDic setValue:tempContentArr forKey:@"content"];
	
	//
	// Save and set content dictionary:
	[[NLContext shared] saveContentDict: tempDic];
	//
	////////////////////////////////////////////////////////////////////
	
}


#pragma mark >>> Parsing downloaded content:
//
- (void) parseContentFile:(NSDictionary *) anDataSource
{
	// Get root object:
	NSDictionary * dicRoot = [anDataSource dictForName: @"content"];
	
	self.contentTreeArr = nil;
	self.contentToDownloadArr = nil;
	
	
	if( dicRoot )
	{
		
		NSString * strExpDate = [dicRoot stringForName:@"expdate"];
		if( strExpDate )
		{
			[NLContext shared].expirationDate = strExpDate;
		}
		
		//
		// Try to read client's server path:
		//
		NSString * strClientURL = [dicRoot stringForName:@"serverurl"];
		if( strClientURL )
		{
			[NLContext shared].clientURL = strClientURL;
		}
	}
	
	//    [self performSelectorOnMainThread:@selector(downloadLogoFile)
	//                           withObject:nil
	//                        waitUntilDone:NO];
	
	[self finishDownloadingContent];
}


#pragma mark >>> File operations
//
- (BOOL) saveData:(NSData *) anData atPath:(NSString *) anPath forName:(NSString *) anName
{
	if( anData && anPath && anName && 0 < [anPath length] && 0 < [anName length] )
	{
		NSFileManager * fm = [NSFileManager defaultManager];
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		if ([paths count] > 0)
		{
			NSString * userDocumentsPath = [paths objectAtIndex:0];
			
			NSString * fullDirPath = [userDocumentsPath stringByAppendingPathComponent: anPath];
			NSError * error = nil;
			if( [fm createDirectoryAtPath: fullDirPath
			  withIntermediateDirectories: YES
							   attributes: nil
									error: &error] )
			{
				NSString * fullContentPath = [fullDirPath stringByAppendingPathComponent: anName];
				if( [anData writeToFile:fullContentPath atomically: YES] )
				{
					return YES;
				}
			}
		}
	}
	
	return NO;
}

- (BOOL) saveFileAtPath:(NSString *) sorcePath toPath:(NSString *) destinationPath forName:(NSString *) anName;
{
	if( sorcePath && destinationPath && anName && 0 < [sorcePath length] && 0 < [destinationPath length] && 0 < [anName length] )
	{
		NSFileManager * fm = [NSFileManager defaultManager];
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		if ([paths count] > 0)
		{
			NSString * userDocumentsPath = [paths objectAtIndex:0];
			
			NSString * fullDirPath = [userDocumentsPath stringByAppendingPathComponent: destinationPath];
			NSError * error = nil;
			if( [fm createDirectoryAtPath: fullDirPath
			  withIntermediateDirectories: YES
							   attributes: nil
									error: &error] )
			{
				NSString * fullContentPath = [fullDirPath stringByAppendingPathComponent: anName];
				
				[fm moveItemAtPath:sorcePath
							toPath:fullContentPath
							 error:&error];
				if( !error )
				{
					return YES;
				}
				else
				{
					NSLog(@"%@. saveFileAtPath error: %@", [self class], [error localizedDescription]);
				}
			}
		}
	}
	
	return NO;
}



#pragma mark >>> Connections pool helper
//
- (NSString *) addConnectionToPool:(URLConnectionWrapper *) anConnection
{
	NSString * sharedKey = [NSString stringWithFormat:@"%p", anConnection];
	
	[requestPoolDic setObject: anConnection forKey:sharedKey];
	
	return sharedKey;
}

- (void) removeConnection:(URLConnectionWrapper *) anConnection
{
	NSString * testKey	= [NSString stringWithFormat:@"%p", anConnection];
	
	anConnection.delegate = nil;
	
	[requestPoolDic removeObjectForKey: testKey];
}



#pragma mark -
#pragma mark URLConnectionWrapperProtocol
//
- (void) connectionStarted:(URLConnectionWrapper *) connection
{
	self.viewProgress.progress = connection.progress;
	//[self uiUpdateFileStatusString:[NSString stringWithFormat:@"%@/%@ Mb", [self mbFromBytes: connection.downloadedLength], [self mbFromBytes: connection.expectedLength]]];
	[self uiUpdateFileStatusString: @""];
}

- (void) connectionProgress:(URLConnectionWrapper *)connection
{
	self.viewProgress.progress = connection.progress;
	[self uiUpdateFileStatusString:[NSString stringWithFormat:@"%@/%@ Mb", [self mbFromBytes: connection.downloadedLength], [self mbFromBytes: connection.expectedLength]]];
}

- (void) connectionFinished:(URLConnectionWrapper *) connection
{
	self.viewProgress.progress = connection.progress;
	[self uiUpdateFileStatusString:[NSString stringWithFormat:@"%@/%@ Mb", [self mbFromBytes: connection.downloadedLength], [self mbFromBytes: connection.expectedLength]]];
	
	//NSData * dt = [connection responseData];
	//if( dt )
	{
		if( [connection.userInfo objectForKey: kAVCDownloadContentFileKey] )
		{
			//
			// Clean pool:
			[self removeConnection: connection];
			
			/*
			 NSDictionary * responseDict = [request responseHeaders];
			 NSLog(@"\nResponse headers: %@", responseDict);
			 
			 NSString * strType = [responseDict objectForKey: @"Content-Type"];
			 if( NSNotFound != [strType rangeOfString:@"text/html"].location )
			 {
			 [[NLContext shared] showAlertWithTitle: @"Connection Error"
			 andText: [request responseString]];
			 }
			 else if( NSNotFound != [strType rangeOfString:@"application/xml"].location )
			 */
			{
				NSError * error = nil;
				NSData * dt = [connection responseData];
				NSDictionary * dataSource = [XMLReader dictionaryForXMLData: dt error: &error];
				if( error )
				{
					[NLAlertView show:@"Parse Error" message:[error localizedDescription]];
					goto END;
				}
				
				[logger log:@"---> Content.xml file downloaded!\n"];
				
				[self performSelectorOnMainThread: @selector(parseContentFile:)
									   withObject: dataSource
									waitUntilDone: NO];
				return;
			}
		}
	}
	
END:
	[self uiShowWaitIndicator: NO];
}

- (void) connectionFailed:(URLConnectionWrapper *) connection
{
	self.viewProgress.progress = 0.f;
	
	BOOL isContentFileError = NO;
	BOOL isSaved = NO;
	if( [connection.userInfo objectForKey: kAVCDownloadContentFileKey] )
	{
		[logger log:@"---> FAILED downloading content file with error: %@\n", [[connection error] localizedDescription]];
		
		isContentFileError = YES;
		//
		// Cleanup:
		[self removeConnection: connection];
		
		[self uiShowWaitIndicator: NO];
		
		[NLAlertView show:@"Request Error"
				  message:[[connection error] localizedDescription]
				  buttons:@[@"OK"]
					block:^(NLAlertView *alertView, NSInteger buttonIndex)
		 {
			 [self stopDownloading];
		 }];
	}
	
	if( !isContentFileError )
	{
		//
		// Fill array of failed connections:
		[failedDownloadsArr addObject: connection];
		
		//
		// Cleanup:
		[self removeConnection: connection];
		
		//
		// Update counters:
		if( !isSaved )
		{
			itemsInWork--;
			itemsPassed++;
		}
		
		[self finishDownloadingContent];
	}
}

- (void) connectionCancelled:(URLConnectionWrapper *) connection
{
	self.viewProgress.progress = 0.f;
	
	BOOL isContentFileError = NO;
	BOOL isSaved = NO;
	if( [connection.userInfo objectForKey: kAVCDownloadContentFileKey] )
	{
		[logger log:@"---> Cancel downloading content file: %@ with error: %@\n", [connection.originalURL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[connection error] localizedDescription]];
		
		isContentFileError = YES;
		[NLAlertView show:@"Request Error" message:[[connection error] localizedDescription]];
		//
		// Cleanup:
		[self removeConnection: connection];
		
		[self uiShowWaitIndicator: NO];
	}
	
	if( !isContentFileError )
	{
		//
		// Fill array of failed connections:
		[failedDownloadsArr addObject: connection];
		
		//
		// Cleanup:
		[self removeConnection: connection];
		
		//
		// Update counters:
		if( !isSaved )
		{
			itemsInWork--;
			itemsPassed++;
		}
		
		[self finishDownloadingContent];
	}
}

@end
