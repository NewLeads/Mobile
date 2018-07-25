//
//  NLFieldCellView.m
//
//
//  Created by idevs.com on 06/07/2014.
//  Copyright (c) 2014 CGMobile. All rights reserved.
//

#import "NLFieldCellView.h"



@implementation NLFieldCellView

+ (NSString *) reuseID
{
	return @"TextFieldCellID";
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
