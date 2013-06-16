//
//  PBPopoverView.h
//  PBNavigationViewController
//
//  Created by Nick Bolton on 6/9/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBMoveableView.h"

@interface PBPopoverView : PBMoveableView

@property (nonatomic, strong) NSImage *topLeftImage;
@property (nonatomic, strong) NSImage *topRightImage;
@property (nonatomic, strong) NSImage *topImage;
@property (nonatomic, strong) NSImage *leftImage;
@property (nonatomic, strong) NSImage *centerImage;
@property (nonatomic, strong) NSImage *rightImage;
@property (nonatomic, strong) NSImage *bottomLeftImage;
@property (nonatomic, strong) NSImage *bottomImage;
@property (nonatomic, strong) NSImage *bottomRightImage;
@property (nonatomic, strong) NSImage *beakImage;
@property (nonatomic, getter = isBeakVisible) BOOL beakVisible;
@property (nonatomic, getter = isFlipped) BOOL flipped;
@property (nonatomic) NSPoint beakReferencePoint;
@property (nonatomic) BOOL smoothingBeakMovement;

- (void)resetBeak;

@end
