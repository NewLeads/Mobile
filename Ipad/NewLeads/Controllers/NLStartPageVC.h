//
//  NLStartPageVC.h
//  NewLeads
//
//  Created by idevs.com on 17/03/2015.
//  Copyright (c) 2015 idevs.com. All rights reserved.
//

#import "NLCommonViewController.h"
#import "ASIHTTPRequestDelegate.h"

extern NSString * const kPageRecentLink;
extern NSString * const kPageClickToBeginLink;
extern NSString * const kPageCusteditName;
extern NSString * const kPageEdittabName;
extern NSString * const kPageEditleadName;

@class NLLeadsViewController;

@interface NLStartPageVC : NLCommonViewController

@property (nonatomic, assign) BOOL isLoaded;
@property (nonatomic, assign) NLLeadsViewController	* leadsVC;

- (void) goHome:(BOOL) force;
- (void) sendStatData:(NSString *) anDataString;
- (void) sendScannedData:(NSData *) anData forStation:(NSString *) anStationID;
- (void) uploadImageData:(NSData *) imgData;

@end
