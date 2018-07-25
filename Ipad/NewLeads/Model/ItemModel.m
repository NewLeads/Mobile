//
//  ItemModel.m
//  NewLeads
//
//  Created by idevs.com on 27/09/2011.
//  Copyright 2011 idevs.com. All rights reserved.
//

#import "ItemModel.h"


@implementation ItemModel

@synthesize image;


- (id) init
{
	if( nil != (self = [super init]) )
	{
	}
	
	return self;
	
	//NSAssert1(0, @"%@ - \"init\". You should use \"initWithDictionary:\" to create object!", [self class]);
	//return nil;
}

- (id) initWithDictionary:(NSDictionary *) dataSourceDict fromPlist:(BOOL) anFlag
{
	if( nil != (self = [super init]) )
	{
	}
	return self;
}

- (void) dealloc
{
	self.image = nil;
	
	[super dealloc];
}



#pragma mark -
#pragma mark Core logic
//
- (void) setImage:(UIImage *)anImage
{
	if( image )
	{
		[image release];
		image = nil;
	}
	if( nil != anImage )
	{
		image = [anImage retain];
	}
}

- (NSString *) stringForKey:(NSString *) anKey fromDic:(NSDictionary *) anDic
{
	NSString * value = [anDic stringForName: anKey];
	
	return (value == (id)[NSNull null] ? @"" : (value == nil ? @"" : value));
}

- (int) intForKey:(NSString *) anKey fromDic:(NSDictionary *) anDic
{
	BOOL success = NO;
	int value = [anDic intForName:anKey success: &success];
	
	if( success )
	{		
		return value;
	}
	
	return 0;
}

//
- (NSDictionary *) dictionaryRepresentation
{
	return nil;
}

@end
