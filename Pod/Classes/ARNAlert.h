//
//  ARNAlert.h
//  ARNAlert
//
//  Created by Airin on 2014/10/06.
//  Copyright (c) 2014 Airin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ARNAlertBlock)(id resultObj);
typedef void (^ARNAlertTextFieldBlock)(UITextField *textField, NSNumber *index);

@interface ARNAlert : NSObject

+ (void)showNoActionAlertWithTitle:(NSString *)title
                           message:(NSString *)message
                       buttonTitle:(NSString *)buttonTitle;

+ (void)shoAlertWithTitle:(NSString *)title
                  message:(NSString *)message
        cancelButtonTitle:(NSString *)cancelButtonTitle
              cancelBlock:(ARNAlertBlock)cancelBlock
            okButtonTitle:(NSString *)okButtonTitle
                  okBlock:(ARNAlertBlock)okBlock;

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message;

- (void)setCancelTitle:(NSString *)cancelTitle
           cancelBlock:(ARNAlertBlock)cancelBlock;

- (void)addActionTitle:(NSString *)actionTitle
           actionBlock:(ARNAlertBlock)actionBlock;

// TODO : 残念な感じ...
// iOS7 is Only One Block
- (void)addTextFieldWithPlaceholder:(NSString *)placeholder // use iOS8 only
                     alertViewStyle:(UIAlertViewStyle)alertViewStyle // use iOS7 only
                        actionBlock:(ARNAlertTextFieldBlock)actionBlock;

- (void)show;

@end