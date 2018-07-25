//
//  UILabel+SizeCalc.m
//  
//
//  Created by idevs.com on 06/07/2014.
//  Copyright (c) 2014 CGMobile. All rights reserved.
//

#import "UILabel+SizeCalc.h"

@implementation UILabel (SizeCalc)

- (CGFloat) measureHeightOfContent
{
	if(!self.text.length)
	{
		return 0;
	}
#ifndef __IPHONE_7_0
	if( floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1 )
	{
#endif
		NSDictionary * stringAttributes = [NSDictionary dictionaryWithObject:self.font forKey: NSFontAttributeName];
		
		return ceilf(1.f + [self.text boundingRectWithSize:CGSizeMake(self.bounds.size.width, MAXFLOAT)
												   options:NSStringDrawingUsesLineFragmentOrigin
												attributes:stringAttributes
												   context:nil].size.height);
#ifndef __IPHONE_7_0
	}
	else
	{
		return [self.text sizeWithFont:self.font
					 constrainedToSize:CGSizeMake(self.bounds.size.width, MAXFLOAT)
						 lineBreakMode:NSLineBreakByWordWrapping].height;
	}
#endif
}

- (CGRect) fixHeight
{
	CGRect rcFrame		= self.frame;
	rcFrame.size.height	= 2 + [self measureHeightOfContent];
	self.frame			= rcFrame;
	
	return rcFrame;
}

@end
