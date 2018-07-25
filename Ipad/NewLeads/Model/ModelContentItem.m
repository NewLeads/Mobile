//
//  ModelContentItem.m
//  NLeads
//
//  Created by idevs.com on 20/06/2011.
//  Copyright 2011 idevs.com. All rights reserved.
//

#import "ModelContentItem.h"
#import "CGRThumbCreator.h"
//
#import <QuartzCore/CALayer.h>



@interface ModelContentItem ()

- (UIImage *) imageWithShadowForImage:(UIImage *) anImage;
- (void) saveThumb;

@end



@implementation ModelContentItem

@synthesize isFavorite;
@synthesize itemParentPath, itemPath, itemTabID, itemFileDescription, itemFullName, itemName, itemExtension, itemThumb, itemBaseType, viewThumb, thumbRect, itemContent;

- (id) init
{
	if( nil != (self = [super init] ))
	{
		self.isFavorite		= NO;
		
		self.itemBaseType	= kCGRUnknown;
		self.itemParentPath	= nil;
		self.itemPath		= nil;
		self.itemName		= nil;
		self.itemTabID		= nil;
		self.itemFileDescription = nil;
		self.itemExtension	= nil;
		self.itemThumb		= nil;
		self.itemContent	= nil;
	}
	return self;
}

- (void) dealloc
{
	self.isFavorite		= NO;
	
	self.itemParentPath	= nil;
	self.itemPath = nil;
	self.itemTabID	= nil;
	self.itemFileDescription = nil;
	self.itemFullName = nil;
	self.itemName = nil;
	self.itemExtension = nil;
	self.itemContent = nil;
	
	self.itemThumb = nil;
	self.viewThumb = nil;
	
	[super dealloc];
}



#pragma mark -
#pragma mark Core logic
//
- (void) updateThumbForRect:(CGRect) anThumbRect
{
	thumbRect = anThumbRect;
	
	if( kCGRUnknown == itemBaseType )
	{
		itemBaseType = [[CGRThumbCreator sharedCreator] baseTypeFromItemType: itemExtension];
	}
	if( kCGRUnknown != itemBaseType )
	{
		UIImage * img = [[CGRThumbCreator sharedCreator] thumbFromItemType: itemBaseType
																	inPath: itemPath
																	inRect: thumbRect 
															   forDelegate: self];
		if( img )
		{
			if( kCGRFolder != itemBaseType )
			{
				img = [self imageWithShadowForImage: img];
			}
			
			self.itemThumb = img;
			[self saveThumb];
		}
		else
		{
			self.itemThumb = [UIImage imageNamed:@"item_default_file.png"];
		}
//		UIImageView * view = [[UIImageView alloc] initWithFrame:thumbRect];
//		[view setImage: self.itemThumb];
		UIImageView * view = [[UIImageView alloc] initWithImage:self.itemThumb];

		self.viewThumb = view;
		[view release];
	}
}

- (void) updateThumbForImage:(UIImage *) anThumb
{
	self.itemThumb = anThumb;
	UIImageView * view = [[UIImageView alloc] initWithImage:self.itemThumb];
	self.viewThumb = view;
	[view release];
}

- (void) saveThumb
{
	if( self.itemPath && self.itemThumb )
	{
		NSData * d = UIImagePNGRepresentation(self.itemThumb);
		if( d )
		{
			[d writeToFile: [self.itemPath stringByAppendingString:@"_thumb"]
				atomically: YES];
		}
	}
}

- (UIImage *) imageWithShadowForImage:(UIImage *) anImage
{
	float shadowOffset = 6;
	CGRect rc = CGRectMake(0, 0, anImage.size.width + shadowOffset + 3, anImage.size.height + shadowOffset + 3);
	
	UIGraphicsBeginImageContext(rc.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGSize          myShadowOffset = CGSizeMake(shadowOffset, shadowOffset);
	float           myColorValues[] = {0.1, 0.1, 0.1, .5};// 3
    CGColorRef      myColor;// 4
    CGColorSpaceRef myColorSpace;
	
	//CGContextSetShadow(context, myShadowOffset, 25);
	myColorSpace = CGColorSpaceCreateDeviceRGB ();// 9
    myColor = CGColorCreate (myColorSpace, myColorValues);// 10
    CGContextSetShadowWithColor (context, myShadowOffset, 5, myColor);
	
	CGColorRelease (myColor);// 13
    CGColorSpaceRelease (myColorSpace); 
	
	[anImage drawInRect: CGRectMake(0,0, anImage.size.width, anImage.size.height)];
	
	if( kCGRVideo == itemBaseType )
	{
		UIImage * overlay = [UIImage imageNamed:@"video-arrow.png"];
		[overlay drawInRect: CGRectMake(rc.size.width/2 - overlay.size.width/2, 
										rc.size.height/2 - overlay.size.height/2,
										overlay.size.width, overlay.size.height)];
	}
	
	anImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return anImage;
}

- (NSString *) description
{
	return [NSString stringWithFormat:@"\r{\rpath = %@,\rfiledescription=%@,\rname = %@,\rext = %@,\rbaseType = %d\r}", self.itemPath, self.itemFileDescription, self.itemName, self.itemExtension, self.itemBaseType];
}


#pragma mark -
#pragma mark CGRThumbCreator delegate
//
- (void) thumbCreatorDidCompleted:(UIImage *) thumb
{
	self.itemThumb = thumb;
}

- (void) thumbCreatorDidFailed
{
}


#pragma mark -
#pragma mark UIWebView delegate
//
- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	return YES;
}

- (void) webViewDidStartLoad:(UIWebView *)webView
{
	// Do nothing...
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
	UIImage * img = nil;
	UIGraphicsBeginImageContext(webView.frame.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	[webView.layer renderInContext:context];
	img = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	self.itemThumb = [self imageWithShadowForImage: img];
	
	self.viewThumb.frame = thumbRect;
	[self.viewThumb setImage:self.itemThumb];
	
	[self saveThumb];
	
	[[CGRThumbCreator sharedCreator] completeForView: webView];
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[[CGRThumbCreator sharedCreator] completeForView: webView];
}


@end
