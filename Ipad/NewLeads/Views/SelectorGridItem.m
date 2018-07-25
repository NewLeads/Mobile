//
//  SelectorGridItem.m
//  NewLeads
//
//  Created by idevs.com on 28/06/2011.
//  Copyright 2011 idevs.com. All rights reserved.
//

#import "SelectorGridItem.h"
#import "ModelContentItem.h"
#import <QuartzCore/QuartzCore.h>



#pragma mark -
#pragma mark Configuration
//
CGSize		kSelectorGridItemSize_iPhone	= { 0,  48};
CGSize		kSelectorGridContentSize_iPhone	= { 0,  48};
CGSize		kSelectorGridItemSize_iPad		= { 0,  77};
CGSize		kSelectorGridContentSize_iPad	= { 0,  77};
//
NSInteger	kSGSideMargin_iPhone			= 1;
NSInteger	kSGTopMargin_iPhone				= 1;
NSInteger	kSGSideMargin_iPad				= 2;
NSInteger	kSGTopMargin_iPad				= 2;




@implementation SelectorGridItem

@synthesize hidden;
@synthesize modelItem;


+ (CGSize) sizeItem
{
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
	{
		return kSelectorGridItemSize_iPad;
	}
	else
	{
		return kSelectorGridItemSize_iPhone;
	}
}

+ (CGSize) sizeContent
{
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
	{
		return kSelectorGridContentSize_iPad;
	}
	else
	{
		return kSelectorGridContentSize_iPhone;
	}
}

- (id) initWithFrame:(CGRect)frame
{
    if( nil != (self = [super initWithFrame:frame]) )
	{
    }
    return self;
}

- (void) dealloc
{
	[viewSelection removeFromSuperview];
	viewSelection = nil;
	
    [super dealloc];
}



#pragma mark -
#pragma mark Core logic
//
- (void) setupItem:(ModelContentItem *) anItem
{
	NSInteger kSGSideMargin = 0;
	NSInteger kSGTopMargin = 0;
	
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
	{
		kSGSideMargin	= kSGSideMargin_iPad;
		kSGTopMargin	= kSGTopMargin_iPad;
	}
	else
	{
		kSGSideMargin	= kSGSideMargin_iPhone;
		kSGTopMargin	= kSGTopMargin_iPhone;
	}
	
	//
	// Prepare item:
	modelItem = anItem;
	
	CGRect rc	= anItem.viewThumb.frame;
	itemSize	= CGSizeMake(rc.size.width + 4*kSGSideMargin, [SelectorGridItem sizeContent].height);
	contentSize = CGSizeMake(rc.size.width + 2*kSGSideMargin, [SelectorGridItem sizeContent].height);
	
	rc.origin	= CGPointMake(contentSize.width/2 - rc.size.width/2,
							  kSGTopMargin);
	anItem.viewThumb.frame = rc;

	[self addSubview:anItem.viewThumb];
	
	rc			= self.frame;
	rc.size		= itemSize;
	self.frame	= rc;
	
	//
	// Prepare label:
	UILabel * labelTitle = [[UILabel alloc] initWithFrame: CGRectMake(kSGSideMargin, 
																	  itemSize.height - 20, 
																	  contentSize.width - kSGSideMargin, 
																	  18)];
	labelTitle.textAlignment	= NSTextAlignmentCenter;
	labelTitle.lineBreakMode	= NSLineBreakByTruncatingTail;
	labelTitle.font				= [UIFont boldSystemFontOfSize:14];
	labelTitle.minimumScaleFactor	= 11.f/14.f;
	labelTitle.textColor		= [UIColor whiteColor];
//	labelTitle.backgroundColor	= [UIColor redColor];
	labelTitle.backgroundColor	= [UIColor clearColor];
	labelTitle.autoresizingMask	= UIViewAutoresizingNone;
	
	labelTitle.text = anItem.itemName;
	
	[self addSubview: labelTitle];
	
	[labelTitle release];
	
//	self.layer.borderColor = [[UIColor greenColor] CGColor];
//	self.layer.borderWidth = 2;

	[self layoutSubviews];
}

- (void) setHidden:(BOOL) anFlag
{
	if( isSelected )
	{
		viewSelection.hidden = anFlag;
	}
	[super setHidden: anFlag];
}

- (void) setIsEnabled:(BOOL) anFlag
{
	if( !anFlag )
	{
		for( UIView * v in self.subviews )
		{
			v.alpha = 0.2;
		}
	}
	else
	{
		for( UIView * v in self.subviews )
		{
			v.alpha = 1.0;
		}
	}
}

- (void) setIsSelected:(BOOL) anFlag
{
	isSelected = anFlag;
	if( anFlag )
	{
		UIImage * ribbon = nil;
		if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
		{
			ribbon = [NLUtils  stretchedImageNamed:@"item-cat-selection" width:CGRectMake(0, 3, 0, 0)];
		}
		else
		{
			ribbon = [NLUtils  stretchedImageNamed:@"item-cat-selection" width:CGRectMake(0, 2, 0, 0)];
		}

		viewSelection = [[[UIImageView alloc] initWithImage: ribbon] autorelease];
		viewSelection.frame = CGRectMake(0, 0, contentSize.width, contentSize.height);
		viewSelection.backgroundColor = [UIColor clearColor];

		[self insertSubview: viewSelection atIndex: 0];
	}
	else
	{
		[viewSelection removeFromSuperview];
		viewSelection = nil;
	}
}

- (void) setIsHighlighted:(BOOL) anFlag
{
	isHighlighted = anFlag;
	
	if( anFlag )
	{
		if( isSelected )
		{
			return;
		}
		self.layer.backgroundColor = [[UIColor lightGrayColor] CGColor];
		self.layer.cornerRadius= 10;
	}
	else
	{
		self.layer.backgroundColor = [[UIColor clearColor] CGColor];
		self.layer.cornerRadius= 0;
	}
}


@end
