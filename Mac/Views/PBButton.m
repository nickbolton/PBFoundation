//
//  PBButton.m
//  PBListView
//
//  Created by Nick Bolton on 2/10/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBButton.h"

@interface PBButton() {
    NSTrackingRectTag _trackingTag;
}

@property (nonatomic, strong) NSImage *defaultImage;
@property (nonatomic, strong) NSImage *defaultAlternateImage;

@end

@implementation PBButton

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

- (void)setEnabled:(BOOL)flag {

    if (flag == NO && _disabledImage != nil) {
        self.defaultImage = self.image;
        self.defaultAlternateImage = self.alternateImage;
        self.image = _disabledImage;
        if (self.alternateImage != nil) {
            if (_alternateDisabledImage != nil) {
                self.alternateImage = _alternateDisabledImage;
            } else {
                self.alternateImage = _disabledImage;
            }
        }
    } else {
        self.image = _defaultImage;
        self.alternateImage = _defaultAlternateImage;
    }
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
