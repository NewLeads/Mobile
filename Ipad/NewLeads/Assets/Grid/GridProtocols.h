//
//  GridProtocols.h
//  NewLeads
//
//  Created by idevs.com on 08/06/2011.
//  Copyright 2011 idevs.com. All rights reserved.
//



@class GridControl;
@class GridItem;
@class ModelContentItem;

@protocol GridControlDatasourceDelegate <NSObject>

@required
//
// Datasource
- (NSInteger)			numberOfItemsInGridControl:(GridControl *) inControl;
- (CGSize)				gridControl:(GridControl *) inControl sizeForItemAtIndex:(NSUInteger) inIndex;
- (GridItem *)			gridControl:(GridControl *) inControl itemForControlAtIndex:(NSUInteger) inIndex;
- (ModelContentItem *)	gridControl:(GridControl *) inControl dataForItemAtIndex:(NSUInteger) inIndex;
@end

@protocol GridControlDelegate <NSObject>

@optional
//
// Selection
- (void)			gridControl:(GridControl *) inControl didSelectItemAtIndex:(NSUInteger) inIndex withItem:(GridItem *) inItem;

@end
