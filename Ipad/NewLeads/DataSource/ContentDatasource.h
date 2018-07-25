//
//  ContentDatasource.h
//  NewLeads
//
//  Created by idevs.com on 28/06/2011.
//  Copyright 2011 idevs.com. All rights reserved.
//

#import <Foundation/Foundation.h>



@class ContentDatasource;

@protocol ContentDatasourceDelegate

- (void) contentDatasourceDidComplete:(ContentDatasource *) anSource;

@end


@class LogoItem;

@interface ContentDatasource : NSObject 
{
@private
	LogoItem * logoItem;
	NSString * folderPath;
	NSMutableArray	* rootArray;
	NSMutableArray	* chaptersArray;
	NSMutableArray	* modelArray;
	
	//
	// Delegate:
	id<ContentDatasourceDelegate> delegate;
}

@property (nonatomic, assign) id<ContentDatasourceDelegate> delegate;
@property (nonatomic, readonly) NSArray	* chaptersArray;
@property (nonatomic, readonly) NSArray	* sourceArray;
@property (nonatomic, readonly) LogoItem * logoItem;


//- (void) copyDefaultBundleResources; // Test only!
- (void) readContent;

@end
