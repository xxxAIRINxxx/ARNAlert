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

- (IBAction)singleButtonAlert:(id)sender
{
    ARNAlert *alert = [[ARNAlert alloc] initWithTitle:@"test Title" message:@"test Message"];
    [alert addActionTitle:@"OK" actionBlock:^(id action) {
        NSLog(@"OK Button tapped!");
    }];
    [alert show];
}

- (IBAction)doubleButtonAlert:(id)sender
{
    [ARNAlert shoAlertWithTitle:@"test Title"
                        message:@"test Message"
              cancelButtonTitle:@"Cancel"
                    cancelBlock:^(id action){
                        NSLog(@"cancelBlock call!");
                    }
                  okButtonTitle:@"OK"
                        okBlock:^(id action){
                            NSLog(@"okBlock call!");
                        }];
}

- (IBAction)tripleButtonAlert:(id)sender
{
    ARNAlert *alert = [[ARNAlert alloc] initWithTitle:@"test Title" message:@"test Message"];
    [alert addActionTitle:@"button1" actionBlock:^(id action) {
        NSLog(@"button1 Button tapped!");
    }];
    [alert addActionTitle:@"button2" actionBlock:^(id action) {
        NSLog(@"button2 Button tapped!");
    }];
    [alert addActionTitle:@"button3" actionBlock:^(id action) {
        NSLog(@"button3 Button tapped!");
    }];
    [alert setCancelTitle:@"cancel" cancelBlock:^(id action) {
        NSLog(@"cancel Button tapped!");
    }];
    [alert show];
}

@end
