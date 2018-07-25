//
//  LogoItem.h
//  NewLeads
//
//  Created by Karnyenka Andrew on 14/12/2011.
//  Copyright (c) 2011 idevs.com. All rights reserved.
//

#import "ItemModel.h"



@interface LogoItem : ItemModel
{
@private
//
//
	NSString	* logoFileName;
}

@property (nonatomic, readwrite, copy) NSString	* logoFileName;

- (void) extractLogoFromDictionary:(NSDictionary *) dataSourceDict fromPlist:(BOOL) anFlag;

@end
