//
//  GridItem.m
//  NewLeads
//
//  Created by idevs.com on 27/06/2011.
//  Copyright 2011 idevs.com. All rights reserved.
//

#import "GridItem.h"
#import "ModelContentItem.h"
#import <QuartzCore/QuartzCore.h>


@implementation GridItem

@synthesize isSelected, isEnabled, isHighlighted;
@synthesize contentSize, itemSize;


- (id) initWithFrame:(CGRect)frame 
{
    if( nil != (self = [super initWithFrame:frame]) )
    {
        // Initialization code.
    }
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

- (void) setupItem:(ModelContentItem *) anItem
{
//	[self addSubview:anItem.viewThumb];
//	self.layer.borderColor = [[UIColor greenColor] CGColor];
//	self.layer.borderWidth = 2;
}

@end
