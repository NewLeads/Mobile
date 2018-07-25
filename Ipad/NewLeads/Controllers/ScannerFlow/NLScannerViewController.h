//
//  NLScannerViewController.h
//  NewLeads
//
//  Created by idevs.com on 20/06/2013.
//  Copyright (c) 2013 idevs.com. All rights reserved.
//

#import "NLCommonViewController.h"


@class NLScannerViewController;
typedef void (^ScannerActionBlock)(NLScannerViewController * scanner, NSData * anData, NSError * error);


@interface NLScannerViewController : NLCommonViewController

@property (nonatomic, readwrite, copy) ScannerActionBlock actionBlock;

@end
