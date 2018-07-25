//
//  LogoItem.m
//  NewLeads
//
//  Created by Karnyenka Andrew on 14/12/2011.
//  Copyright (c) 2011 idevs.com. All rights reserved.
//

#import "LogoItem.h"



#pragma mark -
#pragma mark COnfiguration
// 
NSString * const kTILogoKey			= @"logo";


@implementation LogoItem

@synthesize logoFileName;

- (id) init
{
	if( nil != (self = [super init]) )
	{
		self.logoFileName = @"";
	}
	return self;
}

- (id) initWithDictionary:(NSDictionary *) dataSourceDict fromPlist:(BOOL) anFlag
{
	if( nil != (self = [super initWithDictionary:dataSourceDict fromPlist:anFlag]) )
	{
		NSAssert1( nil != dataSourceDict, @"%@ - \"initWithDictionary:\". Wrong or nil dataSource!", [self class]);
		
		[self extractLogoFromDictionary: dataSourceDict fromPlist: anFlag];
	}
	return self;
}

- (void) dealloc
{
	self.logoFileName = nil;
	
	[super dealloc];
}



#pragma mark -
#pragma mark Core logic
//
- (void) extractLogoFromDictionary:(NSDictionary *) dataSourceDict fromPlist:(BOOL) anFlag
{
	if( dataSourceDict && 0 != [dataSourceDict count] )
	{
		if( !anFlag )
		{
			NSString * path		= [self stringForKey: kTILogoKey fromDic: dataSourceDict];
			self.logoFileName	= [path lastPathComponent];
			self.logoFileName = [self.logoFileName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		}
		else
		{
			self.logoFileName	= [dataSourceDict valueForKey: kTILogoKey];
			self.logoFileName = [self.logoFileName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		}
	}
}

@end
