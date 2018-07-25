//
//  TabItem.h
//  NewLeads
//
//  Created by idevs.com on 27/09/2011.
//  Copyright 2011 idevs.com. All rights reserved.
//

#import "ItemModel.h"



@class ContentItem;

@interface TabItem : ItemModel
{
@private
	//
	// Logic:
	BOOL		isDownloadNeeded;
	
	//
	//
	NSString	* tabDesc;
	NSString	* tabFolder;
	NSString	* tabIconFileName;
	NSString	* tabID;
	NSArray		* tabItems;
}

@property (nonatomic, readwrite, assign) BOOL		isDownloadNeeded;
@property (nonatomic, readwrite, copy) NSString	* tabDesc;
@property (nonatomic, readwrite, copy) NSString	* tabID;
@property (nonatomic, readwrite, copy) NSString	* tabFolder;
@property (nonatomic, readwrite, copy) NSString	* tabIconFileName;
@property (nonatomic, readwrite, retain) NSArray	* tabItems;


- (void) extractTabFromDictionary:(NSDictionary *) dataSourceDict fromPlist:(BOOL) anFlag;
- (void) extractTabItemsFromDictionary:(NSDictionary *) dataSourceDict fromPlist:(BOOL) anFlag;

- (void) removeItem:(ContentItem *) anItem;

@end
