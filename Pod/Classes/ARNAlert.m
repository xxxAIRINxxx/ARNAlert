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
@property (nonatomic, strong) UIAlertView *alertView;

@property (nonatomic) ARNAlertObject *cancelObj;
@property (nonatomic) NSMutableArray *blockArray;
@property (nonatomic) NSMutableArray *textFieldBlockArray;

@end

@implementation ARNAlert

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

+ (void)showAlertWithTitle:(NSString *)title
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
    
    if (!actionTitle || !actionTitle.length) {
        alertObj.title = @"OK";
    } else {
        alertObj.title = actionTitle;
    }
    
    if (!actionBlock) {
        alertObj.block = ^(id resultObj){};
    } else {
        alertObj.block = actionBlock;
    }
    
    [self.blockArray addObject:alertObj];
}

- (void)addTextFieldWithPlaceholder:(NSString *)placeholder fillInText:(NSString *)text
{
    ARNAlertObject *alertObj = [ARNAlertObject new];
    
    if (placeholder) {
        alertObj.placeholder = placeholder;
    }
    if (text) {
        alertObj.title = text;
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

#pragma mark - Private

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

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)messages
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
    
    NSString *cancelButtonTitle = nil;
    if (self.cancelObj) {
        cancelButtonTitle = self.cancelObj.title;
    } else if (self.textFieldBlockArray.count) {
        [self setCancelTitle:nil cancelBlock:nil];
        cancelButtonTitle = self.cancelObj.title;
    }
    
    __block NSString *otherButtonTitle = nil;
    NSMutableArray *otherButtonTitles = [NSMutableArray array];
    [self.blockArray enumerateObjectsUsingBlock:^(ARNAlertObject *alertObj, NSUInteger idx, BOOL *stop) {
        if (idx == 0) {
            otherButtonTitle = alertObj.title;
        } else {
            [otherButtonTitles addObject:alertObj.title];
        }
    }];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:self.title
                                                        message:self.message
                                                       delegate:self
                                              cancelButtonTitle:cancelButtonTitle
                                              otherButtonTitles:otherButtonTitle, nil];
    
    for (NSString *buttonTitle in otherButtonTitles) {
        [alertView addButtonWithTitle:buttonTitle];
    }
    
    if (self.textFieldBlockArray.count == 1) {
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    } else if (self.textFieldBlockArray.count == 2) {
        alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    }
    
    objc_setAssociatedObject([[self class] parentController], &kARNAlertAlertKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [alertView show];
    self.alertView = alertView;
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
    
    [self.textFieldBlockArray enumerateObjectsUsingBlock:^(ARNAlertObject *alertObj, NSUInteger idx, BOOL *stop) {
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = alertObj.placeholder;
            textField.text = alertObj.title;
        }];
    }];
    
    [self.blockArray enumerateObjectsUsingBlock:^(ARNAlertObject *alertObj, NSUInteger idx, BOOL *stop) {
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
    }];
    
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

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    if (self.textFieldBlockArray.count) {
        NSInteger textLength = [[[alertView textFieldAtIndex:0] text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length;
        if (!textLength) {
            return NO;
        }
    }
    return YES;
}

- (void)willPresentAlertView:(UIAlertView *)alertView
{
    if (!self.textFieldBlockArray.count) { return; }
    
    [self.textFieldBlockArray enumerateObjectsUsingBlock:^(ARNAlertObject *alertObj, NSUInteger idx, BOOL *stop) {
        UITextField *textField = [alertView textFieldAtIndex:idx];
        if (textField) {
            textField.placeholder = alertObj.placeholder;
            textField.text        = alertObj.title;
        }
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    id results = alertView;
    
    if (self.textFieldBlockArray.count) {
        NSMutableArray *textFields = [NSMutableArray array];
        
        [self.textFieldBlockArray enumerateObjectsUsingBlock:^(ARNAlertObject *alertObj, NSUInteger idx, BOOL *stop) {
            UITextField *textField = [alertView textFieldAtIndex:idx];
            if (textField) {
                [textFields addObject:textField];
            }
        }];
        results = textFields;
    }
    
    if (buttonIndex == alertView.cancelButtonIndex) {
        if (self.cancelObj.block) {
            self.cancelObj.block(results);
        }
    } else {
        NSInteger resultIndex = buttonIndex;
        if (self.textFieldBlockArray.count || self.cancelObj.block) {
            // cancel button or textfield index = 0
            resultIndex--;
        }
        
        if (self.blockArray.count > resultIndex) {
            ARNAlertObject *alertObj = self.blockArray[resultIndex];
            if (alertObj.block) {
                alertObj.block(results);
            }
        }
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    self.alertView = nil;
    [ARNAlert dismiss];
}

@end