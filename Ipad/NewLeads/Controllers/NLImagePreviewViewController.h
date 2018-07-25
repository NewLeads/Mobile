//
//  NLImagePreviewViewController.h
//  NewLeads
//
//  Created by Arseniy Astapenko on 8/26/13.
//  Copyright (c) 2013 idevs.com. All rights reserved.
//

#import "NLCommonViewController.h"

typedef void(^NLImagePreviewDoneCallback)(UIImage *image, BOOL canceled);

@interface NLImagePreviewViewController : NLCommonViewController

@property (nonatomic,copy) NLImagePreviewDoneCallback doneCallback;
@property (nonatomic, retain) UIImage* img;

@end
