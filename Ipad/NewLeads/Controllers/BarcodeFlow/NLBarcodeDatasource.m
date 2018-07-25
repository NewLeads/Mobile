//
//  NLBarcodeDatasource.m
//  NewLeads
//
//  Created by idevs.com on 27/01/2015.
//  Copyright (c) 2015 idevs.com. All rights reserved.
//

#import "NLBarcodeDatasource.h"
//
// Assets:
#import "BarcodeScanner.h"



/*
 #define MWB_CODE_MASK_NONE                  0x00000000u
 #define MWB_CODE_MASK_QR                    0x00000001u
 #define MWB_CODE_MASK_DM                    0x00000002u
 #define MWB_CODE_MASK_RSS                   0x00000004u
 #define MWB_CODE_MASK_39                    0x00000008u
 #define MWB_CODE_MASK_EANUPC                0x00000010u
 #define MWB_CODE_MASK_128                   0x00000020u
 #define MWB_CODE_MASK_PDF                   0x00000040u
 #define MWB_CODE_MASK_AZTEC                 0x00000080u
 #define MWB_CODE_MASK_25                    0x00000100u
 #define MWB_CODE_MASK_93                    0x00000200u
 #define MWB_CODE_MASK_CODABAR               0x00000400u
 #define MWB_CODE_MASK_DOTCODE               0x00000800u
 #define MWB_CODE_MASK_11                    0x00001000u
 #define MWB_CODE_MASK_MSI                   0x00002000u
 #define MWB_CODE_MASK_ALL                   0x00ffffffu
*/

//typedef NS_ENUM(NSInteger, NLBarcodeType)
//{
////	kBarcodeNone	= 0,
//	kBarcodeQR,
//	kBarcodeDM,
////	kBarcodeRSS,
//	kBarcode39,
//	kBarcodeEANUPC,
//	kBarcode128,
//	kBarcodePDF,
//	kBarcodeAZTEC,
////	kBarcode25,
////	kBarcode93,
//	kBarcodeCODABAR,
////	kBarcodeDOTCODE,
////	kBarcode11,
////	kBarcodeMSI,
////	kBarcodeALL,
//	//
//	kBarcodesCount
//};
//
NSString * const	kNLArchiveBarcodesFileName	= @"NLBarcodes4.archive";


@interface NLBarcodeDatasource ()
//
//
@property (nonatomic, readwrite, strong) NSArray * arrBarcodes;
@property (nonatomic, readwrite, strong) NSArray * arrBarcodesSorted;
@property (nonatomic, strong) NSArray * arrBarcodeNames;
@property (nonatomic, strong) NSArray * arrBarcodeNamesSorted;
@property (nonatomic, strong) NSMutableSet * setSelected;

@end

@implementation NLBarcodeDatasource

- (instancetype) init
{
	if( nil != (self = [super init]) )
	{
		self.setSelected = [NSMutableSet set];
		
		[self loadData];
	}
	return self;
}

- (void) initialSetup
{
	NSMutableArray * tempArr = [NSMutableArray array];
	
	for(NSInteger i = 0; i < kBarcodesCount; i++)
	{
		NLBarcode * barcode = [NLBarcode new];
		
		switch(i)
		{
//			case kBarcodeNone:
//			{
//				barcode.codeValue	= [NSNumber numberWithInteger:MWB_CODE_MASK_NONE];
//				barcode.codeSelected= [NSNumber numberWithBool:NO];
//				barcode.codeName	= @"None";
//				barcode.codeDescription= @"None selected";
//			}
//				break;
			case kBarcodeQR:
			{
				barcode.codeValue	= [NSNumber numberWithInteger:MWB_CODE_MASK_QR];
				barcode.codeSelected= [NSNumber numberWithBool:NO];
				barcode.codeName	= @"QR Code";
				barcode.codeDescription= @"QR Code is a 2D (matrix) barcode format initially developed, patented and owned by Toyota subsidiary Denso Wave for car parts management; it is now in the public domain. The “QR” is derived from “Quick Response”, as the creator intended the barcode to allow its contents to be decoded rapidly. QR Code can store up to 2,335 ASCII characters in one barcode symbol, and includes Error Correction Code (ECC) which allows error-free reading even when a symbol that has been partially lost or destroyed. Additionally, QR Codes are playing a prominent role in Apple’s new electronic wallet iOS app, Passbook.";
			}
				break;
			case kBarcodeDM:
			{
				barcode.codeValue	= [NSNumber numberWithInteger:MWB_CODE_MASK_DM];
				barcode.codeSelected= [NSNumber numberWithBool:NO];
				barcode.codeName	= @"Data Matrix";
				barcode.codeDescription= @"Data Matrix is a 2D (matrix) barcode format available as open standard. Data Matrix was designed in 1989 and was standardized by many organizations including NASA, US DoD and major industry branches such as electronics, pharmaceutical and postal marking. The encoded information can be either text or raw data. Typical data size is from few bytes up to 2 kilobytes. The length of the encoded data depends on the used symbol dimension. Error correction codes are added to increase symbol strength: they can be read even if they are partially damaged. A Datamatrix symbol can store up to 2,335 alphanumeric characters.";
			}
				break;
//			case kBarcodeRSS:
//			{
//				barcode.codeValue	= [NSNumber numberWithInteger:MWB_CODE_MASK_RSS];
//				barcode.codeSelected= [NSNumber numberWithBool:NO];
//				barcode.codeName	= @"GS1 DataBar";
//				barcode.codeDescription= @"GS1 DataBar™ symbols can carry more information and identify smaller items then the standard EAN and UPC barcodes. GS1 DataBar enables GTIN identification for fresh variable measure and hard-to-mark products like loose produce, jewelry and cosmetics. Additionally, GS1 DataBar can carry GS1 Application Identifiers such as serial numbers, lot numbers, and expiration dates, creating solutions to support product authentication and traceability for fresh food products and couponing.";
//			}
//				break;
			case kBarcode39:
			{
				barcode.codeValue	= [NSNumber numberWithInteger:MWB_CODE_MASK_39];
				barcode.codeSelected= [NSNumber numberWithBool:NO];
				barcode.codeName	= @"Code 39";
				barcode.codeDescription= @"Code 39 (also called “3 of 9 Code”) was developed by Dr. David Allais and Ray Stevens in 1974. Code 39 is a discrete, variable length symbology and was the first alphanumeric barcode to be developed. It is designed to encode twenty-six uppercase letters (A-Z), numeric digits (0-9), and seven special characters: space, minus (-), plus (+), period(.), dollar sign ($), slash(/), and percent (%). It can be extended to encode the ASCII character set by using a two character coding scheme. Each character is composed of nine elements: five bars and four spaces. Three of the elements are wide (binary value 1) and six elements are narrow (binary value 0), the width ratio can be chosen between 1:2 and 1:3. Code 39 is one of the only type of barcodes in common use that does not require a checksum. An inadequately interpreted bar cannot generate another valid character. The template must then add a fixed asterisk (*) before and after the data and print the field using a Code 39 barcode font. This “self-checking” makes it especially attractive for applications where it is inconvenient to perform calculations each time a barcode is printed.";
			}
				break;
			case kBarcodeEANUPC:
			{
				barcode.codeValue	= [NSNumber numberWithInteger:MWB_CODE_MASK_EANUPC];
				barcode.codeSelected= [NSNumber numberWithBool:NO];
				barcode.codeName	= @"EAN/UPC";
				barcode.codeDescription= @"EAN barcode is primarily used in supermarkets to identify products at the point of sale. In 1977 the EAN code was used by 12 countries (all the countries of the European Community). Today, use of the EAN code has spread to all west European countries, USA, Canada, Australia and Japan.\nUPC was the first barcode symbology widely adopted. It was designed to make it ideal for coding products. UPC can be printed on packages using a variety of printing processes. The format allows the symbol to be scanned with any package orientation. Omnidirectional scanning allows any package orientation provided the symbol faces the scanner. UPC format can be scanned by hand-held wands and can be printed by equipment in the store.";
			}
				break;
			case kBarcode128:
			{
				barcode.codeValue	= [NSNumber numberWithInteger:MWB_CODE_MASK_128];
				barcode.codeSelected= [NSNumber numberWithBool:NO];
				barcode.codeName	= @"Code 128";
				barcode.codeDescription= @"Code 128 is a very high density barcode symbology only used for alphanumeric barcodes. The symbol can be as long as necessary to store the encoded data and is designed to encode all 128 ASCII characters; it will use the least amount of space for data of 6 characters or more of any one-dimensional barcode symbology.\nCode 128 is made up of six sections: the quiet zone, start character, encoded character, check character, stop character and another quiet zone. Each data character is made up of eleven black or white modules with the exception of the stop character, which has 13 modules. Three bars and three spaces are formed out of these eleven modules; bars and spaces can vary between one and four modules wide.\nCode 128 includes a checksum digit for verification. The barcode may also be verified character-by-character affirming the parity of each data byte. Its specific structure also allows numeric data to be encoded at double-density.";
			}
				break;
			case kBarcodePDF:
			{
				barcode.codeValue	= [NSNumber numberWithInteger:MWB_CODE_MASK_PDF];
				barcode.codeSelected= [NSNumber numberWithBool:NO];
				barcode.codeName	= @"PDF417";
				barcode.codeDescription= @"PDF417 is a stacked linear barcode symbol format used in a variety of applications such as transportation, identification cards, and inventory management. PDF stands for Portable Data File. The PDF417 symbology was invented by Dr. Ynjiun P. Wang at Symbol Technologies in 1991. (Wang 1993) It is represented by ISO standard 15438. Additionally, PDF417 Codes are playing a prominent role in Apple’s new electronic wallet iOS app, Passbook.";
			}
				break;
			case kBarcodeAZTEC:
			{
				barcode.codeValue	= [NSNumber numberWithInteger:MWB_CODE_MASK_AZTEC];
				barcode.codeSelected= [NSNumber numberWithBool:NO];
				barcode.codeName	= @"Aztec Code";
				barcode.codeDescription= @"Aztec Code is a very efficient two-dimensional (2D) symbology that uses square modules with unique finder pattern in the middle of the symbol. Characters, numbers, text and bytes of data can all be encoded in an Aztec barcode. Aztec code has the potential to use less space than other matrix barcodes because it does not require a surrounding blank \"quiet zone\".The symbol is built on a square grid with a bulls-eye pattern at its center used for locating the code. Data is encoded in concentric square rings around the bulls-eye pattern. Aztec Code is one of the smallest and most dependable symbologies in use today. Additionally, Aztec Codes are playing a prominent role in Apple’s new electronic wallet iOS app, Passbook.";
			}
				break;
//			case kBarcode25:
//			{
//				barcode.codeValue	= [NSNumber numberWithInteger:MWB_CODE_MASK_25];
//				barcode.codeSelected= [NSNumber numberWithBool:NO];
//				barcode.codeName	= @"Code 25";
//				barcode.codeDescription= @"Code 25 is a very simple numeric code which is able to display digits from 0 to 9. The code is primary used in industry and is also known as \"Code 2 of 5\" or \"Code 25 Industrial\". Code 25 has no built-in check digit.\nCode 25 Interleaved is a special type of Code 25 that is also a numeric code able to display digits from 0 to 9. The code is also known as \"Code 2 of 5 Interleaved\". It has no built-in check digit. The advantage of Code 25 Interleaved is that the code uses self-checking and it is very compact so it does not need much space like the simple Code 25. Code 25 Interleaved is only valid if there is a even number of digits. To display an odd number of digits you have to add a zero to the beginning (123 becomes 0123) or you may use your own check digit.";
//			}
//				break;
//			case kBarcode93:
//			{
//				barcode.codeValue	= [NSNumber numberWithInteger:MWB_CODE_MASK_93];
//				barcode.codeSelected= [NSNumber numberWithBool:NO];
//				barcode.codeName	= @"Code 93";
//				barcode.codeDescription= @"Code 93 Designed by Internec to provide higher density and data security to its predecessor, Code 39, Code 93 is an alphanumeric, variable-length symbology with automatic checksums. While it can represent the full ASCII character set by using combinations to two characters, it improves on Code 39 by offering a continuous symbology with more compact codes. One of the primary users of this barcode type is the Canadian postal service.";
//			}
//				break;
			case kBarcodeCODABAR:
			{
				barcode.codeValue	= [NSNumber numberWithInteger:MWB_CODE_MASK_CODABAR];
				barcode.codeSelected= [NSNumber numberWithBool:NO];
				barcode.codeName	= @"Codabar";
				barcode.codeDescription= @"Codabar is a self-checking barcode symbology popular with blood banks, libraries, photo labs and FedEx air bills. This barcode type is a low-density numeric barcode. It includes 16 characters and allows for use of four separate Start and Stop characters (A, B, C, and D). Codabar barcodes can be of variable length and do not require a checksum.";
			}
				break;
//			case kBarcodeDOTCODE:
//			{
//				barcode.codeValue	= [NSNumber numberWithInteger:MWB_CODE_MASK_DOTCODE];
//				barcode.codeSelected= [NSNumber numberWithBool:NO];
//				barcode.codeName	= @"DotCode";
//				barcode.codeDescription= @"DotCode is a public domain optical data carrier designed to be reliably readable when printed by high-speed inkjet or laser dot technologies. Thus real time data like expiration date, lot number or serial number could be applied to products in a machine-readable form at production line speeds. A dotcode, generically, is a type of bar code that encodes data in an array of nominally disconnected dots at chosen sites within a regular grid of possible locations.";
//			}
//				break;
//			case kBarcode11:
//			{
//				barcode.codeValue	= [NSNumber numberWithInteger:MWB_CODE_MASK_11];
//				barcode.codeSelected= [NSNumber numberWithBool:NO];
//				barcode.codeName	= @"Code 11";
//				barcode.codeDescription= @"Code 11, also known as USD-8, is a linear, discrete, non-self-checking, bidirectional, numeric barcode symbology, used primarily for labelling telecommunications equipment.";
//			}
//				break;
//			case kBarcodeMSI:
//			{
//				barcode.codeValue	= [NSNumber numberWithInteger:MWB_CODE_MASK_MSI];
//				barcode.codeSelected= [NSNumber numberWithBool:NO];
//				barcode.codeName	= @"MSI Plessey";
//				barcode.codeDescription= @"MSI Plessey, also known as MSI and MSI Modified Plessey, is a continuous, non-self-checking, arbitrary length, numeric barcode symbology. It was developed by the MSI Data Corporation, based on the original Plessey Code. It is used primarily to mark retail shelves for inventory control.";
//			}
//				break;
//			case kBarcodeALL:
//			{
//				barcode.codeValue	= [NSNumber numberWithInteger:MWB_CODE_MASK_ALL];
//				barcode.codeSelected= [NSNumber numberWithBool:NO];
//				barcode.codeName	= @"All";
//				barcode.codeDescription= @"All selected";
//			}
//				break;
			default:
				break;
		}
		
		[tempArr addObject:barcode];
	}
	
	self.arrBarcodes = tempArr.copy;
	self.arrBarcodesSorted = nil;
	self.arrBarcodeNames = nil;
	self.arrBarcodeNamesSorted = nil;
}



#pragma mark - Core logic
//
- (void) setupFromXML:(NSDictionary *) dicSource
{
	//TODO: Add new logic
}

- (NSArray *) barcodes:(BOOL) sorted
{
	if( sorted )
	{
		if( !self.arrBarcodesSorted )
		{
			NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"codeName" ascending:NO];
			
			self.arrBarcodesSorted = [self.arrBarcodes sortedArrayUsingDescriptors:@[sortDescriptor]];
		}
		return self.arrBarcodesSorted;

	}
	return self.arrBarcodes;
}

- (NSArray *) barcodeNames:(BOOL) sorted
{
	if( 0 == self.arrBarcodes.count )
	{
		return nil;
	}
	
	if( sorted )
	{
		if( !self.arrBarcodeNamesSorted )
		{
			self.arrBarcodeNamesSorted = [[self barcodes:YES] valueForKeyPath:@"codeName"];
		}
		return self.arrBarcodeNamesSorted;
	}
	
	if( !self.arrBarcodeNames )
	{
		self.arrBarcodeNames = [[self barcodes:NO] valueForKeyPath:@"codeName"];
	}
	return self.arrBarcodeNames;
}

- (NSArray *) selected
{
	return [self.setSelected allObjects];
}

- (void) selectItem:(BOOL) isSelect atIndex:(NSInteger) anIndex
{
	NLBarcode * barcode = [[self barcodes:NO] objectAtIndex:anIndex];
	barcode.codeSelected= [NSNumber numberWithBool:isSelect];
	
	if( isSelect )
	{
		[self.setSelected addObject:barcode.codeValue];
	}
	else
	{
		[self.setSelected removeObject:barcode.codeValue];
	}

	// TODO Not finished logic - we need to handle None and All items
}

- (BOOL) hasCodeEnabled:(uint32_t) code
{
	for( NLBarcode * bc in self.arrBarcodes )
	{
		if( code == [bc.codeValue unsignedIntegerValue] )
		{
			return bc.isSelected;
		}
	}
	return NO;
}

//- (void) selectNoneItems
//{
//	// TODO Not finished logic - we need to handle None and All items
//	//
//	for(NLBarcode * barcode in [self barcodes] )
//	{
//		barcode.codeSelected = [NSNumber numberWithBool:NO];
//	}
//	
//	[self.setSelected removeAllObjects];
//	
//	NLBarcode * none = [[self barcodes] objectAtIndex:kBarcodeNone];
//	[self.setSelected addObject:none.codeValue];
//}

//- (void) selectAllItems
//{
//	// TODO Not finished logic - we need to handle None and All items
//	//
//	for(NLBarcode * barcode in [self barcodes] )
//	{
//		barcode.codeSelected = [NSNumber numberWithBool:YES];
//	}
//
//	[self.setSelected addObjectsFromArray:[[self barcodes] valueForKeyPath:@"codeValue"]];
//}

#pragma mark >>> Serialization/Deserialization
//
- (void) loadData
{
	NSString * archivePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:kNLArchiveBarcodesFileName];
	NSArray * storedBarcodes = [NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];
	
	if( storedBarcodes )
	{
		//NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"codeName" ascending:NO];

        self.arrBarcodes = storedBarcodes;//[storedBarcodes sortedArrayUsingDescriptors:@[sortDescriptor]];
	}
	else
	{
		[self initialSetup];
	}
	
	//[[NSFileManager defaultManager] removeItemAtPath:archivePath error:NULL];
	
	if( 0 != self.arrBarcodes.count )
	{
		NSPredicate * filter = [NSPredicate predicateWithFormat:@"codeSelected == YES"];
		NSArray * arrResult = [self.arrBarcodes filteredArrayUsingPredicate:filter];
		
		if( 0 != arrResult.count )
		{
			[self.setSelected addObjectsFromArray:[arrResult valueForKeyPath:@"codeValue"]];
		}
	}
}

- (void) flushData
{
    NSFileManager* fm = [NSFileManager defaultManager];
	NSString * archivePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:kNLArchiveBarcodesFileName];
    
    if ([fm fileExistsAtPath:archivePath])
    {
        [fm removeItemAtPath:archivePath error:nil];
    }

	BOOL res = [NSKeyedArchiver archiveRootObject:self.arrBarcodes toFile:archivePath];
 
	if( !res )
    {
        [NLAlertView showError:@"Bar code settings were not saved!"];
    }
}

@end
