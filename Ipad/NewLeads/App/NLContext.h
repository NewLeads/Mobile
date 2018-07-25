//
//  NLContext.h
//  NewLeads2
//
//  Created by idevs.com on 15/08/2011.
//  Copyright 2011 idevs.com. All rights reserved.
//


extern NSString * const kNLLogoutPassphrase;
extern NSString * const kNLNotifLogoutWasSuccessful;
extern NSString * const kNLNotifBarcodeSettingsWasChanged;


@interface NLContext : NSObject 
{
@private
	//
	// Logic:
	BOOL				isFirstLaunch;
	BOOL				isLoggedIn;	
	BOOL				isTimeToDie;
	
	//
	// Datasource:
	NSDictionary		* contentDict;
	//
	
	//
	// User info:
	NSString			* userLogin;
	NSString			* userPassword;
	NSString			* expirationDate;
	NSString			* storedDate;
	NSString			* clientURL;
	
	//
	// Resource:
	NSString			* datasourceAddress;
	NSString			* datasourceFolder;
	
	//
	// Leads info:
	NSInteger			leadID;
	NSString			* leadFirstName;
	NSString			* leadLastName;
}

@property (nonatomic, readwrite, assign)	BOOL		isFirstLaunch;
@property (nonatomic, readwrite, assign)	BOOL		isLoggedIn;
@property (nonatomic, readwrite, assign)	BOOL		isTimeToDie;
//@property (nonatomic, readwrite, assign)	BOOL		isBizCardActivated; // from ftp
@property (nonatomic, readwrite, assign)	BOOL		isBizCardAvail;
@property (nonatomic, readwrite, assign)	BOOL		isBarCodeAvail;
//@property (nonatomic, readwrite, assign)	BOOL		isIntermecAvail;
@property (nonatomic, readwrite, assign)	BOOL		isSocketAvail;
@property (nonatomic, readwrite, assign)	BOOL		isWritePadAvail;
@property (nonatomic, readwrite, assign)	BOOL		isSketchPadAvail;
@property (nonatomic, readwrite, assign)	BOOL		isSignatureAvail;
@property (nonatomic, readwrite, assign)	BOOL		isScanAndGo;
@property (nonatomic, readwrite, assign)	BOOL		isRawMode;
@property (nonatomic, readwrite, retain)	NSString	* userLogin;
@property (nonatomic, readwrite, retain)	NSString	* userPassword;
@property (nonatomic, readwrite, retain)	NSString	* expirationDate;
@property (nonatomic, readwrite, retain)	NSString	* storedDate;
@property (nonatomic, readwrite, retain)	NSString	* datasourceAddress;
@property (nonatomic, readwrite, retain)	NSString	* datasourceFolder;
//
@property (nonatomic, readwrite, retain)	NSString	* clientURL;
//
//@property (nonatomic, readwrite, copy)		NSString	* baseURL;
//@property (nonatomic, readwrite, copy)		NSString	* submitURL;
@property (nonatomic, readwrite, copy)		NSString	* stationID;

//
@property (nonatomic, readwrite, retain)	NSDictionary* contentDict;
//
@property (nonatomic, readwrite, assign)	NSInteger	leadID;
@property (nonatomic, readwrite, retain)	NSString	* leadFirstName;
@property (nonatomic, readwrite, retain)	NSString	* leadLastName;

@property (nonatomic, readwrite, retain)	NSString	* scanPage;

+ (NLContext *) shared;

- (void) loadAppSettings;
- (void) saveAppSettings;
- (void) reset;

- (void) saveContentDict:(NSDictionary *) anDataSource;
- (NSDictionary*) loadContentDict;

- (void) cleanLeadData;

- (UIImage *) stretchedImageNamed:(NSString *) anName width:(CGSize) anSize;

- (NSString *) appVersion;

@end
