//
//  NLAlertView.h
//
//
//  Created by Karnyenka Andrew on 18/09/2012.
//  Copyright (c) 2012 All rights reserved.
//


@class NLAlertView;
typedef void (^NLAlertViewBlock)(NLAlertView *alertView, NSInteger buttonIndex);

@interface NLAlertView : UIAlertView

+ (void) show:(NSString*)title message:(NSString*)message buttons:(NSArray *)buttons block:(NLAlertViewBlock)block;
+ (void) show:(NSString*)title message:(NSString*)message;
+ (void) showError:(NSString*)message;

@end



@class NLPasswordAlertView;
typedef void (^NLPasswordAlertViewBlock)(NLPasswordAlertView *alertView, NSString * fieldValue, NSInteger buttonIndex);

@interface NLPasswordAlertView : UIAlertView

+ (void) show:(NSString*)title message:(NSString*)message buttons:(NSArray *)buttons block:(NLPasswordAlertViewBlock)block;

@end
