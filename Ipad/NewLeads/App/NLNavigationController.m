//
//  NLNavigationController.m
//
//  Created by idevs.com on 27/02/2014.
//  Copyright (c) 2013. All rights reserved.
//

#import "NLNavigationController.h"



@implementation NLNavigationController

- (BOOL) shouldAutorotate
{
	return [[self.viewControllers lastObject] shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations
{
	return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
	return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}

- (UIViewController *) rootController
{
	return (self.viewControllers && 0 != self.viewControllers.count ? self.viewControllers[0] : nil);
}

- (UIViewController *) topController
{
	return (self.viewControllers && 0 != self.viewControllers.count ? [[self.viewControllers lastObject] visibleViewController]: nil);
}

- (NSString *) debugDescription
{
	return [NSString stringWithFormat:@"\n%@, title: %@, parent: %@, current: %@, childs: %@\n",
			self,
			self.title,
			self.presentingViewController,
			self.presentedViewController,
			self.viewControllers];
}

@end
