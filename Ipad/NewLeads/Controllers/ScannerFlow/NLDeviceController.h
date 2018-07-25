//
//  NLDeviceController.h
//  NewLeads
//
//  Created by idevs.com on 20/06/2013.
//  Copyright (c) 2013 idevs.com. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString * const kDeviceErrorDomain;

typedef enum
{
	kDeviceStateUnknown	= -1,
	kDeviceStateDisconnected,
	kDeviceStateConnecting,
	kDeviceStateConnected,
	kDeviceStateDataGathering,
	kDeviceStateDataReady,
	kDeviceStateDataFailed
	
} kDeviceState;


@class NLDeviceController;
typedef void (^NLDeviceStateBlock)(NLDeviceController * controller, kDeviceState state);
typedef void (^NLDeviceInfoBlock)(NLDeviceController * controller, NSString * info);


@interface NLDeviceController : NSObject

+ (NLDeviceController *) device;

@property (nonatomic, readonly, assign, getter = isDeviceReady) BOOL deviceReady;
@property (nonatomic, readonly, assign) kDeviceState	state;
//
@property (nonatomic, readonly, retain) NSError			* error;
//
@property (nonatomic, readonly, retain) NSData			* data;
//
@property (nonatomic, readwrite, copy) NLDeviceStateBlock stateBlock;
@property (nonatomic, readwrite, copy) NLDeviceInfoBlock infoBlock;
//
@property (nonatomic, readwrite, assign) BOOL cardMode;
@property (nonatomic, readonly, copy) NSString * cardModeText;

- (void) connect;
- (void) disconnect;
//
- (void) scanBarcodePressed;
- (void) scanBarcodeReleased;
//
- (void) sendTestData;

@end
