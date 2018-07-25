//
//  TabItem.m
//  NewLeads
//
//  Created by idevs.com on 27/09/2011.
//  Copyright 2011 idevs.com. All rights reserved.
//

#import "TabItem.h"
#import "ContentItem.h"



#pragma mark -
#pragma mark COnfiguration
// 
NSString * const kTIDescriptionKey	= @"description";
NSString * const kTIFolderKey		= @"folder";
NSString * const kTIFilesKey		= @"files";
NSString * const kTIFileKey			= @"file";
NSString * const kTITabIconKey		= @"icon";
NSString * const kTITabIDKey		= @"tabid";



@implementation TabItem

@synthesize isDownloadNeeded, tabID, tabDesc, tabFolder, tabIconFileName, tabItems;

- (id) init
{
	if( nil != (self = [super init]) )
	{
		self.isDownloadNeeded	= YES;
		self.tabDesc	= @"";
		self.tabID		= @"";
		self.tabFolder	= @"";
		self.tabIconFileName = @"";
		self.tabItems	= nil;
	}
	return self;
}

- (id) initWithDictionary:(NSDictionary *) dataSourceDict fromPlist:(BOOL) anFlag
{
	if( nil != (self = [super initWithDictionary:dataSourceDict fromPlist:anFlag]) )
	{
		NSAssert1( nil != dataSourceDict, @"%@ - \"initWithDictionary:\". Wrong or nil dataSource!", [self class]);
		
		self.isDownloadNeeded	= YES;
		self.tabDesc	= @"";
		self.tabID		= @"";
		self.tabFolder	= @"";
		self.tabIconFileName = @"";
		self.tabItems	= nil;
		
		[self extractTabFromDictionary: dataSourceDict fromPlist: anFlag];
	}
	return self;
}

- (void) dealloc
{
	self.isDownloadNeeded	= NO;
	self.tabID		= nil;
	self.tabDesc	= nil;
	self.tabFolder	= nil;
	self.tabItems	= nil;
	
	[super dealloc];
}



#pragma mark -
#pragma mark Core logic
//
- (void) extractTabFromDictionary:(NSDictionary *) dataSourceDict fromPlist:(BOOL) anFlag
{
	if( dataSourceDict && 0 != [dataSourceDict count] )
	{
		if( !anFlag )
		{
			self.tabDesc	= [self stringForKey: kTIDescriptionKey fromDic: dataSourceDict];
			self.tabFolder	= [self stringForKey: kTIFolderKey fromDic: dataSourceDict];
			self.tabID		= [self stringForKey: kTITabIDKey fromDic: dataSourceDict];
			self.tabIconFileName = [self stringForKey: kTITabIconKey fromDic: dataSourceDict];
			self.tabIconFileName = [self.tabIconFileName lastPathComponent];
			self.tabIconFileName = [self.tabIconFileName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

		}
		else
		{
			self.tabDesc	= [dataSourceDict valueForKey: kTIDescriptionKey];
			self.tabID		= [dataSourceDict valueForKey: kTITabIDKey];
			self.tabFolder	= [dataSourceDict valueForKey: kTIFolderKey];
			self.tabIconFileName = [dataSourceDict valueForKey: kTITabIconKey];
			self.tabIconFileName = [self.tabIconFileName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

		}
		[self extractTabItemsFromDictionary: dataSourceDict fromPlist: anFlag];
	}
}

- (void) extractTabItemsFromDictionary:(NSDictionary *) dataSourceDict fromPlist:(BOOL) anFlag
{
	if( dataSourceDict && 0 != [dataSourceDict count] )
	{
		if( !anFlag )
		{
			NSArray * tempDictArr = [dataSourceDict arrayOfNodesForName: kTIFilesKey];
			if( [tempDictArr  isKindOfClass:[NSArray class]] )
			{
				NSDictionary* tempDic		= [tempDictArr objectAtIndex: 0];
				NSArray		* tempFilesArr	= [tempDic arrayOfNodesForName: kTIFileKey];
				NSMutableArray * tempArr	= [[NSMutableArray alloc] initWithCapacity:[tempFilesArr count]];
				for( NSDictionary * dic in tempFilesArr )
				{
					ContentItem * item	= [[ContentItem alloc] initWithDictionary: dic fromPlist: anFlag];
					item.parent			= self;
					
					[tempArr addObject: item];
					[item release];
				}
				
				if( tempArr )
				{
					self.tabItems = [NSArray arrayWithArray: tempArr];
				}
				[tempArr release];
			}
		}
		else
		{
			NSArray * tempDictArr = [dataSourceDict valueForKey: kTIFilesKey];
			if( [tempDictArr  isKindOfClass:[NSArray class]] )
			{
				NSMutableArray * tempArr	= [[NSMutableArray alloc] init];
				for( NSDictionary * tempDic in tempDictArr )
				{
					NSDictionary * itemDic = [tempDic valueForKey: kTIFileKey];

					ContentItem * item	= [[ContentItem alloc] initWithDictionary: itemDic fromPlist: anFlag];
					item.parent			= self;
					
					[tempArr addObject: item];
					[item release];
				}
				
				if( tempArr )
				{
					self.tabItems = [NSArray arrayWithArray: tempArr];
				}
				[tempArr release];
			}
		}
	}
}

- (NSDictionary *) dictionaryRepresentation
{
	NSMutableDictionary * tempDic = [[NSMutableDictionary alloc] init];
	
	[tempDic setValue:tabDesc forKey:kTIDescriptionKey];
	[tempDic setValue:tabFolder forKey:kTIFolderKey];
	[tempDic setValue:tabID		forKey:kTITabIDKey];
	[tempDic setValue:tabIconFileName forKey:kTITabIconKey];
	
	
	NSMutableArray * tempArr = [[NSMutableArray alloc] init];
	for(ContentItem * c in tabItems)
	{
		[tempArr addObject:[NSDictionary dictionaryWithObject:[c dictionaryRepresentation] 
													   forKey:kTIFileKey]];
	}
	
	[tempDic setValue:tempArr forKey:kTIFilesKey];
	[tempArr release];
	
	return [tempDic autorelease];
}

- (void) removeItem:(ContentItem *) anItem
{
	if( [tabItems containsObject: anItem] )
	{
		NSMutableArray * mutableCopy = [tabItems mutableCopy];
		
		[mutableCopy removeObject: anItem];
		
		self.tabItems = [mutableCopy autorelease];
	}
}



#pragma mark -
#pragma mark NSObject
//
- (NSString *) description
{
	return [NSString stringWithFormat:@"%@:\nDescription: %@\nTabID: %@\nFolder: %@\nItems: %@\n", [self class], self.tabDesc, tabID, tabFolder, tabItems];
}

@end
