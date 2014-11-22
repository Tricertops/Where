//
//  ViewController.m
//  Where Am I
//
//  Created by Martin Kiss on 21.11.14.
//  Copyright (c) 2014 Triceratops. All rights reserved.
//

@import UIKit;
@import Where;


@interface ViewController : UIViewController

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Where detect];
}

@end

