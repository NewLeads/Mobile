//
//  NLDeviceController.m
//  NewLeads
//
//  Created by idevs.com on 20/06/2013.
//  Copyright (c) 2013 idevs.com. All rights reserved.
//
#import "NLDeviceController.h"
//
// Assets:
#import "DTDevices.h"
#import "NSDataCrypto.h"
#import "dukpt.h"


#pragma mark - Configuration
//
NSString * const kDefaultsScanModeValueKey	= @"ScanMode";
NSString * const kDeviceErrorDomain		= @"com.newleads.error";
typedef enum
{
	kTypeUndefined				= 0,
	kTypeMagneticStripeReader	= 1 << 0,
	kTypeBarcodeReader			= 1 << 1,
	kTypeRFCardsReader			= 1 << 2,
	kTypeSmarcardReader			= 1 << 3

} kDeviceType;



@interface NLDeviceController ()
<
	DTDeviceDelegate
>

@property (nonatomic, readwrite, assign) kDeviceState	state;
@property (nonatomic, readwrite, assign) int			type;
//
@property (nonatomic, readwrite, assign) BOOL			scanActive;
@property (nonatomic, readwrite, retain) NSMutableString * status;
@property (nonatomic, readwrite, assign) MS_MODES		cardModeValue;
//
@property (nonatomic, readwrite, retain) NSError		* error;
//
@property (nonatomic, readwrite, retain) NSData			* data;
//
@property (nonatomic, readwrite, assign) DTDevices		* dtDevice;


- (void) startDevice;
- (void) stopDevice;

- (void) connectionState:(int)state;
//
// Helpers:
- (NSString *) toHexString:(void *)data length:(int)length space:(bool)space;
- (NSString *) hexToString:(NSString *) label data:(void *)data length:(int) length;
- (uint16_t) crc16:(uint8_t *)data length:(int)length crc16:(uint16_t)crc16;

@end



@implementation NLDeviceController

@synthesize cardMode;

+ (NLDeviceController *) device
{
	static NLDeviceController * _sharedObject = nil;
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
		self.state			= kDeviceStateUnknown;
		self.type			= 0;
		self.cardModeValue	= MS_RAW_CARD_DATA; // By default
		self.status			= [NSMutableString string];
		
		self.dtDevice		= [DTDevices sharedDevice];

		[self.dtDevice addDelegate:self];
		
		NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
		if( ![defaults valueForKey:kDefaultsScanModeValueKey] )
		{
			[defaults setInteger:self.cardModeValue forKey:kDefaultsScanModeValueKey];
			[defaults synchronize];
		}
		else
		{
			self.cardModeValue = (MS_MODES)[defaults integerForKey:kDefaultsScanModeValueKey];
		}
	}
	return self;
}


#pragma mark - Core logic
//
- (BOOL) isDeviceReady
{
	return ( kDeviceStateConnected == self.state );
}

- (void) connect
{
	self.type = 0;
	
	[self.dtDevice connect];

	NSLog(@"Try to connect to device");
}

- (void) disconnect
{
	[self stopDevice];
	
	[self.dtDevice disconnect];
	
	self.type = 0;
	
	NSLog(@"Try to disconnect from device");
}

- (void) startDevice
{
	NSError * localError = nil;
	//[self.dtDevice msSetCardDataMode:MS_RAW_CARD_DATA error:&localError];

	[self.dtDevice msSetCardDataMode:self.cardModeValue error:&localError];
	
	NSLog(@"startDevice: kTypeMagneticStripeReader. Error = %@", localError);
	
	if( self.type & kTypeMagneticStripeReader )
	{
//		NSError * localError = nil;
//		[self.dtDevice msSetCardDataMode:MS_RAW_CARD_DATA error:&localError];
//		NSLog(@"startDevice: kTypeMagneticStripeReader. Error = %@", localError);
	}
	else if( self.type & kTypeBarcodeReader )
	{
		// Do nothing yet...
	}
	else if( self.type & kTypeRFCardsReader )
	{
//		NSError * localError = nil;
		if( ![self.dtDevice rfInit:CARD_SUPPORT_TYPE_A|CARD_SUPPORT_ISO15 error:&localError] )
		{
			self.error = localError;
			[self.status setString:[localError localizedDescription]];
		}
		else
		{
			[self.status setString:@"RF Card reader intited"];
		}
	}
	else if( self.type & kTypeSmarcardReader )
	{
		// Do nothing yet...
	}
}

- (void) stopDevice
{
	if( self.type & kTypeMagneticStripeReader )
	{
		// Do nothing yet...
	}
	else if( self.type & kTypeBarcodeReader )
	{
		// Do nothing yet...
	}
	else if( self.type & kTypeRFCardsReader )
	{
		NSError * localError;
		if( ![self.dtDevice rfClose:&localError] )
		{
			[self.status setString:[localError localizedDescription]];
		}
		else
		{
			[self.status setString:@"RF Card reader closed"];
		}			
	}
	else if( self.type & kTypeSmarcardReader )
	{
		// Do nothing yet...
	}
}

- (void) scanBarcodePressed
{
	int scanMode		= 0;
	BOOL result			= NO;
	NSError * localError= nil;
	
	if( (result = [self.dtDevice barcodeGetScanMode:&scanMode error:&localError]) && scanMode==MODE_MOTION_DETECT)
    {
        if(self.scanActive)
        {
            self.scanActive = NO;
            result = [self.dtDevice barcodeStopScan:&localError];
        }
		else
		{
            self.scanActive = YES;
            result = [self.dtDevice barcodeStartScan:&localError];
        }
    }
	else
	{
        result = [self.dtDevice barcodeStartScan:&localError];
	}
	
	self.error = localError;
	
	if( !result )
	{
		self.stateBlock(self, kDeviceStateDataFailed);
	}
	else
	{
		self.stateBlock(self, kDeviceStateDataGathering);
	}
}

- (void) scanBarcodeReleased
{
	int scanMode		= 0;
	BOOL result			= NO;
	NSError * localError= nil;
	
    if( (result = [self.dtDevice barcodeGetScanMode:&scanMode error:&localError]) && scanMode != MODE_MOTION_DETECT )
	{
        result = [self.dtDevice barcodeStopScan:&localError];
	}
	self.error = localError;
	
	if( !result )
	{
		self.stateBlock(self, kDeviceStateDataFailed);
	}
	else
	{
		self.stateBlock(self, kDeviceStateDataGathering);
	}
}

- (void) sendTestData
{
	int p = rand()%7;
	switch(p)
	{
		case 0:
		{
			// GUS SWEENEY
			self.data = [@"@@~323124~NEWLEADS SAMPLE BADGES 4-2012~GUS~SWEENEY~VICE PRESIDENT, TECHNOLOGY~LINAGORA~14 OAK PARK~~~MENLO PARK~CA~94025~USA~415.703.2376~~~SUPPORT@NEWLEADS.COM~" dataUsingEncoding:NSUTF8StringEncoding];
		}
			break;
		case 1:
		{
			// PATRICK VASAN
			self.data = [@"@@~322763~NEWLEADS SAMPLE BADGES 4-2012~PATRICK~VASAN~MR~FACTPOINT GROUP~333 POST STREET~44~~SAN FRANCISCO~CA~94107~USA~650.432.4174~~~SUPPORT@NEWLEADS.COM~" dataUsingEncoding:NSUTF8StringEncoding];
		}
			break;
		case 2:
		{
			// MARK WALTER
			self.data = [@"@@~273~NEWLEADS SAMPLE BADGES 4-2012~MARK~WALTER~DIRECTOR, PRODUCT MARKETING~SEMI NEWS~1245 MAIN~~~SAN JOSE~CA~94006~CA~49 (89) 2543987~~~SUPPORT@NEWLEADS.COM~" dataUsingEncoding:NSUTF8StringEncoding];
		}
			break;
		case 3:
		{
			// DAVID WHITE
			self.data = [@"@@~322704~NEWLEADS SAMPLE BADGES 4-2012~DAVID~WHITE~PRESIDENT~INGRES~1274 CONCANNON BLVD~~~NEW YORK~NY~10018~USA~3034952744~~~SUPPORT@NEWLEADS.COM~" dataUsingEncoding:NSUTF8StringEncoding];
		}
			break;
		case 4:
		{
			// WILLIAMS PARTNER
			self.data = [@"@@~322895~NEWLEADS SAMPLE BADGES 4-2012~JAI~WILLIAMS~PARTNER~LINUX GAZETTE~3410 HILLVIEW AVENUE~~~MADERA~CA~93638~USA~415-621-2925~~~SUPPORT@NEWLEADS.COM~" dataUsingEncoding:NSUTF8StringEncoding];
		}
			break;
		case 5:
		{
			// PETER ZAPOLSKY
			self.data = [@"@@~323051~NEWLEADS SAMPLE BADGES 4-2012~PETER~ZAPOLSKY~VICE PRESIDENT~GREENCAMPAIGNS.COM~836 TANGLEWOOD DRIVE~~~LOS ALTOS~CA~94022~USA~650-854-5560~~~SUPPORT@NEWLEADS.COM~" dataUsingEncoding:NSUTF8StringEncoding];
		}
			break;
		case 6:
		{
			// PIERRE SHIRASAWA
			self.data = [@"@@~323358~NEWLEADS SAMPLE BADGES 4-2012~PIERRE~SHIRASAWA~OBM LEADER~LINAGORA~27 RUE DE BERRI~~~FRAMINGHAM~MA~1701~USA~202.365.0727~~~SUPPORT@NEWLEADS.COM~" dataUsingEncoding:NSUTF8StringEncoding];
		}
			break;
	}

	self.stateBlock(self, kDeviceStateDataReady);
}

- (void) setCardMode:(BOOL)anCardMode
{
	if( anCardMode )
	{
		self.cardModeValue = MS_RAW_CARD_DATA;
	}
	else
	{
		self.cardModeValue = MS_PROCESSED_CARD_DATA;
	}
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	[defaults setInteger:self.cardModeValue forKey:kDefaultsScanModeValueKey];
}

- (BOOL) cardMode
{
	return ( MS_RAW_CARD_DATA == self.cardModeValue ? YES : NO);
}

- (NSString *) cardModeText
{
	if( MS_PROCESSED_CARD_DATA == self.cardModeValue )
	{
		return @"Processed";
	}
	else if( MS_RAW_CARD_DATA == self.cardModeValue )
	{
		return @"Raw";
	}

	return nil;
}

#pragma mark - Helpers
//
- (NSString *) toHexString:(void *)data length:(int)length space:(bool)space
{
	const char HEX[]="0123456789ABCDEF";
	char s[2000];
	
	int len=0;
	for(int i=0;i<length;i++)
	{
		s[len++]=HEX[((uint8_t *)data)[i]>>4];
		s[len++]=HEX[((uint8_t *)data)[i]&0x0f];
        if(space)
            s[len++]=' ';
	}
	s[len]=0;
	return [NSString stringWithCString:s encoding:NSASCIIStringEncoding];
}

- (NSString *) hexToString:(NSString *) label data:(void *)data length:(int) length
{
	const char HEX[]="0123456789ABCDEF";
	char s[2000];
	for(int i=0;i<length;i++)
	{
		s[i*3]=HEX[((uint8_t *)data)[i]>>4];
		s[i*3+1]=HEX[((uint8_t *)data)[i]&0x0f];
		s[i*3+2]=' ';
	}
	s[length*3]=0;
	
    if(label)
        return [NSString stringWithFormat:@"%@(%d): %s",label,length,s];
    else
        return [NSString stringWithCString:s encoding:NSASCIIStringEncoding];
}

- (uint16_t) crc16:(uint8_t *)data length:(int)length crc16:(uint16_t)crc16
{
	if(length==0) return 0;
	int i=0;
	while(length--)
	{
		crc16=(uint8_t)(crc16>>8)|(crc16<<8);
		crc16^=*data++;
		crc16^=(uint8_t)(crc16&0xff)>>4;
		crc16^=(crc16<<8)<<4;
		crc16^=((crc16&0xff)<<4)<<1;
		i++;
	}
	return crc16;
}




#pragma mark - DTDevice delegate
//
/**
 Notification sent when some of the features gets enabled or disabled
 @param feature feature type, one of the FEAT_* constants
 @param value FEAT_UNSUPPORTED if the feature is not supported on the connected device(s), FEAT_SUPPORTED or one of the specific constants for each feature otherwise
 */
-(void)deviceFeatureSupported:(int)feature value:(int)value
{
	NSLog(@"deviceFeatureSupported:\nfeature: %d, value: %d", feature, value);
	switch(feature)
	{
		case FEAT_MSR:
		{
			if( FEAT_SUPPORTED == value )
				self.type |= kTypeMagneticStripeReader;
		}
			break;
		case FEAT_BARCODE:
		{
			if( FEAT_SUPPORTED == value )
				self.type |= kTypeBarcodeReader;
		}
			break;
		case FEAT_RF_READER:
		{
			if( FEAT_SUPPORTED == value )
				self.type |= kTypeRFCardsReader;
		}
			break;
		case FEAT_SMARTCARD:
		{
			if( FEAT_SUPPORTED == value )
				self.type |= kTypeSmarcardReader;
		}
			break;
		default:
		{
		}
			break;
	}
}

/**
 Notifies about the current connection state
 @param state - connection state, one of:
 <table>
 <tr><td>CONN_DISCONNECTED</td><td>there is no connection to any device and the sdk will not try to make one even if the device is attached</td></tr>
 <tr><td>CONN_CONNECTING</td><td>no device is currently connected, but the sdk is actively trying to</td></tr>
 <tr><td>CONN_CONNECTED</td><td>One or more devices are connected</td></tr>
 </table>
 **/
- (void) connectionState:(int)state
{
	self.state = kDeviceStateUnknown;
	self.error = nil;
	
	[self.status setString:@""];
	
	switch(state)
	{
		case CONN_DISCONNECTED:
		{
			[self.status setString:@"state: CONN_DISCONNECTED"];
			self.state = kDeviceStateDisconnected;
		}
			break;
		case CONN_CONNECTING:
		{
			[self.status setString:@"state: CONN_CONNECTING"];
			self.state = kDeviceStateConnecting;
		}
			break;
		case CONN_CONNECTED:
		{
			[self.status setString:@"state: CONN_CONNECTED\n"];
			[self.status appendString:@"********** Device Info **********\n"];
			[self.status appendFormat:@"deviceName: %@\n", [self.dtDevice deviceName]];
			[self.status appendFormat:@"deviceModel: %@\n", [self.dtDevice deviceModel]];
			[self.status appendFormat:@"firmwareRevision: %@\n", [self.dtDevice firmwareRevision]];
			[self.status appendFormat:@"hardwareRevision: %@\n", [self.dtDevice hardwareRevision]];
			[self.status appendFormat:@"serialNumber: %@\n", [self.dtDevice serialNumber]];
			[self.status appendFormat:@"sdkVersion: %d\n", [self.dtDevice sdkVersion]];
			
			[self startDevice];
			
			self.state = kDeviceStateConnected;
		}
			break;
	}
	
	self.infoBlock(self, self.status);
	self.stateBlock(self, self.state);
}

/**
 Notification sent when barcode is successfuly read. This notification is used when barcode type is set to BARCODE_TYPE_DEFAULT or BARCODE_TYPE_EXTENDED.
 @param barcode - string containing barcode data
 @param type - barcode type, one of the BAR_* constants
 **/
-(void)barcodeData:(NSString *)barcode type:(int)type
{
	self.data = [barcode dataUsingEncoding:NSUTF8StringEncoding];
	
	NSLog(@"barcode type: %d, barcodeData: %@", type, barcode);

	[self.status setString:@""];
	[self.status appendFormat:@"Type: %d\n",type];
	[self.status appendFormat:@"Type text: %@\n",[self.dtDevice barcodeType2Text:type]];
	[self.status appendFormat:@"Barcode: %@",barcode];

	self.infoBlock(self, self.status);
	self.stateBlock(self, kDeviceStateDataReady);
}

/**
 Notification sent when barcode is successfuly read. This notification is used when barcode type is set to BARCODE_TYPE_ISO15424, or barcode engine is CR-800.
 @param barcode - string containing barcode data
 @param isotype - ISO 15424 barcode type
 **/
-(void)barcodeData:(NSString *)barcode isotype:(NSString *)isotype
{
	NSLog(@"barcode isotype: %@, barcodeData: %@", isotype, barcode);
	
	self.data = [barcode dataUsingEncoding:NSUTF8StringEncoding];
	
	[self.status setString:@""];
	[self.status appendFormat:@"ISO Type: %@\n",isotype];
	[self.status appendFormat:@"Barcode: %@",barcode];
	
	self.infoBlock(self, self.status);
	self.stateBlock(self, kDeviceStateDataReady);
}

/**
 Notification sent when magnetic card is successfuly read
 @param tracks contains the raw magnetic card data. These are the bits directly from the magnetic head.
 The maximum length of a single track is 704 bits (88 bytes), so the command returns the 3 tracks as 3x88 bytes block
 **/
-(void)magneticCardRawData:(NSData *)tracks
{
	NSLog(@"magneticCardRawData:\ntracks: %@", tracks);

	//self.data = tracks;
    self.data = [[self toHexString:(void *)[tracks bytes] length:(int)[tracks length] space:false] dataUsingEncoding:NSUTF8StringEncoding];
	
	int sound[]={2700,150,5400,150};
	[self.dtDevice playSound:100 beepData:sound length:sizeof(sound) error:nil];
	
	[self.status setString:[self toHexString:(void *)[tracks bytes] length:(int)[tracks length] space:true]];
	
	self.infoBlock(self, self.status);
	self.stateBlock(self, kDeviceStateDataReady);
}

/**
 Notification sent when magnetic card is successfuly read
 @param track1 - data contained in track 1 of the magnetic card or nil
 @param track2 - data contained in track 2 of the magnetic card or nil
 @param track3 - data contained in track 3 of the magnetic card or nil
 **/
-(void)magneticCardData:(NSString *)track1 track2:(NSString *)track2 track3:(NSString *)track3
{
	NSLog(@"magneticCardData:\ntrack1: %@,\ntrack2: %@\ntrack3: %@", track1, track2, track3);
	
	[self.status setString:@""];
	
	NSDictionary * card = [self.dtDevice msProcessFinancialCard:track1 track2:track2];
	if(card)
	{
		if([card valueForKey:@"cardholderName"])
			[self.status appendFormat:@"Name: %@\n",[card valueForKey:@"cardholderName"]];
		if([card valueForKey:@"accountNumber"])
			[self.status appendFormat:@"Number: %@\n",[card valueForKey:@"accountNumber"]];
		if([card valueForKey:@"expirationMonth"])
			[self.status appendFormat:@"Expiration: %@/%@\n",[card valueForKey:@"expirationMonth"],[card valueForKey:@"expirationYear"]];
		[self.status appendString:@"\n"];
	}
	
	if(track1!=NULL)
		[self.status appendFormat:@"Track 1:%@Z", track1];
	if(track2!=NULL)
		[self.status appendFormat:@"Track 2:%@Z", track2];
	if(track3!=NULL)
		[self.status appendFormat:@"Track 3:%@Z", track3];
	
	self.infoBlock(self, self.status);
	
	int sound[]={2730,150,0,30,2730,150};
	[self.dtDevice playSound:100 beepData:sound length:sizeof(sound) error:nil];
    
    //also, if we have pinpad connected, ask for pin entry
    if(card && [self.dtDevice getSupportedFeature:FEAT_PIN_ENTRY error:nil]==FEAT_SUPPORTED)
    {
		[NLAlertView show:@"PIN Entry"
				  message:@"Do you want to enter PIN?"
				  buttons:[NSArray arrayWithObjects:@"Cancel", @"Yes", nil]
					block:^(NLAlertView *alertView, NSInteger buttonIndex)
		{
			if( 1 == buttonIndex )
			{
				//Ask for pin, display progress dialog, the pin result will be done via notification
				if( [self.dtDevice ppadStartPINEntry:0 startY:2 timeout:30 echoChar:'*' message:[NSString stringWithFormat:@"Amount: %.2f\nEnter PIN:",12.34] error:nil])
				{
					self.infoBlock(self, @"Please use the pinpad to complete the operation...");
				}
			}
		}];
    }
	else
	{
		NSMutableString * cardData = [NSMutableString string];
		if(track1!=NULL)
			[cardData appendFormat:@"Track 1:%@Z", track1];
		if(track2!=NULL)
			[cardData appendFormat:@"Track 2:%@Z", track2];
		if(track3!=NULL)
			[cardData appendFormat:@"Track 3:%@Z", track3];
		
		if( cardData && 0 != [cardData length] )
		{
			self.data = [cardData dataUsingEncoding:NSUTF8StringEncoding];
			
			self.infoBlock(self, [NSString stringWithFormat:@"magneticCardData done:\n%@", cardData]);
			self.stateBlock(self, kDeviceStateDataReady);
		}
	}
}

/**
 Notification sent when PIN entry procedure have completed or was cancelled
 **/
- (void)PINEntryCompleteWithError:(NSError *) anError
{
    if( anError )
    {
		self.infoBlock(self, [NSString stringWithFormat:@"PIN entry failed: %@",anError.localizedDescription]);
    }
	else
    {
		NSError * localError = nil;
		
        self.infoBlock(self, @"PIN entry complete");
		
        self.data = [self.dtDevice pinGetPINBlockUsingDUKPT:1 keyVariant:nil pinFormat:PIN_FORMAT_ISO1 error:&localError];
		
		self.error = localError;
		
        if(self.data)
        {
            self.infoBlock(self, [NSString stringWithFormat:@"PIN entry complete, encrypted data:\n%@",[self toHexString:(uint8_t *)self.data.bytes length:(int)self.data.length space:true]]);
			self.stateBlock(self, kDeviceStateDataReady);
        }
		else
		{
            self.infoBlock(self, [NSString stringWithFormat:@"Getting PIN data failed: %@",localError.localizedDescription]);
			self.stateBlock(self, kDeviceStateDataFailed);
		}
    }
}

/**
 Notification sent when magnetic card is successfuly read. The data is being sent encrypted.
 @param encryption encryption algorithm used, one of ALG_* constants
 
 For AES256, after decryption, the result data will be as follows:
 - Random data (4 bytes)
 - Device identification text (16 ASCII characters, unused bytes are 0)
 - Processed track data in the format: 0xF1 (track1 data), 0xF2 (track2 data) 0xF3 (track3 data). It is possible some of the tracks will be empty, then the identifier will not be present too, for example 0xF1 (track1 data) 0xF3 (track3 data)
 - End of track data (byte 0x00)
 - CRC16 (2 bytes) - the CRC is performed from the start of the encrypted block (the Random Data block) to the end of the track data (including the 0x00 byte).
 The data block is rounded to 16 bytes
 
 In the more secure way, where the decryption key resides in a server only, the card read process will look something like:
 - (User) swipes the card
 - (iOS program) receives the data via magneticCardEncryptedData and sends to the server
 - (iOS program)[optional] sends current device serial number along with the data received from magneticCardEncryptedData. This can be used for data origin verification
 - (Server) decrypts the data, extracts all the information from the fields
 - (Server)[optional] if the ipod program have sent the device serial number before, the server compares the received serial number with the one that's inside the encrypted block
 - (Server) checks if the card data is the correct one, i.e. all needed tracks are present, card is the same type as required, etc and sends back notification to the ipod program.
 
 
 For IDTECH with DUKPT the data contains:
 - DATA[0]:	CARD TYPE: 0 - payment card
 - DATA[1]:	TRACK FLAGS
 - DATA[2]:	TRACK 1 LENGTH
 - DATA[3]:	TRACK 2 LENGTH
 - DATA[4]:	TRACK 3 LENGTH
 - DATA[??]:	TRACK 1 DATA MASKED
 - DATA[??]:	TRACK 2 DATA MASKED
 - DATA[??]:	TRACK 3 DATA
 - DATA[??]:	TRACK 1 AND TRACK 2 TDES ENCRYPTED
 - DATA[??]:	TRACK 1 SHA1 (0x14 BYTES)
 - DATA[??]:	TRACK 2 SHA1 (0x14 BYTES)
 - DATA[??]:	DUKPT SERIAL AND COUNTER (0x0A BYTES)
 
 @param tracks contain information which tracks are successfully read and inside the encrypted data as bit fields, bit 1 corresponds to track 1, etc, so value of 7 means all tracks are read
 @param data contains the encrypted card data
 **/
-(void)magneticCardEncryptedData:(int)encryption tracks:(int)tracks data:(NSData *)anData
{
	NSLog(@"magneticCardEncryptedData:\nencryption: %d,\ntracks: %d\ndata: %@", encryption, tracks, anData);
	
	//self.data = anData;
    self.data = [[self toHexString:(void *)[anData bytes] length:(int)[anData length] space:false] dataUsingEncoding:NSUTF8StringEncoding];
    
	
	[self.status setString:@""];
/*
    if(tracks!=0)
    {
        //you can check here which tracks are read and discard the data if the requred ones are missing
        // for example:
        //if(!(tracks&2)) return; //bail out if track 2 is not read
    }
	
	//last used decryption key is stored in preferences
	NSString *decryptionKey=[[NSUserDefaults standardUserDefaults] objectForKey:@"DecryptionKey"];
	if(decryptionKey==nil || decryptionKey.length!=32)
		decryptionKey=@"11111111111111111111111111111111"; //sample default
    
    if(encryption==ALG_AES256 || encryption==ALG_EH_AES256)
    {
        NSData *decrypted=[data AESDecryptWithKey:[decryptionKey dataUsingEncoding:NSASCIIStringEncoding]];
        //basic check if the decrypted data is valid
        if(decrypted)
        {
            uint8_t *bytes=(uint8_t *)[decrypted bytes];
            for(int i=0;i<((int)[decrypted length]-2);i++)
            {
                if(i>(4+16) && !bytes[i])
                {
                    uint16_t crc16=[self crc16:bytes length:(i+1) crc16:0];
                    uint16_t crc16Data=(bytes[i+1]<<8)|bytes[i+2];
                    
                    if(crc16==crc16Data)
                    {
                        int snLen=0;
                        for(snLen=0;snLen<16;snLen++)
                            if(!bytes[4+snLen])
                                break;
                        NSString *sn=[[NSString alloc] initWithBytes:&bytes[4] length:snLen encoding:NSASCIIStringEncoding];
                        //do something with that serial number
                        NSLog(@"Serial number in encrypted packet: %@",sn);
                        
                        //crc matches, extract the tracks then
                        int dataLen=i;
                        //check for JIS card
                        if(bytes[4+16]==0xF5)
                        {
                            NSString * strData=[[NSString alloc] initWithBytes:&bytes[4+16+1] length:(dataLen-4-16-2) encoding:NSASCIIStringEncoding];
                            //pass to the non-encrypted function to display JIS card
                            [self magneticJISCardData:strData];
                        }else
                        {
                            int t1=-1,t2=-1,t3=-1,tend;
                            NSString *track1=nil,*track2=nil,*track3=nil;
                            //find the tracks offset
                            for(int j=(4+16);j<dataLen;j++)
                            {
                                if(bytes[j]==0xF1)
                                    t1=j;
                                if(bytes[j]==0xF2)
                                    t2=j;
                                if(bytes[j]==0xF3)
                                    t3=j;
                            }
                            if(t1!=-1)
                            {
                                if(t2!=-1)
                                    tend=t2;
                                else
                                    if(t3!=-1)
                                        tend=t3;
                                    else
                                        tend=dataLen;
                                track1=[[NSString alloc] initWithBytes:&bytes[t1+1] length:(tend-t1-1) encoding:NSASCIIStringEncoding];
                            }
                            if(t2!=-1)
                            {
                                if(t3!=-1)
                                    tend=t3;
                                else
                                    tend=dataLen;
                                track2=[[NSString alloc] initWithBytes:&bytes[t2+1] length:(tend-t2-1) encoding:NSASCIIStringEncoding];
                            }
                            if(t3!=-1)
                            {
                                tend=dataLen;
                                track3=[[NSString alloc] initWithBytes:&bytes[t3+1] length:(tend-t3-1) encoding:NSASCIIStringEncoding];
                            }
                            
                            //pass to the non-encrypted function to display tracks
                            [self magneticCardData:track1 track2:track2 track3:track3];
                        }
                        return;
                    }
                }
            }
        }
		else
        {
            [self.status setString:@"Decrypted data is null"];
            self.infoBlock(self, self.status);
			
            return;
        }

        [self.status setString:@"Card data cannot be decrypted, possibly key is invalid"];
    }

    if(encryption==ALG_EH_IDTECH)
    {//IDTECH
        //find the tracks, turn to ascii hex the data
        int index=0;
        uint8_t *bytes=(uint8_t *)[data bytes];
        NSLog(@"Packet: %@",[self toHexString:bytes length:data.length space:true]);
        
        index++; //card encoding type
        index++; //track status
        int t1Len=bytes[index++]; //track 1 unencrypted length
        int t2Len=bytes[index++]; //track 2 unencrypted length
        int t3Len=bytes[index++]; //track 3 unencrypted length
        NSString *t1masked=[[NSString alloc] initWithBytes:&bytes[index] length:t1Len encoding:NSASCIIStringEncoding];
        index+=t1Len; //track 1 masked
        NSString *t2masked=[[NSString alloc] initWithBytes:&bytes[index] length:t2Len encoding:NSASCIIStringEncoding];
        index+=t2Len; //track 2 masked
        NSString *t3masked=[[NSString alloc] initWithBytes:&bytes[index] length:t3Len encoding:NSASCIIStringEncoding];
        index+=t3Len; //track 3 masked
        uint8_t *encrypted=&bytes[index]; //encrypted
        int encLen=[data length]-index-10-40;
        NSLog(@"Encrypted: %@",[self toHexString:encrypted length:encLen space:true]);
        index+=encLen;
        index+=20; //track1 sha1
        index+=20; //track2 sha1
        uint8_t *dukptser=&bytes[index]; //dukpt serial number
        
        [self.status appendFormat:@"IDTECH card format\n"];
        [self.status appendFormat:@"Track1: %@\n",t1masked];
        [self.status appendFormat:@"Track2: %@\n",t2masked];
        [self.status appendFormat:@"Track3: %@\n",t3masked];
        [self.status appendFormat:@"\r\nEncrypted: %@\n",[self toHexString:encrypted length:encLen space:true]];
        [self.status appendFormat:@"KSN: %@\n\n",[self toHexString:dukptser length:10 space:true]];
        
        //try decrypting the data
        //calculate the IPEK based on the BDK and serial number
        //insert your own BDK here and calculate the IPEK, for the demo we are using predefined IPEK, that is loaded on the test units
        //uint8_t bdk[16]={...};
        uint8_t ipek[16]={0x82,0xDF,0x8A,0xC0,0x22,0x91,0x62,0xAF,0x04,0x0C,0xF4,0xD0,0x76,0x43,0x72,0x79};
        //dukptDeriveIPEK(bdk,dukptser,ipek);
        NSLog(@"IPEK: %@",[self toHexString:ipek length:sizeof(ipek) space:true]);
		
        //calculate the key based on the serial number and IPEK
        uint8_t idtechKey[16]={0};
        dukptCalculateDataKey(dukptser,ipek,idtechKey);
        NSLog(@"KSN: %@",[self toHexString:dukptser length:10 space:true]);
        NSLog(@"DUKPT KEY: %@",[self toHexString:idtechKey length:16 space:true]);
        
        //decrypt the data with the calculated key
        uint8_t decrypted[512];
        trides_crypto(kCCDecrypt,0,encrypted,encLen,decrypted,idtechKey);
        NSLog(@"Decrypted: %@",[self toHexString:decrypted length:encLen space:true]);
        NSString *t1=@"";
        NSString *t2=@"";
        if(t1Len)
            t1=[[NSString alloc] initWithBytes:&decrypted[0] length:t1Len encoding:NSASCIIStringEncoding];
        if(t2Len)
            t2=[[NSString alloc] initWithBytes:&decrypted[t1Len] length:t2Len encoding:NSASCIIStringEncoding];
        if([t1 hasPrefix:@"%B"])
            [self.status appendFormat:@"Decrypted T1: %@\n",t1];
        else
            [self.status appendFormat:@"Decrypting T1 failed"];
        if([t2 hasPrefix:@";"])
            [self.status appendFormat:@"Decrypted T2: %@\n",t2];
        else
            [self.status appendFormat:@"Decrypting T2 failed"];
    }
	
*/
	
	self.infoBlock(self, self.status);
	self.stateBlock(self, kDeviceStateDataReady);
}

/**
 Notification sent when magnetic card is successfuly read. The raw card data is encrypted via the selected encryption algorithm.
 After decryption, the result data will be as follows:
 - Random data (4 bytes)
 - Device identification text (16 ASCII characters, unused bytes are 0)
 - Track data: the maximum length of a single track is 704 bits (88 bytes), so track data contains 3x88 bytes
 - CRC16 (2 bytes) - the CRC is performed from the start of the encrypted block (the Random Data block) to the end of the track data.
 The data block is rounded to 16 bytes
 @param encryption encryption algorithm used, one of ALG_* constants
 @param data - Contains the encrypted raw card data
 **/
-(void)magneticCardEncryptedRawData:(int)encryption data:(NSData *)anData
{
	NSLog(@"magneticCardEncryptedRawData:\nencryption: %d,\ndata: %@", encryption, anData);
	
	//self.data = anData;
    self.data = [[self toHexString:(void *)[anData bytes] length:(int)[anData length] space:false] dataUsingEncoding:NSUTF8StringEncoding];
	
	[self.status setString:@""];
	
	self.infoBlock(self, self.status);
	self.stateBlock(self, kDeviceStateDataReady);
}

/**
 Notification sent when JIS I & II magnetic card is successfuly read
 @param data - data contained in the magnetic card
 **/
-(void)magneticJISCardData:(NSString *) anData
{
	NSLog(@"magneticJISCardData:\ndata: %@", anData);
	
	self.data = [anData dataUsingEncoding:NSUTF8StringEncoding];
	
	[self.status setString:[NSString stringWithFormat:@"JIS card data:\n%@", anData]];
	
	int sound[]={2730,150,0,30,2730,150};
	[self.dtDevice playSound:100 beepData:sound length:sizeof(sound) error:nil];

	self.infoBlock(self, self.status);
	self.stateBlock(self, kDeviceStateDataReady);
}

/**
 Notification sent when smartcard was inserted
 **/
-(void)smartCardInserted:(SC_SLOTS)slot
{
	NSLog(@"smartCardInserted:\nslot: %d", slot);
	
	NSError * localError = nil;
	
	NSData * atr = [self.dtDevice scCardPowerOn:slot error:&localError];
    if(atr)
    {
		NSString * text = [NSString stringWithFormat:@"SmartCard Inserted\nATR: %@",[self toHexString:(void *)[atr bytes] length:(int)[atr length] space:true]];

        self.infoBlock(self, text);
	}
	else
    {
        self.infoBlock(self, @"SmartCart reset failed!");
    }
}

/**
 Notification sent when smartcard was removed
 **/
-(void)smartCardRemoved:(SC_SLOTS)slot
{
	NSLog(@"smartCardRemoved:\nslot: %d", slot);
	
	self.infoBlock(self, @"SmartCard Removed");
}

#define CHECK_RESULT(description,result) if(result)[s appendFormat:@"%@: SUCCESS\n",description]; else [s appendFormat:@"%@: FAILED (%@)\n",description,localError.localizedDescription];

/**
 Notification sent when a new supported RFID card enters the field
 @param cardIndex the index of the card, use this index with all subsequent commands to the card
 @param info information about the card
 **/
-(void)rfCardDetected:(int)cardIndex info:(DTRFCardInfo *)info
{
	NSLog(@"rfCardDetected. CardIndex: %d, info: %@", cardIndex, info);
	
	self.data = info.UID;
	
	NSError * localError = nil;
    
    NSMutableString *s=[[[NSMutableString alloc] init] autorelease];
    [s appendFormat:@"%@ card detected\n",info.typeStr];
    [s appendFormat:@"Serial: %@\n",[self hexToString:nil data:(uint8_t *)info.UID.bytes length:(int)info.UID.length]];
    
	switch (info.type)
    {
        case CARD_MIFARE_MINI:
        case CARD_MIFARE_CLASSIC_1K:
        case CARD_MIFARE_CLASSIC_4K:
        case CARD_MIFARE_PLUS:
        {
			//16 bytes reading and 16 bytes writing
            //try to authenticate first with default key
            const uint8_t key[]={0xFF,0xFF,0xFF,0xFF,0xFF,0xFF};
			//
            //it is best to store the keys you are going to use once in the device memory, then use mfAuthByStoredKey function to authenticate blocks rahter than having the key in your program
            BOOL r=[self.dtDevice mfAuthByKey:cardIndex type:'A' address:8 key:[NSData dataWithBytes:key length:sizeof(key)] error:&localError];
            CHECK_RESULT(@"Authenticate",r);
			//
            // Try reading a block we authenticated before
            NSData *block=[self.dtDevice mfRead:cardIndex address:8 length:16 error:&localError];
            CHECK_RESULT(@"Read block",block);
            if(block)
			{
                [s appendFormat:@"Data: %@\n",[self hexToString:nil data:(uint8_t *)block.bytes length:(int)block.length]];
            //write something, be VERY cautious where you write, as you can easily render the card useless forever
            //const uint8_t dataToWrite[16]={0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x0E,0x0F};
            //r=[linea mfWrite:cardIndex address:8 data:[NSData dataWithBytes:dataToWrite length:sizeof(dataToWrite)] error:&error];
            //CHECK_RESULT(@"Write block",r);
			}
        }
			break;
        case CARD_MIFARE_ULTRALIGHT:
        {
			//16 bytes reading, 4 bytes writing
            //try reading a block
            NSData * block=[self.dtDevice mfRead:cardIndex address:8 length:16 error:&localError];
            CHECK_RESULT(@"Read block",block);
            if(block)
			{
                [s appendFormat:@"Data: %@\n",[self hexToString:nil data:(uint8_t *)block.bytes length:(int)block.length]];
			}
            //write something to the card
            const uint8_t dataToWrite[4]={0x00,0x01,0x02,0x03};
            int r=[self.dtDevice mfWrite:cardIndex address:8 data:[NSData dataWithBytes:dataToWrite length:sizeof(dataToWrite)] error:&localError];
            CHECK_RESULT(@"Write block",r);
        }
			break;
        case CARD_MIFARE_ULTRALIGHT_C:
        {
			//16 bytes reading, 4 bytes writing, authentication may be required
            //try reading a block we authenticated before
            NSData *block=[self.dtDevice mfRead:cardIndex address:8 length:16 error:&localError];
            CHECK_RESULT(@"Read block",block);
            if(block)
			{
                [s appendFormat:@"Data: %@\n", [self hexToString:nil data:(uint8_t *)block.bytes length:(int)block.length]];
			}
            //write something to the card
            const uint8_t dataToWrite[4]={0x00,0x01,0x02,0x03};
            int r = [self.dtDevice mfWrite:cardIndex address:8 data:[NSData dataWithBytes:dataToWrite length:sizeof(dataToWrite)] error:&localError];
            CHECK_RESULT(@"Write block",r);
        }
			break;
        case CARD_ISO15693:
        {
			//block size is different between cards
            [s appendFormat:@"Block size: %d\n",info.blockSize];
            [s appendFormat:@"Number of blocks: %d\n",info.nBlocks];
            //try reading 2 blocks
            NSData *block=[self.dtDevice iso15693Read:cardIndex startBlock:0 length:info.blockSize error:&localError];
            CHECK_RESULT(@"Read blocks",block);
            if(block)
			{
                [s appendFormat:@"Data: %@\n",[self hexToString:nil data:(uint8_t *)block.bytes length:(int)block.length]];
			}
            //write something to the card
            const uint8_t dataToWrite[4]={0x00,0x01,0x02,0x03};
            int r=[self.dtDevice iso15693Write:cardIndex startBlock:0 data:[NSData dataWithBytes:dataToWrite length:sizeof(dataToWrite)] error:&localError];
            CHECK_RESULT(@"Write blocks",r);
        }
			break;
//        case CARD_ISO14443:
            //unsupported
//            break;
    }
    [s appendFormat:@"Please remove card"];

    [self.status setString:s];
	
	self.infoBlock(self, self.status);
	self.stateBlock(self, kDeviceStateDataReady);
	
	[self.dtDevice rfRemoveCard:cardIndex error:nil];
}

/**
 Notification sent when the card leaves the field
 @param cardIndex the index of the card, use this index with all subsequent commands to the card
 */
-(void)rfCardRemoved:(int)cardIndex
{
	NSLog(@"rfCardRemoved. CardIndex: %d", cardIndex);
}


@end
