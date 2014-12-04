//
//  ARNAlert.h
//  ARNAlert
//
//  Created by Airin on 2014/10/06.
//  Copyright (c) 2014 Airin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ARNAlertBlock)(id resultObj);

@interface ARNAlertObject : NSObject

@property (nonatomic, copy) NSString     *title;
@property (nonatomic, copy) ARNAlertBlock block;

@end

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

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message NS_DESIGNATED_INITIALIZER;

- (void)setCancelTitle:(NSString *)cancelTitle
           cancelBlock:(ARNAlertBlock)cancelBlock;

- (void)addActionTitle:(NSString *)actionTitle
           actionBlock:(ARNAlertBlock)actionBlock;

// iOS7 is Max 2 Fields (1 : UIAlertViewStylePlainTextInput, 2 : UIAlertViewStyleLoginAndPasswordInput)
- (void)addTextFieldWithPlaceholder:(NSString *)placeholder;

- (void)show;

@end