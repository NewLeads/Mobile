//
//  ContentItem.m
//  NewLeads
//
//  Created by idevs.com on 27/09/2011.
//  Copyright 2011 idevs.com. All rights reserved.
//

#import "ContentItem.h"



#pragma mark -
#pragma mark COnfiguration
//
NSString * const kCIDescriptionKey	= @"description";
NSString * const kCIFileDescriptionKey	= @"filedescription";
NSString * const kCIFileNameKey		= @"filename";



@implementation ContentItem

@synthesize isLocal, parent;
@synthesize contentDesc, contentFileDesc, contentFileName;

- (id) init
{
	if( nil != (self = [super init]) )
	{
		self.isLocal		= NO;
		self.parent			= nil;
		self.contentDesc	= @"";
		self.contentFileDesc= @"";
		self.contentFileName= @"";
	}
	return self;
}

- (id) initWithDictionary:(NSDictionary *) dataSourceDict fromPlist:(BOOL) anFlag
{
	if( nil != (self = [super initWithDictionary:dataSourceDict fromPlist:anFlag]) )
	{
		NSAssert1( nil != dataSourceDict, @"%@ - \"initWithDictionary:\". Wrong or nil dataSource!", [self class]);
		
		[self extractContentFromDictionary: dataSourceDict fromPlist: anFlag];
	}
	return self;
}

- (void) dealloc
{
	self.isLocal		= NO;
	self.parent			= nil;
	self.contentDesc	= nil;
	self.contentFileDesc= nil;
	self.contentFileName= nil;
	
	[super dealloc];
}



#pragma mark -
#pragma mark Core logic
//
- (void) extractContentFromDictionary:(NSDictionary *) dataSourceDict fromPlist:(BOOL) anFlag
{
	if( dataSourceDict && 0 != [dataSourceDict count] )
	{
		if( !anFlag )
		{
			self.contentDesc	= [self stringForKey: kCIDescriptionKey fromDic: dataSourceDict];
			self.contentFileDesc= [self stringForKey: kCIFileDescriptionKey fromDic: dataSourceDict];
			self.contentFileName= [self stringForKey: kCIFileNameKey fromDic: dataSourceDict];
			self.contentFileName= [self.contentFileName lastPathComponent];
			self.contentFileName = [self.contentFileName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		}
		else
		{
			self.contentDesc	= [dataSourceDict valueForKey: kCIDescriptionKey];
			self.contentFileDesc= [dataSourceDict valueForKey: kCIFileDescriptionKey];
			self.contentFileName= [dataSourceDict valueForKey: kCIFileNameKey];
			self.contentFileName = [self.contentFileName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		}
	}
}

- (NSDictionary *) dictionaryRepresentation
{
	NSMutableDictionary * tempDic = [[NSMutableDictionary alloc] init];
	
	[tempDic setValue:contentDesc forKey:kCIDescriptionKey];
	[tempDic setValue:contentFileDesc forKey:kCIFileDescriptionKey];
	[tempDic setValue:contentFileName forKey:kCIFileNameKey];
	
	return [tempDic autorelease];
}


#pragma mark -
#pragma mark NSObject
//
- (NSString *) description
{
	return [NSString stringWithFormat:@"%@:\nisLocal:%d\nDescription: %@\nFileDescription: %@\nFilename: %@\n", 
			[self class], 
			self.isLocal, 
			self.contentDesc, 
			self.contentFileDesc, 
			self.contentFileName];
}

@end
