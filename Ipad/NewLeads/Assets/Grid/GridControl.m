//
//  GridControl.m
//  NewLeads
//
//  Created by idevs.com on 08/06/2011.
//  Copyright 2011 idevs.com. All rights reserved.
//

#import "GridControl.h"
#import "GridItem.h"
//
#import <QuartzCore/QuartzCore.h>
#import "ModelContentItem.h"



#pragma mark -
#pragma mark Configuration
//
const CGFloat		kItemTopMargin		= 20.f;
const CGFloat		kItemLeftMargin		= 20.f;

const NSUInteger	itemsPerRow		= 2;




@interface GridControl ()

- (void) setup;

@end



@implementation GridControl

@synthesize ID, items;
@synthesize gridDataSource, gridDelegate, selectedIndex, isHorizontal, appearAnimated;
@synthesize isRibbonHor;


- (id) initWithFrame:(CGRect) frame 
{    
	if( nil != (self = [super initWithFrame:frame]) )
    {
		[self setup];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
	if( nil != (self = [super initWithCoder:aDecoder]) )
	{
		[self setup];
	}
	return self;	
}

- (void) dealloc 
{
	self.delegate	= nil;
	self.gridDataSource	= nil;
	self.gridDelegate = nil;
	
	[items release];
	
    [super dealloc];
}

- (void) setup
{
	self.multipleTouchEnabled = NO;
	self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;

	enableItems = YES;
	
	selectedIndex = NSNotFound;
	
	items = [[NSMutableArray alloc] init];
}

- (void) layoutSubviews
{
	[super layoutSubviews];
	
	//self.frame = self.superview.bounds;
	
//	self.layer.borderColor = [[UIColor whiteColor] CGColor];
//	self.layer.borderWidth = 1.f;
	//
	// Stupid control - should be changed to more sophisticated...
	//
	if( gridDataSource )
	{
		if( !isRibbonHor )
		{
			CGSize itemSize = [gridDataSource gridControl:self sizeForItemAtIndex: 0];
			
			NSUInteger idx	= 0;
			NSUInteger k		= itemsPerRow;
			CGFloat borderDX	= roundf(self.bounds.size.width/k)/2 - itemSize.width/2;
			CGFloat borderDY	= kItemTopMargin;
			CGFloat subStep		= roundf((self.bounds.size.width/k) - itemSize.width)/2;
			CGFloat stepW		= borderDX + itemSize.width + subStep;
			
			
			if (self.bounds.size.width > self.bounds.size.height) 
			{
				k += 1;
				borderDX	= roundf(self.bounds.size.width/k)/2 - itemSize.width/2;
				subStep		= roundf((self.bounds.size.width/k) - itemSize.width)/2;
				stepW		= borderDX + itemSize.width + subStep;
			}
			NSUInteger rows = (NSUInteger)ceilf((float)[items count] / (float)k);
			if (!rows) 
			{
				rows = 1;
			}
			if( isHorizontal )
			{
				[self setContentSize: CGSizeMake([items count] * (itemSize.width + 20.0) + 20.0, self.bounds.size.height)];
			}
			else
			{
				[self setContentSize: CGSizeMake(self.bounds.size.width, 2*borderDY + rows * itemSize.height)];
			}
		
			//[CATransaction begin];
			//[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
			if( appearAnimated )
			{
				[UIView beginAnimations:nil context:NULL];
				[UIView setAnimationDuration:0.3];
			}
			
			for (GridItem * aItem in items) 
			{
				//if (idx != selectedIndex) 
				{
					NSUInteger indexInRow = idx % k;
					NSUInteger row = idx / k;
					if( isHorizontal )
					{
						aItem.frame = CGRectMake(idx * itemSize.width,
												 self.bounds.size.height/2 - itemSize.height/2,
												 itemSize.width, itemSize.height);
					}
					else
					{
						aItem.frame = CGRectMake(borderDX + (indexInRow * stepW),
												 borderDY + row * itemSize.height,
												 itemSize.width, itemSize.height);
					}
				}		
				idx++;
			}
			//[CATransaction commit];
			if( appearAnimated )
			{
				[UIView setAnimationDelegate:self];
				[UIView commitAnimations];
			}
		}
		else
		{
			NSInteger idx = 0;
			NSInteger accumulatedWidth = 0;
			for (GridItem * aItem in items) 
			{
				CGSize itemSize = [gridDataSource gridControl:self sizeForItemAtIndex: idx];
				aItem.frame = CGRectMake(accumulatedWidth,
										 self.bounds.size.height/2 - itemSize.height/2,
										 itemSize.width, itemSize.height);
				accumulatedWidth += itemSize.width;
				idx++;
			}
			
			[self setContentSize:CGSizeMake(accumulatedWidth, self.bounds.size.height)];
		}
	}
}



#pragma mark -
#pragma mark Core logic
//
- (void) reloadData
{
	if( gridDataSource && [gridDataSource respondsToSelector:@selector(numberOfItemsInGridControl:)] )
	{
		selectedIndex = NSNotFound;
		
		for( GridItem * aItem in items )
		{
			[aItem removeFromSuperview];
		}
		[items removeAllObjects];
	
		NSUInteger count = [gridDataSource numberOfItemsInGridControl:self];
		for( NSUInteger idx = 0; idx < count; idx++ )
		{
			//CGSize itemSize = [gridDataSource gridControl:self sizeForItemAtIndex: idx];
			//GridItem * aItem = [[GridItem alloc] initWithFrame:CGRectMake(0.0, 0.0, itemSize.width, itemSize.height)];

			GridItem * aItem = [gridDataSource gridControl:self itemForControlAtIndex: idx];
			ModelContentItem * data = [gridDataSource gridControl: self dataForItemAtIndex: idx];
			[aItem setupItem: data];
			
			[items addObject: aItem];
			[self addSubview: aItem];
		}
		[self setNeedsLayout];
	}
}

- (void) enableItems:(BOOL) aFlag
{
	enableItems = aFlag;
	
	for(GridItem * aItem in items) 
	{
		aItem.isEnabled = aFlag;
	}
}

- (void) enableItem:(BOOL) aFlag atIndex:(NSUInteger) anIndex
{
	if( 0 == anIndex && anIndex < [items count] )
	{
		((GridItem*)[items objectAtIndex: anIndex]).isEnabled = aFlag;
	}
}

- (void) unSelectAll
{
	for(GridItem * aItem in items) 
	{
		aItem.isSelected = NO;
	}
}

- (void) unHighlightAll
{
	for(GridItem * aItem in items) 
	{
		aItem.isHighlighted = NO;
	}
}

- (void) hideAll:(BOOL) anFlag
{
	for(GridItem * aItem in items) 
	{
		aItem.hidden = anFlag;
	}
}



#pragma mark -
#pragma mark Private
//
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( !enableItems )
	{
		return;
	}

	UITouch * t = [touches anyObject];
	CGPoint location = [t locationInView: self];
	
	NSUInteger idx = 0;
	for(GridItem * aItem in items) 
	{
		if (CGRectContainsPoint(aItem.frame, location))
		{
			if( lastItem != aItem )
			{
				lastItem.isHighlighted = NO;
				
				selectedIndex = idx;
				lastItem = aItem;
				lastItem.isHighlighted = YES;
			}
			return;
		}
		idx++;
	}
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch * t = [touches anyObject];
	CGPoint location = [t locationInView: self];
	
	NSUInteger idx = 0;
	for(GridItem * aItem in items) 
	{
		if (CGRectContainsPoint(aItem.frame, location))
		{
			if( lastItem != aItem )
			{					
				lastItem.isHighlighted = NO;
				
				selectedIndex = idx;
				lastItem = aItem;
				lastItem.isHighlighted = YES;
			}					
			return;
		}
		idx++;
	}
	
	lastItem.isHighlighted = NO;
	lastItem = nil;
	selectedIndex = NSNotFound;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch * t = [touches anyObject];
	CGPoint location = [t locationInView: self];
	
	NSUInteger idx = 0;
	for(GridItem * aItem in items) 
	{
		if (CGRectContainsPoint(aItem.frame, location))
		{
			[self scrollRectToVisible:CGRectMake(aItem.frame.origin.x - 10.0, 
												 aItem.frame.origin.y - 10.0, 
												 aItem.frame.size.width + 20.0,
												 aItem.frame.size.height + 20.0)
							 animated:YES];
				
			lastItem.isHighlighted = NO;
			lastItem = nil;
			
			selectedIndex = idx;
			
			if( gridDelegate && [gridDelegate respondsToSelector:@selector(gridControl:didSelectItemAtIndex:withItem:)] )
			{
				[gridDelegate gridControl:self didSelectItemAtIndex:idx withItem: aItem];
			}
			return;
		}
		idx++;
	}
	
	lastItem.isHighlighted = NO;
	lastItem = nil;
	selectedIndex = NSNotFound;
}

@end
