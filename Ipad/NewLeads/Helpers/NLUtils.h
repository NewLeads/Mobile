//
//  NLUtils.h
//
//
//  Created by idevs.com on 15/01/2013.
//  Copyright (c) 2013 All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark - Global definitions
//
/**
 System Version
 */
#define SYSTEM_VERSION		([[[UIDevice currentDevice] systemVersion] floatValue])

#define IOS4_OR_HIGHER		(SYSTEM_VERSION >= 4.f)
#define IOS5_OR_HIGHER		(SYSTEM_VERSION >= 5.f)
#define IOS6_OR_HIGHER		(SYSTEM_VERSION >= 6.f)
#define IOS7_OR_HIGHER		(SYSTEM_VERSION >= 7.f)
#define IOS8_OR_HIGHER		(SYSTEM_VERSION >= 8.f)

#define IOS4				(IOS4_OR_HIGHER && !IOS5_OR_HIGHER)
#define IOS5				(IOS5_OR_HIGHER && !IOS6_OR_HIGHER)
#define IOS6				(IOS6_OR_HIGHER && !IOS7_OR_HIGHER)
#define IOS7				(IOS7_OR_HIGHER && !IOS8_OR_HIGHER)
#define IOS8				IOS8_OR_HIGHER
#define IOS8_0_X			!(SYSTEM_VERSION >= 8.1f || SYSTEM_VERSION < 8.0f)
//
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 ( IS_IPHONE && (fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON) )
#define IS_RETINA ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2)
#define IS_IPAD (NSNotFound != [[[UIDevice currentDevice] model] rangeOfString:@"iPad"].location)
//
#define HCString(k) [HCUtils stringValue:k]
#define HCNumber(k) [HCUtils numberValue:k]


@interface NLUtils : NSObject

typedef enum
{
	kButtonMinTextW			= 57,
	kButtonMinTextH			= 30,
	kButtonMinTextSideGap	= 8,
	kButtonMinIconW			= 44,
	kButtonMinIconH			= 34,
	kButtonMinIconSideGap	= 2,
	kButtonFontSize			= 12,
	
} ButtonDimensionScheme;

+ (UIBarButtonItem *) buttonBackWithTitle:(NSString *) anTitle;
+ (UIBarButtonItem *) buttonBackWithTitle:(NSString *) anTitle forTarget:(id) anTarget withAction:(SEL)anAction;
+ (UIBarButtonItem *) buttonDoneWithTitle:(NSString *) anTitle;
+ (UIBarButtonItem *) buttonDoneWithTitle:(NSString *) anTitle forTarget:(id) anTarget withAction:(SEL)anAction;
+ (UIBarButtonItem *) buttonDoneWithIcon:(NSString *) anImageName;
+ (UIBarButtonItem *) buttonDoneWithIcon:(NSString *) anImageName forTarget:(id) anTarget withAction:(SEL)anAction;
+ (UIBarButtonItem *) buttonBarWithBackground:(NSString *) anImageName title:(NSString *) anTitle;
+ (UIBarButtonItem *) buttonBarWithBackground:(NSString *) anImageName title:(NSString *) anTitle forTarget:(id) anTarget withAction:(SEL)anAction;
//
+ (UIImage *) stretchedImageNamed:(NSString *) anName width:(CGRect)anRect;
//
+ (UIActionSheet *) sheetWithTitle:(NSString *) title cancelTitle:(NSString *) cancel buttonNames:(NSArray *) arrButtonNames;
//
+ (UILabel *) staticLabelWithText:(NSString *) anText inFrame:(CGRect) anFrame;

+ (BOOL) boolValue:(id) anValue;
+ (NSString *) stringValue:(id) anValue;
+ (NSNumber *) numberValue:(id) anValue;
+ (NSInteger) intValue:(id) anValue;
+ (CGFloat) floatValue:(id) anValue;

@end

#pragma mark - UIImage (Additions)
//
@interface UIImage (Additions)

+ (UIImage *) image:(UIImage *) img scalingAndCroppingForSize:(CGSize)targetSize;

@end

