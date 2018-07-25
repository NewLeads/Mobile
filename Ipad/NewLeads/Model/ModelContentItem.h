//
//  ModelContentItem.h
//  NLeads
//
//  Created by idevs.com on 20/06/2011.
//  Copyright 2011 idevs.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CGRThumbCreatorAssets.h"



@interface ModelContentItem : NSObject < UIWebViewDelegate >
{
@private
	BOOL		isFavorite;

	NSString	* itemParentPath;
	NSString	* itemPath;
	NSString	* itemFullName;
	NSString	* itemTabID;
	NSString	* itemFileDescription;
	NSString	* itemName;
	NSString	* itemExtension;
	CGRect		thumbRect;
	UIImage		* itemThumb;
	UIImageView	* viewThumb;
	NSArray		* itemContent;
	
	CGRBaseType itemBaseType;
	
}
@property (nonatomic, readwrite, assign) BOOL		isFavorite;
//
@property (nonatomic,  readwrite) CGRBaseType itemBaseType;
@property (nonatomic, readonly) CGRect		thumbRect;
@property (nonatomic, retain) NSString	* itemParentPath;
@property (nonatomic, retain) NSString * itemPath;
@property (nonatomic, retain) NSString * itemFullName;
@property (nonatomic, retain) NSString	* itemTabID;
@property (nonatomic, retain) NSString	* itemFileDescription;
@property (nonatomic, retain) NSString * itemName;
@property (nonatomic, retain) NSString * itemExtension;
//
@property (nonatomic, retain) UIImage * itemThumb;
@property (nonatomic, retain) UIImageView * viewThumb;
//
@property (nonatomic, retain) NSArray * itemContent;

- (void) updateThumbForRect:(CGRect) anThumbRect;
- (void) updateThumbForImage:(UIImage *) anThumb;

@end
