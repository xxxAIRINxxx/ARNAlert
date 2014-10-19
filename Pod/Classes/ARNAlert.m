//
//  ARNAlert.m
//  ARNAlert
//
//  Created by Airin on 2014/10/06.
//  Copyright (c) 2014 Airin. All rights reserved.
//

#import "ARNAlert.h"

#import <BlocksKit+UIKit.h>

#if !__has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif


static NSString * const kARNAlertAlertViewStyleKey = @"ARNAlertAlertViewStyleKey";
static NSString * const kARNAlertTextFieldBlockKey = @"ARNAlertTextFieldBlockKey";
static NSString * const kARNAlertPlaceholderKey    = @"ARNAlertPlaceholderKey";

static UIWindow         *window_          = nil;
static UIViewController *controller_      = nil;
static NSMutableArray   *alertQueueArray_ = nil;

@interface ARNAlert ()

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;

@property (nonatomic, copy) NSString         *cancelTitle;
@property (nonatomic, copy) ARNAlertBlock     cancelBlock;
@property (nonatomic, strong) NSMutableArray *blockArray;
@property (nonatomic, strong) NSMutableArray *textFieldBlockArray;

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
    if (!window_) {
        window_ = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        window_.windowLevel = UIWindowLevelAlert;
    }
    if (!controller_) {
        controller_ = [[UIViewController alloc] init];
        controller_.view.backgroundColor = [UIColor clearColor];
        window_.rootViewController = controller_;
    }
    if (!window_.isKeyWindow) {
        window_.alpha = 1;
        [window_ makeKeyAndVisible];
    }
    if (!alertQueueArray_) {
        alertQueueArray_ = [NSMutableArray array];
    }
    
    return controller_;
}

+ (void)dismiss
{
    if (![[self class] isiOS8orLater]) {
        return;
    }
    
    if (!window_) {
        return;
    }
    
    if (alertQueueArray_.count) {
        UIAlertController *alertController = (UIAlertController *)alertQueueArray_[0];
        [[[self class] parentController] presentViewController:alertController animated:YES completion:nil];
        [alertQueueArray_ removeObject:alertController];
    } else {
        window_.alpha = 0;
        [window_.rootViewController.view removeFromSuperview];
        window_.rootViewController = nil;
        controller_ = nil;
        window_     = nil;
        UIWindow *mainWindow = [[UIApplication sharedApplication].delegate window];
        [mainWindow makeKeyAndVisible];
    }
}

+ (void)showNoActionAlertWithTitle:(NSString *)title
                           message:(NSString *)message
                       buttonTitle:(NSString *)buttonTitle
{
    NSAssert(title || message, @"title and message nothing");
    
    if (!buttonTitle || !buttonTitle.length) {
        buttonTitle = @"OK";
    }
    
    ARNAlert *alert = [[ARNAlert alloc] initWithTitle:title message:message];
    [alert setCancelTitle:buttonTitle cancelBlock:^(id action) {}];
    
    [alert show];
}

+ (void)shoAlertWithTitle:(NSString *)title
                  message:(NSString *)message
        cancelButtonTitle:(NSString *)cancelButtonTitle
              cancelBlock:(ARNAlertBlock)cancelBlock
            okButtonTitle:(NSString *)okButtonTitle
                  okBlock:(ARNAlertBlock)okBlock
{
    NSAssert(title || message, @"title and message nothing");
    NSAssert(cancelButtonTitle || cancelBlock, @"cancelButtonTitle and cancelBlock nothing");
    NSAssert(okButtonTitle || okBlock, @"okButtonTitle and okBlock nothing");
    
    ARNAlert *alert = [[ARNAlert alloc] initWithTitle:title message:message];
    [alert setCancelTitle:cancelButtonTitle cancelBlock:cancelBlock];
    [alert addActionTitle:okButtonTitle actionBlock:okBlock];
    
    [alert show];
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message
{
    if (!(self = [super init])) { return nil; }
    
    self.title      = title;
    self.message    = message;
    self.blockArray = [NSMutableArray array];
    self.textFieldBlockArray = [NSMutableArray array];
    
    return self;
}

- (void)setCancelTitle:(NSString *)cancelTitle
           cancelBlock:(ARNAlertBlock)cancelBlock
{
    self.cancelTitle = cancelTitle;
    self.cancelBlock = cancelBlock;
}

- (void)addActionTitle:(NSString *)actionTitle
           actionBlock:(ARNAlertBlock)actionBlock
{
    if (!actionTitle || !actionBlock) {
        return;
    }
    
    [self.blockArray addObject:@{[actionTitle copy]: [actionBlock copy]}];
}

// iOS7 is Only One Block
- (void)addTextFieldWithPlaceholder:(NSString *)placeholder
                     alertViewStyle:(UIAlertViewStyle)alertViewStyle
                        actionBlock:(ARNAlertTextFieldBlock)actionBlock
{
    if (!actionBlock) {
        return;
    }
    if (!placeholder) {
        placeholder = @"";
    }

    if ([[self class] isiOS8orLater]) {
        [self.textFieldBlockArray addObject:@{kARNAlertPlaceholderKey : [placeholder copy],
                                              kARNAlertTextFieldBlockKey : [actionBlock copy]}];
    } else {
        [self.textFieldBlockArray removeAllObjects];
        [self.textFieldBlockArray addObject:@{kARNAlertPlaceholderKey : [placeholder copy],
                                              kARNAlertAlertViewStyleKey : @(alertViewStyle),
                                              kARNAlertTextFieldBlockKey : [actionBlock copy]}];
    }
}

- (void)shoAlertWithTitle:(NSString *)title
                  message:(NSString *)messages
{
    if (!self.title) {
        self.title = @"";
    }
    if (!self.message) {
        self.message = @"";
    }
    if (self.cancelBlock && (!self.cancelTitle || !self.cancelTitle.length)) {
        self.cancelTitle = @"Cancel";
    }
    
    if ([[self class] isiOS8orLater]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:self.title
                                                                                 message:self.message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        __block NSMutableArray *textFields = [NSMutableArray array];
        
        if (self.textFieldBlockArray.count) {
            for (int ai = 0; ai < self.textFieldBlockArray.count; ++ai) {
                NSDictionary *blockDict = self.textFieldBlockArray[ai];
                NSString *placeholder = blockDict[kARNAlertPlaceholderKey];
                [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                    textField.placeholder = placeholder;
                    textField.bk_didEndEditingBlock = ^(UITextField *textField) {
                        ARNAlertTextFieldBlock block = blockDict[kARNAlertTextFieldBlockKey];
                        block(textField, @(ai));
                    };
                    [textFields addObject:textField];
                }];
            }
            if (!self.blockArray.count) {
                [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action) {
                                                                      [ARNAlert dismiss];
                                                                  }]];
            }
        }
        
        if (self.cancelBlock) {
            void (^block)() = [self.cancelBlock copy];
            [alertController addAction:[UIAlertAction actionWithTitle:self.cancelTitle
                                                                style:UIAlertActionStyleCancel
                                                              handler:^(UIAlertAction *action) {
                                                                  [ARNAlert dismiss];
                                                                  if (textFields.count) {
                                                                      block(textFields);
                                                                  } else {
                                                                      block(action);
                                                                  }
                                                              }]];
        }
        for (int i = 0; i < self.blockArray.count; ++i) {
            NSDictionary *blockDict = self.blockArray[i];
            NSString *key = [(NSString *)blockDict.allKeys[0] copy];
            [alertController addAction:[UIAlertAction actionWithTitle:key
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                                                                  [ARNAlert dismiss];
                                                                  void (^block)() = blockDict[key];
                                                                  if (textFields.count) {
                                                                      block(textFields);
                                                                  } else {
                                                                      block(action);
                                                                  }
                                                              }]];
        }
        
        if ([[self class] parentController].presentedViewController) {
            [alertQueueArray_ addObject:alertController];
        } else {
            [[[self class] parentController] presentViewController:alertController animated:YES completion:nil];
        }
    } else {
        UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:self.title message:self.message];
        
        __block NSMutableArray *textFields = [NSMutableArray array];
        if (self.textFieldBlockArray.count) {
            NSDictionary *blockDict = self.textFieldBlockArray[0];
            NSNumber *key = (NSNumber *)blockDict[kARNAlertAlertViewStyleKey];
            [alert setAlertViewStyle:key.integerValue];
            [alert bk_setDidShowBlock:^(UIAlertView *alertView) {
                
                ARNAlertTextFieldBlock block = blockDict[kARNAlertTextFieldBlockKey];
                if ([alertView textFieldAtIndex:0]) {
                    UITextField *textField = [alertView textFieldAtIndex:0];
                    textField.bk_didEndEditingBlock = ^(UITextField *textField) {
                        block(textField, @0);
                    };
                    [textFields addObject:textField];
                }
                if (key.integerValue == UIAlertViewStyleLoginAndPasswordInput) {
                    UITextField *textField = [alertView textFieldAtIndex:1];
                    textField.bk_didEndEditingBlock = ^(UITextField *textField) {
                        block(textField, @1);
                    };
                    [textFields addObject:textField];
                }
            }];
            
            if (!self.blockArray.count) {
                [alert bk_addButtonWithTitle:@"OK" handler:^{
                }];
            }
        }
        
        if (self.cancelBlock) {
            void (^block)() = [self.cancelBlock copy];
            [alert bk_setCancelButtonWithTitle:self.cancelTitle handler:^{
                if (textFields.count) {
                    block(textFields);
                } else {
                    block(alert);
                }
            }];
        }
        
        for (int i = 0; i < self.blockArray.count; ++i) {
            NSDictionary *blockDict = self.blockArray[i];
            NSString *key = [(NSString *)blockDict.allKeys[0] copy];
            [alert bk_addButtonWithTitle:key handler:^{
                void (^block)() = blockDict[key];
                if (textFields.count) {
                    block(textFields);
                } else {
                    block(alert);
                }
            }];
        }
        
        [alert show];
    }
}

- (void)show
{
    [self shoAlertWithTitle:self.title message:self.message];
}

@end