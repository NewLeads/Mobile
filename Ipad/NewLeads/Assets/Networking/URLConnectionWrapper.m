//
//  URLConnectionWrapper.m
//  NewLeads
//
//  Created by idevs.com on 28/09/2011.
//  Copyright 2011 idevs.com. All rights reserved.
//


#import "URLConnectionWrapper.h"



#pragma mark - Configuration
//
NSString * const kURLConnectionWrapperErrorDomain	= @"URLConnectionWrapperErrorDomain";
//
NSInteger kURLConnectionWrapperTimeout				= 60.f;
//
static BOOL	debugEnabled;



@interface URLConnectionWrapper ()

@property (nonatomic, readwrite, retain) NSURLConnection	* connection;
@property (nonatomic, readwrite, retain) NSMutableData		* receivedData;
@property (nonatomic, readwrite, retain) NSOutputStream		* fileStream;
@property (nonatomic, readwrite, copy) NSString				* filePath;

- (void) destroyConn;
- (void) cleanupConn;

@end



@implementation URLConnectionWrapper

@synthesize connection, receivedData, fileStream, filePath;
@synthesize delegate, userInfo, originalURL, error;
@synthesize progress, downloadedLength, expectedLength;


+ (void) enableDebug:(BOOL) anFlag
{
	debugEnabled = anFlag;
}

// Init:
+ (id) connectionWithString:(NSString *) anAddressString
{
	NSURL * newURL = [NSURL URLWithString: anAddressString];
	if( newURL )
	{
		return [[[URLConnectionWrapper alloc] initConnectionWithURL: newURL] autorelease];
	}
	
	return nil;
}

+ (id) connectionWithURL:(NSURL *) anURL
{
	if( anURL )
	{
		return [[[URLConnectionWrapper alloc] initConnectionWithURL: anURL] autorelease];
	}
	
	return nil;
}
//
- (id) initConnectionWithString:(NSString *) anAddressString
{
	if( anAddressString )
	{
		NSURL * newURL = [NSURL URLWithString: anAddressString];
		if( newURL )
		{
			return [self initConnectionWithURL: newURL];
		}
	}
	return nil;
}

- (id) initConnectionWithURL:(NSURL *) anURL
{
	if( nil != (self = [super init]) )
	{
		connTimeout			= kURLConnectionWrapperTimeout;
		self.originalURL	= anURL;
	}
	return self;
}

- (void) dealloc
{
	self.originalURL = nil;
	self.error = nil;
	self.userInfo = nil;
	
	[self cancelConnection];
	
	[super dealloc];
}



#pragma mark - Core logic
//
- (BOOL) startConnection
{
	connectionExists = NO;
	
	errorCode = kConn_NoError;
	errorString = nil;

	progress		= 0;
	expectedLength	= 0;
	downloadedLength= 0;
	
	
	NSURLRequest * request = [[NSURLRequest alloc] initWithURL: originalURL
												   cachePolicy: NSURLRequestUseProtocolCachePolicy
											   timeoutInterval: connTimeout];
	if( request )
	{
		//
		// Memory leak workaround.
		// Source: http://www.friendlydeveloper.com/2010/04/successfully-working-around-the-infamous-nsurlconnection-leak/
		//
		[[NSURLCache sharedURLCache] setMemoryCapacity:0];
		[[NSURLCache sharedURLCache] setDiskCapacity:0];
		
		self.connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
		
		[request release];
		request = nil;
		
		if( self.connection )
		{
			timeOut = CFAbsoluteTimeGetCurrent();
			
			if( self.filePath )
			{
				self.fileStream = [[[NSOutputStream alloc] initToFileAtPath: filePath append:NO] autorelease];
				if( self.fileStream )
				{
					[self.fileStream open];
				}
			}
			else
			{
				self.receivedData = [[[NSMutableData alloc] init] autorelease];
			}
			
			if( delegate )
			{
				[delegate connectionStarted: self];
			}
			
			return YES;
		}
		else
		{
			errorCode	= kConn_NotReachable;
			errorString	= [NSString stringWithFormat:@"Create connection failed! Unknown error."];
			
			self.error = [[[NSError alloc] initWithDomain: kURLConnectionWrapperErrorDomain 
													 code: errorCode
												 userInfo: [NSDictionary dictionaryWithObjectsAndKeys:errorString,NSLocalizedDescriptionKey,nil]] autorelease]; 
			if( delegate )
			{
				[delegate connectionFailed: self];
			}
		}
	}
	
	return NO;
}

- (BOOL) pauseConnection
{
	// TODO: Add logic here...
	return YES;
}

- (void) cancelConnection
{
	[self cleanupConn];
	
	if( delegate && [delegate respondsToSelector:@selector(connectionCancelled:)] )
	{
		[delegate connectionCancelled:self];
	}
}

- (void) destroyConn
{
	if( self.connection )
	{
		[self.connection cancel];
		self.connection = nil;
		/*
		 //
		 // Memory leak workaround.
		 // Source: http://stackoverflow.com/questions/1345663/nsurlconnection-leak
		 //
		 NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
		 [NSURLCache setSharedURLCache:sharedCache];
		 [sharedCache release];
		 */
	}
}

- (void) cleanupConn
{
	connectionExists = NO;
	
	[self destroyConn];
	
	self.filePath = nil;
	
	if( self.fileStream )
	{
		[self.fileStream close];
		self.fileStream = nil;
	}
	
	if( self.receivedData )
	{
		self.receivedData = nil;
	}
}
//
#pragma mark >>> Setup
//
- (void) setTimeout:(NSTimeInterval) newConnTimeout
{
	connTimeout = newConnTimeout;
}

- (void) setDownloadDestinationPath:(NSString *) anPath
{
	NSAssert2(nil != anPath, @"%@. Wrong destination path: %@", [self class], anPath);
	
	self.filePath = anPath;
}
//
#pragma mark >>> Data management
//
- (NSData *) responseData
{
	return receivedData;
}

- (NSString *) responseString
{
	if( receivedData && 0 < [receivedData length] )
	{
		NSString * str = [[NSString alloc] initWithData: receivedData encoding: NSUTF8StringEncoding];
		
		return [str autorelease];
	}
	
	return nil;
}



#pragma mark - NSURLConnectionDelegate
//
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	//
	// TODO: Add response checks!
	
	expectedLength = response.expectedContentLength;
	
	if( debugEnabled )
	{
		NSLog(@"%@ - didReceiveResponse:\r\n\tresponseURL: %@, \r\n\ttextEncodingName: %@, \r\n\tsuggestedFilename: %@, \r\n\tMIMEType: %@ \r\n tExpectedLength: %lld",[self class], [response URL], [response textEncodingName], [response suggestedFilename], [response MIMEType], [response expectedContentLength] );
	}
	
	if( delegate && [delegate respondsToSelector:@selector(connectionProgress:)] )
	{
		[delegate connectionProgress:self];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	NSLog(@"%@ - didReceiveAuthenticationChallenge",[self class]);
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
	return nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if( self.fileStream )
	{
		NSInteger       bytesWritten;
		NSInteger       bytesWrittenSoFar;
		
		NSInteger       dataLength	= [data length];
		const uint8_t * dataBytes	= [data bytes];
		
		downloadedLength += dataLength;
		
		bytesWrittenSoFar = 0;
		do 
		{
			bytesWritten = [self.fileStream write:&dataBytes[bytesWrittenSoFar] maxLength:dataLength - bytesWrittenSoFar];
			assert(bytesWritten != 0);
			
			if( -1 == bytesWritten )
			{
				NSLog(@"%@. Can't write data. Error: %@ (%@)", [self class], [self.fileStream.streamError localizedDescription], self.filePath);
				[self cancelConnection];
				break;
			} 
			else 
			{
				bytesWrittenSoFar += bytesWritten;
			}
		} while (bytesWrittenSoFar != dataLength);
	}
	else if( self.receivedData )
	{
		[receivedData appendData:data];
		
		downloadedLength = [receivedData length];
	}
	
	
	if( 0 < expectedLength && 0 < downloadedLength )
	{
		progress = (CGFloat)(downloadedLength) / (CGFloat)(expectedLength);
	}
	
	if( delegate && [delegate respondsToSelector:@selector(connectionProgress:)] )
	{
		[delegate connectionProgress:self];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *) anError
{
	[self destroyConn];
	[self cleanupConn];
	
    // inform the user
	if (CFAbsoluteTimeGetCurrent() - timeOut > kURLConnectionWrapperTimeout )
	{
		errorCode = kConn_Timeout;
	}
	else
	{	
		errorCode = kConn_NotReachable;
	}

	errorString = [NSString stringWithFormat:@"Connection failed! Error - %@ %@", [anError localizedDescription], [[anError userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]];
	if( debugEnabled )
	{
		NSLog(@"%@ - didFailWithError: %@",[self class], errorString);
	}

	

	self.error = [[[NSError alloc] initWithDomain: kURLConnectionWrapperErrorDomain 
											 code: errorCode
										 userInfo: [NSDictionary dictionaryWithObjectsAndKeys:errorString,NSLocalizedDescriptionKey,nil]] autorelease]; 
	if( delegate )
	{
		[delegate connectionFailed:self];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	// NOTE: receivedData is declared as a method instance elsewhere

	[self destroyConn];
	
	connectionExists = NO;

	if( debugEnabled )
	{
		NSLog(@"%@ - connectionDidFinishLoading: Succeeded!",[self class]);
	}
	
	if( delegate )
	{
		[delegate connectionFinished:self];
	}	
}

@end
