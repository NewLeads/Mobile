//
//  NLCommonViewController.h
//  NewLeads
//
//  Created by idevs.com on 25/09/2013.
//  Copyright (c) 2013 idevs.com. All rights reserved.
//

#import <UIKit/UIKit.h>



@class NLRootViewController;

@interface NLCommonViewController : UIViewController

@property (nonatomic, readonly, retain) UIBarButtonItem * barLogo;

- (void) cleanup;

- (void) notifications:(NSNotification *) anNotif;

- (void) showHUD:(BOOL) isShow;
- (void) showHUD:(BOOL) isShow animated:(BOOL) isAnimated;
- (void) showHUD:(BOOL) isShow animated:(BOOL) isAnimated withText:(NSString *) anText;

@end
