//
//  AdminLogger.h
//  NewLeads
//
//  Created by Karnyenka Andrew on 30/01/2012.
//  Copyright (c) 2012 idevs.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AdminLogger : NSObject
{
@private
	//
	// Logic
	
	//
	// Data:
	NSMutableString * log;
}

- (void) log:(NSString*)message, ...;
- (void) flush;
//
- (NSString *) logContent;

@end
