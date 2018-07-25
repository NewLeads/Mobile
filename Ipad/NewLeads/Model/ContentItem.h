//
//  ContentItem.h
//  NewLeads
//
//  Created by idevs.com on 27/09/2011.
//  Copyright 2011 idevs.com. All rights reserved.
//

#import "ItemModel.h"



@class TabItem;

@interface ContentItem : ItemModel
{
@private
	//
	// Logic:
	BOOL		isLocal;
	
	//
	// Parent:
	TabItem		* parent;
	
	//
	// Model:
	NSString	* contentDesc;
	NSString	* contentFileDesc;
	NSString	* contentFileName;
}

@property (nonatomic, readwrite, assign) BOOL		isLocal;
@property (nonatomic, readwrite, assign) TabItem	* parent;
@property (nonatomic, readwrite, copy) NSString	* contentDesc;
@property (nonatomic, readwrite, copy) NSString	* contentFileDesc;
@property (nonatomic, readwrite, copy) NSString	* contentFileName;


- (void) extractContentFromDictionary:(NSDictionary *) dataSourceDict fromPlist:(BOOL) anFlag;

@end
