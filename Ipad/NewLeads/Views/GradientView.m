//
//  GradientView.m
//  NewLeads
//
//  Created by idevs.com on 27/06/2011.
//  Copyright 2011 idevs.com. All rights reserved.
//

#import "GradientView.h"


@interface GradientView ()

- (void) setup;
- (void) drawInContext:(CGContextRef)context;
//
- (CGGradientDrawingOptions) drawingOptions;
- (CGPoint) LGStart:(CGRect) bounds;
- (CGPoint) LGEnd:(CGRect) bounds;
- (CGPoint) RGCenter:(CGRect) bounds;
- (CGFloat) RGInnerRadius:(CGRect) bounds;
- (CGFloat) RGOuterRadius:(CGRect) bounds;

@end


@implementation GradientView

@synthesize type;


- (id) initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if(self != nil)
	{
		isInited = NO;
		gradient = NULL;
		[self setup];
	}
	return self;
}

- (void) dealloc
{
	CGGradientRelease(gradient);
	[super dealloc];
}

- (void) willMoveToSuperview:(UIView *)newSuperview
{
	[self setup];
}

- (void) setup
{
	if( !isInited )
	{
		self.type = kRadialGradient;
		CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
		CGFloat colors[] =
		{
			67.0 / 255.0,  67.0 / 255.0,  67.0 / 255.0, 1.00, // Center
			53.0 / 255.0,  53.0 / 255.0,  53.0 / 255.0, 1.00, // Middle
			44.0 / 255.0,  44.0 / 255.0,  44.0 / 255.0, 1.00, // Outer
		};
		gradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4));
		CGColorSpaceRelease(rgb);
		
		isInited = YES;
	}
}

- (void) setColorArray:(NSArray *) newColors
{
	if( !newColors || 2 > [newColors count] )
		return;
	
	if( gradient )
	{
		CGGradientRelease(gradient);
		gradient = NULL;
	}
	
	CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
	CGFloat locations[3];
	if( kLinearGradient == type )
	{
		locations[0] = 0.f;
		locations[1] = 1.f;
	}
	else if( kRadialGradient == type )
	{
		locations[0] = 0.f;
		locations[2] = 1.f;
		locations[1] = 0.43f;
	}
	gradient = CGGradientCreateWithColors(rgb, (CFArrayRef)newColors, locations);
	
	/*
	if( kLinearGradient == type )
	{
		CGFloat colors[8] = {0};
		
		for( int i = 0, j = 0; i < 8; i += 4, j++ )
		{
			const CGFloat * components = CGColorGetComponents(((UIColor *)[newColors objectAtIndex: j]).CGColor);
			int num = CGColorGetNumberOfComponents(((UIColor *)[newColors objectAtIndex: j]).CGColor);
			for( int k = 0; k < num; k++ )
			{
				colors[i+k] = components[k];
			}
		}
		gradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4));
	}
	else if( kRadialGradient == type )
	{
		CGFloat colors[12] = {0};
		for( int i = 0, j = 0; i < 12; i += 4, j++ )
		{
			const CGFloat * components = CGColorGetComponents(((UIColor *)[newColors objectAtIndex: j]).CGColor);
			int num = CGColorGetNumberOfComponents(((UIColor *)[newColors objectAtIndex: j]).CGColor);
			for( int k = 0; k < num; k++ )
			{
				colors[i+k] = components[k];
			}
		}
		gradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4));
	}
	 */
	CGColorSpaceRelease(rgb);
}

- (void) setType:(int)newType
{
	if(newType != type)
	{
		type = newType;
		[self setNeedsDisplay];
	}
}

- (void) drawRect:(CGRect)rect
{
	// Since we use the CGContextRef a lot, it is convienient for our demonstration classes to do the real work
	// inside of a method that passes the context as a parameter, rather than having to query the context
	// continuously, or setup that parameter for every subclass.
	[self drawInContext:UIGraphicsGetCurrentContext()];
}


// Returns an appropriate starting point for the demonstration of a linear gradient
- (CGPoint) LGStart:(CGRect) bounds
{
	return CGPointMake(bounds.origin.x, bounds.origin.y + bounds.size.height * 0.25);
}

// Returns an appropriate ending point for the demonstration of a linear gradient
- (CGPoint) LGEnd:(CGRect) bounds
{
	return CGPointMake(bounds.origin.x, bounds.origin.y + bounds.size.height * 0.75);
}

// Returns the center point for for the demonstration of the radial gradient
- (CGPoint) RGCenter:(CGRect) bounds
{
	return CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
}

// Returns an appropriate inner radius for the demonstration of the radial gradient
- (CGFloat) RGInnerRadius:(CGRect) bounds
{
	CGFloat r = bounds.size.width < bounds.size.height ? bounds.size.width : bounds.size.height;
	return r * 0.125f;
}

// Returns an appropriate outer radius for the demonstration of the radial gradient
- (CGFloat) RGOuterRadius:(CGRect) bounds
{
	CGFloat r = bounds.size.width < bounds.size.height ? bounds.size.width : bounds.size.height;
	return r * 0.95f;
}

- (CGGradientDrawingOptions) drawingOptions
{
	CGGradientDrawingOptions options = 0;
	options |= kCGGradientDrawsBeforeStartLocation;
	options |= kCGGradientDrawsAfterEndLocation;

	return options;
}

- (void) drawInContext:(CGContextRef)context
{
	// Use the clip bounding box, sans a generous border
	CGRect clip = CGRectInset(CGContextGetClipBoundingBox(context), 0.0, 0.0);
	
	CGPoint start, end;
	CGFloat startRadius, endRadius;
	
	// Clip to area to draw the gradient, and draw it. Since we are clipping, we save the graphics state
	// so that we can revert to the previous larger area.
	CGContextSaveGState(context);
	CGContextClipToRect(context, clip);
	
	CGGradientDrawingOptions options = [self drawingOptions];
	switch(type)
	{
		case kLinearGradient:
			// A linear gradient requires only a starting & ending point.
			// The colors of the gradient are linearly interpolated along the line segment connecting these two points
			// A gradient location of 0.0 means that color is expressed fully at the 'start' point
			// a location of 1.0 means that color is expressed fully at the 'end' point.
			// The gradient fills outwards perpendicular to the line segment connectiong start & end points
			// (which is why we need to clip the context, or the gradient would fill beyond where we want it to).
			// The gradient options (last) parameter determines what how to fill the clip area that is "before" and "after"
			// the line segment connecting start & end.
			start = [self LGStart:clip];
			end = [self LGEnd:clip ];
			CGContextDrawLinearGradient(context, gradient, start, end, options);
			CGContextRestoreGState(context);
			break;
			
		case kRadialGradient:
			// A radial gradient requires a start & end point as well as a start & end radius.
			// Logically a radial gradient is created by linearly interpolating the center, radius and color of each
			// circle using the start and end point for the center, start and end radius for the radius, and the color ramp
			// inherant to the gradient to create a set of stroked circles that fill the area completely.
			// The gradient options specify if this interpolation continues past the start or end points as it does with
			// linear gradients.
			start = end = [self RGCenter:clip];
			startRadius = [self RGInnerRadius:clip];
			endRadius = [self RGOuterRadius:clip];
			CGContextDrawRadialGradient(context, gradient, start, startRadius, end, endRadius, options);
			CGContextRestoreGState(context);
			break;
	}
}


@end
