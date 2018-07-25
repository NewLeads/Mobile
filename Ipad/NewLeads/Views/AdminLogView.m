//
//  AdminLogView.m
//  NewLeads
//
//  Created by Karnyenka Andrew on 30/01/2012.
//  Copyright (c) 2012 idevs.com. All rights reserved.
//

#import "AdminLogView.h"

@implementation AdminLogView

@synthesize textView, btnClose;

- (id) initWithFrame:(CGRect)frame
{
	if( nil != (self = [super initWithFrame:frame] ))
	{
		
	}
	return self;
}

- (void) awakeFromNib
{
	[super awakeFromNib];
}

- (void) dealloc 
{
	self.textView = nil;
	self.btnClose = nil;
	
    [super dealloc];
}

@end
