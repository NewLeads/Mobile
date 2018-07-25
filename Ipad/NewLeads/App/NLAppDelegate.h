//
//  NLAppDelegate.h
//  NewLeads
//
//  Created by idevs.com on 27/06/2011.
//  Copyright 2011 idevs.com. All rights reserved.
//



@interface NLAppDelegate : UIResponder
<
	UIApplicationDelegate
>
//
// UI - XIB:
@property (nonatomic, retain) IBOutlet UIWindow * window;


+ (NLAppDelegate *) shared;

- (void) showAdmin;
- (void) showLeads;

- (void) logout;

@end

