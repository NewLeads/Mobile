//
//  NLCaptureViewController.h
//  NewLeads
//
//  Created by Arseniy Astapenko on 8/20/13.
//  Copyright (c) 2013 idevs.com. All rights reserved.
//

#import "NLCommonViewController.h"
//
// Assets:
#import "PBJVision.h"



@protocol NLCaptureViewControllerDelegate <NSObject>

@optional
- (void) didFinishedCaptureWithData:(NSData *) imgData cropRect:(CGRect) rcCrop;
- (void) didFinishedCaptureWithImage:(UIImage *) img cropRect:(CGRect) rcCrop;

@end



@interface NLCaptureViewController : NLCommonViewController

@property (nonatomic, assign) id<NLCaptureViewControllerDelegate> delegate;

@end
