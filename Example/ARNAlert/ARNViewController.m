//
//  ARNViewController.m
//  ARNAlert
//
//  Created by Airin on 10/06/2014.
//  Copyright (c) 2014 Airin. All rights reserved.
//

#import "ARNViewController.h"

#import "ARNAlert.h"

@interface ARNViewController ()

@end

@implementation ARNViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)noActionButtonAlert:(id)sender
{
    [ARNAlert showNoActionAlertWithTitle:@"no action title" message:@"no action message" buttonTitle:@"No Acttion"];
}

- (IBAction)singleButtonAlert:(id)sender
{
    ARNAlert *alert = [[ARNAlert alloc] initWithTitle:@"test Title" message:@"test Message"];
    [alert addActionTitle:@"OK" actionBlock:^(id resultObj) {
        NSLog(@"OK Button tapped!");
    }];
    [alert show];
}

- (IBAction)doubleButtonAlert:(id)sender
{
    [ARNAlert shoAlertWithTitle:@"test Title"
                        message:@"test Message"
              cancelButtonTitle:@"Cancel"
                    cancelBlock:^(id resultObj){
                        NSLog(@"cancelBlock call!");
                    }
                  okButtonTitle:@"OK"
                        okBlock:^(id resultObj){
                            NSLog(@"okBlock call!");
                        }];
}

- (IBAction)tripleButtonAlert:(id)sender
{
    ARNAlert *alert = [[ARNAlert alloc] initWithTitle:@"test Title" message:@"test Message"];
    [alert addActionTitle:@"button1" actionBlock:^(id resultObj) {
        NSLog(@"button1 Button tapped!");
    }];
    [alert addActionTitle:@"button2" actionBlock:^(id resultObj) {
        NSLog(@"button2 Button tapped!");
    }];
    [alert addActionTitle:@"button3" actionBlock:^(id resultObj) {
        NSLog(@"button3 Button tapped!");
    }];
    [alert setCancelTitle:@"cancel" cancelBlock:^(id resultObj) {
        NSLog(@"cancel Button tapped!");
    }];
    [alert show];
}

- (IBAction)rollAlert:(id)sender
{
    ARNAlert *alert1 = [[ARNAlert alloc] initWithTitle:@"test Title 1" message:@"test Message 1"];
    [alert1 addActionTitle:@"OK" actionBlock:^(id resultObj) {
        NSLog(@"1 OK Button tapped!");
    }];
    [alert1 show];
    
    ARNAlert *alert2 = [[ARNAlert alloc] initWithTitle:@"test Title 2" message:@"test Message 2"];
    [alert2 addActionTitle:@"OK" actionBlock:^(id resultObj) {
        NSLog(@"2 OK Button tapped!");
    }];
    [alert2 show];
    
    ARNAlert *alert3 = [[ARNAlert alloc] initWithTitle:@"test Title 3" message:@"test Message 3"];
    [alert3 addActionTitle:@"OK" actionBlock:^(id resultObj) {
        NSLog(@"3 OK Button tapped!");
    }];
    [alert3 show];
}

- (IBAction)textAlert:(id)sender
{
    if ( ([[[UIDevice currentDevice] systemVersion] compare:@"8" options:NSNumericSearch] != NSOrderedAscending)) {
        ARNAlert *alert = [[ARNAlert alloc] initWithTitle:@"test Text " message:@"test Message"];
        [alert addTextFieldWithPlaceholder:@"place1" alertViewStyle:0 actionBlock:^(UITextField *texitField) {
            NSLog(@"texitField1.text : %@", texitField.text);
        }];
        [alert addTextFieldWithPlaceholder:@"place2" alertViewStyle:0 actionBlock:^(UITextField *texitField) {
            NSLog(@"texitField2.text : %@", texitField.text);
        }];
        [alert addTextFieldWithPlaceholder:@"place2" alertViewStyle:0 actionBlock:^(UITextField *texitField) {
            NSLog(@"texitField3.text : %@", texitField.text);
        }];
        [alert show];
    } else {
        ARNAlert *alert = [[ARNAlert alloc] initWithTitle:@"test Text " message:@"test Message"];
        [alert addTextFieldWithPlaceholder:@"place1" alertViewStyle:UIAlertViewStylePlainTextInput actionBlock:^(id resultObj) {
            NSLog(@"texitField.text : %@", [[(UIAlertView *)resultObj textFieldAtIndex:0] text]);
        }];
        [alert addTextFieldWithPlaceholder:@"place2" alertViewStyle:UIAlertViewStylePlainTextInput actionBlock:^(id resultObj) {
            NSLog(@"texitField.text : %@", [[(UIAlertView *)resultObj textFieldAtIndex:0] text]);
        }];
        [alert addActionTitle:@"button1" actionBlock:^(id resultObj) {
            NSLog(@"button1 tapped!");
        }];
        [alert addActionTitle:@"button2" actionBlock:^(id resultObj) {
            NSLog(@"button2 tapped!");
        }];
        [alert setCancelTitle:@"Cancel" cancelBlock:^(id resultObj) {
            NSLog(@"cancel Button tapped!");
        }];
        [alert show];
    }
}

@end
