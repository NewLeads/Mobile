//
//  GridItem.h
//  NewLeads
//
//  Created by idevs.com on 27/06/2011.
//  Copyright 2011 idevs.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ModelContentItem;

@interface GridItem : UIView 
{
@protected
	//
	//
	BOOL isEnabled;
	BOOL isSelected;
	BOOL isHighlighted;
	//
	CGSize itemSize;
	CGSize contentSize;
}

@property (nonatomic, readwrite) BOOL isSelected;
@property (nonatomic, readwrite) BOOL isEnabled;
@property (nonatomic, readwrite) BOOL isHighlighted;

@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, assign) CGSize contentSize;


- (void) setupItem:(ModelContentItem *) anItem;

@end
