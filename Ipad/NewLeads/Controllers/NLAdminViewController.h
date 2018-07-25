//
//  NLAdminViewController.h
//  NewLeads
//
//  Created by idevs.com on 25/09/2013.
//  Copyright (c) 2013 idevs.com. All rights reserved.
//

#import "NLCommonViewController.h"
#import "ASIHTTPRequestDelegate.h"
#import "URLConnectionWrapper.h"
#import "HeaderView.h"


@class LogoItem;
@class AdminLogger;


@interface NLAdminViewController : NLCommonViewController
<
	UITextFieldDelegate,
	UIAlertViewDelegate,
	ASIHTTPRequestDelegate,
	URLConnectionWrapperProtocol
>
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
// UI - Shared:
//
@property (nonatomic, readwrite, retain) IBOutlet UIView			* viewForm;
@property (nonatomic, readwrite, retain) IBOutlet UIView			* viewDownloading;
//
@property (nonatomic, readwrite, assign) IBOutlet UIView			* viewAddress;
@property (nonatomic, readwrite, assign) IBOutlet UIView			* viewFolder;
@property (nonatomic, readwrite, assign) IBOutlet UIView			* viewLogin;
@property (nonatomic, readwrite, assign) IBOutlet UIView			* viewPass;
@property (nonatomic, readwrite, assign) IBOutlet UIView			* viewStation;
//
@property (nonatomic, readwrite, assign) IBOutlet UITextField		* fieldLogin;
@property (nonatomic, readwrite, assign) IBOutlet UITextField		* fieldPass;
@property (nonatomic, readwrite, assign) IBOutlet UITextField		* fieldPath;
@property (nonatomic, readwrite, assign) IBOutlet UITextField		* fieldAddress;
@property (nonatomic, readwrite, assign) IBOutlet UITextField		* fieldStationID;
@property (nonatomic, readwrite, assign) IBOutlet UIButton			* btnLogin;
@property (nonatomic, readwrite, assign) IBOutlet UILabel			* labelProgress;
@property (nonatomic, readwrite, assign) IBOutlet UILabel			* labelFileName;
@property (nonatomic, readwrite, assign) IBOutlet UILabel			* labelFileStatus;
@property (nonatomic, readwrite, assign) IBOutlet UIProgressView	* viewProgress;
@property (nonatomic, readwrite, assign) IBOutlet UIActivityIndicatorView	* viewActivity;
//
// Logic:
@property (nonatomic, readwrite, assign) UITextField	* fieldCurrent;
@property (nonatomic, readwrite, assign) NSInteger		keyboardH;

@end
