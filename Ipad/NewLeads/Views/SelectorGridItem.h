//
//  SelectorGridItem.h
//  NewLeads
//
//  Created by idevs.com on 28/06/2011.
//  Copyright 2011 idevs.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridItem.h"



@class ModelContentItem;

@interface SelectorGridItem : GridItem
{
@private
	//
	// Logic:
	BOOL		hidden;
	
	//
	// Selection:
	UIView			* viewSelection;
	
	//
	// Datasource:
	ModelContentItem * modelItem;
	
	
}

@property (nonatomic,  readwrite) BOOL		hidden;
@property (nonatomic, assign) ModelContentItem * modelItem;


+ (CGSize) sizeItem;
+ (CGSize) sizeContent;

@end
