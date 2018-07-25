//
//  NLSwitchCellView.m
//
//
//  Created by idevs.com on 22/07/2014.
//  Copyright (c) 2014 CGMobile. All rights reserved.
//

#import "NLSwitchCellView.h"



@interface NLSwitchCellView ()
//
// UI - XIB:
@property (nonatomic, readwrite, assign)	IBOutlet UILabel	* labelText;
@property (nonatomic, readwrite, assign)	IBOutlet UISwitch	* viewSwitch;
@property (nonatomic, readwrite, assign)	IBOutlet UIImageView* iconImageView;
//
// Logic:
@property (nonatomic, readwrite, retain) NSIndexPath * cellPath;
//
// Completions:
@property (nonatomic, readwrite, copy) NLCellSwitchAction completion;

@end



@implementation NLSwitchCellView

+ (NSString *) reuseID
{
	return @"SwitchCellID";
}

- (void)awakeFromNib
{
}



#pragma mark - Actions
//
- (IBAction) onChangeValue:(id)sender
{
	if( self.completion )
	{
		self.completion(self.viewSwitch.tag, self.cellPath, self.viewSwitch.isOn);
	}
}


#pragma mark - Core logic
//
- (void) setTAG:(NSInteger)TAG
{
	self.viewSwitch.tag = TAG;
}

- (void) setState:(BOOL)state
{
	self.viewSwitch.on = state;
}

- (void) setEnable:(BOOL)enable
{
	self.viewSwitch.enabled = enable;
}

- (void) setText:(NSString *)text
{
	self.labelText.text = text;
}

- (void) setIndexPath:(NSIndexPath *)indexPath
{
	self.cellPath = indexPath;
}

- (void) setupSwitchAction:(NLCellSwitchAction)switchAction
{
	self.completion = switchAction;
}

- (void) setIconImage:(UIImage*)iconImage
{
    self.iconImageView.image = iconImage;
}


@end
