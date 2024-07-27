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
    self.numberOfTabs = 3;
    [self setUpTabs];
    [self setUpViewPager];
}

- (void)setUpTabs {
    self.tabs = [NSMutableArray array];
    for (NSInteger i = 0; i < self.numberOfTabs; i++) {
        UIViewController *vc = [[UIViewController alloc] init];
        vc.view.backgroundColor = [UIColor colorWithHue:((float)i / (float)self.numberOfTabs) saturation:0.5 brightness:0.9 alpha:1.0];
        UILabel *label = [[UILabel alloc] init];
        label.text = [NSString stringWithFormat:@"Content for Tab %ld", (long)i];
        label.textColor = [UIColor blackColor];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        [vc.view addSubview:label];
        [NSLayoutConstraint activateConstraints:@[
            [label.centerXAnchor constraintEqualToAnchor:vc.view.centerXAnchor],
            [label.centerYAnchor constraintEqualToAnchor:vc.view.centerYAnchor]
        ]];
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
    viewPager.eyStyle.WormColor = [UIColor blueColor];
    viewPager.eyStyle.kPaddingOfIndicator = 0;
    viewPager.currentTabIndex = 0;
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

- (NSInteger)wtsBadgeForTabWithIndex:(NSInteger)index { 
    if (index == 2) {
        return 1;
    }
    return 0;
}

- (CustomBadge *)wtsCustomBadgeForTabWithIndex:(NSInteger)index tabFrame:(CGRect)tabFrame {
    if (index != 1) {
        return nil;
    }
    CGFloat badgeSize = 8;
    CGFloat badgeMargin = 5;
    
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, badgeSize, badgeSize)];
    customView.backgroundColor = [UIColor blueColor];
    customView.layer.cornerRadius = badgeSize / 2;
    
    CGFloat badgeX = tabFrame.size.width + badgeMargin;
    CGFloat badgeY = tabFrame.size.height / 2 - badgeSize / 2;
    
    CGPoint badgePosition = CGPointMake(badgeX, badgeY);
    
    return [[CustomBadge alloc] initWithView:customView position:badgePosition];
}

@end
