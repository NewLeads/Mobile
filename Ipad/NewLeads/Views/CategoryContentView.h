//
//  CategoryContentView.h
//  NewLeads
//
//  Created by idevs.com on 28/06/2011.
//  Copyright 2011 idevs.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridProtocols.h"



@class NLLeadsViewController;
@class GradientView;
@class ContentGridItem;

@interface CategoryContentView : UIView 
<
	GridControlDatasourceDelegate, 
	GridControlDelegate,
	UIWebViewDelegate,
	UIScrollViewDelegate
>
{
@private
	BOOL	webCleanup;
	//
	// UI:
	CGRect			rectContent;
	//
	// BG:
	//GradientView	* viewBG;
	//UIImageView		* viewBG;
	//
	// Toolbar staff:
	//GradientView	* viewToolbar;
	UIImageView		* viewToolbar;
	UILabel			* labelTitle;
	UIButton		* btnClose;
	UIButton		* btnPrev;
	UIButton		* btnNext;
	UIButton		* btnFavorite;
	
	//
	// Content view:
	NSInteger		currentItemIndex;
	ContentGridItem * currentItem;
	ContentGridItem * lastItem;
	UIView			* contentViewer;
	UIWebView		* contentItemViewer;
	//
	// Folder viewer:
	NSArray			* currendDataSource;
	GridControl		* currentFolder;
	
	NLLeadsViewController		* parent;
}

@property (nonatomic, assign) NLLeadsViewController * parent;

- (void) showContentFromView:(UIView *) anView;
- (void) showContentFromItem:(ContentGridItem *) anItem;
- (void) stop;
//
- (void) unSelectAll;
- (void) unHighlightAll;

@end
