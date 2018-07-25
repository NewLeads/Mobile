//
//  AdminLogger.m
//  NewLeads
//
//  Created by Karnyenka Andrew on 30/01/2012.
//  Copyright (c) 2012 idevs.com. All rights reserved.
//

#import "AdminLogger.h"



#pragma mark Configuration
//
NSString * const kALFileName	= @"log";
NSString * const kALFileExt		= @"txt";



@implementation AdminLogger

- (id) init 
{
    if( nil != (self = [super init]) )
	{
		log = [[NSMutableString alloc] init];
    }
    return self;
}

- (void) dealloc 
{
	[log release];
	log = nil;
	
    [super dealloc];
}



#pragma mark Core logic
//
- (void) log:(NSString*)message, ...
{
	va_list params;
	va_start(params, message);
	
	NSString* info = [[NSString alloc] initWithFormat:message arguments:params];
	[log appendString: info];
	[info release];
}

- (void) flush
{
	if( 0 == [log length] )
		return;
	
	NSArray	* paths		= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString * documents= [NSString stringWithString:[paths objectAtIndex:0]];
	NSString * filePath	= [NSString stringWithFormat:@"%@/%@.%@", documents, kALFileName, kALFileExt];

	if( filePath )
	{
		NSError * error = nil;
		if( ![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error] )
		{
			if( error )
			{
				NSLog(@"%@. Can't open log file! Error = %@", [self class], [error localizedDescription]);
			}
		}
		
		error = nil;
		
		[log writeToFile: filePath
			  atomically: YES
				encoding: NSUTF8StringEncoding
				   error: &error];
		
		if( error )
		{
			NSLog(@"%@. Can't write log file! Error = %@", [self class], [error localizedDescription]);
		}
	}
	
	[log deleteCharactersInRange:NSMakeRange(0, [log length])];
}

- (NSString *) logContent
{
	NSString * fileContent = nil;
	
	NSArray	* paths		= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString * documents= [NSString stringWithString:[paths objectAtIndex:0]];
	NSString * filePath	= [NSString stringWithFormat:@"%@/%@.%@", documents, kALFileName, kALFileExt];
	
	BOOL isDirectory = NO;
	if( filePath && [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory] )
	{
		NSError * error = nil;
		fileContent = [NSString stringWithContentsOfFile: filePath
												encoding: NSUTF8StringEncoding
												   error: &error];
		
		if( error )
		{
			NSLog(@"%@. Can't open log file! Error = %@", [self class], [error localizedDescription]);
		}
	}
	
	return fileContent;
}

@end
