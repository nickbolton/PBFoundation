//
//  PBFlexibleBackgroundViewController.m
//  PBNavigationViewController
//
//  Created by Nick Bolton on 6/9/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBFlexibleBackgroundViewController.h"
#import "PBPopoverView.h"

@interface PBFlexibleBackgroundViewController ()

@end

@implementation PBFlexibleBackgroundViewController

- (void)commonInit {
    self.beakImageName = @"pbn_beak";
    self.topImageName = @"pbn_top";
    self.topLeftImageName = @"pbn_top_left";
    self.topRightImageName = @"pbn_top_right";
    self.leftImageName = @"pbn_left";
    self.centerImageName = @"pbn_center";
    self.rightImageName = @"pbn_right";
    self.bottomLeftImageName = @"pbn_bottom_left";
    self.bottomImageName = @"pbn_bottom";
    self.bottomRightImageName = @"pbn_bottom_right";
}

- (NSSize)minimumSize {

    CGFloat minWidth =
    _backgroundView.topLeftImage.size.width +
    _backgroundView.topRightImage.size.width +
    _backgroundView.beakImage.size.width;

    CGFloat minHeight =
    _backgroundView.topLeftImage.size.height +
    _backgroundView.bottomLeftImage.size.height;

    return NSMakeSize(minWidth, minHeight);
}

- (void)awakeFromNib {
    [super awakeFromNib];

    NSAssert([_backgroundView isKindOfClass:[PBPopoverView class]],
             @"Root view must be a PBPopoverView");

    _backgroundView.beakImage = [NSImage imageNamed:_beakImageName];
    _backgroundView.topImage = [NSImage imageNamed:_topImageName];
    _backgroundView.topLeftImage = [NSImage imageNamed:_topLeftImageName];
    _backgroundView.topRightImage = [NSImage imageNamed:_topRightImageName];
    _backgroundView.leftImage = [NSImage imageNamed:_leftImageName];
    _backgroundView.centerImage = [NSImage imageNamed:_centerImageName];
    _backgroundView.rightImage = [NSImage imageNamed:_rightImageName];
    _backgroundView.bottomLeftImage = [NSImage imageNamed:_bottomLeftImageName];
    _backgroundView.bottomImage = [NSImage imageNamed:_bottomImageName];
    _backgroundView.bottomRightImage = [NSImage imageNamed:_bottomRightImageName];
}

@end
