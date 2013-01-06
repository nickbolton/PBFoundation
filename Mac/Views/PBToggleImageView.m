//
//  PBToggleImageView.m
//  PaperPlanes
//
//  Created by Nick Bolton on 1/6/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBToggleImageView.h"

@interface PBToggleImageView() {
    
    BOOL _mouseOverView;
    NSTrackingRectTag _trackingTag;
}

@property (nonatomic, strong) NSImage *origTopImage;
@property (nonatomic, strong) NSImage *origMiddleImage;
@property (nonatomic, strong) NSImage *origBottomImage;

@end


@implementation PBToggleImageView

- (void)awakeFromNib {
    _mouseOverView = NO;
    NSRect frame = NSMakeRect(0, 0, NSWidth(self.frame), NSHeight(self.frame));
    _trackingTag = [self addTrackingRect:NSIntegralRect(frame) owner:self userData:nil assumeInside:NO];
}

- (void)dealloc {
    [self removeTrackingRect:_trackingTag];
}

- (void)setTopImage:(NSImage *)topImage {
    self.origTopImage = topImage;
    super.topImage = topImage;
}

- (void)setMiddleImage:(NSImage *)middleImage {
    self.origMiddleImage = middleImage;
    super.middleImage = middleImage;
}

- (void)setBottomImage:(NSImage *)bottomImage {
    self.origBottomImage = bottomImage;
    super.bottomImage = bottomImage;
}

- (void)toggleState {
    self.on = !_on;
}

- (void)updateImages {

    NSImage *topImage;
    NSImage *middleImage;
    NSImage *bottomImage;

    if (_on) {
        topImage = _topAlternateImage;
        middleImage = _middleAlternateImage;
        bottomImage = _bottomAlternateImage;
    } else {
        topImage = _origTopImage;
        middleImage = _origMiddleImage;
        bottomImage = _origBottomImage;
    }

    super.topImage = topImage;
    super.middleImage = middleImage;
    super.bottomImage = bottomImage;

    [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)event {
    NSLog(@"%s", __PRETTY_FUNCTION__);

    if (self.isEnabled) {

        if (self.target != nil && _mouseDownAction != nil) {
            [self.target performSelector:_mouseDownAction withObject:self];
        }

        [self toggleState];

        self.on = YES;

        [self updateImages];

        [self setNeedsDisplay:YES];
    }
}

- (void)mouseUp:(NSEvent *)event {
    NSLog(@"%s", __PRETTY_FUNCTION__);

    if (self.isEnabled) {
        
        SEL action = [super action];
        id target = [super target];
        [target performSelector:action withObject:self];

        if (self.target != nil && _mouseUpAction != nil) {
            [self.target performSelector:_mouseUpAction withObject:self];
        }

        self.on = !_momentary;
        [self updateImages];
    }
}

- (void)mouseEntered:(NSEvent *)event {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    _mouseOverView = YES;

    self.window.acceptsMouseMovedEvents = YES;

    [self updateImages];

    if (self.target != nil && _mouseEnteredAction != nil) {
        [self.target performSelector:_mouseEnteredAction withObject:self];
    }
}

- (void)mouseExited:(NSEvent *)event {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    _mouseOverView = NO;

    self.window.acceptsMouseMovedEvents = NO;

    [self updateImages];

    if (self.target != nil && _mouseExitedAction != nil) {
        [self.target performSelector:_mouseExitedAction withObject:self];
    }
}

- (void)mouseMoved:(NSEvent *)event {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if (self.target != nil && _mouseMovedAction != nil) {
        [self.target performSelector:_mouseMovedAction withObject:self];
    }
}

- (id)objectValue {
    return [NSNumber numberWithBool:_on];
}

- (void)setObjectValue:(id < NSCopying >)object {
    if ([(NSObject *)object isKindOfClass:[NSNumber class]]) {
        self.on = [(NSNumber *)object boolValue];
    }
}

@end
