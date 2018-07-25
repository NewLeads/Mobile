//
//  NLBarcode.h
//  NewLeads
//
//  Created by idevs.com on 06/02/2015.
//  Copyright (c) 2015 idevs.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NLBarcode : NSObject <NSCopying, NSCoding>

@property (nonatomic, strong) NSNumber		* codeValue;
@property (nonatomic, strong) NSNumber		* codeSelected;
@property (nonatomic, strong) NSString		* codeName;
@property (nonatomic, strong) NSString		* codeDescription;

- (NSUInteger) code;
- (BOOL) isSelected;

@end
