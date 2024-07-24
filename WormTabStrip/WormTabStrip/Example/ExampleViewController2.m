//
//  ExampleViewController2.m
//  WormTabStrip
//
//  Created by Alvaro Marcos on 24/7/24.
//  Copyright © 2024 EzimetYusup. All rights reserved.
//

#import "ExampleViewController2.h"
#import "WormTabStrip-Swift.h"

@interface ExampleViewController2 () <WormTabStripDelegate>

@property (nonatomic, strong) NSMutableArray<UIViewController *> *tabs;
@property (nonatomic, assign) NSInteger numberOfTabs;

@end

@implementation ExampleViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.numberOfTabs = 4;
    [self setUpTabs];
    [self setUpViewPager];
}

- (void)setUpTabs {
    self.tabs = [NSMutableArray array];
    for (NSInteger i = 0; i < self.numberOfTabs; i++) {
        UIViewController *vc = [[UIViewController alloc] init];
        [self.tabs addObject:vc];
    }
}

- (void)setUpViewPager {
    CGRect frame = CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height - 40);
    WormTabStrip *viewPager = [[WormTabStrip alloc] initWithFrame:frame];
    [self.view addSubview:viewPager];
    viewPager.delegate = self;
    viewPager.eyStyle.wormStyle = WormStyleNotWormyLine;
    viewPager.eyStyle.isWormEnable = YES;
    viewPager.eyStyle.spacingBetweenTabs = 0;
    viewPager.eyStyle.dividerBackgroundColor = [UIColor clearColor];
    viewPager.eyStyle.tabItemSelectedColor = [UIColor blueColor];
    viewPager.eyStyle.tabItemDefaultColor = [UIColor lightGrayColor];
    viewPager.eyStyle.topScrollViewBackgroundColor = [UIColor whiteColor];
    viewPager.eyStyle.contentScrollViewBackgroundColor = [UIColor whiteColor];
    viewPager.eyStyle.WormColor = [UIColor lightGrayColor];
    viewPager.eyStyle.kPaddingOfIndicator = 15;
    viewPager.currentTabIndex = 1;
    [viewPager buildUI];
}

#pragma mark - WormTabStripDelegate

- (NSInteger)wtsNumberOfTabs {
    return self.numberOfTabs;
}

- (void)wtsDidSelectTabWithIndex:(NSInteger)index { 
    NSLog(@"selected index: %ld", (long)index);
}

- (NSString * _Nonnull)wtsTitleForTabWithIndex:(NSInteger)index {
    return [NSString stringWithFormat:@"Tab %ld", (long)index];
}

- (UIView * _Nonnull)wtsViewOfTabWithIndex:(NSInteger)index { 
    UIViewController *vc = self.tabs[index];
    return vc.view;
}

@end
