//
//  NLStatistics.m
//  NewLeads
//
//  Created by idevs.com on 17/10/2011.
//  Copyright 2011 idevs.com. All rights reserved.
//

#import "NLStatistics.h"
#import "ModelContentItem.h"



#pragma mark -
#pragma mark Configuration
//
NSString * const kStatTourRootKey		= @"tour_information";
NSString * const kStatTourDateKey		= @"date";
NSString * const kStatTourStartTimeKey	= @"start_time";
NSString * const kStatTourEndTimeKey	= @"end_time";
NSString * const kStatRootKey			= @"documents_viewed";
NSString * const kStatItemKey			= @"file";
NSString * const kStatItemDescKey		= @"description";
NSString * const kStatItemFileDescKey	= @"filedescription";
NSString * const kStatItemFilenameKey	= @"filename";
NSString * const kStatItemTabIDKey		= @"tabid";
NSString * const kStatItemTimeKey		= @"time";
//
NSString * const kStatItemFavoritedKey	= @"favorites";
//
static BOOL debugEnabled				= NO;



@interface NLStatistics ()

@property (nonatomic, readwrite, assign)	BOOL		hasOpenCategory;
@property (nonatomic, readwrite, assign)	BOOL		hasOpenDocument;
@property (nonatomic, readwrite, copy)		NSString	* categoryName;
@property (nonatomic, readwrite, copy)		NSString	* docFileDescription;
@property (nonatomic, readwrite, copy)		NSString	* docFileName;
@property (nonatomic, readwrite, copy)		NSString	* docTabID;
@property (nonatomic, readwrite, retain)	NSDate		* startPeriod;

- (void) cleanup;
- (NSDateFormatter *) dateFormatter;
- (NSDateFormatter *) timeFormatter;

@end


@implementation NLStatistics

@synthesize hasOpenCategory, hasOpenDocument;
@synthesize categoryName, docTabID, docFileDescription, docFileName, startPeriod;


+ (void) enableDebug:(BOOL) anFlag
{
	debugEnabled = anFlag;
}

- (id) init
{
	if( nil != (self = [super init]) )
	{
		[self cleanup];
		
		tourStorageDic	= [[NSMutableDictionary alloc] init];
		docStorageArr	= [[NSMutableArray alloc] init];
		docFavorites	= [[NSMutableSet alloc] init];
	}
	return self;
}

- (void) dealloc
{
	[self cleanup];
	
	[tourStorageDic release];
	[docStorageArr release];
	[docFavorites release];
	
	[super dealloc];
}



#pragma mark -
#pragma mark Core logic
//
- (void) startTour
{
	if( hasOpenedTour )
	{
		NSAssert1(0, @"%@ - \"startTour\". Wrong sequence. Try to start tour without end old one!", [self class]);
	}
	
	hasOpenedTour = YES;
	
	NSDate * currentDate = [NSDate date];
	NSString * startDate	= [[self dateFormatter] stringFromDate: currentDate];
	NSString * startTime	= [[self timeFormatter] stringFromDate: currentDate];
	
	[tourStorageDic setObject:startDate forKey: kStatTourDateKey];
	[tourStorageDic setObject:startTime forKey: kStatTourStartTimeKey];
}

- (void) endTour
{
	NSDate * currentDate = [NSDate date];
	NSString * endTime	= [[self timeFormatter] stringFromDate: currentDate];
	
	[tourStorageDic setObject:endTime forKey: kStatTourEndTimeKey];
	
	hasOpenedTour = NO;
}

- (void) startCategoryWithName:(NSString *) anName
{	
	if( hasOpenCategory )
	{
		[self endCurrentCategory];
	}
	
	hasOpenCategory		= YES;
	self.categoryName	= anName;
}

//- (void) startDocWithFileName:(NSString *) anName fileDescription:(NSString *) anDesc tabID:(NSString *) anTabID
- (void) startDocWithItem:(ModelContentItem *) anItem
{	
	if( hasOpenCategory )
	{
		if( self.hasOpenDocument )
		{
			[self endCurrentDocument];
		}
		
		self.hasOpenDocument	= YES;
		self.docFileDescription	= anItem.itemFileDescription;
		self.docFileName		= anItem.itemFullName;
		self.docTabID			= anItem.itemTabID;
		self.startPeriod		= [NSDate date];
	}
	else
	{
		NSAssert2(0, @"%@ - \"startDocumentWithName\". Wrong sequence. Try to add document \"%@\" without opened category!", [self class], anItem.itemFullName);
	}
}

- (void) endCurrentDocument
{
	if( hasOpenCategory )
	{
		if( hasOpenDocument && self.docFileName )
		{
			NSDate * currentDate = [NSDate date];
			NSTimeInterval diff = [currentDate timeIntervalSinceDate: self.startPeriod];
			if( 0 < diff )
			{
				diff /= 60;
			}
			NSMutableDictionary * itemDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
											  self.categoryName, kStatItemDescKey,
											  self.docFileDescription, kStatItemFileDescKey,
											  self.docFileName, kStatItemFilenameKey,
											  self.docTabID, kStatItemTabIDKey,
											  [NSNumber numberWithDouble:diff], kStatItemTimeKey, 
											  nil];
			[docStorageArr addObject: itemDict];
			
			self.hasOpenDocument= NO;
			self.startPeriod	= nil;
			self.docFileName	= nil;
		}
		else
		{
			NSAssert1(0, @"%@ - \"endCurrentDocument\". Wrong sequence. Try to close document without opened!", [self class]);
		}
	}
	else
	{
		NSAssert1(0, @"%@ - \"endCurrentDocument\". Wrong sequence. Try to close document without opened!", [self class]);
	}
}

- (void) endCurrentCategory
{
	if( hasOpenCategory && self.categoryName )
	{
		if( hasOpenDocument )
		{
			[self endCurrentDocument];
		}
		[self cleanup];
	}
}

- (void) updateFavoriteForItem:(ModelContentItem *) anItem
{
	if( anItem.isFavorite )
	{
		[docFavorites addObject:anItem];
	}
	else
	{
		[docFavorites removeObject:anItem];
	}
}

//- (NSData *) statData
- (NSString *) statDataString
{
//	if( 0 == [docStorageArr count] )
//	{
//		return nil;
//	}
	
	NSMutableString * xmlString = [[NSMutableString alloc] init];
	
	//
	// Add tour info section:
	//
	[xmlString appendString:[NSString stringWithFormat:@"<%@>", kStatTourRootKey]];
	// Date tag:
	[xmlString appendString: [NSString stringWithFormat:@"<%@>%@</%@>", kStatTourDateKey, [tourStorageDic objectForKey:kStatTourDateKey], kStatTourDateKey]];
	// Start time tag:
	[xmlString appendString: [NSString stringWithFormat:@"<%@>%@</%@>", kStatTourStartTimeKey, [tourStorageDic objectForKey:kStatTourStartTimeKey], kStatTourStartTimeKey]];
	// End time tag:
	[xmlString appendString: [NSString stringWithFormat:@"<%@>%@</%@>", kStatTourEndTimeKey, [tourStorageDic objectForKey:kStatTourEndTimeKey], kStatTourEndTimeKey]];
	// Close tour info section:
	[xmlString appendString:[NSString stringWithFormat:@"</%@>", kStatTourRootKey]];
	
	//
	// Add documents history section:
	//
	[xmlString appendString:[NSString stringWithFormat:@"<%@>", kStatRootKey]];
	for( NSDictionary * dic in docStorageArr )
	{
		// Open item tag:
		[xmlString appendString: [NSString stringWithFormat:@"<%@>", kStatItemKey]];
		//
		// Description:
		[xmlString appendString: [NSString stringWithFormat:@"<%@>%@</%@>", kStatItemDescKey, [dic objectForKey:kStatItemDescKey], kStatItemDescKey]];
		//
		// Filedescription:
		[xmlString appendString: [NSString stringWithFormat:@"<%@>%@</%@>", kStatItemFileDescKey, [dic objectForKey:kStatItemFileDescKey], kStatItemFileDescKey]];
		//
		// Filename:
		[xmlString appendString: [NSString stringWithFormat:@"<%@>%@</%@>", kStatItemFilenameKey, [dic objectForKey:kStatItemFilenameKey], kStatItemFilenameKey]];
		//
		// TabID:
		[xmlString appendString: [NSString stringWithFormat:@"<%@>%@</%@>", kStatItemTabIDKey, [dic objectForKey:kStatItemTabIDKey], kStatItemTabIDKey]];
		//
		// Time:
		[xmlString appendString: [NSString stringWithFormat:@"<%@>%@</%@>", kStatItemTimeKey, [dic objectForKey:kStatItemTimeKey], kStatItemTimeKey]];
		//
		// Close item tag:
		[xmlString appendString: [NSString stringWithFormat:@"</%@>", kStatItemKey]];
	}
	[xmlString appendString:[NSString stringWithFormat:@"</%@>", kStatRootKey]];
	
	
	if( 0 < [docFavorites count] )
	{
		//
		// Add documents history section:
		//
		[xmlString appendString:[NSString stringWithFormat:@"<%@>", kStatItemFavoritedKey]];
		for( ModelContentItem * i in docFavorites )
		{
			// Open item tag:
			[xmlString appendString: [NSString stringWithFormat:@"<%@>", kStatItemKey]];
			//
			// Description:
			[xmlString appendString: [NSString stringWithFormat:@"<%@>%@</%@>", kStatItemDescKey, i.itemParentPath, kStatItemDescKey]];
			//
			// Filedescription:
			[xmlString appendString: [NSString stringWithFormat:@"<%@>%@</%@>", kStatItemFileDescKey, i.itemFileDescription, kStatItemFileDescKey]];
			//
			// Filename:
			[xmlString appendString: [NSString stringWithFormat:@"<%@>%@</%@>", kStatItemFilenameKey, i.itemFullName, kStatItemFilenameKey]];
			//
			// Close item tag:
			[xmlString appendString: [NSString stringWithFormat:@"</%@>", kStatItemKey]];
		}
		[xmlString appendString: [NSString stringWithFormat:@"</%@>", kStatItemFavoritedKey]];
	}
	//
	//
	[self cleanup];
	[tourStorageDic removeAllObjects];
	[docStorageArr removeAllObjects];
	[docFavorites removeAllObjects];
	
	//
	//
//	NSData * statData = [xmlString dataUsingEncoding: NSUTF8StringEncoding];
//	[xmlString release];
	
//	return statData;
	
	if( debugEnabled )
	{
		NSLog(@"%@:\n-------------->\n %@\n-------------->", [self class], xmlString);
	}
	
	return [xmlString autorelease];
}

- (void) cleanup
{
	self.hasOpenCategory	= NO;
	self.hasOpenDocument	= NO;
	self.categoryName		= nil;
	self.docFileDescription		= nil;
	self.docFileName		= nil;
	self.startPeriod		= nil;
}

- (NSDateFormatter *) dateFormatter
{
	static NSDateFormatter	* dateFormatter = nil;
	
	if( !dateFormatter )
	{
		dateFormatter = [[NSDateFormatter alloc] init];
		
		[dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease]];
		[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		[dateFormatter setDateFormat:@"MM/dd/YYYY Ex"];
	}
	
	return dateFormatter;
}

- (NSDateFormatter *) timeFormatter
{
	static NSDateFormatter	* timeFormatter = nil;
	
	if( !timeFormatter )
	{
		timeFormatter = [[NSDateFormatter alloc] init];
		
		[timeFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease]];
		[timeFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		[timeFormatter setDateFormat:@"HH:mm:ss"];
	}
	
	return timeFormatter;
}

@end
