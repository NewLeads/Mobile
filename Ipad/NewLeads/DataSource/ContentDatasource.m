//
//  ContentDatasource.m
//  NewLeads
//
//  Created by idevs.com on 28/06/2011.
//  Copyright 2011 idevs.com. All rights reserved.
//

#import "ContentDatasource.h"
#import "ModelContentItem.h"
#import "ContentGridItem.h"
#import "CGRThumbCreator.h"
//
#import "TabItem.h"
#import "ContentItem.h"
#import "LogoItem.h"



#pragma mark -
#pragma mark Configuration
//
NSString * const	kContentDirName	= @"content";



@interface ContentDatasource ()

@property (nonatomic, readwrite, retain) NSString * folderPath;

- (void) createContentModel;
- (ModelContentItem *) readItemAtPath:(NSString *) aPath;

@end



@implementation ContentDatasource

@synthesize folderPath;
@synthesize sourceArray = rootArray, delegate, chaptersArray;
@synthesize logoItem;


- (id) init
{
	if( nil != (self = [super init] ))
	{
		rootArray = [[NSMutableArray alloc] init];
		chaptersArray = [[NSMutableArray alloc] init];
		modelArray	= [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) dealloc
{
	if( modelArray )
	{
		[modelArray release];
		modelArray = nil;
	}
	if( rootArray )
	{
		[rootArray release];
		rootArray = nil;
	}
	if( chaptersArray )
	{
		[chaptersArray release];
		chaptersArray = nil;
	}

	if( logoItem )
	{
		[logoItem release];
		logoItem = nil;
	}
	
	self.folderPath = nil;
	
	[super dealloc];
}



#pragma mark -
#pragma mark Core logic
//
- (void) readContent
{
	NSArray * arrHome = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* homePath	= [arrHome objectAtIndex: 0];
	NSString* pathToContentDir	= [homePath stringByAppendingPathComponent: [NLContext shared].datasourceFolder];
	
	[self createContentModel];
	
	for( TabItem * tab in modelArray )
	{
		NSMutableArray * tempArr = [[NSMutableArray alloc] init];
		for( ContentItem * item in tab.tabItems )
		{
			NSString * itemPath = [NSString stringWithFormat:@"%@/%@/%@", pathToContentDir, tab.tabFolder, item.contentFileName];
			
			ModelContentItem * realItem = [self readItemAtPath: itemPath];
			if( realItem )
			{
				realItem.itemParentPath	= [NSString stringWithFormat:@"%@", tab.tabFolder];
				realItem.itemName = item.contentDesc;
				realItem.itemFileDescription = item.contentFileDesc;
				realItem.itemTabID = tab.tabID;
				[tempArr addObject: realItem];
			}
		}
		[rootArray addObject: tempArr];
		[tempArr release];
	}
}

- (void) createContentModel
{
	if( [NLContext shared].contentDict )
	{
		NSDictionary * contentDict = [NLContext shared].contentDict;
		
		//
		//
		NSArray * arrHome = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString* homePath	= [arrHome objectAtIndex: 0];
		NSString* pathToContentDir	= [homePath stringByAppendingPathComponent: [NLContext shared].datasourceFolder];
		
		logoItem = [[LogoItem alloc] initWithDictionary:contentDict fromPlist:YES];
		NSString * logoPath = [pathToContentDir stringByAppendingPathComponent:logoItem.logoFileName];
		NSFileManager	* fileManager	= [NSFileManager defaultManager];
		
		if( [fileManager fileExistsAtPath: logoPath] )
		{
			UIImage * img = [UIImage imageWithContentsOfFile: logoPath];
			if( img )
			{
				[logoItem setImage:img];
			}
		}
		
		//
		// Get list of tabs:
		NSArray * tabsArr = [contentDict objectForKey:@"content"];
		if( tabsArr )
		{
			for( NSDictionary * tabDict in tabsArr )
			{
				NSDictionary * subDict = [tabDict objectForKey:@"content_tab"];
				
				TabItem * item = [[TabItem alloc] initWithDictionary: subDict fromPlist: YES];
				
				ModelContentItem * modelItem = [[ModelContentItem alloc] init];
				
				modelItem.itemPath = item.tabFolder;
				modelItem.itemName = item.tabDesc;
				modelItem.itemTabID	= item.tabID;
				modelItem.itemBaseType = kCGRFolder;
				
				NSString * imageName = [NSString stringWithFormat:@"%@/%@/%@", pathToContentDir, item.tabFolder, item.tabIconFileName];
				UIImage * img = [UIImage imageWithContentsOfFile: imageName];
				if( img )
				{
					[modelItem updateThumbForImage: img];
				}
				else
				{
					imageName = [[[NSBundle mainBundle] bundlePath]  stringByAppendingPathComponent: @"item_cat_library.png"];
					img = [UIImage imageWithContentsOfFile: imageName];
					[modelItem updateThumbForImage: img];
				}
				
				[chaptersArray addObject: modelItem];
				[modelArray addObject:item];
				[modelItem release];
				[item release];
			}
		}
	}
}

- (ModelContentItem *) readItemAtPath:(NSString *) aPath
{
	ModelContentItem * modelItem	= nil;
	NSFileManager	* fileManager	= [NSFileManager defaultManager];

	if( [fileManager fileExistsAtPath: aPath] )
	{
		modelItem = [[ModelContentItem alloc] init];

		NSString * fileName = [aPath lastPathComponent];
		NSString * fileExt	= [[fileName pathExtension] lowercaseString];
		
		//
		// TODO: Rewrite this stupid staff!!!
		//		
		if( [[fileName pathExtension] isEqualToString:@"zip"] )
		{
			NSMutableArray * components = [[[fileName componentsSeparatedByString:@"."] mutableCopy] autorelease];
			if( 2 <= [components count])
			{
				fileExt  = [NSString stringWithFormat:@"%@.%@", 
							[[components objectAtIndex:[components count]-2] lowercaseString], 
							[[components objectAtIndex:[components count]-1] lowercaseString]];
				
				[components removeLastObject];
				[components removeLastObject];
				
				for( NSString * s in components )
				{
					fileName = [fileName stringByAppendingString:s];
				}
			}
			else
			{
				NSLog(@"~~~> readContent->currFile->rawFileName->zip && components < 2! WTF!!!");
				NSLog(@"~~~> Skip item: %@", aPath);
				goto END;
			}
		}
			
		modelItem.itemName		= [fileName stringByDeletingPathExtension];
		modelItem.itemFullName	= fileName;
		modelItem.itemExtension	= fileExt;
		modelItem.itemPath		= aPath;
			
		NSString * thumbPath = [aPath stringByAppendingString:@"_thumb"];
		if( thumbPath && [fileManager fileExistsAtPath: thumbPath] )
		{
			UIImage * img = [UIImage imageWithContentsOfFile:thumbPath];
			if( img )
			{
				[modelItem updateThumbForImage: img];
				modelItem.itemBaseType = [[CGRThumbCreator sharedCreator] baseTypeFromItemType:modelItem.itemExtension];
			}
		}
		else
		{
			[modelItem updateThumbForRect:CGRectMake(0, 0, [ContentGridItem sizeContent].width, [ContentGridItem sizeContent].height)];
		}
	}
	
END:
	return [modelItem autorelease];
}

@end
