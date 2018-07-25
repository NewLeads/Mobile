//
//  NLContext.m
//  NewLeads2
//
//  Created by idevs.com on 15/08/2011.
//  Copyright 2011 idevs.com. All rights reserved.
//

#import "NLContext.h"
//
#import "AppVersion.h"



#pragma mark -
#pragma mark Configuration
//
NSString * const kDefaultsAppDictKey		= @"AppDefaults";
NSString * const kDefaultsUserDictKey		= @"UserDefaults";
NSString * const kDefaultsFirstLaunchKey	= @"FirstLaunchV3";
NSString * const kDefaultsLoginKey			= @"UserLogin";
NSString * const kDefaultsPasswordKey		= @"UserPassword";
NSString * const kDefaultsFirstDateKey		= @"FirstLaunchDate";
NSString * const kDefaultsExpirationKey		= @"ExpirationDate";
NSString * const kDefaultsClientURLKey		= @"ClientURL";
NSString * const kDefaultsSourceFolderKey	= @"SourceFolder";
NSString * const kDefaultsSourceAddressKey	= @"SourceAddress";
NSString * const kDefaultsBizCardActivatedValueKey	= @"BizCardActivated"; // from ftp flag
NSString * const kDefaultsBizCardValueKey	= @"BizCardAvailable";
NSString * const kDefaultsBarCodeValueKey	= @"BarCodeAvailable";
NSString * const kDefaultsIntermecValueKey	= @"IntermecAvailable";
NSString * const kDefaultsSocketValueKey	= @"SocketAvailable";
NSString * const kDefaultsWritePadValueKey	= @"WritePadAvailiable";
NSString * const kDefaultsSketchPadValueKey	= @"SketchPadAvailiable";
NSString * const kDefaultsSignatureValueKey	= @"SignatureAvailiable";
NSString * const kDefaultsScanAndGoValueKey	= @"ScanAndGo";
NSString * const kDefaultsRawModeValueKey	= @"RawMode";
//
NSString * const kDefaultsLeadIDKey			= @"LeadID";
NSString * const kDefaultsLeadFirstNameKey	= @"LeadFirstName";
NSString * const kDefaultsLeadLastNameKey	= @"LeadLastName";
//
//NSString * const kDefaultsBaseURLKey			= @"textBaseURL";
//NSString * const kDefaultsSubmitURLKey			= @"textSubmitURL";
NSString * const kDefaultsStationIDKey			= @"textStationID";
//
NSString * const kDefaultsDataFormat		= @"MM/dd/yyyy h:mm:ss a";
//
NSString * const kNLLogoutPassphrase				= @"NewLeads270";
NSString * const kNLNotifLogoutWasSuccessful		= @"VGNotifLogoutWasSuccessful";
NSString * const kNLNotifBarcodeSettingsWasChanged	= @"NotifBarcodeSettingsWasChanged";




@interface NLContext ()

@property (nonatomic, retain) NSUserDefaults * userDefaults;

- (void) validateDate;
- (void) removeContentFile;

@end



@implementation NLContext

@synthesize datasourceFolder, datasourceAddress;
@synthesize isFirstLaunch, isLoggedIn, isTimeToDie;
@synthesize userLogin, userPassword, expirationDate, storedDate, clientURL;
@synthesize contentDict;
@synthesize leadID, leadFirstName, leadLastName;

#pragma mark Create singleton instance:
//

+ (instancetype) shared
{
	static dispatch_once_t pred;
	static NLContext * sharedInstance = nil;
	
	dispatch_once(&pred, ^(void)
	{
		sharedInstance = [[self alloc] init];
	});
	
	return sharedInstance;
}

- (id) init
{
	if( nil != (self = [super init]) )
	{
		NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
		
		if( ![userDefaults objectForKey:kDefaultsFirstLaunchKey] )
		{			
			[userDefaults setObject:[NSNumber numberWithBool:YES] forKey:kDefaultsFirstLaunchKey];
			[userDefaults setObject:@"" forKey:kDefaultsLoginKey];
			[userDefaults setObject:@"" forKey:kDefaultsPasswordKey];
			//[userDefaults setObject:savedDateString  forKey:kDefaultsFirstDateKey];
			[userDefaults setObject:@""  forKey:kDefaultsExpirationKey];
			[userDefaults setObject:@""  forKey:kDefaultsClientURLKey];
			[userDefaults setObject:@"" forKey:kDefaultsSourceFolderKey];
			[userDefaults setObject:@"" forKey:kDefaultsSourceAddressKey];
			[userDefaults setObject:[NSNumber numberWithBool:NO] forKey:kDefaultsBizCardActivatedValueKey];
            [userDefaults setObject:[NSNumber numberWithBool:NO] forKey:kDefaultsBizCardValueKey];
            [userDefaults setObject:[NSNumber numberWithBool:NO] forKey:kDefaultsBarCodeValueKey];
            [userDefaults setObject:[NSNumber numberWithBool:NO] forKey:kDefaultsIntermecValueKey];
			[userDefaults setObject:[NSNumber numberWithBool:NO] forKey:kDefaultsSocketValueKey];
			[userDefaults setObject:[NSNumber numberWithBool:NO] forKey:kDefaultsWritePadValueKey];
            [userDefaults setObject:[NSNumber numberWithBool:NO] forKey:kDefaultsSketchPadValueKey];
            [userDefaults setObject:[NSNumber numberWithBool:NO] forKey:kDefaultsSignatureValueKey];
            [userDefaults setObject:[NSNumber numberWithBool:NO] forKey:kDefaultsScanAndGoValueKey];
            [userDefaults setObject:[NSNumber numberWithBool:NO] forKey:kDefaultsRawModeValueKey];
			//
			[userDefaults setObject:[NSNumber numberWithInt:-1] forKey:kDefaultsLeadIDKey];
			[userDefaults setObject:@"" forKey:kDefaultsLeadFirstNameKey];
			[userDefaults setObject:@"" forKey:kDefaultsLeadLastNameKey];
			//
//			[userDefaults setObject:@"" forKey:kDefaultsBaseURLKey];
//			[userDefaults setObject:@"" forKey:kDefaultsSubmitURLKey];
			[userDefaults setObject:@"" forKey:kDefaultsStationIDKey];
			//
			[userDefaults synchronize];
		}
		[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
		
		NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
		NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
		[formatter setLocale:usLocale];
		[usLocale release];
		
		[formatter setDateFormat: kDefaultsDataFormat];
		self.storedDate = [formatter stringFromDate:[NSDate date]];
		[formatter release];

		
		[self cleanLeadData];
		
		[self loadAppSettings];
		
		[self validateDate];
		
		if( !isTimeToDie )
		{
			[self loadContentDict];
		}
	}
	return self;
}

- (void) dealloc
{
	self.contentDict	= nil;
	self.userLogin		= nil;
	self.userPassword	= nil;
	self.expirationDate	= nil;
	self.clientURL		= nil;
	self.datasourceFolder	= nil;
	self.datasourceAddress	= nil;
	//
	self.leadID			= -1;
	self.leadFirstName	= nil;
	self.leadLastName	= nil;
	
	[super dealloc];
}



#pragma mark -
#pragma mark Core logic
//
- (void) reset
{	
	self.isFirstLaunch	= YES;
	self.isTimeToDie	= NO;
	self.isLoggedIn		= NO;
	
	//self.isBizCardActivated	= NO;
    self.isBizCardAvail = NO;
    self.isBarCodeAvail = NO;
    //self.isIntermecAvail = YES;
	self.isWritePadAvail= NO;
    self.isSketchPadAvail = NO;
    self.isSignatureAvail = NO;
    self.isScanAndGo    = NO;
    self.isSocketAvail  = NO;
    self.isRawMode     = NO;
	self.userLogin		= @"";
	self.userPassword	= @"";
	self.datasourceFolder	= @"";
	self.datasourceAddress	= @"";
	self.expirationDate	= @"";
	self.clientURL		= @"";
	self.contentDict	= nil;
    self.scanPage    = nil;
	//
	self.leadID			= -1;
	self.leadFirstName	= nil;
	self.leadLastName	= nil;
	
	
//	[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
//	
//	NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
//	NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
//	[formatter setLocale:usLocale];
//	[formatter setDateFormat: kDefaultsDataFormat];
//	NSString * savedDate = [formatter stringFromDate:[NSDate date]];
	
//	[userDefaults setObject:savedDate  forKey:kDefaultsFirstDateKey];
	
	[self removeContentFile];
	[self saveAppSettings];
	[self loadAppSettings];
}

- (void) validateDate
{
	[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
	
	NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
	NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[formatter setLocale:usLocale];
	[usLocale release];
	
	[formatter setDateFormat: kDefaultsDataFormat];
	
	NSDate * savedDate	= [formatter dateFromString: self.storedDate];
	NSDate * expDate	= [formatter dateFromString: self.expirationDate];
	[formatter release];
	
	if( savedDate && expDate )
	{
		NSTimeInterval diff = [expDate timeIntervalSinceDate: savedDate];
		if( 0 > diff )
		{
			isTimeToDie = YES;
		}
	}
}



#pragma mark -
#pragma mark Content file management
//
- (void) saveContentDict:(NSDictionary *) anDataSource
{
	if( anDataSource && (0 != [anDataSource count]) )
	{
		NSError * error = nil;
		NSData * plistData = [NSPropertyListSerialization dataWithPropertyList:anDataSource
																		format:NSPropertyListXMLFormat_v1_0
																	   options:0
																		 error:&error];
		if(plistData) 
		{
			NSArray		* paths		= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString	* documents	= [NSString stringWithString:[paths objectAtIndex:0]];
			NSString	* filePath	= [NSString stringWithFormat:@"%@/%@", documents, @"content.plist"];
		
			[plistData writeToFile:filePath atomically:YES];
		}
		else 
		{
			NSLog(@"%@", [error localizedDescription]);
		}		
	}
}

- (NSDictionary*) loadContentDict
{
	NSArray		* paths		= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString	* documents	= [NSString stringWithString:[paths objectAtIndex:0]];
	NSString	* filePath	= [NSString stringWithFormat:@"%@/%@", documents, @"content.plist"];
	
	if( filePath && [[NSFileManager defaultManager] fileExistsAtPath: filePath] )
	{
		NSError *error = nil;
        NSPropertyListFormat format;
		
		NSData * plistXML = [[NSFileManager defaultManager] contentsAtPath:filePath];
        NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization propertyListWithData:plistXML
																					   options:NSPropertyListImmutable
																						format:&format
																						 error:&error];
        if( !temp ) 
		{
            NSLog(@"Error reading plist: %@, format: %lu", [error localizedDescription], (unsigned long)format);
        }
		else
		{
			self.contentDict = temp;
		}
	}
    
    return self.contentDict;
}

- (void) removeContentFile
{
	NSArray		* paths		= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString	* documents	= [NSString stringWithString:[paths objectAtIndex:0]];
	NSString	* filePath	= [NSString stringWithFormat:@"%@/%@", documents, @"content.plist"];
	
	if( filePath && [[NSFileManager defaultManager] fileExistsAtPath: filePath] )
	{
		[[NSFileManager defaultManager] removeItemAtPath: filePath error: nil];
	}
}



#pragma mark -
#pragma mark App settings
//
-(void) loadAppSettings
{
	NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
	
    self.isFirstLaunch		= [(NSNumber*)[userDefaults objectForKey:kDefaultsFirstLaunchKey] boolValue];	
	self.userLogin			= [userDefaults stringForKey:kDefaultsLoginKey];	
	self.userPassword		= [userDefaults stringForKey:kDefaultsPasswordKey];	
	//self.storedDate			= [userDefaults stringForKey:kDefaultsFirstDateKey];
	self.expirationDate		= [userDefaults stringForKey:kDefaultsExpirationKey];	
	self.clientURL			= [userDefaults stringForKey:kDefaultsClientURLKey];
	self.datasourceFolder	= [userDefaults stringForKey:kDefaultsSourceFolderKey];
	self.datasourceAddress	= [userDefaults stringForKey:kDefaultsSourceAddressKey];
	//self.isBizCardActivated		= [(NSNumber*)[userDefaults objectForKey:kDefaultsBizCardActivatedValueKey] boolValue];
	self.isBizCardAvail		= [(NSNumber*)[userDefaults objectForKey:kDefaultsBizCardValueKey] boolValue];
    self.isBarCodeAvail		= [(NSNumber*)[userDefaults objectForKey:kDefaultsBarCodeValueKey] boolValue];
    //self.isIntermecAvail		= [(NSNumber*)[userDefaults objectForKey:kDefaultsIntermecValueKey] boolValue];
	self.isSocketAvail		= [(NSNumber*)[userDefaults objectForKey:kDefaultsSocketValueKey] boolValue];
	self.isWritePadAvail	= [(NSNumber*)[userDefaults objectForKey:kDefaultsWritePadValueKey] boolValue];
    self.isSketchPadAvail   = [(NSNumber*)[userDefaults objectForKey:kDefaultsSketchPadValueKey] boolValue];
	self.isSignatureAvail	= [(NSNumber*)[userDefaults objectForKey:kDefaultsSignatureValueKey] boolValue];
    self.isScanAndGo        = [(NSNumber*)[userDefaults objectForKey:kDefaultsScanAndGoValueKey] boolValue];
    self.isRawMode          = [(NSNumber*)[userDefaults objectForKey:kDefaultsRawModeValueKey] boolValue];
	//
//	self.leadID				= [(NSNumber*)[userDefaults stringForKey:kDefaultsLeadIDKey] intValue];
//	self.leadFirstName		= [userDefaults stringForKey:kDefaultsLeadFirstNameKey];
//	self.leadLastName		= [userDefaults stringForKey:kDefaultsLeadLastNameKey];
//	self.baseURL			= [userDefaults stringForKey:kDefaultsBaseURLKey];
//	self.submitURL			= [userDefaults stringForKey:kDefaultsSubmitURLKey];
	self.stationID			= [userDefaults stringForKey:kDefaultsStationIDKey];
}

- (void) saveAppSettings
{
	NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
	
    [userDefaults setObject:[NSNumber numberWithBool: isFirstLaunch] forKey:kDefaultsFirstLaunchKey];
	//[userDefaults setObject:[NSNumber numberWithBool: self.isBizCardActivated] forKey:kDefaultsBizCardActivatedValueKey];
    [userDefaults setObject:[NSNumber numberWithBool: self.isBizCardAvail] forKey:kDefaultsBizCardValueKey];
    [userDefaults setObject:[NSNumber numberWithBool: self.isBarCodeAvail] forKey:kDefaultsBarCodeValueKey];
    //[userDefaults setObject:[NSNumber numberWithBool: self.isIntermecAvail] forKey:kDefaultsIntermecValueKey];
	[userDefaults setObject:[NSNumber numberWithBool: self.isSocketAvail] forKey:kDefaultsSocketValueKey];
	[userDefaults setObject:[NSNumber numberWithBool: self.isWritePadAvail] forKey:kDefaultsWritePadValueKey];
    [userDefaults setObject:[NSNumber numberWithBool: self.isSketchPadAvail] forKey:kDefaultsSketchPadValueKey];
    [userDefaults setObject:[NSNumber numberWithBool: self.isSignatureAvail] forKey:kDefaultsSignatureValueKey];
    [userDefaults setObject:[NSNumber numberWithBool: self.isScanAndGo] forKey:kDefaultsScanAndGoValueKey];
    [userDefaults setObject:[NSNumber numberWithBool: self.isRawMode] forKey:kDefaultsRawModeValueKey];
	
    if(self.userLogin)
	{
		[userDefaults setObject:self.userLogin forKey:kDefaultsLoginKey];
	}
	if(self.userPassword)
	{
		[userDefaults setObject:self.userPassword forKey:kDefaultsPasswordKey];
	}
	if( datasourceFolder )
	{
		[userDefaults setObject:self.datasourceFolder forKey:kDefaultsSourceFolderKey];
	}
	if( datasourceAddress )
	{
		[userDefaults setObject:self.datasourceAddress forKey:kDefaultsSourceAddressKey];
	}
	if( expirationDate )
	{
		[userDefaults setObject:expirationDate forKey:kDefaultsExpirationKey];
	}
	if( clientURL )
	{
		[userDefaults setObject:clientURL forKey:kDefaultsClientURLKey];
	}
	//
	// Lead info:
//	[userDefaults setObject:[NSNumber numberWithInt:self.leadID] forKey:kDefaultsLeadIDKey];
//	if( self.leadFirstName )
//	{
//		[userDefaults setObject:self.leadFirstName forKey:kDefaultsLeadFirstNameKey];
//	}
//	if( self.leadLastName )
//	{
//		[userDefaults setObject:self.leadLastName forKey:kDefaultsLeadLastNameKey];
//	}
//	[userDefaults setObject:self.baseURL forKey:kDefaultsBaseURLKey];
//	[userDefaults setObject:self.submitURL forKey:kDefaultsSubmitURLKey];
	[userDefaults setObject:self.stationID forKey:kDefaultsStationIDKey];
	
	[userDefaults synchronize];
}

- (void) setIsFirstLaunch:(BOOL) anFlag
{
	isFirstLaunch = anFlag;
}

- (void) setUserLogin:(NSString *) anLogin
{
	if( userLogin )
	{
		[userLogin release];
		userLogin = nil;
	}
	if( nil != anLogin )
	{
		userLogin = [anLogin retain];
	}
}

- (void) setUserPassword:(NSString *) anPassword
{
	if( userPassword )
	{
		[userPassword release];
		userPassword = nil;
	}
	if( anPassword )
	{
		userPassword = [anPassword retain];
	}
}

- (void) setExpirationDate:(NSString *) anDate
{
	if( expirationDate )
	{
		[expirationDate release];
		expirationDate = nil;
	}
	if( anDate )
	{
		expirationDate = [anDate retain];
	}
}

- (void) setDatasourceFolder:(NSString *) anSourceFolder
{
	if( datasourceFolder )
	{
		[datasourceFolder release];
		datasourceFolder = nil;
	}
	if( anSourceFolder )
	{
		datasourceFolder = [anSourceFolder retain];
	}
}

- (void) setDatasourceAddress:(NSString *) anSourceAddress
{
	if( datasourceAddress )
	{
		[datasourceAddress release];
		datasourceAddress = nil;
	}
	if( anSourceAddress )
	{
		datasourceAddress = [anSourceAddress retain];
	}
}


#pragma mark -
#pragma mark Work with lead data
//
- (void) cleanLeadData
{
	self.leadID			= -1;
	self.leadFirstName	= nil;
	self.leadLastName	= nil;
}




#pragma mark UI helpers:
//
- (UIImage *) stretchedImageNamed:(NSString *) anName width:(CGSize) anSize
{
	UIImage * imgResult = nil;
	UIImage * imgSource = [UIImage imageNamed:anName];
	
	if( imgSource )
	{
#if defined(__IPHONE_5_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_5_0
		if( [imgSource respondsToSelector:@selector(resizableImageWithCapInsets:)] )
		{
			imgResult = [imgSource resizableImageWithCapInsets:UIEdgeInsetsMake(0, anSize.width, 0, anSize.width)];
		}
		else // Support iOS version prior to the 5.0
#endif
		{
			imgResult = [imgSource stretchableImageWithLeftCapWidth:anSize.width topCapHeight:0];
		}
	}
	
	return imgResult;
}

- (NSString *) appVersion
{
	NSString* appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
	NSString* gitVersion = GIT_VERSION;
	NSString* buildVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];

	NSRange dashRange = [GIT_VERSION rangeOfString:@"-g" options:NSBackwardsSearch];
	if ([APP_VERSION length]>0 && dashRange.location!=NSNotFound && dashRange.location+2<[GIT_VERSION length])
		gitVersion = [gitVersion substringFromIndex:(dashRange.location+2)];
	if ([gitVersion length]>0)
		gitVersion = [NSString stringWithFormat:@"%@(%@)-%@", appVersion, buildVersion, gitVersion];
	else
		gitVersion = [NSString stringWithFormat:@"%@(%@)", appVersion, buildVersion];

	return gitVersion;
}

@end
