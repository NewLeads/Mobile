//
//  GradientView.h
//  NewLeads
//
//  Created by idevs.com on 27/06/2011.
//  Copyright 2011 idevs.com. All rights reserved.
//

#import <UIKit/UIKit.h>


enum
{
	kLinearGradient = 0,
	kRadialGradient = 1
};


@interface GradientView : UIView 
{
@private
	BOOL	isInited;
	int		type;
	
	CGGradientRef	gradient;
}

@property(nonatomic, readwrite) int type;



- (void) setColorArray:(NSArray *) newColors;


@end
