//
//  UILabel+SizeCalc.h
//  
//
//  Created by idevs.com on 06/07/2014.
//  Copyright (c) 2014 CGMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (SizeCalc)

- (CGFloat) measureHeightOfContent;
- (CGRect) fixHeight;

@end
