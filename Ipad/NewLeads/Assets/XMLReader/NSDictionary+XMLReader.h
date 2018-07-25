//
//  NSDictionary+XMLReader.h
//  Peek
//
//  Created by Arseniy Astapenko on 8/4/11.
//  Copyright 2011 idevs.com. All rights reserved.
//

@interface NSDictionary (XMLReader)
- (NSString*)stringForName:(NSString*)name; 
- (NSString*)valueForName:(NSString*)name success:(BOOL*)successPointer; 
- (int)intForName:(NSString*)name success:(BOOL*)successPointer;
- (float)floatForName:(NSString*)name success:(BOOL*)successPointer;
- (double)doubleForName:(NSString*)name success:(BOOL*)successPointer;
- (NSDictionary*) dictForName:(NSString*)name;
- (NSDictionary*) dictInChildNodes:(NSString*)node, ... NS_REQUIRES_NIL_TERMINATION;
- (NSArray*) arrayOfNodesForName:(NSString*)name;
@end
