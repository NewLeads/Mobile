//
//  NLSocketScannerController.m
//  NewLeads
//
//  Created by idevs.com on 01/07/2015.
//  Copyright (c) 2015 idevs.com. All rights reserved.
//

#import "NLSocketScannerController.h"
//
// Datasources:
#import "NLBarcodeDatasource.h"
//
// Assets:
#import "SktScanAPI.h"
#import "ScanApiHelper.h"
#import "SktScanTypes.h"
//
#import "BarcodeScanner.h"




@interface NLSocketScannerController ()
<
	ScanApiHelperDelegate
>
//
// Datasource:
@property (nonatomic, strong) NSData * rawData;
//
// Logic:
@property (nonatomic, strong) NSTimer		* scanApiConsumer;
@property (nonatomic, strong) ScanApiHelper * scanApiHelper;
@property (nonatomic, strong) DeviceInfo	* scanDeviceInfo;
@property (nonatomic, assign) unsigned char dataConfirmationMode;

@end



@implementation NLSocketScannerController

+ (NLSocketScannerController *) device
{
	static NLSocketScannerController * _sharedObject = nil;
	static dispatch_once_t once = 0;
	
	dispatch_once(&once, ^(void)
	{
		_sharedObject = [[self alloc] init];
	});
	return _sharedObject;
}

- (id) init
{
	if( nil != (self = [super init]) )
	{
		self.scanApiHelper = [ScanApiHelper new];
		[self.scanApiHelper setDelegate:self];
		
		self.dataConfirmationMode = kSktScanDataConfirmationModeDevice;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifications:) name:UIApplicationWillTerminateNotification object:nil];
	}
	return self;
}



#pragma mark - Notifications
//
- (void) notifications:(NSNotification *) aNotif
{
	NSString * name = aNotif.name;
	
	if( [name isEqualToString:kNLNotifBarcodeSettingsWasChanged] || [name isEqualToString:UIApplicationWillEnterForegroundNotification] )
	{
		[self applySettings];
	}
	else if( [name isEqualToString:UIApplicationWillTerminateNotification] )
	{
		[self shutdown];
	}
}



#pragma mark - Core logic
//
- (BOOL) isDeviceReady
{
	return [self.scanApiHelper isScanApiOpen];
}

- (void) connect
{
	if( ![self isDeviceReady] )
	{
		[self.scanApiHelper open];
	}
	// start the ScanAPI Consumer timer to check if ScanAPI has a ScanObject for us to consume
	// all the asynchronous events coming from ScanAPI or property get/set complete operation
	// will be received in this consumer timer
	if( self.scanApiConsumer )
	{
		[self.scanApiConsumer invalidate];
		self.scanApiConsumer = nil;
	}
	self.scanApiConsumer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifications:) name:kNLNotifBarcodeSettingsWasChanged object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifications:) name:UIApplicationWillEnterForegroundNotification object:nil];
	
	NSLog(@"Try to connect to socket scanner");
}

- (void) disconnect
{
	if( [self isDeviceReady] )
	{
		if( self.scanApiConsumer )
		{
			[self.scanApiConsumer invalidate];
			self.scanApiConsumer = nil;
		}
		
		[[NSNotificationCenter defaultCenter] removeObserver:self name:kNLNotifBarcodeSettingsWasChanged object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
	}
	
	NSLog(@"Try to disconnect socket scanner");
}

- (void) shutdown
{
	if( [self isDeviceReady] )
	{
		[self.scanApiHelper close];
	}
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSData *) data
{
	if( self.rawData )
	{
		return self.rawData.copy;
	}
	
	return nil;
}

- (NSString *) stringData
{
	if( self.rawData )
	{
		return [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
	}
	
	return nil;
}

- (void) log:(NSString *) anMessage
{
	NSLog(@"Log: %@", anMessage);
}

- (void) applySettings
{
	if( !self.scanDeviceInfo )
	{
		return;
	}
	
	NLBarcodeDatasource * datasource = [NLBarcodeDatasource new];
	//
	//
	for( int value = kSktScanSymbologyAustraliaPost; value < kSktScanSymbologyLastSymbologyID; value++)
	{
		BOOL enabled = NO;
		
		switch(value)
		{
			case kSktScanSymbologyAustraliaPost: break;
			// Check below:
			case kSktScanSymbologyAztec:
			{
				enabled = [datasource hasCodeEnabled:MWB_CODE_MASK_AZTEC];
				break;
			}
			case kSktScanSymbologyBooklandEan: break;
			case kSktScanSymbologyBritishPost: break;
			case kSktScanSymbologyCanadaPost: break;
			case kSktScanSymbologyChinese2of5: break;
			// Check below:
			case kSktScanSymbologyCodabar:
			{
				enabled = [datasource hasCodeEnabled:MWB_CODE_MASK_CODABAR];
				break;
			}
			case kSktScanSymbologyCodablockA: break;
			case kSktScanSymbologyCodablockF: break;
			case kSktScanSymbologyCode11: break;
			// Check below:
			case kSktScanSymbologyCode39:
			case kSktScanSymbologyCode39Extended:
			case kSktScanSymbologyCode39Trioptic:
			{
				enabled = [datasource hasCodeEnabled:MWB_CODE_MASK_DM];
				break;
			}
			case kSktScanSymbologyCode93: break;
			// Check below:
			case kSktScanSymbologyCode128:
			{
				enabled = [datasource hasCodeEnabled:MWB_CODE_MASK_128];
				break;
			}
			case kSktScanSymbologyDataMatrix:
			{
				enabled = [datasource hasCodeEnabled:MWB_CODE_MASK_DM];
				break;
			}
			case kSktScanSymbologyDutchPost: break;
			// Check below:
			case kSktScanSymbologyEan8:
			case kSktScanSymbologyEan13:
			case kSktScanSymbologyEan128:
			case kSktScanSymbologyEan128Irregular:
			case kSktScanSymbologyEanUccCompositeAB:
			case kSktScanSymbologyEanUccCompositeC:
			{
				enabled = [datasource hasCodeEnabled:MWB_CODE_MASK_EANUPC];
				break;
			}
			case kSktScanSymbologyGs1Databar: break;
			case kSktScanSymbologyGs1DatabarLimited: break;
			case kSktScanSymbologyGs1DatabarExpanded: break;
			case kSktScanSymbologyInterleaved2of5: break;
			case kSktScanSymbologyIsbt128: break;
			case kSktScanSymbologyJapanPost: break;
			case kSktScanSymbologyMatrix2of5: break;
			case kSktScanSymbologyMaxicode: break;
			case kSktScanSymbologyMsi: break;
			// Check below:
			case kSktScanSymbologyPdf417:
			case kSktScanSymbologyPdf417Micro:
			{
				enabled = [datasource hasCodeEnabled:MWB_CODE_MASK_PDF];
				break;
			}
			case kSktScanSymbologyPlanet: break;
			case kSktScanSymbologyPlessey: break;
			case kSktScanSymbologyPostnet: break;
			// Check below:
			case kSktScanSymbologyQRCode:
			{
				enabled = [datasource hasCodeEnabled:MWB_CODE_MASK_QR];
				break;
			}
			case kSktScanSymbologyStandard2of5: break;
			case kSktScanSymbologyTelepen: break;
			case kSktScanSymbologyTlc39: break;
			// Check below:
			case kSktScanSymbologyUpcA:
			case kSktScanSymbologyUpcE0:
			case kSktScanSymbologyUpcE1:
			{
				enabled = [datasource hasCodeEnabled:MWB_CODE_MASK_EANUPC];
				break;
			}
			case kSktScanSymbologyUspsIntelligentMail: break;
			case kSktScanSymbologyDirectPartMarking: break;
			case kSktScanSymbologyHanXin: break;
			// Skip below:
			case kSktScanSymbologyNotSpecified:
			case kSktScanSymbologyLastSymbologyID:
			default:
				continue;
		}
		
		NSLog(@"value: %d, enabled: %d", value, enabled);
		[self.scanApiHelper postSetSymbologyInfo:self.scanDeviceInfo SymbologyId:value Status:enabled Target:self Response:@selector(onSetProperty:)];
	}
}

// OnSetProperty
// update the progress bar and in case of error
// save the property ID and the error in the device info object
// so the configuration screen can use this information to display
// an error to the user and to put back the previous setting
-(SKTRESULT)onSetProperty:(id<ISktScanObject>)scanObject
{
	SKTRESULT result=ESKT_NOERROR;
	if(self.scanDeviceInfo!=nil)
	{
		result=[[scanObject Msg]Result];
		
		if(!SKTSUCCESS(result))
		{
			[self.scanDeviceInfo setPropertyError:[[scanObject Property]getID] Error:result];
		}
	}
//	[self log:[NSString stringWithFormat:@"Setting property: %d status: %d error :%ld",[[[scanObject Property] Symbology] getID], [[[scanObject Property] Symbology] getStatus], result]];
	
	return result;
}



#pragma mark - ScanApiHelperDelegate timer
//
- (void) onTimer
{
	[self.scanApiHelper doScanApiReceive];
}



#pragma mark - ScanApiHelperDelegate
//
/**
 * called when ScanAPI initialization has been completed
 * @param result contains the initialization result
 */
-(void) onScanApiInitializeComplete:(SKTRESULT) result
{
	self.rawData = nil;
	
	if( SKTSUCCESS(result) )
	{
		[self log:[NSString stringWithFormat:@"ScanAPI initialize complete returns :%ld",result]];
		
		// set the confirmation mode to be local on the device (more responsive)
		[self.scanApiHelper postSetConfirmationMode:self.dataConfirmationMode Target:self Response:nil];
	}
	else
	{
		[self log:[NSString stringWithFormat:@"Unable to initialize ScanAPI: %ld",result]];
	}
}

/**
 * called when ScanAPI has been terminated. This will be
 * the last message received from ScanAPI
 */
-(void) onScanApiTerminated
{
	if( self.scanApiConsumer )
	{
		[self.scanApiConsumer invalidate];
		self.scanApiConsumer = nil;
	}
	
	self.scanDeviceInfo = nil;
	self.rawData = nil;
}

/**
 * called each time a device connects to the host
 * @param result contains the result of the connection
 * @param newDevice contains the device information
 */
-(void)onDeviceArrival:(SKTRESULT)result device:(DeviceInfo*)deviceInfo
{
	if( SKTSUCCESS(result) )
	{
		[self log:[NSString stringWithFormat:@"Arrived device: %@", [deviceInfo getName]]];
		
		self.scanDeviceInfo = deviceInfo;
		[self applySettings];
		
#if DEBUG == 1
//		[self log:[NSString stringWithFormat:@"Device has properties:\n"]];
//		
//		for( NSUInteger value = kSktScanSymbologyAustraliaPost; value < kSktScanSymbologyLastSymbologyID; value++)
//		{
//			SymbologyInfo * si = [self.scanDeviceInfo getSymbologyInfo:(enum ESktScanSymbologyID) value];
//			
//			[self log:[NSString stringWithFormat:@"property: %@ status: %d", [si getName], [si isEnabled]]];
//		}
#endif
	}
	else
	{
		[self log:[NSString stringWithFormat:@"Unable to open the scanner. Result: %ld", result]];
	}
}

/**
 * called each time a device disconnect from the host
 * @param deviceRemoved contains the device information
 */
-(void) onDeviceRemoval:(DeviceInfo*) deviceRemoved
{
	if( [[deviceRemoved getName] isEqualToString:[self.scanDeviceInfo getName]] )
	{
//		[self log:[NSString stringWithFormat:@"Removing device: %@", [deviceRemoved getName]]];
		
		self.scanDeviceInfo = nil;
	}
	else
	{
		[self log:[NSString stringWithFormat:@"Try to remove unknown device: %@.\nCurrent device is: %@", [deviceRemoved getName], [self.scanDeviceInfo getName]]];
	}
}

/**
 * called each time ScanAPI is reporting an error
 * @param result contains the error code
 */
-(void) onError:(SKTRESULT) result
{
	self.rawData = nil;
	
	NSString* errstr=nil;
	if(result==ESKT_UNABLEINITIALIZE)
		errstr=[NSString stringWithFormat:@"ScanAPI is reporting an error %ld. Please turn off and on the scanner.", result];
	else if(result==ESKT_OUTDATEDVERSION)
		errstr=[NSString stringWithFormat:@"This scanner requires a more recent version of ScannerSettings. Please update ScannerSettings or some of the Scanner features won't work correctly."];
	else
		errstr=[NSString stringWithFormat:@"ScanAPI is reporting an error %ld", result];

	[self log:errstr];
}

/**
 * called when an error occurs during the retrieval
 * of a ScanObject from ScanAPI.
 * @param result contains the retrieval error code
 */
-(void) onErrorRetrievingScanObject:(SKTRESULT) result
{
	// ???
}

/**
 * called each time ScanAPI receives decoded data from scanner
 * @param result is ESKT_NOERROR when decodedData contains actual
 * decoded data. The result can be set to ESKT_CANCEL when the
 * end-user cancels a SoftScan operation
 * @param deviceInfo contains the device information from which
 * the data has been decoded
 * @param decodedData contains the decoded data information
 */
-(void) onDecodedDataResult:(long) result device:(DeviceInfo*) device decodedData:(id<ISktScanDecodedData>) decodedData
{
	self.rawData = nil;
	
	if( SKTSUCCESS(result) )
	{
		if( device == self.scanDeviceInfo)
		{
			[device setDecodeData:decodedData];
		
			DecodedDataInfo * di = [device getDecodedData];
			self.rawData = [NSData dataWithBytes:[di getData] length:[di getLength]];
			
			// TODO: Possible implement logic below in some time...in the future:
			//
			// if the confirmation mode is set to App then this
			// App must confirm it has received the data and the
			// scanner then will unlock the trigger for the next scan
			if( kSktScanDataConfirmationModeApp == self.dataConfirmationMode )
			{
				[self.scanApiHelper postSetDataConfirmation:device Target:self Response:nil];
			}
			
			if( self.stateBlock )
			{
				dispatch_async(dispatch_get_main_queue(), ^(void)
				{
					self.stateBlock(self, 1);
				});
			}
		}
	}
	else
	{
		if( self.stateBlock )
		{
			dispatch_async(dispatch_get_main_queue(), ^(void)
			{
				self.stateBlock(self, 0);
			});
		}
	}
}

@end
