//
//  NewLeadsVC.h
//  NewLeads
//
//  Created by idevs.com on 27/06/2011.
//  Copyright 2011 idevs.com. All rights reserved.
//

#import "NLCommonViewController.h"
//


#pragma mark - Configuration
//
extern NSString * const kLogoutPassphrase;
//

@interface NLLeadsViewController : NLCommonViewController


// Actions

- (void) cleanup;

- (void) initScanner:(BOOL) anFlag;
- (void) initSocketScanner:(BOOL) anFlag;

- (void) showCameraWithOverlay;
- (void) showCaptureController;
- (void) showCropControllerWithImage:(UIImage *) anImage;

@end


@interface UIImage(DisableRotation)
- (UIImage *)fixrotation;
- (UIImage *)fixrotationForInitalOrientation:(UIImageOrientation)imageOrientation;

@end
