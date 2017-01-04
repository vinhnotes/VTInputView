//
//  ViewController.m
//  VTInputView
//
//  Created by Soliton-Mac on 1/4/17.
//  Copyright © 2017 VinhVu. All rights reserved.
//

#import "ViewController.h"
#import "VTInputView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showAlert{
    VTInputView* km = [[VTInputView alloc] init];
    km.style = Login;
    km.cancelButtonText = @"Cancel";
    UIWindow* window = [UIApplication sharedApplication].windows.firstObject;
    CGRect frame = CGRectMake(0, 0, MIN(280, window.frame.size.width-50), 180);
    km.frame = frame;
    km.center = CGPointMake(window.center.x, window.center.y-30);
    km.title = @"Input UserID and Password";
    km.touchSubmitCompleted = ^(void){
        
    };
    [km show];
}
@end
