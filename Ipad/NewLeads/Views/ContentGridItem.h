//
//  ContentGridItem.h
//  NewLeads
//
//  Created by idevs.com on 28/06/2011.
//  Copyright 2011 idevs.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridItem.h"



@class ModelContentItem;
@class NLLeadsViewController;

@interface ContentGridItem : GridItem 
<
	UIActionSheetDelegate,
	UIGestureRecognizerDelegate
>
{
@private
	//
	// Logic:
	UIActionSheet * favoritePopover;
	
	//
	//
	id	target;
	SEL selector;
	//
	// Selection:
	UIView			* viewSelection;
	
	//
	// Datasource:
	ModelContentItem * modelItem;
	
	//
	// UI:
	UIImageView		* imageFavorite;
	
	NLLeadsViewController		* parent;
}

@property (nonatomic, assign) ModelContentItem * modelItem;
@property (nonatomic, assign) NLLeadsViewController		* parent;

+ (CGSize) sizeItem;
+ (CGSize) sizeContent;

- (void) setFavorite:(BOOL) anFlag;
- (void) cleanup;

@end
