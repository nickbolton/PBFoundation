//
//  PBToggleImageView.h
//  PBFoundation
//
//  Created by Nick Bolton on 1/6/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBStretchableImageView.h"

@interface PBToggleImageView : PBStretchableImageView

@property (nonatomic, strong) NSImage *topAlternateImage;
@property (nonatomic, strong) NSImage *middleAlternateImage;
@property (nonatomic, strong) NSImage *bottomAlternateImage;

@property (nonatomic, assign) SEL mouseDownAction;
@property (nonatomic, assign) SEL mouseUpAction;
@property (nonatomic, assign) SEL mouseMovedAction;
@property (nonatomic, assign) SEL mouseEnteredAction;
@property (nonatomic, assign) SEL mouseExitedAction;

@property (nonatomic) BOOL on;
@property (nonatomic, getter = isMomentary) BOOL momentary;

@end
