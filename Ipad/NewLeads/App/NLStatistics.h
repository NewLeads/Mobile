//
//  NLStatistics.h
//  NewLeads
//
//  Created by idevs.com on 17/10/2011.
//  Copyright 2011 idevs.com. All rights reserved.
//



@class ModelContentItem;

@interface NLStatistics : NSObject 
{
@private
	//
	// Logic:
	BOOL		hasOpenedTour;
	BOOL		hasOpenCategory;
	BOOL		hasOpenDocument;
	NSString	* categoryName;
	NSString	* docFileDescription;
	NSString	* docFileName;
	NSString	* docTabID;
	NSDate		* startPeriod;
	
	//
	//
	
	//
	// Storage:
	NSMutableDictionary	* tourStorageDic;
	NSMutableArray	* docStorageArr;
	NSMutableSet	* docFavorites;
}

+ (void) enableDebug:(BOOL) anFlag;
//
- (void) startTour;
- (void) endTour;
- (void) startCategoryWithName:(NSString *) anName;
//- (void) startDocWithFileName:(NSString *) anName fileDescription:(NSString *) anDesc tabID:(NSString *) anTabID;
- (void) startDocWithItem:(ModelContentItem *) anItem;
- (void) endCurrentDocument;
- (void) endCurrentCategory;
- (void) updateFavoriteForItem:(ModelContentItem *) anItem;
//
//- (NSData *) statData;
- (NSString *) statDataString;

@end
