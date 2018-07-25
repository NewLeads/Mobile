//
//  XMLReader.h
//
//  Created by Troy on 9/18/10.
//  Copyright 2010 Troy Brant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMLReader : NSObject < NSXMLParserDelegate >
{
    NSMutableArray *dictionaryStack;
    NSMutableString *textInProgress;
    NSError * __autoreleasing *errorPointer; //http://stackoverflow.com/questions/7804435/automatic-reference-counting-pointer-to-non-const-type-nserror-with-no-expl
}

+ (NSDictionary *)dictionaryForXMLData:(NSData *)data error:(NSError **)errorPointer;
+ (NSDictionary *)dictionaryForXMLString:(NSString *)string error:(NSError **)errorPointer;

@end
