//
//  NLBarcodeDatasource.h
//  NewLeads
//
//  Created by idevs.com on 27/01/2015.
//  Copyright (c) 2015 idevs.com. All rights reserved.
//

#import "NLBarcode.h"

typedef NS_ENUM(NSInteger, NLBarcodeType)
{
	kBarcodeQR = 0,
	kBarcodeDM,
	kBarcode39,
	kBarcodeEANUPC,
	kBarcode128,
	kBarcodePDF,
	kBarcodeAZTEC,
	kBarcodeCODABAR,
	//
	kBarcodesCount
};


@interface NLBarcodeDatasource : NSObject

@property (nonatomic, readonly, strong) NSArray * arrBarcodes;

- (void) setupFromXML:(NSDictionary *) dicSource;
- (void) flushData;

- (NSArray *) barcodes:(BOOL) sorted;		// Array of NLBarcode objects. If YES - returns items sorted by "code name" overiwise - unsorted - order as in ENUM
- (NSArray *) barcodeNames:(BOOL) sorted;	// Array of NSString objects. If YES - returns items sorted by "code name" overiwise - unsorted - order as in ENUM
- (NSArray *) selected;		// Array of NSNumber objects contained code value

- (void) selectItem:(BOOL) isSelect atIndex:(NSInteger) anIndex; // We assume that logic takes default unsorted array
//- (void) selectNoneItems;
//- (void) selectAllItems;

- (BOOL) hasCodeEnabled:(uint32_t) code;

@end
