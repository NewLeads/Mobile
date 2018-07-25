//
//  NLButtonCellView.h
//
//
//  Created by idevs.com on 06/07/2014.
//  Copyright (c) 2014 CGMobile. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^NLCellButtonAction)(UIButton * button);


@interface NLButtonCellView : UITableViewCell
//
// UI - XIB:
@property (nonatomic, readwrite, assign) IBOutlet UIButton * btnAction;

+ (NSString *) reuseID;
+ (CGFloat) cellHeight;

- (void) setupCompletion:(NLCellButtonAction) anCompletion;

@end
