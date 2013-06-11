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

    PBPopoverView *backgroundView = (id)self.view;

    CGFloat minWidth =
    backgroundView.topLeftImage.size.width +
    backgroundView.topRightImage.size.width +
    backgroundView.beakImage.size.width;

    CGFloat minHeight =
    backgroundView.topLeftImage.size.height +
    backgroundView.bottomLeftImage.size.height;

    return NSMakeSize(minWidth, minHeight);
}

- (void)awakeFromNib {
    [super awakeFromNib];

    PBPopoverView *backgroundView = (id)self.view;

    NSAssert([backgroundView isKindOfClass:[PBPopoverView class]],
             @"Root view must be a PBPopoverView");

    backgroundView.beakImage = [NSImage imageNamed:_beakImageName];
    backgroundView.topImage = [NSImage imageNamed:_topImageName];
    backgroundView.topLeftImage = [NSImage imageNamed:_topLeftImageName];
    backgroundView.topRightImage = [NSImage imageNamed:_topRightImageName];
    backgroundView.leftImage = [NSImage imageNamed:_leftImageName];
    backgroundView.centerImage = [NSImage imageNamed:_centerImageName];
    backgroundView.rightImage = [NSImage imageNamed:_rightImageName];
    backgroundView.bottomLeftImage = [NSImage imageNamed:_bottomLeftImageName];
    backgroundView.bottomImage = [NSImage imageNamed:_bottomImageName];
    backgroundView.bottomRightImage = [NSImage imageNamed:_bottomRightImageName];
}

@end
