//
//  NLBarcode.m
//  NewLeads
//
//  Created by idevs.com on 06/02/2015.
//  Copyright (c) 2015 idevs.com. All rights reserved.
//

#import "NLBarcode.h"

@implementation NLBarcode

#pragma mark >>> NSCopying
//
- (id) copyWithZone:(NSZone *)zone
{
	NLBarcode * barcode = [[NLBarcode allocWithZone:zone] init];
	
	[barcode setCodeValue:self.codeValue];
	[barcode setCodeSelected:self.codeSelected];
	[barcode setCodeName:[self.codeName copy]];
	[barcode setCodeDescription:[self.codeDescription copy]];
	
	return barcode;
}

#pragma mark >>> NSCoding
//
- (id) initWithCoder:(NSCoder *)aDecoder
{
	if( nil != (self = [super init]) )
	{
		[self setCodeValue:[aDecoder decodeObjectForKey:@"codeValue"]];
		[self setCodeSelected:[aDecoder decodeObjectForKey:@"codeSelected"]];
		[self setCodeName:[aDecoder decodeObjectForKey:@"codeName"]];
		[self setCodeDescription:[aDecoder decodeObjectForKey:@"codeDescription"]];
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:self.codeValue forKey:@"codeValue"];
	[aCoder encodeObject:self.codeSelected forKey:@"codeSelected"];
	[aCoder encodeObject:self.codeName forKey:@"codeName"];
	[aCoder encodeObject:self.codeDescription forKey:@"codeDescription"];
}


- (NSUInteger) code
{
	return [self.codeValue unsignedIntegerValue];
}

- (BOOL) isSelected
{
	return [self.codeSelected boolValue];
}

@end
