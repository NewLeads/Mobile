//
//  GridControl.h
//  NewLeads
//
//  Created by idevs.com on 08/06/2011.
//  Copyright 2011 idevs.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridProtocols.h"



@interface GridControl : UIScrollView
{
@protected
	BOOL	appearAnimated;
	BOOL	enableItems;
	int		ID;
	
	//
	// Selection:
	NSUInteger		previousIndex;
	NSUInteger		selectedIndex;
	GridItem		* lastItem;
	
	
	//
	//
	NSMutableArray	* items;
	
	//
	// Delegate:
	id <GridControlDatasourceDelegate>	gridDataSource;
	id <GridControlDelegate>			gridDelegate;
    
	BOOL isHorizontal;
	BOOL isRibbonHor;
}

@property (nonatomic, readwrite) int ID;
@property (nonatomic, readwrite) BOOL isHorizontal;
@property (nonatomic, readwrite) BOOL isRibbonHor;
@property (nonatomic, readwrite) BOOL	appearAnimated;
@property (nonatomic, assign)	id<GridControlDatasourceDelegate>	gridDataSource;
@property (nonatomic, assign)	id<GridControlDelegate>				gridDelegate;
@property (nonatomic, readonly)	NSUInteger							selectedIndex;
@property (nonatomic, readonly)	NSArray	* items;


- (void) reloadData;
- (void) enableItems:(BOOL) aFlag;
- (void) enableItem:(BOOL) aFlag atIndex:(NSUInteger) anIndex;
- (void) unSelectAll;
- (void) unHighlightAll;
- (void) hideAll:(BOOL) anFlag;

@end
