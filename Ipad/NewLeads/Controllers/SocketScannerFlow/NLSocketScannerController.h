//
//  NLSocketScannerController.h
//  NewLeads
//
//  Created by idevs.com on 01/07/2015.
//  Copyright (c) 2015 idevs.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NLSocketScannerController;
typedef void (^NLSocketScannerStateBlock)(NLSocketScannerController * ssController, int state);


@interface NLSocketScannerController : NSObject

@property (nonatomic, readwrite, copy) NLSocketScannerStateBlock stateBlock;


+ (NLSocketScannerController *) device;

- (void) connect;
- (void) disconnect;
- (void) shutdown;
//
- (NSData *) data;
- (NSString *) stringData;
//

@end
