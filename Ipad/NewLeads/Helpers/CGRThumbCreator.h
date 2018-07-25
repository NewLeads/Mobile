//
//  CGRThumbCreator.h
//
//
//  Created by idevs.com on 07/06/2011.
//  Copyright 2011 idevs.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CGRThumbCreatorAssets.h"


CGSize sizeThatFitsKeepingAspectRatio(CGSize originalSize, CGSize sizeToFit);


@interface CGRThumbCreator : NSObject < UIWebViewDelegate >
{
@private
	NSMutableArray * arrViews;
}

+ (CGRThumbCreator *) sharedCreator;
+ (void) enableDebug:(BOOL) enable;
//
//
// The extension in lower case!!!
- (CGRBaseType) baseTypeFromItemType:(NSString *) itemExtension;
//
- (UIImage *) thumbFromItemType:(CGRBaseType) itemBaseType inPath:(NSString *) path inRect:(CGRect) thumbRect forDelegate:(id<UIWebViewDelegate>) delegate;
//
- (UIImage *) thumbFromPDFAtPath: (NSString *) path inRect:(CGRect) thumbRect;
//
- (UIImage *) thumbFromVideoAtPath: (NSString *) path inRect:(CGRect) thumbRect;
//
- (UIImage *) thumbFromImageAtPath: (NSString *) path inRect:(CGRect) thumbRect;
- (UIImage *) thumbFromImage:(UIImage *) anImage inRect:(CGRect) thumbRect;
//
- (void) thumbFromDocAtPath: (NSString *) path inRect:(CGRect) thumbRect forDelegate:(id<UIWebViewDelegate>) delegate;
- (void) completeForView:(UIWebView *) completedView;

@end
