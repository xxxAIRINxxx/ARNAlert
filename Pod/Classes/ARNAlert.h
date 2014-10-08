//
//  ARNAlert.h
//  ARNAlert
//
//  Created by Airin on 2014/10/06.
//  Copyright (c) 2014 Airin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ARNAlertBlock)(id action);

@interface ARNAlert : NSObject

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

- (void)show;

@end
