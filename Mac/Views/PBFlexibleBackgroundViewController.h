//
//  PBFlexibleBackgroundViewController.h
//  PBNavigationViewController
//
//  Created by Nick Bolton on 6/9/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PBPopoverView;

@interface PBFlexibleBackgroundViewController : NSViewController

@property (nonatomic, weak) IBOutlet PBPopoverView *backgroundView;

@property (nonatomic, strong) NSString *beakImageName;
@property (nonatomic, strong) NSString *topImageName;
@property (nonatomic, strong) NSString *topLeftImageName;
@property (nonatomic, strong) NSString *topRightImageName;
@property (nonatomic, strong) NSString *leftImageName;
@property (nonatomic, strong) NSString *rightImageName;
@property (nonatomic, strong) NSString *centerImageName;
@property (nonatomic, strong) NSString *bottomLeftImageName;
@property (nonatomic, strong) NSString *bottomImageName;
@property (nonatomic, strong) NSString *bottomRightImageName;

- (void)commonInit;
- (NSSize)minimumSize;

@end
