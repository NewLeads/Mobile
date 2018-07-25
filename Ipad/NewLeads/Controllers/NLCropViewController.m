//
//  NLCropViewController.m
//  NewLeads
//
//  Created by idevs.com on 16/08/2013.
//  Copyright (c) 2013 idevs.com. All rights reserved.
//

#import "NLCropViewController.h"
//
// Assets:
#import "HFImageEditorFrameView.h"



@interface NLCropViewController ()

@property (nonatomic, readwrite, assign) IBOutlet UINavigationBar * navBar;
//

@end



@implementation NLCropViewController

- (void) viewDidLoad
{
	[super viewDidLoad];

	self.navBar.topItem.title	= @"Image Processing";
	self.navBar.topItem.leftBarButtonItem = [NLUtils buttonDoneWithTitle:@"Cancel" forTarget:self withAction:@selector(cancelAction:)];
	self.navBar.topItem.rightBarButtonItem = [NLUtils buttonDoneWithTitle:@"Save" forTarget:self withAction:@selector(doneAction:)];
}

- (BOOL)shouldAutorotate
{
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
	return (UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskPortraitUpsideDown);//UIInterfaceOrientationMaskPortraitUpsideDown;
}




- (void)startTransformHook
{
	self.navBar.topItem.leftBarButtonItem.enabled = NO;
	self.navBar.topItem.rightBarButtonItem.enabled = NO;
}

- (void)endTransformHook
{
	self.navBar.topItem.leftBarButtonItem.enabled = YES;
	self.navBar.topItem.rightBarButtonItem.enabled = YES;
}

@end
