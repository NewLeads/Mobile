//
//  NLImagePreviewViewController.m
//  NewLeads
//
//  Created by Arseniy Astapenko on 8/26/13.
//  Copyright (c) 2013 idevs.com. All rights reserved.
//

#import "NLImagePreviewViewController.h"

@interface NLImagePreviewViewController ()
@property (nonatomic, assign) IBOutlet UIImageView* preview;

- (IBAction) onButtonCancel;
- (IBAction) onButtonSend;
@end



@implementation NLImagePreviewViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) dealloc
{
    self.img = nil;
    self.doneCallback = nil;
    [super dealloc];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.preview.image = self.img;
}

- (void) viewWillLayoutSubviews
{
    CGRect r = self.view.bounds;
    self.preview.center = CGPointMake(r.size.width/2, r.size.height/2);
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void) viewDidUnload
{
    [super viewDidUnload];
    self.img = nil;
}



#pragma mark - Actions
//
- (IBAction) onButtonCancel
{
    if (self.doneCallback)
    {
        self.doneCallback(nil, YES);
    }
    
}

- (IBAction) onButtonSend
{
    if (self.doneCallback)
    {
        self.doneCallback(self.preview.image, NO);
    }
}

@end
