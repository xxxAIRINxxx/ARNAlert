//
//  ARNAlert.m
//  ARNAlert
//
//  Created by Airin on 2014/10/06.
//  Copyright (c) 2014 Airin. All rights reserved.
//

#if !__has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "ARNAlert.h"

#import <UIKit/UIKit.h>
#import <objc/message.h>

static NSString * const kARNAlertAlertKey = @"kARNAlertAlertKey";

static UIWindow         *window_           = nil;
static UIViewController *parentController_ = nil;
static NSMutableArray   *alertQueueArray_  = nil;

@implementation ARNAlertObject

@end

@interface ARNAlert () <UIAlertViewDelegate>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;

@property (nonatomic) ARNAlertObject *cancelObj;
@property (nonatomic) NSMutableArray *blockArray;
@property (nonatomic) NSMutableArray *textFieldBlockArray;

@end

@implementation ARNAlert

+ (BOOL)isiOS8orLater
{
    if ( ([[[UIDevice currentDevice] systemVersion] compare:@"8" options:NSNumericSearch] != NSOrderedAscending)) {
        return YES;
    } else {
        return NO;
    }
}

+ (UIViewController *)parentController
{
    if (!parentController_) {
        parentController_ = [UIViewController new];
        parentController_.view.backgroundColor = [UIColor clearColor];
    }
    if (!alertQueueArray_) {
        alertQueueArray_ = [NSMutableArray array];
    }
    
    if ([[self class] isiOS8orLater]) {
        if (!window_) {
            window_ = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            window_.windowLevel = UIWindowLevelAlert;
        }
        window_.rootViewController = parentController_;
        
        if (!window_.isKeyWindow) {
            window_.alpha = 1;
            [window_ makeKeyAndVisible];
        }
    }
    
    return parentController_;
}

+ (void)showNoActionAlertWithTitle:(NSString *)title
                           message:(NSString *)message
                       buttonTitle:(NSString *)buttonTitle
{
    ARNAlert *alert = [[ARNAlert alloc] initWithTitle:title message:message];

    if (!buttonTitle || !buttonTitle.length) {
        [alert setCancelTitle:@"OK" cancelBlock:nil];
    } else {
        [alert setCancelTitle:buttonTitle cancelBlock:nil];
    }
    
    [alert show];
}

+ (void)shoAlertWithTitle:(NSString *)title
                  message:(NSString *)message
        cancelButtonTitle:(NSString *)cancelButtonTitle
              cancelBlock:(ARNAlertBlock)cancelBlock
            okButtonTitle:(NSString *)okButtonTitle
                  okBlock:(ARNAlertBlock)okBlock
{
    ARNAlert *alert = [[ARNAlert alloc] initWithTitle:title message:message];
    
    if (cancelButtonTitle) {
        [alert setCancelTitle:cancelButtonTitle cancelBlock:cancelBlock];
    }
    
    [alert addActionTitle:okButtonTitle actionBlock:okBlock];
    
    [alert show];
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message
{
    if (!(self = [super init])) { return nil; }
    
    _title   = title;
    _message = message;
    
    _blockArray = [NSMutableArray array];
    _textFieldBlockArray = [NSMutableArray array];
    
    return self;
}

- (void)setCancelTitle:(NSString *)cancelTitle
           cancelBlock:(ARNAlertBlock)cancelBlock
{
    ARNAlertObject *alertObj = [ARNAlertObject new];
    
    if (!cancelTitle || !cancelTitle.length) {
        alertObj.title = @"Cancel";
    } else {
        alertObj.title = cancelTitle;
    }
    
    if (!cancelBlock) {
        alertObj.block = ^(id resultObj){};
    } else {
        alertObj.block = cancelBlock;
    }
    self.cancelObj = alertObj;
}

- (void)addActionTitle:(NSString *)actionTitle
           actionBlock:(ARNAlertBlock)actionBlock
{
    ARNAlertObject *alertObj = [ARNAlertObject new];
    
    if (actionTitle) {
        alertObj.title = actionTitle;
    }
    
    if (!actionBlock) {
        alertObj.block = ^(id resultObj){};
    } else {
        alertObj.block = actionBlock;
    }
    
    [self.blockArray addObject:alertObj];
}

- (void)addTextFieldWithPlaceholder:(NSString *)placeholder
{
    ARNAlertObject *alertObj = [ARNAlertObject new];
    
    if (placeholder) {
        alertObj.title = placeholder;
    }
    
    if ([[self class] isiOS8orLater]) {
        [self.textFieldBlockArray addObject:alertObj];
    } else {
        if (self.textFieldBlockArray.count < 2) {
            [self.textFieldBlockArray addObject:alertObj];
        }
    }
}

- (void)show
{
    [self showAlertWithTitle:self.title message:self.message];
}

- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)messages
{
    if (!self.title) {
        self.title = @"";
    }
    if (!self.message) {
        self.message = @"";
    }
    
    if ([[self class] isiOS8orLater]) {
        [self showAlertController];
    } else {
        [self showAlertView];
    }
}

- (void)showAlertView
{
    if (objc_getAssociatedObject([[self class] parentController], &kARNAlertAlertKey)) {
        [alertQueueArray_ addObject:self];
        return;
    }
    
    UIAlertView *alertView = [UIAlertView new];
    alertView.title    = self.title;
    alertView.message  = self.message;
    alertView.delegate = self;
    
    for (ARNAlertObject *alertObj in self.blockArray) {
        [alertView addButtonWithTitle:alertObj.title];
    }
    if (self.cancelObj) {
        alertView.cancelButtonIndex = [alertView addButtonWithTitle:self.cancelObj.title];
    }
    
    if (self.textFieldBlockArray.count == 1) {
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    } else if (self.textFieldBlockArray.count == 2) {
        alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    }
    
    objc_setAssociatedObject([[self class] parentController], &kARNAlertAlertKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [alertView show];
}

- (void)showAlertController
{
    if ([[self class] parentController].presentedViewController) {
        [alertQueueArray_ addObject:self];
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:self.title
                                                                             message:self.message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    for (ARNAlertObject *alertObj in self.textFieldBlockArray) {
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = alertObj.title;
        }];
    }
    
    for (ARNAlertObject *alertObj in self.blockArray) {
        ARNAlertBlock block = alertObj.block;
        UIAlertAction *action = [UIAlertAction actionWithTitle:alertObj.title
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {
                                                           if (alertController.textFields.count) {
                                                               block(alertController.textFields);
                                                           } else {
                                                               block(action);
                                                           }
                                                           [ARNAlert dismiss];
                                                       }];
        [alertController addAction:action];
    }
    
    if (self.cancelObj) {
        ARNAlertBlock block = [self.cancelObj.block copy];
        UIAlertAction *action = [UIAlertAction actionWithTitle:self.cancelObj.title
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction *action) {
                                                           if (alertController.textFields.count) {
                                                               block(alertController.textFields);
                                                           } else {
                                                               block(action);
                                                           }
                                                           [ARNAlert dismiss];
                                                       }];
        [alertController addAction:action];
    }
    
    if (!self.blockArray.count && !self.cancelObj) {
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [ARNAlert dismiss];
                                                          }]];
    }
    
    [[[self class] parentController] presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - dismiss

+ (void)dismiss
{
    if ([[self class] isiOS8orLater]) {
        [[self class] dismissAlertController];
    } else {
        [[self class] dismissAlertView];
    }
}

+ (void)dismissAlertController
{
    if (alertQueueArray_.count) {
        ARNAlert *alert = alertQueueArray_[0];
        [alertQueueArray_ removeObject:alert];
        [alert showAlertWithTitle:alert.title message:alert.message];
    } else {
        window_.alpha = 0;
        [window_.rootViewController.view removeFromSuperview];
        window_.rootViewController = nil;
        parentController_ = nil;
        window_           = nil;
        UIWindow *mainWindow = [[UIApplication sharedApplication].delegate window];
        [mainWindow makeKeyAndVisible];
    }
}

+ (void)dismissAlertView
{
    objc_setAssociatedObject([[self class] parentController], &kARNAlertAlertKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (alertQueueArray_.count) {
        ARNAlert *alert = alertQueueArray_[0];
        [alertQueueArray_ removeObject:alert];
        [alert showAlertWithTitle:alert.title message:alert.message];
    }
}

#pragma mark - UIAlertViewDelegate

/*
 The field at index 0 will be the first text field (the single field or the login field), the field at index 1 will be the password field. */

- (void)willPresentAlertView:(UIAlertView *)alertView
{
    if (!self.textFieldBlockArray.count) { return; }
    
    for (NSUInteger i = 0; i < self.textFieldBlockArray.count; ++i) {
        UITextField *textField = [alertView textFieldAtIndex:i];
        if (textField) {
            ARNAlertObject *alertObj = self.textFieldBlockArray[i];
            textField.placeholder = alertObj.title;
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    id results = alertView;
    
    if (self.textFieldBlockArray.count) {
        NSMutableArray *textFields = [NSMutableArray array];
        
        for (NSUInteger i = 0; i < 2; ++i) {
            UITextField *textField = [alertView textFieldAtIndex:i];
            if (textField) {
                [textFields addObject:textField];
            }
        }
        results = textFields;
    }
    
    if (buttonIndex == alertView.cancelButtonIndex) {
        if (self.cancelObj.block) {
            self.cancelObj.block(results);
        }
    } else {
        ARNAlertObject *alertObj = self.blockArray[buttonIndex];
        if (alertObj.block) {
            alertObj.block(results);
        }
    }
    
    [ARNAlert dismiss];
}

@end