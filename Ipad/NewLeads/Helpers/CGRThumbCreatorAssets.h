/*
 *  CGRThumbCreatorAssets.h
 *
 *  Created by idevs.com on 21/06/2011.
 *  Copyright 2011 idevs.com. All rights reserved.
 *
 */


@protocol CGRThumbCreatorProtocol < NSObject >

@optional
- (void) thumbCreatorDidCompleted:(UIImage *) thumb;
- (void) thumbCreatorDidFailed;

@end



/*
 * For details see:
 * - Technical Q&A QA1630. Using UIWebView to display select document types.
 * - MPMoviePlayerController Class Reference - Supported Formats.
 * - UIImage Class Reference - Supported Image Formats.
 *
 */
typedef enum
{
	kCGRUnknown = 0,
	kCGRFolder,					// Folder - container for other items...
	kCGRImage,
	kCGRVideo,
	kCGRPDF,
	kCGRDocument_Early_3_0,
	kCGRDocument_Late_3_0,
	
} CGRBaseType;

typedef enum
{
	kCGRImageUnknown = 0,
	kCGRImageTIFF,		// *.tiff, *.tif
	kCGRImageJPG,		// *.jpg, *.jpeg,
	kCGRImageGIF,		// *.gif
	kCGRImagePNG,		// *.png
	kCGRImageBMP,		// *.bmp, *.BMPf
	kCGRImageICO,		// *.ico
	kCGRImageCUR,		// *.cur
	kCGRImageXBM,		// *.xbm
	
} CGRImageType;

typedef enum
{
	kCGRVideoUnknown = 0,
	kCGRVideoMOV,		// *.mov
	kCGRVideoMP4,		// *.mp4
	kCGRVideoMPV,		// *.mpv
	kCGRVideo3GP,		// *.3gp
	
} CGRVideoType;

typedef enum
{
	kCGRTxt,			// *.txt
	kCGRHtml,			// *.htm/html
	kCGRPowerpoint,		// *.ppt
	kCGRWord,			// *.doc
	kCGRExcel,			// *.xls
	kCGRKeynote,		// *.key.zip
	kCGRNumbers,		// *.numbers.zip
	kCGRPages,			// *.pages.zip
	
} CGRDocumentEarly30Type;

typedef enum
{
	kCGRRTF,			// *.rtf
	kCGRRTFD,			// *.rtfd.zip
	kCGRKeynote_09,		// *.key
	kCGRNumbers_09,		// *.numbers
	kCGRPages_09		// *.pages
	
} CGRDocumentLate30Type;
