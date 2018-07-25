//
//  NLUtils.m
// 
//
//  Created by idevs.com on 15/01/2013.
//  Copyright (c) 2013 All rights reserved.
//

#import "NLUtils.h"
#import <objc/runtime.h>



@implementation NLUtils

static NSNumberFormatter *numberFormatter = nil;


+ (UIBarButtonItem *) buttonBackWithTitle:(NSString *) anTitle
{
	return [NLUtils buttonBackWithTitle:anTitle forTarget:nil withAction:nil];
}

+ (UIBarButtonItem *) buttonBackWithTitle:(NSString *) anTitle forTarget:(id) anTarget withAction:(SEL)anAction
{
	UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
	btn.frame = CGRectMake(0, 0, 100, 44);
	btn.autoresizingMask			= UIViewAutoresizingFlexibleWidth;
	//
	[btn addTarget:anTarget action:anAction forControlEvents:UIControlEventTouchUpInside];
    //
	// Background:
	//
	UIImage * img = [NLUtils stretchedImageNamed:@"btn-default-back" width:CGRectMake(0, 0, 13.0, 13.0)];
	[btn setBackgroundImage:img forState:UIControlStateNormal];
	[btn setBackgroundImage:img forState:UIControlStateHighlighted];
	//
	// Title:
	//
	[btn setTitle:anTitle forState:UIControlStateNormal];
	[btn setTitleEdgeInsets:UIEdgeInsetsMake(1, 13, 0, 7)];
	//
	// Title appearance:
	UIColor * textColor			= [UIColor whiteColor];
	UIColor * textColorActive	= [UIColor lightTextColor];
	UIColor * shadowColor		= [UIColor colorWithRed:113.f/255.f green:113.f/255.f blue:113.f/255.f alpha:1.f];
	[btn setTitleColor:textColor forState:UIControlStateNormal];
	[btn setTitleColor:textColorActive forState:UIControlStateHighlighted];
	[btn setTitleShadowColor:shadowColor forState:UIControlStateNormal];
	[btn setTitleShadowColor:shadowColor forState:UIControlStateHighlighted];
	//
    btn.titleLabel.font			= [UIFont fontWithName:@"HelveticaNeue" size:kButtonFontSize];
    btn.titleLabel.shadowOffset	= CGSizeMake(0, 1);
    //
	// Geometry:
	//
	CGRect rcTitle		= [btn titleRectForContentRect:CGRectMake(0, 0, INT_MAX, kButtonMinTextH)];
	rcTitle.size.width += 13 + 2*kButtonMinTextSideGap;
	NSInteger w			= ( kButtonMinTextW > (rcTitle.size.width) ? kButtonMinTextW : (rcTitle.size.width));
	btn.frame			= CGRectMake(0, 0, w, img.size.height);
	//
	UIBarButtonItem * btnBackItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
	
	return [btnBackItem autorelease];
}

+ (UIBarButtonItem *) buttonDoneWithTitle:(NSString *) anTitle
{
	return [NLUtils buttonDoneWithTitle:anTitle forTarget:nil withAction:nil];
}

+ (UIBarButtonItem *) buttonDoneWithTitle:(NSString *) anTitle forTarget:(id) anTarget withAction:(SEL)anAction
{
	UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
	btn.frame = CGRectMake(0, 0, 100, 44);
	btn.autoresizingMask			= UIViewAutoresizingNone;
	//
	[btn addTarget:anTarget action:anAction forControlEvents:UIControlEventTouchUpInside];
    //
	// Background:
	//
	UIImage * img = [NLUtils stretchedImageNamed:@"btn-default" width:CGRectMake(0, 0, 6.0, 6.0)];
	[btn setBackgroundImage:img forState:UIControlStateNormal];
	[btn setBackgroundImage:img forState:UIControlStateHighlighted];
	//
	// Title:
	//
	[btn setTitle:anTitle forState:UIControlStateNormal];
	[btn setTitleEdgeInsets:UIEdgeInsetsMake(1, 3, 0, 0)];
	//
	// Title appearance:
	UIColor * textColor			= [UIColor whiteColor];
	UIColor * textColorActive	= [UIColor lightTextColor];
	UIColor * shadowColor		= [UIColor colorWithRed:113.f/255.f green:113.f/255.f blue:113.f/255.f alpha:1.f];
	[btn setTitleColor:textColor forState:UIControlStateNormal];
	[btn setTitleColor:textColorActive forState:UIControlStateHighlighted];
	[btn setTitleShadowColor:shadowColor forState:UIControlStateNormal];
	[btn setTitleShadowColor:shadowColor forState:UIControlStateHighlighted];
	//
    btn.titleLabel.font			= [UIFont systemFontOfSize:kButtonFontSize];//[UIFont fontWithName:@"HelveticaNeue" size:kButtonFontSize];
    btn.titleLabel.shadowOffset	= CGSizeMake(0, 1);
    //
	// Geometry:
	//
	CGRect rcTitle		= [btn titleRectForContentRect:CGRectMake(0, 0, INT_MAX, kButtonMinTextH)];
	rcTitle.size.width += 2*kButtonMinTextSideGap;
	NSInteger w			= ( kButtonMinTextW > (rcTitle.size.width) ? kButtonMinTextW : (rcTitle.size.width));
	btn.frame			= CGRectMake(0, 0, w, img.size.height);
	//
	UIBarButtonItem * btnBackItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
	
	return [btnBackItem autorelease];
}

+ (UIBarButtonItem *) buttonDoneWithIcon:(NSString *) anImageName
{
	return [NLUtils buttonDoneWithIcon:anImageName forTarget:nil withAction:nil];
}

+ (UIBarButtonItem *) buttonDoneWithIcon:(NSString *) anImageName forTarget:(id) anTarget withAction:(SEL)anAction
{
	UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
	btn.frame = CGRectMake(0, 0, 100, 44);
	btn.autoresizingMask			= UIViewAutoresizingFlexibleWidth;
	//
	[btn addTarget:anTarget action:anAction forControlEvents:UIControlEventTouchUpInside];
    //
	// Background:
	//
	UIImage * img = [NLUtils stretchedImageNamed:@"btn-default" width:CGRectMake(0, 0, 6.0, 6.0)];
	[btn setBackgroundImage:img forState:UIControlStateNormal];
	[btn setBackgroundImage:img forState:UIControlStateHighlighted];
	//
	// Icon:
	//
	[btn setImage:[UIImage imageNamed:anImageName] forState:UIControlStateNormal];
    //
	// Geometry:
	//
	CGRect rcImage		= [btn imageRectForContentRect:CGRectMake(0, 0, INT_MAX, kButtonMinIconH)];
	rcImage.size.width += 2*kButtonMinIconSideGap;
	NSInteger w			= ( kButtonMinIconW > (rcImage.size.width) ? kButtonMinIconW : (rcImage.size.width));
	btn.frame			= CGRectMake(0, 0, w, img.size.height);
	//
	UIBarButtonItem * btnBackItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
	
	return [btnBackItem autorelease];
}

+ (UIBarButtonItem *) buttonBarWithBackground:(NSString *) anImageName title:(NSString *) anTitle
{
	return [NLUtils buttonBarWithBackground:anImageName title:anTitle forTarget:nil withAction:nil];
}

+ (UIBarButtonItem *) buttonBarWithBackground:(NSString *) anImageName title:(NSString *) anTitle forTarget:(id) anTarget withAction:(SEL)anAction
{
	UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
	btn.frame = CGRectMake(0, 0, 100, 44);
	btn.autoresizingMask			= UIViewAutoresizingNone;
	//
	[btn addTarget:anTarget action:anAction forControlEvents:UIControlEventTouchUpInside];
    //
	// Background:
	//
	UIImage * img = [NLUtils stretchedImageNamed:anImageName width:CGRectMake(0, 0, 6.0, 6.0)];
	[btn setBackgroundImage:img forState:UIControlStateNormal];
	[btn setBackgroundImage:img forState:UIControlStateHighlighted];
	//
	// Title:
	//
	[btn setTitle:anTitle forState:UIControlStateNormal];
	[btn setTitleEdgeInsets:UIEdgeInsetsMake(1, 3, 0, 0)];
	//
	// Title appearance:
	UIColor * textColor			= [UIColor whiteColor];
	UIColor * textColorActive	= [UIColor lightTextColor];
	UIColor * shadowColor		= [UIColor colorWithRed:113.f/255.f green:113.f/255.f blue:113.f/255.f alpha:1.f];
	[btn setTitleColor:textColor forState:UIControlStateNormal];
	[btn setTitleColor:textColorActive forState:UIControlStateHighlighted];
	[btn setTitleShadowColor:shadowColor forState:UIControlStateNormal];
	[btn setTitleShadowColor:shadowColor forState:UIControlStateHighlighted];
	//
    btn.titleLabel.font			= [UIFont systemFontOfSize:kButtonFontSize];//[UIFont fontWithName:@"HelveticaNeue" size:kButtonFontSize];
    btn.titleLabel.shadowOffset	= CGSizeMake(0, 1);
    //
	// Geometry:
	//
	CGRect rcTitle		= [btn titleRectForContentRect:CGRectMake(0, 0, INT_MAX, kButtonMinTextH)];
	rcTitle.size.width += 2*kButtonMinTextSideGap;
	NSInteger w			= ( kButtonMinTextW > (rcTitle.size.width) ? kButtonMinTextW : (rcTitle.size.width));
	btn.frame			= CGRectMake(0, 0, w, img.size.height);
	//
	UIBarButtonItem * btnItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
	
	return [btnItem autorelease];
}


#pragma mark >>> Image stretching
//
+ (UIImage *) stretchedImageNamed:(NSString *) anName width:(CGRect)anRect
{
	UIImage * imgResult = nil;
	UIImage * imgSource = [UIImage imageNamed:anName];
	
	if( imgSource )
	{
		if( [imgSource respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)] )
		{
			imgResult = [imgSource resizableImageWithCapInsets:UIEdgeInsetsMake(anRect.size.height, anRect.size.width, anRect.size.height, anRect.size.width) resizingMode:UIImageResizingModeStretch];
		}
		else if( [imgSource respondsToSelector:@selector(resizableImageWithCapInsets:)] )
		{
			imgResult = [imgSource resizableImageWithCapInsets:UIEdgeInsetsMake(anRect.size.height, anRect.size.width, anRect.size.height, anRect.size.width)];
		}
		else // Support iOS version prior to the 5.0
		{
			imgResult = [imgSource stretchableImageWithLeftCapWidth:anRect.size.width topCapHeight:anRect.size.height];
		}
	}
	
	return imgResult;
}

#pragma mark >>> UIActionSheet
//
+ (UIActionSheet *) sheetWithTitle:(NSString *) title cancelTitle:(NSString *) cancel buttonNames:(NSArray *) arrButtonNames
{
	UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:title
														delegate:nil
											   cancelButtonTitle:nil
										  destructiveButtonTitle:nil
											   otherButtonTitles:nil];
	
	for( NSString * strName in arrButtonNames)
	{
		[sheet addButtonWithTitle: strName];
	}
	
	[sheet addButtonWithTitle:cancel];
	sheet.destructiveButtonIndex = [arrButtonNames count];
	
	return [sheet autorelease];
}

+ (UILabel *) staticLabelWithText:(NSString *) anText inFrame:(CGRect) anFrame
{
	UILabel * label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, anFrame.size.width, anFrame.size.height)] autorelease];
	label.autoresizingMask	= UIViewAutoresizingFlexibleWidth;
	label.contentMode		= UIViewContentModeCenter;
	label.backgroundColor	= [UIColor clearColor];
	label.textColor			= [UIColor blackColor];
	label.shadowColor		= [UIColor whiteColor];
	label.shadowOffset		= CGSizeMake(0, -1);
	label.font				= [UIFont fontWithName:@"Helvetica Neue" size:22];
	//
	label.textAlignment		= (IOS4 || IOS5) ? NSTextAlignmentCenter : NSTextAlignmentCenter;
	label.numberOfLines		= 0;
	//
	label.text				= anText;
	
	return label;
}

#pragma mark >>> Convient dataypes extract methods
//
+ (BOOL) boolValue:(id) anValue
{
	if( anValue )
	{
		if( [anValue isKindOfClass:[NSDecimalNumber class]] )
		{
			return [(NSDecimalNumber*) anValue  integerValue];
		}
		if( [anValue isKindOfClass:[NSString class]] )
		{
			if([[anValue lowercaseString] isEqualToString:@"true"])
				return YES;
			
			if([[anValue lowercaseString] isEqualToString:@"false"])
				return NO;
			
			return [anValue boolValue];
		}
		if( [anValue isKindOfClass:[NSNumber class]] )
		{
			return [(NSNumber*) anValue boolValue];
		}
		if( CFBooleanGetTypeID() == CFGetTypeID(anValue) )
		{
			return [(NSNumber *)anValue boolValue];
		}
	}
	return NO;
}

+ (NSString *) stringValue:(id) anValue
{
	if( anValue )
	{
		if( [anValue isKindOfClass:[NSString class]] )
		{
			return anValue;
		}
		if( CFStringGetTypeID() == CFGetTypeID(anValue) )
		{
			return anValue;
		}
		if( [anValue isKindOfClass:[NSDecimalNumber class]] )
		{
			return [(NSDecimalNumber*) anValue stringValue];
		}
		if( [anValue isKindOfClass:[NSNumber class]] )
		{
			return [(NSNumber*) anValue stringValue];
		}
	}
	return nil;
}

+ (NSNumber *) numberValue:(id) anValue
{
    NSString* numberString = [self stringValue:anValue];
    if (!numberString) return nil;
    
    if (!numberFormatter)
    {
        numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

    }
    
    return [numberFormatter numberFromString:numberString];
}

+ (NSInteger) intValue:(id) anValue
{
	if( anValue )
	{
		if( [anValue isKindOfClass:[NSString class]] )
		{
			return [(NSString *) anValue integerValue];
		}
		if( [anValue isKindOfClass:[NSDecimalNumber class]] )
		{
			return [(NSDecimalNumber*) anValue  integerValue];
		}
		if( [anValue isKindOfClass:[NSNumber class]] )
		{
			return [(NSNumber*) anValue integerValue];
		}
		if( CFNumberGetTypeID() == CFGetTypeID(anValue) )
		{
			return [(NSNumber *)anValue integerValue];
		}
	}
	return 0;
}

+ (CGFloat) floatValue:(id) anValue
{
	if( anValue )
	{
		if( [anValue isKindOfClass:[NSString class]] )
		{
			return [(NSString *) anValue floatValue];
		}
		if( [anValue isKindOfClass:[NSDecimalNumber class]] )
		{
			return [(NSDecimalNumber*) anValue  floatValue];
		}
		if( [anValue isKindOfClass:[NSNumber class]] )
		{
			return [(NSNumber*) anValue floatValue];
		}
		if( CFNumberGetTypeID() == CFGetTypeID(anValue) )
		{
			return [(NSNumber *)anValue floatValue];
		}
	}
	return 0.f;
}

@end

#pragma mark - UIImage (Additions)
//
@implementation UIImage (Additions)

+ (UIImage *) image:(UIImage *) img scalingAndCroppingForSize:(CGSize)targetSize
{
	UIImage *sourceImage = img;
	UIImage *newImage = nil;
	CGSize imageSize = sourceImage.size;
	CGFloat width = imageSize.width;
	CGFloat height = imageSize.height;
	CGFloat targetWidth = targetSize.width;
	CGFloat targetHeight = targetSize.height;
	CGFloat scaleFactor = 0.0f;
	CGFloat scaledWidth = targetWidth;
	CGFloat scaledHeight = targetHeight;
	CGPoint thumbnailPoint = CGPointMake(0.0f,0.0f);
	
	if (CGSizeEqualToSize(imageSize, targetSize) == NO)
	{
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
		
        if (widthFactor > heightFactor)
			scaleFactor = widthFactor; // scale to fit height
        else
			scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
		
        // center the image
        if (widthFactor > heightFactor)
		{
			thumbnailPoint.y = (targetHeight - scaledHeight) /2;
		}
        else
			if (widthFactor < heightFactor)
			{
				thumbnailPoint.x = (targetWidth - scaledWidth)/2;
			}
	}
	
	UIGraphicsBeginImageContext(targetSize); // this will crop
	
	CGRect thumbnailRect = CGRectZero;
	thumbnailRect.origin = thumbnailPoint;
	thumbnailRect.size.width  = scaledWidth;
	thumbnailRect.size.height = scaledHeight;
	
	[sourceImage drawInRect:thumbnailRect];
	
	newImage = UIGraphicsGetImageFromCurrentImageContext();
	if(newImage == nil)
        ////NSLog(@"could not scale image");
		
		//pop the context to get back to the default
		UIGraphicsEndImageContext();
	return newImage;
}

@end
