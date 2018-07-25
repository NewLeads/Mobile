//
//  NLAdminViewController.m
//  NewLeads
//
//  Created by idevs.com on 25/09/2013.
//  Copyright (c) 2013 idevs.com. All rights reserved.
//

#import "NLAdminViewController.h"
#import "NLAppDelegate.h"
#import "AdminLogger.h"
#import "AdminLogView.h"
#import "NLBarcodeDatasource.h"
//
// Assets:
#import "ASIHTTPRequest.h"
#import "NSDictionary+XMLReader.h"
#import "XMLReader.h"
#import "URLConnectionWrapper.h"
//
#import <QuartzCore/CALayer.h>



#pragma mark -
#pragma mark Configuration
//
NSString * const kAVCDefaultFTPPrefix	= @"ftp://";
NSString * const kAVCDefaultFTPAddress	= @"ftp.tradeshow-reg.com";//@"108.47.1.67";
//NSString * const kAVCDefaultFTPAddress	= @"http://localhost/~gray13";
NSString * const kAVCDefaultFTPFolder	= @"ES14";//@"SwtichTest1";//@"ScanButtonsONtest3";//@"MY1";
NSString * const kAVCDefaultTestLogin	= @"roomboss";//@"testuser";
NSString * const kAVCDefaultTestPass	= @"Qualify1";//@"testuser";
//
NSString * const kAVCContentFileName	= @"content.xml";
//
NSString * const kAVCDownloadContentFileKey		= @"downloadContentFile";
NSString * const kAVCDownloadLogoFileKey		= @"downloadLogoFile";
NSString * const kAVCDownloadContentDataIconKey	= @"downloadContentDataIcon";
NSString * const kAVCDownloadContentDataKey		= @"downloadContentData";
//
const NSInteger		kAVSimultaneousDownloads	= 1;



@interface NLAdminViewController ()
<UITextFieldDelegate>

//
// UI - XIB:
@property (nonatomic, readwrite, assign) IBOutlet UIScrollView * viewScroll;
//
@property (nonatomic, readwrite, assign) UIView * viewCurrent;

- (CGFloat) minViewCurrentH;

@property (nonatomic, readwrite, retain) NSArray			* contentTreeArr;
@property (nonatomic, readwrite, retain) NSMutableArray		* contentToDownloadArr;
@property (nonatomic, readwrite, retain) NSMutableArray		* failedDownloadsArr;
@property (nonatomic, readwrite, retain) NSMutableDictionary* requestPoolDic;
//
@property (nonatomic, readwrite, copy) NSString				* pathToShowFolder;


- (void) onButtonCloseLog:(id)sender;
//
- (void) uiFillDefaultValues;
- (void) uiShowWaitIndicator:(BOOL) anFlag;
- (void) uiUpdateProgressString:(NSString *) anText;
- (void) uiUpdateFileNameString:(NSString *) anText;
- (void) uiUpdateFileStatusString:(NSString *) anText;
- (void) uiShowLog;
//
- (BOOL) validateTextField:(UITextField *) anField;
- (NSString *) kbFromBytes:(NSUInteger) anBytes;
- (NSString *) mbFromBytes:(NSUInteger) anBytes;
- (void) updatePathToShowFolder;
- (NSString *) folderPathForItem:(NSString *) itemName;
- (NSString *) tempFolderPathForItem:(NSString *) itemName;
//
- (void) downloadContentFile;
- (void) finishDownloadingContent;
//
- (void) parseContentFile:(NSDictionary *) anDataSource;

//
// Helper:
- (NSString *) addConnectionToPool:(URLConnectionWrapper *) anConnection;
- (void) removeConnection:(URLConnectionWrapper *) anConnection;
- (BOOL) saveData:(NSData *) anData atPath:(NSString *) anPath forName:(NSString *) anName;
- (BOOL) saveFileAtPath:(NSString *) sorcePath toPath:(NSString *) destinationPath forName:(NSString *) anName;
//
- (void) saveContentFile;

@end



@implementation NLAdminViewController

@synthesize contentTreeArr, contentToDownloadArr, failedDownloadsArr, requestPoolDic, pathToShowFolder;


- (void) viewDidLoad
{
    [super viewDidLoad];
	
	self.title = @"Admin";
	
	logger = [[AdminLogger alloc] init];
	
	UIImage * imgNormalBG = [NLUtils stretchedImageNamed:@"btn-green" width:CGRectMake(0, 0, 6, 0)];
	[self.btnLogin setBackgroundImage:imgNormalBG forState:UIControlStateNormal];
	
	[self uiFillDefaultValues];
	
	self.requestPoolDic		= [[NSMutableDictionary alloc] init];
	self.failedDownloadsArr	= [[NSMutableArray alloc] init];
	
	self.fieldAddress.delegate = self;
	self.fieldPath.delegate = self;
	self.fieldLogin.delegate = self;
	self.fieldPass.delegate = self;
	self.fieldStationID.delegate = self;
//
	[self uiFillDefaultValues];
	[self uiShowWaitIndicator: NO];
	
	[URLConnectionWrapper enableDebug: NO];
	
	[self uiShowLoginForm:YES];
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.navigationItem.rightBarButtonItem = self.barLogo;
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillBeShown:)
												 name:UIKeyboardWillShowNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillBeHidden:)
												 name:UIKeyboardWillHideNotification object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void) cleanup
{
	logger = nil;
	
	self.contentToDownloadArr	= nil;
	self.failedDownloadsArr		= nil;
	self.contentTreeArr			= nil;
	self.pathToShowFolder		= nil;
	
	if( requestPoolDic )
	{
		//		NSArray * allValues = [requestPoolDic allValues];
		//		for(ASIHTTPRequest * r in allValues )
		//		{
		//			[r clearDelegatesAndCancel];
		//		}
		
		self.requestPoolDic = nil;
	}
	
	[super cleanup];
}



#pragma mark - Actions
//
- (IBAction) onButtonLogin:(id)sender
{
	NSString * strMessage = nil;
	
	if( ![self validateTextField: self.fieldPath] )
	{
		strMessage = @"Path is empty.";
	}
	
	if( ![self validateTextField: self.fieldAddress] )
	{
		strMessage = @"Address in not valid";
	}
	
	if( !strMessage && ![self validateTextField: self.fieldLogin] )
	{
		strMessage = @"The login is wrong";
	}
	
	if( !strMessage && ![self validateTextField: self.fieldPass] )
	{
		strMessage = @"The password is wrong";
	}
	
	if( strMessage )
	{
		[NLAlertView show:@"Error" message:strMessage];

		return;
	}
	
	reDownloadOccur = NO;
	
	[NLContext shared].userLogin			= [self.fieldLogin.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	[NLContext shared].userPassword		= [self.fieldPass.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	[NLContext shared].datasourceFolder	= [self.fieldPath.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	[NLContext shared].datasourceAddress = [self.fieldAddress.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	[NLContext shared].stationID			= self.fieldStationID.text;
	[[NLContext shared] saveAppSettings];
	
	if( self.fieldCurrent )
	{
		[self.fieldCurrent resignFirstResponder];
		self.fieldCurrent = nil;
	}
	
	itemsToDownload = 0;
	itemsPassed		= 0;
	itemsInWork		= 0;
	
	[self updatePathToShowFolder];
	
	if( 0 != [failedDownloadsArr count] )
	{
		[failedDownloadsArr removeAllObjects];
	}
	if( 0 != [[requestPoolDic allValues] count] )
	{
		[requestPoolDic removeAllObjects];
	}
	
	[logger log:@"---> Start downloading: %@\n", [NSDate date]];
	
	//	[self performSelectorOnMainThread: @selector(downloadContentFile)
	//						   withObject: nil
	//						waitUntilDone: NO];

	[self startDownloading];
}

- (void) onButtonCloseLog:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
	
	[self finishDownloadingContent];
}



#pragma mark -
#pragma mark Core logic
//
- (BOOL) validateTextField:(UITextField *) anField
{
	if( anField && 0 != [anField.text length] && ![anField.text isEqualToString:@""] )
	{
		return YES;
	}
	
	return NO;
}

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



#pragma mark >>> UI business:
//
- (void) uiFillDefaultValues
{
#if DEBUG==1
	self.fieldAddress.text	= kAVCDefaultFTPAddress;//[NLContext shared].datasourceAddress; //kAVCDefaultFTPAddress;
	self.fieldPath.text		= kAVCDefaultFTPFolder;//[NLContext shared].datasourceFolder; //kAVCDefaultFTPFolder;
	self.fieldLogin.text	= kAVCDefaultTestLogin;//@"testuser3"; //[NLContext shared].userLogin;//kAVCDefaultTestLogin;
	self.fieldPass.text		= kAVCDefaultTestPass;//@"ftpUser1"; //[NLContext shared].userPassword;//kAVCDefaultTestPass;
#else
	self.fieldAddress.text	= [NLContext shared].datasourceAddress;
	self.fieldPath.text		= [NLContext shared].datasourceFolder;
	self.fieldLogin.text	= [NLContext shared].userLogin;
	self.fieldPass.text		= [NLContext shared].userPassword;
#endif
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
	
		[[NLAppDelegate shared] showLeads];
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
	if( !anDataSource )
	{
		[NLAlertView show:@"Error"
				  message:@"Content file not found or bad connection."
				  buttons:@[@"OK"]
					block:^(NLAlertView *alertView, NSInteger buttonIndex)
		 {
			 [self stopDownloading];
		 }];
		
		return;
	}
	
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
		
		NSString * strValue = nil;
		
		// Business card:
		//
		strValue = [dicRoot stringForName:@"businesscard"];
		if( strValue )
		{
			[NLContext shared].isBizCardAvail = ([[strValue lowercaseString] isEqualToString:@"true"] ? YES : NO);
		}
        
        // Business card:
        //
        strValue = [dicRoot stringForName:@"Show_Scan_Badge"];
        if( strValue )
        {
            [NLContext shared].isBarCodeAvail = ([[strValue lowercaseString] isEqualToString:@"true"] ? YES : NO);
        }
		
		// Sketch Pad:
		//
		strValue = [dicRoot stringForName:@"Sketch_Pad"];
		if( strValue )
		{
			[NLContext shared].isSketchPadAvail = ([[strValue lowercaseString] isEqualToString:@"true"] ? YES : NO);
		}
		
		// Signature Pad:
		//
		strValue = [dicRoot stringForName:@"Signature_Pad"];
		if( strValue )
		{
			[NLContext shared].isSignatureAvail = ([[strValue lowercaseString] isEqualToString:@"true"] ? YES : NO);
		}
		
		// Intermec:
		//
//		strValue = [dicRoot stringForName:@"Intermec"];
//		if( strValue )
//		{
//			[NLContext shared].isIntermecAvail = ([[strValue lowercaseString] isEqualToString:@"true"] ? YES : NO);
//		}
		
		// Socket:
		//
		strValue = [dicRoot stringForName:@"Socket_Scanner"];
		if( strValue )
		{
			[NLContext shared].isSocketAvail = ([[strValue lowercaseString] isEqualToString:@"true"] ? YES : NO);
		}
		
		// Barcodes:
		//
		NSString * strBar = nil;
		NLBarcodeDatasource * bds = [NLBarcodeDatasource new];
		
		strBar = [dicRoot stringForName:@"QRCode"];
		if( strBar )
		{
			[bds selectItem:([[strBar lowercaseString] isEqualToString:@"true"] ? YES : NO) atIndex:kBarcodeQR];
		}

		strBar = [dicRoot stringForName:@"DataMatrix"];
		if( strBar )
		{
			[bds selectItem:([[strBar lowercaseString] isEqualToString:@"true"] ? YES : NO) atIndex:kBarcodeDM];
		}
		
		strBar = [dicRoot stringForName:@"Code39"];
		if( strBar )
		{
			[bds selectItem:([[strBar lowercaseString] isEqualToString:@"true"] ? YES : NO) atIndex:kBarcode39];
		}
		
		strBar = [dicRoot stringForName:@"EANUPC"];
		if( strBar )
		{
			[bds selectItem:([[strBar lowercaseString] isEqualToString:@"true"] ? YES : NO) atIndex:kBarcodeEANUPC];
		}
		
		strBar = [dicRoot stringForName:@"Code128"];
		if( strBar )
		{
			[bds selectItem:([[strBar lowercaseString] isEqualToString:@"true"] ? YES : NO) atIndex:kBarcode128];
		}
		
		strBar = [dicRoot stringForName:@"PDF417"];
		if( strBar )
		{
			[bds selectItem:([[strBar lowercaseString] isEqualToString:@"true"] ? YES : NO) atIndex:kBarcodePDF];
		}
		
		strBar = [dicRoot stringForName:@"Aztec"];
		if( strBar )
		{
			[bds selectItem:([[strBar lowercaseString] isEqualToString:@"true"] ? YES : NO) atIndex:kBarcodeAZTEC];
		}
		
		strBar = [dicRoot stringForName:@"Codabar"];
		if( strBar )
		{
			[bds selectItem:([[strBar lowercaseString] isEqualToString:@"true"] ? YES : NO) atIndex:kBarcodeCODABAR];
		}
		
		[bds flushData];
	}
	
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




#pragma mark -
#pragma mark UIAlertViewDelegate
//
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if( 2 == buttonIndex ) // Re-Download
	{
		reDownloadOccur = YES;
		
		[contentToDownloadArr removeAllObjects];
		/*
		for(URLConnectionWrapper * conn in failedDownloadsArr)
		{
			NSString * testKey = [NSString stringWithFormat:@"%p", conn];
			id item = [conn.userInfo objectForKey:testKey];
			if( [item isKindOfClass:[TabItem class]] )
			{
				((TabItem *)item).isDownloadNeeded = YES;
				
				[contentToDownloadArr addObject: item];
			}
			else if( [item isKindOfClass:[ContentItem class]] )
			{
				((ContentItem *)item).isLocal = NO;
				
				[contentToDownloadArr addObject: ((ContentItem *)item).parent];
			}
		}
		*/
		itemsInWork = 0;
		itemsPassed = 0;
		itemsToDownload = [contentToDownloadArr count];
		
		reDownloadOccur = NO;
		
		[failedDownloadsArr removeAllObjects];
		[self finishDownloadingContent];
	}
	else if( 1 == buttonIndex ) // View Log
	{
		[self uiShowLog];
	}
	else if( 0 == buttonIndex ) // Continue
	{
		/*
		for(URLConnectionWrapper * conn in failedDownloadsArr)
		{
			NSString * testKey = [NSString stringWithFormat:@"%p", conn];
			id item = [conn.userInfo objectForKey:testKey];
			if( [item isKindOfClass:[TabItem class]] )
			{
				((TabItem *) item).tabIconFileName = nil;
			}
			else if([item isKindOfClass:[ContentItem class]] )
			{
				TabItem * parent = ((ContentItem *) item).parent;
				[parent removeItem: item];
			}
		}
		*/
		reDownloadOccur = NO;
		
		[failedDownloadsArr removeAllObjects];
		[self finishDownloadingContent];
	}
}



#pragma mark -
#pragma mark UITextFieldDelegate
//
- (BOOL) textFieldShouldBeginEditing:(UITextField *) textField
{
	self.fieldCurrent = textField;
	
	keyboardActionOccur = NO;
	
	return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
	if( keyboardActionOccur )
	{
		[self.fieldCurrent resignFirstResponder];
		self.fieldCurrent = nil;
	}
	else
	{
		if( textField == self.fieldCurrent )
		{
			self.fieldCurrent = nil;
		}
	}
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
	if( self.fieldCurrent == textField )
	{
		keyboardActionOccur = YES;
		
		[self.fieldCurrent resignFirstResponder];
		self.fieldCurrent = nil;
		
		return YES;
	}
	return NO;
}

#pragma mark >>> Helper - Keyboard
//
- (void) keyboardWillBeShown:(NSNotification*)aNotification
{
	if( 0 != self.keyboardH )
		return;
	
	NSDictionary * info	= [aNotification userInfo];
	
	CGRect keyboardRect = [(NSValue *)[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	self.keyboardH		= [self.view convertRect:keyboardRect fromView:nil].size.height;
	//
	UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, self.keyboardH, 0);
	
	[UIView animateWithDuration:[[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]
					 animations:^(void)
	 {
		 self.viewScroll.contentInset =insets;
	 }
					 completion:^(BOOL finished)
	 {
		 self.viewScroll.contentInset =insets;
	 }];
}

- (void) keyboardWillBeHidden:(NSNotification*)aNotification
{
	if( 0 == self.keyboardH )
		return;
	
	NSDictionary * info	= [aNotification userInfo];
	self.keyboardH		= 0;

	UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, self.keyboardH, 0);
	
	[UIView animateWithDuration:[[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]
					 animations:^(void)
	 {
		 self.viewScroll.contentInset =insets;
	 }
					 completion:^(BOOL finished)
	 {
		 self.viewScroll.contentInset =insets;
	 }];
}

@end
