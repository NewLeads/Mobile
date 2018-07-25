//
//  ItemModel.h
//  NewLeads
//
//  Created by idevs.com on 27/09/2011.
//  Copyright 2011 idevs.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ItemModel : NSObject 
{
@protected
	UIImage		* image;
}

@property (nonatomic, readonly, retain) UIImage		* image;


- (id) initWithDictionary:(NSDictionary *) dataSourceDict fromPlist:(BOOL) anFlag;
- (void) setImage:(UIImage *) anImage;
//
- (NSString *) stringForKey:(NSString *) anKey fromDic:(NSDictionary *) anDic;
- (int) intForKey:(NSString *) anKey fromDic:(NSDictionary *) anDic;
//
- (NSDictionary *) dictionaryRepresentation;

@end
