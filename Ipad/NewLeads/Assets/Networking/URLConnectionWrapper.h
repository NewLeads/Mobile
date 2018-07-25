//
//  URLConnectionWrapper.h
//
//
//  Created by idevs.com on 28/09/2011.
//  Copyright 2011 idevs.com. All rights reserved.
//



#pragma mark - Configuration
//
extern NSString * const kURLConnectionWrapperErrorDomain;
//
extern NSInteger kURLConnectionWrapperTimeout; // Connection timeout before disconnectNSURLRequest...



typedef enum
{
	kConn_NoError,
	kConn_Timeout,
	kConn_NotReachable,
	
} URLConnectionCode;



@class URLConnectionWrapper;

@protocol URLConnectionWrapperProtocol <NSObject>

@required
- (void) connectionStarted:(URLConnectionWrapper *) connection;
- (void) connectionFinished:(URLConnectionWrapper *) connection;
- (void) connectionFailed:(URLConnectionWrapper *) connection;

@optional
- (void) connectionProgress:(URLConnectionWrapper *) connection;
- (void) connectionCancelled:(URLConnectionWrapper *) connection;

@end



@interface URLConnectionWrapper : NSObject 
{
@private
	//
	// Logic:
	BOOL connectionExists;
	
	//
	// Connection:
	id <URLConnectionWrapperProtocol> delegate;
	NSMutableData		* receivedData;
	NSString			* filePath;
    NSURLConnection		* connection;
	NSOutputStream		* fileStream;
	//
	NSURL				* originalURL;
	//
	NSTimeInterval		connTimeout;
	
	//
	// User data:
	NSDictionary * userInfo;
	
	//
	// Informer:
	URLConnectionCode	errorCode;
	NSError				* error;
	NSString			* errorString;
	CFTimeInterval		timeOut;

	//
	// Download progress:
	CGFloat				progress;
	NSUInteger			expectedLength;
	NSUInteger			downloadedLength;
}

//
// Connection:
@property (nonatomic, readwrite, assign) id <URLConnectionWrapperProtocol> delegate;
@property (nonatomic, readwrite, retain) NSDictionary	* userInfo;
@property (nonatomic, readwrite, retain) NSURL			* originalURL;
@property (nonatomic, readwrite, retain) NSError		* error;
//
// Progress:
@property (nonatomic, readwrite, assign) CGFloat		progress;
@property (nonatomic, readwrite, assign) NSUInteger		downloadedLength;
@property (nonatomic, readwrite, assign) NSUInteger		expectedLength;
//
// Downloaded data:
@property (nonatomic, readonly, copy) NSString			* filePath;


+ (void) enableDebug:(BOOL) anFlag;

// Init:
+ (id) connectionWithString:(NSString *) anAddressString;
+ (id) connectionWithURL:(NSURL *) anURL;
//
- (id) initConnectionWithString:(NSString *) anAddressString;
- (id) initConnectionWithURL:(NSURL *) anURL;
//
// Conn control:
- (BOOL) startConnection;
- (BOOL) pauseConnection; // Stub - not working yet
- (void) cancelConnection;
//
// Setup:
- (void) setTimeout:(NSTimeInterval) newConnTimeout;
- (void) setDownloadDestinationPath:(NSString *) anPath;
//
// Data management:
- (NSData *) responseData;
- (NSString *) responseString;
//
@end
