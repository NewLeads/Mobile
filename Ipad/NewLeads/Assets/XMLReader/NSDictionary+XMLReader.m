//
//  NSDictionary+XMLReader.m
//  Peek
//
//  Created by Arseniy Astapenko on 8/4/11.
//  Copyright 2011 idevs.com. All rights reserved.
//

#import "NSDictionary+XMLReader.h"

@implementation NSDictionary (XMLReader)

- (NSString*)valueForName:(NSString*)name success:(BOOL*)successPointer
{
	*successPointer = NO;
	
	id nameDict = (NSDictionary*)[self objectForKey:name];
	if (!nameDict) return nil;
	
	NSDictionary* stringDict = (NSDictionary*) nameDict;
	if ([nameDict isKindOfClass:[NSArray class]])
	{
		stringDict = [nameDict lastObject];
	}
		 
	NSString* stringValue = [stringDict objectForKey:@"attr"];
	if (!stringValue) return nil;
	
	*successPointer = YES;
	
	return stringValue;
}

- (NSString*)stringForName:(NSString*)name
{
	BOOL success;
	return [self valueForName:name success:&success];	
}

- (int)intForName:(NSString*)name success:(BOOL*)successPointer
{
	NSString* stringValue = [self valueForName:name success:successPointer];
	if (*successPointer==NO) return 0;
	
	int val = 0;
	if (![[NSScanner scannerWithString:stringValue] scanInt:&val])
	{
		*successPointer = NO;
		return 0;
	}
	else 
	{
		return val;
	}
}

- (float)floatForName:(NSString*)name success:(BOOL*)successPointer
{
	NSString* stringValue = [self valueForName:name success:successPointer];
	if (*successPointer==NO) return 0;
	
	float val = 0;
	if (![[NSScanner scannerWithString:stringValue] scanFloat:&val])
	{
		*successPointer = NO;
		return 0;
	}
	else 
	{
		return val;
	}	
}

- (double)doubleForName:(NSString*)name success:(BOOL*)successPointer
{
	NSString* stringValue = [self valueForName:name success:successPointer];
	if (*successPointer==NO) return 0;
	
	double val = 0;
	if (![[NSScanner scannerWithString:stringValue] scanDouble:&val])
	{
		*successPointer = NO;
		return 0;
	}
	else 
	{
		return val;
	}	
}

- (NSDictionary*) dictForName:(NSString*)name
{
	return (NSDictionary*)[self valueForKey:name];
}

- (NSDictionary*) dictInChildNodes:(NSString*)node, ... 
{
	if (!node) return nil;
	
	NSMutableArray* nodeList = [[NSMutableArray alloc] initWithCapacity:1];
	va_list voList;
	id voNext;
	[nodeList addObject:node];			
	va_start(voList, node);
	while ((voNext = va_arg(voList, id)) != nil)
	{
		[nodeList addObject: voNext];
	}
	va_end(voList);
	
	
	NSDictionary* resDict = nil;
	
	for (NSString* nextNode in nodeList)
	{
		if (!resDict)
		{	
			resDict = [self dictForName:nextNode];
		}
		else
		{
			resDict = [NSDictionary dictionaryWithDictionary:[resDict dictForName: nextNode]];
		}		
		if (!resDict) break;
	}
	
	[nodeList release];
	
	return resDict;
	
}

- (NSArray*) arrayOfNodesForName:(NSString*)name
{	
	id objNode = [self objectForKey:name];
	if (!objNode) return nil;	
	if ([objNode isKindOfClass:[NSArray class]])
	{
		return (NSArray*)objNode;
	}
	else
	if ([objNode isKindOfClass:[NSDictionary class]])
	{
		return [NSArray arrayWithObject:objNode];
	}
	else
	return nil;	
}

@end
