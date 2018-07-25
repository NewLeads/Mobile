//
//  NLFieldCellView.h
//
//
//  Created by idevs.com on 06/07/2014.
//  Copyright (c) 2014 CGMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NLFieldCellView : UITableViewCell
//
// UI - XIB:
@property (nonatomic, readwrite, assign) IBOutlet UILabel		* labelTitle;
@property (nonatomic, readwrite, assign) IBOutlet UITextField * textField;

+ (NSString *) reuseID;

@end
