//
//  HeaderView.m
//  NewLeads
//
//  Created by idevs.com on 27/06/2011.
//  Copyright 2011 idevs.com. All rights reserved.
//

#import "HeaderView.h"
#import "GradientView.h"



#pragma mark -
#pragma mark Configuration
//
const CGFloat	kLeftLogoTopMargin		= 8;
const CGFloat	kLeftLogoSideMargin		= 8;
const CGFloat	kRightLogoTopMargin		= 6;
const CGFloat	kRightLogoSideMargin	= 6;



@interface HeaderView ()

//
// UI - XIB:
@property (nonatomic, readwrite, assign) IBOutlet UILabel		* labelTitle;
@property (nonatomic, readwrite, assign) IBOutlet UIImageView	* viewLeftLogo;
@property (nonatomic, readwrite, assign) IBOutlet UIImageView	* viewRightLogo;
//
// UI:
@property (nonatomic, readwrite, retain) UIImageView			* viewBG;

- (void) setup;
- (void) updateBG;

@end



@implementation HeaderView


- (id) initWithFrame:(CGRect) frame 
{
	if( nil != (self = [super initWithFrame: frame]) )
	{
		[self setup];
	}
	return self;
}

//- (id) initWithCoder:(NSCoder *)aDecoder
//{
//	if( nil != (self = [super initWithCoder:aDecoder]) )
//	{
//		[self setup];
//	}
//	return self;
//}

- (void) awakeFromNib
{
	[super awakeFromNib];
	
	[self setup];
}

- (void) dealloc
{
//	if( imageLeftLogo )
//	{
//		[imageLeftLogo release];
//	}
	
	if( self.viewBG )
	{
		self.viewBG = nil;
	}
	self.viewLeftLogo = nil;
	self.viewRightLogo = nil;
	
    [super dealloc];
}

- (void) setup
{
	if( !self.viewBG )
	{
		self.viewBG = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
		self.viewBG.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		
		[self updateBG];
		[self insertSubview:self.viewBG atIndex:0];
	}
}

- (void) layoutSubviews
{
	//
	// BG:
	//viewBG.frame = self.bounds;
	[self updateBG];
	
	//
	// Left logo:
	CGRect frame_ = self.viewLeftLogo.frame;
	frame_.origin = CGPointMake(kLeftLogoSideMargin, CGRectGetMidY(self.frame) - CGRectGetHeight(frame_)/2);
	self.viewLeftLogo.frame = frame_;
	
	//
	// Right logo:
	frame_ = self.viewRightLogo.frame;
	frame_.origin = CGPointMake(self.frame.size.width - frame_.size.width - kRightLogoSideMargin, CGRectGetMidY(self.frame) - CGRectGetHeight(frame_)/2);
	self.viewRightLogo.frame = frame_;
	
	//
	// Title:
	self.labelTitle.center = CGPointMake( CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) );
}

- (void) updateLeftLogoImage:(UIImage *) anImage
{
	if( nil == anImage )
	{
		self.viewLeftLogo.image = nil;//imageLeftLogo;
	}
	else
	{
		self.viewLeftLogo.image = anImage;
	}
}



#pragma mark -
#pragma mark Title
//
- (void) setTitle:(NSString *) newTile
{
	self.labelTitle.text = newTile;
}

- (NSString *) title
{
	return self.labelTitle.text;
}



#pragma mark -
#pragma mark Private
//
- (void) updateBG
{
	self.viewBG.image = [NLUtils stretchedImageNamed:@"bg-nav-bar" width:CGRectMake(0, 1, 0, 0)];
	self.viewBG.frame = self.bounds;
}

@end
