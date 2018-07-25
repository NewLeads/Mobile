//
//  CGRThumbCreator.m
//
//
//  Created by idevs.com on 07/06/2011.
//  Copyright 2011 idevs.com. All rights reserved.
//

#import "CGRThumbCreator.h"
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>
//
#import "UIImage+Resize.h"
#import "UIImage+RoundedCorner.h"



#pragma mark -
#pragma mark Configuration
//
static BOOL				isDebugEnabled		= NO;


#pragma -
#pragma mark Sigleton definition
//
static CGRThumbCreator	* sharedCreator		= nil;



CGSize sizeThatFitsKeepingAspectRatio(CGSize originalSize, CGSize sizeToFit)
{
	if (originalSize.width <= sizeToFit.width && originalSize.height <= sizeToFit.height)
	{
		return originalSize;
	}
	
	CGFloat necessaryZoomWidth = sizeToFit.width / originalSize.width;
	CGFloat necessaryZoomHeight = sizeToFit.height / originalSize.height;
	
	CGFloat smallerZoom = MIN(necessaryZoomWidth, necessaryZoomHeight);
	
	CGSize scaledSize = CGSizeMake(roundf(originalSize.width*smallerZoom), roundf(originalSize.height*smallerZoom));
	
	return scaledSize;
}



@implementation CGRThumbCreator


#pragma mark -
#pragma mark Singleton realization
//
+ (CGRThumbCreator *) sharedCreator
{
	if( nil == sharedCreator )
	{
		sharedCreator = [[super allocWithZone:NULL] init];
	}
	return sharedCreator;
}

+ (id)allocWithZone:(NSZone *) zone
{
	return [[self sharedCreator] retain];
}

- (id)copyWithZone:(NSZone *) zone
{
	return self;
}

- (id) retain
{
	return self;
}

- (NSUInteger) retainCount
{
	return NSUIntegerMax;  //denotes an object that cannot be released
}

- (oneway void) release
{
	//do nothing
}

- (id) autorelease
{
	return self;
}



#pragma mark -
#pragma mark Debug mode
//
+ (void) enableDebug:(BOOL) enable
{
	isDebugEnabled = enable;
}



#pragma mark -
#pragma mark Core logic
//
- (id) init
{
	if( nil != (self = [super init]) )
	{
		arrViews = [[NSMutableArray alloc] init];
	}
	return self;
}

#pragma mark >>> detecting item type
//
- (CGRBaseType) baseTypeFromItemType:(NSString *) itemExtension
{
	if( [itemExtension isEqualToString:@"tiff"] || [itemExtension isEqualToString:@"tif"] )
		return kCGRImage;
	if( [itemExtension isEqualToString:@"jpg"] || [itemExtension isEqualToString:@"jpeg"] )
		return kCGRImage;
	if( [itemExtension isEqualToString:@"gif"] )
		return kCGRImage;
	if( [itemExtension isEqualToString:@"png"] )
		return kCGRImage;
	if( [itemExtension isEqualToString:@"bmp"] || [itemExtension isEqualToString:@"BMPf"] )
		return kCGRImage;
	if( [itemExtension isEqualToString:@"ico"] )
		return kCGRImage;
	if( [itemExtension isEqualToString:@"cur"] )
		return kCGRImage;
	if( [itemExtension isEqualToString:@"xbm"] )
		return kCGRImage;

	if( [itemExtension isEqualToString:@"mov"] )
		return kCGRVideo;
	if( [itemExtension isEqualToString:@"mp4"] )
		return kCGRVideo;
	if( [itemExtension isEqualToString:@"mpv"] )
		return kCGRVideo;
	if( [itemExtension isEqualToString:@"3gp"] )
		return kCGRVideo;

	if( [itemExtension isEqualToString:@"pdf"] )
		return kCGRPDF;
	
	if( [itemExtension isEqualToString:@"htm"] || [itemExtension isEqualToString:@"html"] )
		return kCGRDocument_Early_3_0;
	if( [itemExtension isEqualToString:@"txt"] )
		return kCGRDocument_Early_3_0;
	if( [itemExtension isEqualToString:@"ppt"] )
		return kCGRDocument_Early_3_0;
	if( [itemExtension isEqualToString:@"doc"] )
		return kCGRDocument_Early_3_0;
	if( [itemExtension isEqualToString:@"xls"] )
		return kCGRDocument_Early_3_0;
	if( [itemExtension isEqualToString:@"key.zip"] )
		return kCGRDocument_Early_3_0;
	if( [itemExtension isEqualToString:@"numbers.zip"] )
		return kCGRDocument_Early_3_0;
	if( [itemExtension isEqualToString:@"pages.zip"] )
		return kCGRDocument_Early_3_0;
	
	if( [itemExtension isEqualToString:@"rtf"] )
		return kCGRDocument_Late_3_0;
	if( [itemExtension isEqualToString:@"rtfd.zip"] )
		return kCGRDocument_Late_3_0;
	if( [itemExtension isEqualToString:@"key"] )
		return kCGRDocument_Late_3_0;
	if( [itemExtension isEqualToString:@"numbers"] )
		return kCGRDocument_Late_3_0;
	if( [itemExtension isEqualToString:@"pages"] )
		return kCGRDocument_Late_3_0;
	
	return kCGRUnknown;
}
//
- (UIImage *) thumbFromItemType:(CGRBaseType) itemBaseType inPath:(NSString *) path inRect:(CGRect) thumbRect forDelegate:(id<UIWebViewDelegate>) delegate
{
	switch( itemBaseType )
	{
		case kCGRFolder:
			return [UIImage imageNamed:@"item_folder.png"];
		case kCGRImage:
			return [self thumbFromImageAtPath: path inRect: thumbRect];
		
		case kCGRVideo:
			return [self thumbFromVideoAtPath: path inRect: thumbRect];
		
		case kCGRPDF:
			return [self thumbFromPDFAtPath: path inRect: thumbRect];

		case kCGRDocument_Early_3_0:
		case kCGRDocument_Late_3_0:
			[self thumbFromDocAtPath: path inRect: thumbRect forDelegate:delegate];
			return nil;
			
		default:
			break;			
	}
	return nil;
}

#pragma mark >>> PDF conversion
//
- (UIImage *) thumbFromPDFAtPath: (NSString *) path inRect:(CGRect) thumbRect
{
	UIImage* thumbnailImage = nil;
	CGPDFPageRef page		= nil;
	
	
	NSURL * pdfFileUrl		= nil;
	pdfFileUrl				= [NSURL fileURLWithPath:path];
	if( !pdfFileUrl )
	{
		goto END;
	}
	
	CGPDFDocumentRef pdf	= nil;
	pdf						= CGPDFDocumentCreateWithURL((CFURLRef)pdfFileUrl);
	if( NULL == pdf )
	{
		goto END;
	}
	
	page = CGPDFDocumentGetPage(pdf, 1);
	if( NULL == page )
	{
        if( pdf )
        {
            CGPDFDocumentRelease(pdf);
        }
		goto END;
	}
	
	CGRect pageRect = CGPDFPageGetBoxRect(page, kCGPDFCropBox);	
	
//	float ratioDW = fabsf( (thumbRect.size.width/pageRect.size.width));
//	float ratioDH = fabsf( (thumbRect.size.height/pageRect.size.height));
//	
	CGRect aPageRect= CGRectZero;
//	if( pageRect.size.width >= pageRect.size.height)
//	{
//		aPageRect = CGRectMake(0, 0, ratioDW*(pageRect.size.width), ratioDW*(pageRect.size.height));
//	}
//	else
//	{
//		aPageRect = CGRectMake(0, 0, ratioDH*(pageRect.size.width), ratioDH*(pageRect.size.height));
//	}
	
	CGSize aspectSize = sizeThatFitsKeepingAspectRatio(pageRect.size, thumbRect.size);
	aPageRect = CGRectMake(0, 0, aspectSize.width, aspectSize.height);
	
//	CGRect aRect = thumbRect;//CGRectMake(0, 0, WIDTH_PDF_PREVIEW, HEIGHT_PDF_PREVIEW); 
	UIGraphicsBeginImageContext(aPageRect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSaveGState(context);
	CGContextTranslateCTM(context, 0.f, aPageRect.size.height);
	CGContextScaleCTM(context, 1.f, -1.f);
	
	CGContextSetGrayFillColor(context, 1.f, 1.f);
	CGContextFillRect(context, aPageRect);		
	
	//
	// TODO: read conversion parameters instead...
	int angle = 0;	
	
	CGAffineTransform pdfTransform = CGPDFPageGetDrawingTransform(page, kCGPDFCropBox, aPageRect, angle, true);
	CGContextConcatCTM(context, pdfTransform);
	
	CGContextDrawPDFPage(context, page);
	
	thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
	
	CGContextRestoreGState(context);
	UIGraphicsEndImageContext();    
	
    if( pdf )
    {
        CGPDFDocumentRelease(pdf);
    }
    
END:
	
	return thumbnailImage;
}


- (UIImage *) thumbFromVideoAtPath: (NSString *) path inRect:(CGRect) thumbRect
{
	UIImage * thumb = nil;
	NSURL * url = [NSURL fileURLWithPath: path];
	if( url )
	{
		MPMoviePlayerController * player = [[MPMoviePlayerController alloc] init];		
		if( player )
		{
			[player setContentURL: url];			
			thumb = [player thumbnailImageAtTime: 10
									  timeOption: MPMovieTimeOptionNearestKeyFrame];
			
			[player stop];
			[player release];
			player = nil;
			
			thumb = [self thumbFromImage: thumb inRect:thumbRect];
		}
	}
	return thumb;
}
//
- (UIImage *) thumbFromImageAtPath: (NSString *) path inRect:(CGRect) thumbRect
{
	UIImage * imgRaw = [UIImage imageWithContentsOfFile: path];
	if( imgRaw )
	{
		return [self thumbFromImage: imgRaw inRect:thumbRect];
	}
	return nil;
}
					 
- (UIImage *) thumbFromImage:(UIImage *) anImage inRect:(CGRect) thumbRect
{
	CGSize aspectSize = sizeThatFitsKeepingAspectRatio(anImage.size, thumbRect.size);
	
	//UIImage * imgRes = [anImage resizedImage: thumbRect.size interpolationQuality: kCGInterpolationLow];
	UIImage * imgRes = [anImage resizedImage: aspectSize interpolationQuality: kCGInterpolationHigh];
	if( !imgRes )
	{
		//UIGraphicsBeginImageContext(thumbRect.size);
		UIGraphicsBeginImageContext(aspectSize);
		
		//[anImage drawInRect: thumbRect];
		[anImage drawInRect: CGRectMake(0, 0, aspectSize.width, aspectSize.height)];
					
		UIImage * theImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		return theImage;
	}
	return imgRes;
}
//
- (void) thumbFromDocAtPath: (NSString *) path inRect:(CGRect) thumbRect forDelegate:(id<UIWebViewDelegate>) delegate
{
	if( delegate )
	{
		NSURL * url = [NSURL fileURLWithPath:path];
		if( url )
		{
			NSURLRequest *request = [NSURLRequest requestWithURL:url];
			if( request )
			{
				UIWebView * web = [[UIWebView alloc] initWithFrame: thumbRect];
				web.delegate = delegate;
				web.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
				web.scalesPageToFit = YES;
				[web loadRequest:request];
				
				[arrViews addObject: web];
				[web release];
			}
		}
	}
}

- (void) completeForView:(UIWebView *) completedView
{
	if( arrViews && 0 < [arrViews count] )
	{
		[arrViews removeObject: completedView];
	}
}


@end
