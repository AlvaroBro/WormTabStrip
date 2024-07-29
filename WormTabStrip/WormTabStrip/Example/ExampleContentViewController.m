//
//  ExampleContentViewController.m
//  WormTabStrip
//
//  Created by Alvaro Marcos on 29/7/24.
//  Copyright © 2024 EzimetYusup. All rights reserved.
//

#import "ExampleContentViewController.h"

@interface ExampleContentViewController ()

@property (nonatomic, strong) NSString *name;

@end

@implementation ExampleContentViewController

- (instancetype)initWithName:(NSString *)name {
    if (self = [super init]) {
        self.name = name;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@ viewDidLoad", self.name);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"%@ viewWillAppear", self.name);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"%@ viewWillDisappear", self.name);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"%@ viewDidAppear", self.name);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSLog(@"%@ viewDidDisappear", self.name);
}

@end
