//
//  NLButtonCellView.m
//
//
//  Created by idevs.com on 06/07/2014.
//  Copyright (c) 2014 CGMobile. All rights reserved.
//

#import "NLButtonCellView.h"



@interface NLButtonCellView ()
//
// Completions:
@property (nonatomic, readwrite, copy) NLCellButtonAction completion;

@end



@implementation NLButtonCellView

+ (NSString *) reuseID
{
	return @"ActionButtonCellID";
}

+ (CGFloat) cellHeight
{
	return 44.f;
}

- (void)awakeFromNib
{
	[self.btnAction addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Actions
//
- (void) onButton:(id)sender
{
	if( self.completion )
	{
		self.completion((UIButton *) sender);
	}
}



#pragma mark - Core logic
//
- (void) setupCompletion:(NLCellButtonAction) anCompletion
{
	self.completion = anCompletion;
}

@end
