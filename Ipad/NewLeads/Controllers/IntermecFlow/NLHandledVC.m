//
//  NLHandledVC.m
//  NewLeads
//
//  Created by idevs.com on 24/12/2014.
//  Copyright (c) 2014 idevs.com. All rights reserved.
//

#import "NLHandledVC.h"

@interface NLHandledVC ()

@end



@implementation NLHandledVC

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.fieldHandledScanner becomeFirstResponder];
}



#pragma mark - Core logic
//
- (void) setupDataHandler:(HandledScannerDidReveivedData) anDataHandler
{
	self.dataHandler = anDataHandler;
}



#pragma mark - UITextFieldDelegate
//
- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
	// Do not show keyboard
	// See http://stackoverflow.com/a/8210944 for details
	//
	self.fieldHandledScanner.inputView = [[UIView alloc] initWithFrame:CGRectZero];
	
	return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
	NSLog(@"scantext: %@", self.fieldHandledScanner.text);
	
	NSString* new_text = (0 != textField.text.length ? textField.text : nil);
	if( new_text )
	{
		if( self.dataHandler )
		{
			self.dataHandler(self, new_text);
		}
	}
	
	textField.text = nil;
	
	return YES;
}

@end
