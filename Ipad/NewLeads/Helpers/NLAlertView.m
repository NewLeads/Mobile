//
//  NLAlertView.m
//
//
//  Created by Karnyenka Andrew on 18/09/2012.
//  Copyright (c) 2012 All rights reserved.
//

#import "NLAlertView.h"



@interface NLAlertView () <UIAlertViewDelegate>

@property (nonatomic, copy) NLAlertViewBlock block;

@end



@implementation NLAlertView

- (void) dealloc
{
	self.block = nil;
}

+ (void) show:(NSString*)title message:(NSString*)message buttons:(NSArray *)buttons block:(NLAlertViewBlock)block
{
	dispatch_async(dispatch_get_main_queue(), ^(void)
	{
		if( IOS8_OR_HIGHER )
		{
			UIAlertController * alert = [UIAlertController alertControllerWithTitle:title
																			message:message
																	 preferredStyle:UIAlertControllerStyleAlert];
			
			void (^UIAlertActionHandler)(UIAlertAction * action) = ^(UIAlertAction * action)
			{
				if( block )
				{
					NSInteger idx = NSNotFound;
					
					if( 0 != buttons.count )
					{
						idx = [buttons indexOfObject:action.title];
					}
					
					block(nil, idx);
				}
			};
			
			for( NSString * s in buttons )
			{
				UIAlertAction * defaultAction = [UIAlertAction actionWithTitle:s
																		 style:UIAlertActionStyleDefault
																	   handler:UIAlertActionHandler];
			
				[alert addAction:defaultAction];
			}
			
			UIWindow * window = [UIApplication sharedApplication].keyWindow;
			
			UIViewController * visibleVC = (window.rootViewController.presentedViewController ? window.rootViewController.presentedViewController : window.rootViewController);
			
			[visibleVC presentViewController:alert animated:YES completion:nil];
		}
		else
		{
			NLAlertView *alert = [[NLAlertView alloc] initWithTitle:title
															message:message
														   delegate:nil
												  cancelButtonTitle:[buttons objectAtIndex:0]
												  otherButtonTitles:nil];
			
			int counter = 0;
			for( NSString * s in buttons )
			{
				if( 0 == counter++ )
					continue;
				
				[alert addButtonWithTitle: s];
			}
			
			alert.delegate = alert;
			alert.block = block;
			
			[alert show];
		}
	});
}

+ (void) show:(NSString*)title message:(NSString*)message
{
	[NLAlertView show:title message:message buttons:[NSArray arrayWithObject:@"OK"] block:nil];
}

+ (void) showError:(NSString*)message
{
	[NLAlertView show:@"Error" message:message];
}



#pragma mark - UIAlertViewDelegate
//
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(self.block)
	{
		self.block(self, buttonIndex);
	}
}

@end



@interface NLPasswordAlertView ()
<
	UITextFieldDelegate
>

//
// UI:
@property (nonatomic, readwrite, assign) UITextField * textPassword;
//
//
@property (nonatomic, readwrite, copy) NLPasswordAlertViewBlock passAlertBlock;


@end



@implementation NLPasswordAlertView

+ (void) show:(NSString*)title message:(NSString*)message buttons:(NSArray *)buttons block:(NLPasswordAlertViewBlock)block
{
	dispatch_async(dispatch_get_main_queue(), ^(void)
	{
		if( IOS8_OR_HIGHER )
		{
			UIAlertController * alert = [UIAlertController alertControllerWithTitle:title
																			message:message
																	 preferredStyle:UIAlertControllerStyleAlert];
			
			void (^UIAlertActionHandler)(UIAlertAction * action) = ^(UIAlertAction * action)
			{
				if( block )
				{
					NSString * text = [[alert.textFields firstObject] text];
					
					NSInteger idx = NSNotFound;
					
					if( 0 != buttons.count )
					{
						idx = [buttons indexOfObject:action.title];
					}
					
					block(nil, text, idx);
				}
			};
			
			[alert addTextFieldWithConfigurationHandler:^(UITextField *textField)
			{
				textField.secureTextEntry = YES;
			}];
			
			for( NSString * s in buttons )
			{
				UIAlertAction * defaultAction = [UIAlertAction actionWithTitle:s
																		 style:UIAlertActionStyleDefault
																	   handler:UIAlertActionHandler];
				
				[alert addAction:defaultAction];
			}
			
			UIWindow * window = [UIApplication sharedApplication].keyWindow;
			
			UIViewController * visibleVC = (window.rootViewController.presentedViewController ? window.rootViewController.presentedViewController : window.rootViewController);
			
			[visibleVC presentViewController:alert animated:YES completion:nil];
		}
		else
		{
			NLPasswordAlertView *alert = [[NLPasswordAlertView alloc] initWithTitle:title
																			message:message
																		   delegate:nil
																  cancelButtonTitle:[buttons objectAtIndex:0]
																  otherButtonTitles:nil];
			
			int counter = 0;
			for( NSString * s in buttons )
			{
				if( 0 == counter++ )
					continue;
				
				[alert addButtonWithTitle: s];
			}
			
			alert.delegate			= alert;
			alert.alertViewStyle	= UIAlertViewStyleSecureTextInput;
			alert.passAlertBlock	= block;
			
			[alert show];
		}
	});
}


#pragma mark - UIAlertViewDelegate
//
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(self.passAlertBlock)
	{
		self.textPassword = [self textFieldAtIndex:0];
		
		self.passAlertBlock(self, self.textPassword.text, buttonIndex);
	}
}
@end
