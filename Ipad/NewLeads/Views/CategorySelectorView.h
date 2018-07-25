//
//  CategorySelectorView.h
//  NewLeads
//
//  Created by idevs.com on 27/06/2011.
//  Copyright 2011 idevs.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridProtocols.h"


@class GradientView;
@class GridControl;

@interface CategorySelectorView : UIView < UIScrollViewDelegate >
{
@private
	BOOL					isInited;
	
	NSUInteger				oldSelection;
	//
	// UI:
	//
	// BG:
	//GradientView			* viewBG;
	UIImageView				* viewBG;
}

@property (nonatomic, readonly) GridControl	* controlGrid;
@property (nonatomic, readonly) UIButton * btnBusinessCard;
@property (nonatomic, readonly) UIButton * btnIntermec;
@property (nonatomic, readonly) UIButton * btnBarCode;

- (void) startTour:(BOOL) aFlag;
- (void) enableTabs:(BOOL) aFlag;
- (void) selectTab:(BOOL) anFlag atIndex:(NSInteger) anIndex;
- (void) unSelectAll;
- (void) unHighlightAll;
- (void) hideAll:(BOOL) anFlag;
//
- (void) enableButtonTour:(BOOL) anFlag;
- (void) setAnonymousMode;
- (void) setLeadMode;
- (void) setRestartMode;
- (void) setScannerLabelText:(NSString *) anText;

- (void) resetInit;

- (void) hideSettings;
- (void) refreshScanButtons;

@end
