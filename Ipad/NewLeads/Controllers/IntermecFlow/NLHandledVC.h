//
//  NLHandledVC.h
//  NewLeads
//
//  Created by idevs.com on 24/12/2014.
//  Copyright (c) 2014 idevs.com. All rights reserved.
//

#import "NLCommonViewController.h"

@class NLHandledVC;

typedef void(^HandledScannerDidReveivedData)(NLHandledVC * vc, NSString * strData);


@interface NLHandledVC : NLCommonViewController
<
	UITextFieldDelegate
>
//
// UI - XIB:
@property (nonatomic, assign) IBOutlet UITextField * fieldHandledScanner;
//
// Blocks:
@property (nonatomic, copy) HandledScannerDidReveivedData dataHandler;


- (void) setupDataHandler:(HandledScannerDidReveivedData) anDataHandler;

@end
