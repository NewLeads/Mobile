//
//  NLSwitchCellView.h
//
//
//  Created by idevs.com on 22/07/2014.
//  Copyright (c) 2014 CGMobile. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^NLCellSwitchAction)(NSInteger tag, NSIndexPath * path, BOOL state);


@interface NLSwitchCellView : UITableViewCell

@property (nonatomic, readwrite, assign) NSInteger		TAG;
@property (nonatomic, readwrite, assign) BOOL			state;
@property (nonatomic, readwrite, assign) BOOL			enable;
@property (nonatomic, readwrite, copy) NSString			* text;
@property (nonatomic, readwrite, retain) NSIndexPath	* indexPath;


+ (NSString *) reuseID;

- (void) setupSwitchAction:(NLCellSwitchAction)switchAction;
- (void) setIconImage:(UIImage*)iconImage;

@end
