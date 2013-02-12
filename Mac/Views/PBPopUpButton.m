//
//  PBPopUpButton.m
//  PBListView
//
//  Created by Nick Bolton on 2/10/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBPopUpButton.h"

@interface PBPopUpButton() {
    NSTrackingRectTag _trackingTag;
}

@end

@implementation PBPopUpButton

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _onAlphaValue = 1.0f;
    _offAlphaValue = .6f;
}

- (void)startTracking {
    if (_hoverAlphaEnabled) {
        self.alphaValue = _offAlphaValue;
        _trackingTag =
        [self.superview
         addTrackingRect:self.frame
         owner:self
         userData:nil
         assumeInside:YES];
    }
}

- (void)setImage:(NSImage *)image {
    super.image = image;
    ((NSPopUpButtonCell *)self.cell).image = image;
}

- (void)stopTracking {
    if (_hoverAlphaEnabled) {
        [self.superview removeTrackingRect:_trackingTag];
        _trackingTag = 0;
    }
}

- (void)mouseExited:(NSEvent *)event {
    self.alphaValue = _offAlphaValue;
}

- (void)mouseEntered:(NSEvent *)event {
    self.alphaValue = _onAlphaValue;
}

@end
