//
//  ContentGridItem.m
//  NewLeads
//
//  Created by idevs.com on 28/06/2011.
//  Copyright 2011 idevs.com. All rights reserved.
//

#import "ContentGridItem.h"
#import "ModelContentItem.h"
#import "NLLeadsViewController.h"



#pragma mark -
#pragma mark Configuration
//
const CGSize	kContentGridItemSize_iPhone		= { 196,  161};
const CGSize	kContentGridContentSize_iPhone	= { 162,  133};
//
const CGSize	kContentGridItemSize_iPad		= { 315,  258};
const CGSize	kContentGridContentSize_iPad	= { 260,  213};
//
const NSInteger kContentGridThumbTAG	= 100;
const NSInteger kContentGridFavTAG		= 101;



@implementation ContentGridItem


@synthesize modelItem, parent;


+ (CGSize) sizeItem
{
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
	{
		return kContentGridItemSize_iPad;
	}
	else
	{
		return kContentGridItemSize_iPhone;
	}
}

+ (CGSize) sizeContent
{
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
	{
			return kContentGridContentSize_iPad;
	}
	else
	{
		return kContentGridContentSize_iPhone;
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
	if( favoritePopover )
	{
		[favoritePopover release];
		favoritePopover = nil;
	}
	
	[viewSelection removeFromSuperview];
	viewSelection = nil;
	
	self.modelItem = nil;
	//
	// Remove item fav state:
	[self setFavorite:NO];
	
    [super dealloc];
}

- (void) cleanup
{
	if(imageFavorite)
	{
		[imageFavorite removeFromSuperview];
		imageFavorite = nil;
	}
}


#pragma mark -
#pragma mark Core logic
//
- (void) longPress:(UILongPressGestureRecognizer*)sender 
{	
	if( isHighlighted && UIGestureRecognizerStateBegan == sender.state )
	{
		if( favoritePopover )
		{
			[favoritePopover release];
			favoritePopover = nil;
		}
		favoritePopover = [[UIActionSheet alloc] initWithTitle:@"Favorite" 
													  delegate:self 
											 cancelButtonTitle:nil
										destructiveButtonTitle:nil
											 otherButtonTitles:(modelItem.isFavorite ? @"Remove from Favorites" : @"Add to Favorites"), nil];
		
		favoritePopover.destructiveButtonIndex = 0;
		favoritePopover.actionSheetStyle = UIActionSheetStyleBlackOpaque;    

		[favoritePopover showFromRect:self.frame inView:self.superview animated:YES];
	}
}

- (void) setupItem:(ModelContentItem *) anItem
{
	//
	// Prepare item:
	modelItem = anItem;
	
	CGRect rc = anItem.viewThumb.frame;
	rc.origin.x = 6 + roundf([ContentGridItem sizeItem].width/2 - rc.size.width/2);
	rc.origin.y = 10 + roundf([ContentGridItem sizeItem].height/2 - rc.size.height/2);
	anItem.viewThumb.frame = rc;
//	if( kCGRFolder != anItem.itemBaseType )
//	{
//		anItem.viewThumb.layer.shadowOffset		= CGSizeMake(3.f, 3.f);
//		anItem.viewThumb.layer.shadowOpacity	= 0.7f;
//	}
	
	anItem.viewThumb.tag = kContentGridThumbTAG;
	[self addSubview:anItem.viewThumb];
	
	//
	// Prepare label:
	UILabel * labelTitle = [[UILabel alloc] initWithFrame: CGRectMake(10, 
																	  [ContentGridItem sizeItem].height - 20, 
																	  [ContentGridItem sizeItem].width - 25, 
																	  18)];
	labelTitle.textAlignment	= NSTextAlignmentCenter;
	labelTitle.lineBreakMode	= NSLineBreakByTruncatingTail;
	labelTitle.font				= [UIFont boldSystemFontOfSize:14];
	labelTitle.minimumScaleFactor	= 11.f/14.f;
	labelTitle.textColor		= [UIColor whiteColor];
//	labelTitle.backgroundColor	= [UIColor redColor];
	labelTitle.backgroundColor	= [UIColor clearColor];
	labelTitle.autoresizingMask	= UIViewAutoresizingFlexibleWidth;
	
	labelTitle.text = anItem.itemName;//anItem.itemFullName;
	
	[self addSubview: labelTitle];
	
	[labelTitle release];	
	
//	self.layer.borderColor = [[UIColor greenColor] CGColor];
//	self.layer.borderWidth = 2;
	
	[self setFavorite:modelItem.isFavorite];
	
	if( 0 == [[self gestureRecognizers] count] )
	{
		UILongPressGestureRecognizer * longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
		longPressGesture.delegate = self;
		[self addGestureRecognizer:longPressGesture];
		[longPressGesture release];
	}	
}	

- (void) setIsSelected:(BOOL) anFlag
{
	isSelected = anFlag;
	
	if( anFlag )
	{
		viewSelection = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"item_content_selection.png"]] autorelease];
		[self insertSubview: viewSelection atIndex: 0];
	}
	else
	{
		if( [favoritePopover isVisible] )
		{
			[favoritePopover dismissWithClickedButtonIndex:-1 animated:NO];
			[favoritePopover release];
			favoritePopover = nil;
		}
		
		[viewSelection removeFromSuperview];
		viewSelection = nil;
	}
}

- (void) setIsHighlighted:(BOOL) anFlag
{
	isHighlighted = anFlag;
	
	if( anFlag )
	{
		if( self.isSelected )
		{
			return;
		}		
		viewSelection = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"item_content_selection.png"]] autorelease];
		[self insertSubview: viewSelection atIndex: 0];
	}
	else
	{
		if( [favoritePopover isVisible] )
		{
			[favoritePopover dismissWithClickedButtonIndex:-1 animated:NO];
			[favoritePopover release];
			favoritePopover = nil;
		}
		
		[viewSelection removeFromSuperview];
		viewSelection = nil;
	}
}

- (void) setFavorite:(BOOL) anFlag
{
	if( anFlag )
	{
		UIImageView * thumb = (UIImageView *)[self viewWithTag:kContentGridThumbTAG];
		
		imageFavorite	=	[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-fav"]];
		CGRect rcFav	= imageFavorite.frame;
		rcFav.origin.x	= (thumb.frame.origin.x + thumb.frame.size.width) - 8 - rcFav.size.width;
		rcFav.origin.y	= thumb.frame.origin.y;
		imageFavorite.frame = rcFav;
		imageFavorite.tag	= kContentGridFavTAG;
		[self addSubview: imageFavorite];
	}
	else
	{
		[imageFavorite removeFromSuperview];
		imageFavorite = nil;
	}
	modelItem.isFavorite = anFlag;
}

#pragma mark - UIActionSheetDelegate
//
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if( 0 == buttonIndex )
	{
		//
		// Update model data:
		[self setFavorite: !modelItem.isFavorite];
			
		//
		// Update stat info:
		if( parent )
		{
			[parent.stat updateFavoriteForItem:modelItem];
		}
	}
}


#pragma mark - UIGestureRecognizerDelegate
//
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
	if( 0 < [NLContext shared].leadID )
	{
		return YES;
	}

	return NO;
}

@end
