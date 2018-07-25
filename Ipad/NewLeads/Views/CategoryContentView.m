//
//  CategoryContentView.m
//  NewLeads
//
//  Created by idevs.com on 28/06/2011.
//  Copyright 2011 idevs.com. All rights reserved.
//

#import "CategoryContentView.h"
#import "NLLeadsViewController.h"
#import "GradientView.h"
#import "GridControl.h"
#import "ContentGridItem.h"
#import "CGRThumbCreatorAssets.h"
#import "ModelContentItem.h"
#import <QuartzCore/QuartzCore.h>
#import "NLWebBrowserViewController.h"



@interface CategoryContentView ()

- (void) setup;
- (void) updateBG;
- (void) updateToolbar;
- (void) onClose;
- (void) onPrev;
- (void) onNext;
- (void) onFavorite;
//
- (void) pushContentViewer;
- (void) popContentViewer;
//
- (void) pushFolder;
- (void) popFolder;

@end



@implementation CategoryContentView

@synthesize parent;

- (id) initWithFrame:(CGRect) frame 
{
	if( nil != (self = [super initWithFrame: frame]) )
	{
		[self setup];
	}
	return self;
}

- (id) initWithCoder:(NSCoder *) aDecoder
{
	if( nil != (self = [super initWithCoder:aDecoder]) )
	{
		[self setup];
	}
	return self;
}

- (void) dealloc
{
	//[viewBG release];
//	viewBG = nil;

	[viewToolbar release];
	viewToolbar = nil;
	
	[btnClose release];
	btnClose = nil;
	
	[btnPrev release];
	btnPrev = nil;
	
	[btnNext release];
	btnNext = nil;
	
	[labelTitle release];
	labelTitle = nil;
	
	[contentItemViewer release];
	contentItemViewer = nil;
	
    [super dealloc];
}

- (void) setup
{
	/*
	viewBG = [[GradientView alloc] initWithFrame: self.bounds];	
	viewBG.type = kRadialGradient;
//	NSArray * newArr =[NSArray arrayWithObjects:
//					   (id)[[UIColor colorWithRed:200/255 green:200/255 blue:200/255 alpha:0.5] CGColor], // Center
//					   (id)[[UIColor colorWithRed:180/255 green:180/255 blue:180/255 alpha:0.5] CGColor], // Middle
//					   (id)[[UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:0.5] CGColor], // Outer
//					   nil];
//	[viewBG setColorArray: newArr];
	[self insertSubview:viewBG atIndex: 0]; // <~~~ Add below all views...
	 */
	//viewBG = [[UIImageView alloc] initWithFrame:self.bounds];
//	viewBG.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
//	
//	[self updateBG];
//	[self insertSubview:viewBG atIndex: 0];
	
	/*
	viewToolbar = [[GradientView alloc] initWithFrame: CGRectMake(0, 0, self.bounds.size.width, 44)];
	viewToolbar.type = kLinearGradient;
	NSArray * newArr =[NSArray arrayWithObjects:
					   (id)[[UIColor colorWithRed:0.33 green:0.33 blue:0.33 alpha:0.5] CGColor],
					   (id)[[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.3] CGColor],
					   nil];
	
	[viewToolbar setColorArray: newArr];
	*/
	viewToolbar = [[UIImageView alloc] initWithFrame:self.bounds];
	viewToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self updateToolbar];
	
	btnClose = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	[btnClose setBackgroundImage:[UIImage imageNamed:@"btn_close.png"] forState:UIControlStateNormal];
	[btnClose addTarget: self action: @selector(onClose) forControlEvents: UIControlEventTouchUpInside];
	
	//[btnClose setTitle: @"Close" forState:UIControlStateNormal];
	//btnClose.titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	//btnClose.titleLabel.font = [UIFont boldSystemFontOfSize: 14];
	//btnClose.titleLabel.minimumScaleFactor = 14;
	
	
	btnPrev = [[UIButton alloc] initWithFrame:CGRectMake( 0, 5, 37, 33)];
	[btnPrev setImage:[UIImage imageNamed:@"btn_prev.png"] forState:UIControlStateNormal];
	[btnPrev addTarget: self action: @selector(onPrev) forControlEvents: UIControlEventTouchUpInside];
	
	btnNext = [[UIButton alloc] initWithFrame:CGRectMake( 0, 5, 37, 33)];
	[btnNext setImage:[UIImage imageNamed:@"btn_next.png"] forState:UIControlStateNormal];
	[btnNext addTarget: self action: @selector(onNext) forControlEvents: UIControlEventTouchUpInside];
	
	btnFavorite = [[UIButton alloc] initWithFrame:CGRectMake( 0, 0, 44, 44)];
	[btnFavorite setImage:[UIImage imageNamed:@"icon-fav-big"] forState:UIControlStateNormal];
	[btnFavorite setImage:[UIImage imageNamed:@"icon-fav-big-active"] forState:UIControlStateSelected];
	[btnFavorite addTarget: self action: @selector(onFavorite) forControlEvents: UIControlEventTouchUpInside];
	
	labelTitle = [[UILabel alloc] initWithFrame:self.bounds];
	labelTitle.textAlignment	= NSTextAlignmentCenter;
	labelTitle.font				= [UIFont boldSystemFontOfSize:14.0];
	labelTitle.minimumScaleFactor= 12.f/14.f;
	labelTitle.textColor		= [UIColor whiteColor];
	labelTitle.backgroundColor	= [UIColor clearColor];
	labelTitle.autoresizingMask	= UIViewAutoresizingFlexibleWidth;
	
	contentItemViewer = [[UIWebView alloc] initWithFrame:self.bounds];
	contentItemViewer.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	contentItemViewer.scalesPageToFit = YES;
	contentItemViewer.delegate = self;	
	contentItemViewer.tag = 444;
	
	//contentItemViewer.layer.borderColor = [[UIColor redColor] CGColor];
	//contentItemViewer.layer.borderWidth = 2;
}

- (void) layoutSubviews
{
	[super layoutSubviews];
	
	if( 0 < [NLContext shared].leadID )
	{
		btnFavorite.hidden = NO;
	}
	else
	{
		btnFavorite.hidden = YES;
	}
	//
	// BG:
	//viewBG.frame = self.bounds;
	[self updateBG];
	
	//
	// Toolbar:
	[self updateToolbar];
	btnClose.frame = CGRectMake( 7, 44/2-36/2, 66, 32);
	btnPrev.frame = CGRectMake( self.bounds.size.width - 5*2 - 37*2, 5, 37, 33);
	btnNext.frame = CGRectMake( self.bounds.size.width - 5 - 37, 5, 37, 33);
	btnFavorite.frame = CGRectMake( btnPrev.frame.origin.x - btnFavorite.frame.size.width - 5 , (viewToolbar.bounds.size.height - btnFavorite.frame.size.height)/2, btnFavorite.frame.size.width, btnFavorite.frame.size.height);
	float posX = btnClose.frame.origin.x + btnClose.frame.size.width + 20.f;
	labelTitle.frame = CGRectMake(posX, 
								  0, 
								  self.bounds.size.width - (self.bounds.size.width - btnPrev.frame.origin.x) - posX - 20,
								  44);
	
	//
	// Showroom:
	contentItemViewer.frame = CGRectMake(0, viewToolbar.frame.size.height, 
									 self.bounds.size.width, 
									 self.bounds.size.height - viewToolbar.frame.size.height);
	
	if( currentFolder )
	{
		//currentFolder.frame = self.bounds;
	}
}



#pragma mark -
#pragma mark Core logic
//
- (void) showContentFromView:(UIView *) anView
{
	contentViewer = anView;
	
	[self addSubview: contentViewer];
}

- (void) showContentFromItem:(ContentGridItem *) anItem
{
	switch( anItem.modelItem.itemBaseType )
	{
		case kCGRFolder:
		{
			//
			// Currently support folders with one level of deep.
			//
			currendDataSource	= anItem.modelItem.itemContent;
			[self pushFolder];
		}
			break;
		case kCGRImage:
		case kCGRVideo:
			contentItemViewer.mediaPlaybackRequiresUserAction = YES;
		case kCGRPDF:
		case kCGRDocument_Early_3_0:
		case kCGRDocument_Late_3_0:
		{
			NSURL * url = [NSURL fileURLWithPath: anItem.modelItem.itemPath isDirectory: NO];
			if( url )
			{
				NSURLRequest *request = [NSURLRequest requestWithURL:url];
				if( request )
				{
					webCleanup = NO;
					
					currentItem		= anItem;
					labelTitle.text = anItem.modelItem.itemName;

					[self pushContentViewer];
					
					[contentItemViewer loadRequest: request];
					
					//
					// Stat:
					[parent.stat startDocWithItem:anItem.modelItem];
				}
			}
		}
			break;
		default:
			break;
	}
}

- (void) stop
{
	[parent showHUD:NO];
	
	[contentViewer removeFromSuperview];
	contentViewer = nil;
	
	[self onClose];
	[self popFolder];
}

- (void) onClose
{
	[self popContentViewer];
}

- (void) onFavorite
{
	//
	// Update model data:
	[currentItem setFavorite: !currentItem.modelItem.isFavorite];
	//
	// Update button UI:
	btnFavorite.selected = currentItem.modelItem.isFavorite;
	//
	// Update stat info:
	[parent.stat updateFavoriteForItem:currentItem.modelItem];
}

- (void) onPrev
{
	if( currentFolder )
	{
		currentItemIndex--;
		NSInteger count = (NSInteger)[currentFolder.items count];
		if( 0 > currentItemIndex )
		{
			currentItemIndex = count - 1;
		}
		
		ContentGridItem * item = [currentFolder.items objectAtIndex: currentItemIndex];
		
		int counter = 0;
		while( kCGRFolder == item.modelItem.itemBaseType )
		{
			counter++;
			currentItemIndex--;
			if( 0 > currentItemIndex )
			{
				currentItemIndex = count - 1;
				return;
			}
			if( counter >= count )
			{
				// No valid content available
				return;
			}
			item = [currentFolder.items objectAtIndex: currentItemIndex];
		}
		[self showContentFromItem: (ContentGridItem * )[currentFolder.items objectAtIndex: currentItemIndex]];
	}
	else if( parent )
	{
		[parent prevItem];
	}
}

- (void) onNext
{
	if( currentFolder )
	{
		currentItemIndex++;
		NSInteger count = (NSInteger)[currentFolder.items count];
		if( currentItemIndex >= count )
		{
			currentItemIndex = 0;
		}
		
		ContentGridItem * item = [currentFolder.items objectAtIndex: currentItemIndex];
		int counter = 0;
		while( kCGRFolder == item.modelItem.itemBaseType )
		{
			counter++;
			currentItemIndex++;
			if( currentItemIndex >= count )
			{
				currentItemIndex = 0;
			}
			if( counter >= count )
			{
				// No valid content available
				return;
			}
			item = [currentFolder.items objectAtIndex: currentItemIndex];
		}
		[self showContentFromItem: (ContentGridItem * )[currentFolder.items objectAtIndex: currentItemIndex]];
	}
	else if( parent )
	{
		[parent nextItem];
	}
}

- (void) pushContentViewer
{
	if( self != [contentItemViewer superview] )
	{
		[self addSubview: contentItemViewer];
		[self addSubview: viewToolbar];
		[self addSubview: btnClose];
		[self addSubview: btnPrev];
		[self addSubview: btnNext];
		[self addSubview: btnFavorite];
		[self addSubview: labelTitle];
	}
	//
	// Update button state:
	btnFavorite.selected = currentItem.modelItem.isFavorite;
	
	[parent showHUD:YES animated:NO withText:@"Loading..."];
}

- (void) popContentViewer
{
	if( self == [contentItemViewer superview] )
	{
		[btnClose removeFromSuperview];
		[btnPrev removeFromSuperview];
		[btnNext removeFromSuperview];
		[btnFavorite removeFromSuperview];
		[viewToolbar removeFromSuperview];
		[labelTitle removeFromSuperview];
		[contentItemViewer removeFromSuperview];
		
		labelTitle.text = @"";
		
		webCleanup = YES;
		[contentItemViewer loadHTMLString:@"<html><body></body></html>" baseURL:nil];

		//
		// Stat:
		[parent.stat endCurrentDocument];
	}
}

- (void) pushFolder
{
	if( !currentFolder )
	{
		currentFolder = [[GridControl alloc] initWithFrame: self.bounds];
		currentFolder.delegate = self;
		currentFolder.gridDelegate = self;
		currentFolder.gridDataSource = self;
		
		[self popContentViewer];
		
		if( contentViewer )
		{
			[contentViewer removeFromSuperview];
		}
		
		[self addSubview: currentFolder];
		[currentFolder reloadData];
		
		for( ContentGridItem * item in currentFolder.items )
		{
			item.parent = parent;
		}
		[self setNeedsDisplay];
	}
}

- (void) popFolder
{
	if( currentFolder )
	{
		currentFolder.delegate = nil;
		[currentFolder removeFromSuperview];
		[currentFolder release];
		
		if( contentViewer )
		{
			[self addSubview: contentViewer];
		}
		
		currentFolder = nil;
		currendDataSource = nil;
	}
}

- (void) unSelectAll
{
	[currentFolder unSelectAll];
}

- (void) unHighlightAll
{
	[currentFolder unHighlightAll];
}



#pragma mark -
#pragma mark Private
//
- (void) updateBG
{
	//if( UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) )
//	{
//		viewBG.image = [UIImage imageNamed:@"bg_v.png"];
//	}
//	else if(UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
//	{
//		viewBG.image = [UIImage imageNamed:@"bg_h.png"];
//	}
//	viewBG.frame = self.frame;
}

- (void) updateToolbar
{
	viewToolbar.image = [NLUtils stretchedImageNamed:@"bg-nav-bar" width:CGRectMake(0, 1, 0, 0)];
	viewToolbar.frame = CGRectMake(0, 0, self.bounds.size.width, viewToolbar.image.size.height);
}



#pragma mark -
#pragma mark GridControlDelegate
//
- (void) gridContol:(GridControl *) inControl didSelectItemAtIndex:(NSUInteger) inIndex withItem:(GridItem *) inItem
{
	if( kCGRFolder != ((ContentGridItem*)inItem).modelItem.itemBaseType )
	{
		currentItemIndex = inIndex;
		[self showContentFromItem: (ContentGridItem*) inItem];
	}
}



#pragma mark -
#pragma mark GridControlDatasourceDelegate
//
- (NSInteger) numberOfItemsInGridControl:(GridControl *) inControl
{
	return [currendDataSource count];
}

- (CGSize) gridControl:(GridControl *) inControl sizeForItemAtIndex:(NSUInteger) inIndex
{
	return [ContentGridItem sizeItem];
}

- (GridItem *) gridControl:(GridControl *) inControl itemForControlAtIndex:(NSUInteger) inIndex
{
	return [[[ContentGridItem alloc] initWithFrame:CGRectMake(0, 0, [ContentGridItem sizeItem].width, [ContentGridItem sizeItem].height)] autorelease];
}

- (ModelContentItem *) gridControl:(GridControl *) inControl dataForItemAtIndex:(NSUInteger) inIndex
{
	return [currendDataSource objectAtIndex: inIndex];
}



#pragma mark -
#pragma mark UIWebView delegate
//
- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
#if DEBUG == 1
//	NSLog(@"%@ - %@. NavType = %d, %@", [self class], NSStringFromSelector(_cmd), navigationType, request.URL);
//	NSLog(@"scheme = %@, isRefernceURL = %d", [request.URL scheme],[request.URL isFileReferenceURL]);
#endif
	
	if( [[request.URL scheme] isEqualToString:@"http"] )
	{
		NLWebBrowserViewController * wb = [[NLWebBrowserViewController alloc] initWithNibName:@"NLWebBrowserViewController" bundle:nil];
		wb.latestRequest = request;
		
		[parent.navigationController presentViewController:wb animated:YES completion:nil];
		
		[wb release];
		
		return NO;
	}
	else
	{
		return YES;
	}
}

- (void) webViewDidStartLoad:(UIWebView *)webView
{
	if( webCleanup )
	{
		return;
	}
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
	if( webCleanup )
	{
		return;
	}
	
	[parent showHUD:NO];
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	if( webCleanup )
	{
		return;
	}
	
	[parent showHUD:NO];
	
	if([error code] == NSURLErrorCancelled)
		return;
	
	if([error code] == 204) // <~~~ ignore Domain=WebKitErrorDomain Code=204 "Plug-in handled load"
		return;
	
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"Cannot open path"
													message: [NSString stringWithFormat:@"Cannot open path: %@", [error localizedDescription]]
												   delegate: self
										  cancelButtonTitle: @"Ok"
										  otherButtonTitles: nil];
	[alert show];
	[alert release];
}



#pragma mark -
#pragma mark UIScrollView delegate
//
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	[self unSelectAll];
}

@end
