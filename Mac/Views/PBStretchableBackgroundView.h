//
//  PBStretchableBackgroundView.h
//  PBFoundation
//
//  Created by Nick Bolton on 1/5/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PBStretchableBackgroundView : NSView

@property (nonatomic, strong) NSImage *startCapImage;
@property (nonatomic, strong) NSImage *centerFillImage;
@property (nonatomic, strong) NSImage *endCapImage;
@property (nonatomic, getter = isVertical) BOOL vertical;
@property (nonatomic, getter = isFlipped) BOOL flipped;

@end
