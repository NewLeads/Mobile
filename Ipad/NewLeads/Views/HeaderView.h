//
//  HeaderView.h
//  NewLeads
//
//  Created by idevs.com on 27/06/2011.
//  Copyright 2011 idevs.com. All rights reserved.
//

#import <UIKit/UIKit.h>



@class GradientView;

@interface HeaderView : UIView 

@property (nonatomic, readwrite, copy) NSString * title;


- (void) updateLeftLogoImage:(UIImage *) anImage;

@end
