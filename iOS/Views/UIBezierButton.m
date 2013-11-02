//
//  UIBezierButton.m
//  PBFoundation
//
//  Created by Nick Bolton on 11/26/12.
//  Copyright (c) 2012 Pixelbleed LLC. All rights reserved.
//

#import "UIBezierButton.h"

@interface UIBezierButton()

@property (nonatomic, strong) NSMutableDictionary *bezierPaths;
@property (nonatomic, strong) NSMutableDictionary *pathStrokeValues;
@property (nonatomic, strong) NSMutableDictionary *pathFillValues;

@end

@implementation UIBezierButton

- (NSMutableDictionary *)bezierPaths {
    if (_bezierPaths == nil) {
        self.bezierPaths = [NSMutableDictionary dictionary];
    }
    return _bezierPaths;
}

- (NSMutableDictionary *)pathStrokeValues {
    if (_pathStrokeValues == nil) {
        self.pathStrokeValues = [NSMutableDictionary dictionary];
    }
    return _pathStrokeValues;
}

- (NSMutableDictionary *)pathFillValues {
    if (_pathFillValues == nil) {
        self.pathFillValues = [NSMutableDictionary dictionary];
    }
    return _pathFillValues;
}

- (void)setBezierPath:(UIBezierPath *)bezierPath
      forControlState:(UIControlState)controlState {
    self.bezierPaths[@(controlState)] = bezierPath;
    [self setNeedsDisplay];
}

- (void)setPathStrokeColor:(UIColor *)pathStrokeColor
           forControlState:(UIControlState)controlState {
    self.pathStrokeValues[@(controlState)] =
    @{@"color" : pathStrokeColor};
    [self setNeedsDisplay];
}

- (void)setPathFillColor:(UIColor *)pathFillColor
         forControlState:(UIControlState)controlState {
    self.pathFillValues[@(controlState)] =
    @{@"color" : pathFillColor};
    [self setNeedsDisplay];
}

- (UIBezierPath *)bezierPathForControlState:(UIControlState)controlState {
    UIBezierPath *bezierPath = self.bezierPaths[@(controlState)];
    if (bezierPath == nil && controlState != UIControlStateNormal) {
        bezierPath = self.bezierPaths[@(UIControlStateNormal)];
    }
    return bezierPath;
}

- (UIColor *)pathStrokeColorForControlState:(UIControlState)controlState {
    UIColor *color = self.pathStrokeValues[@(controlState)];
    if (color == nil && controlState != UIControlStateNormal) {
        color = self.pathStrokeValues[@(UIControlStateNormal)];
    }
    return color;
}

- (UIColor *)pathFillColorForControlState:(UIControlState)controlState {
    UIColor *color = self.pathFillValues[@(controlState)];
    if (color == nil && controlState != UIControlStateNormal) {
        color = self.pathFillValues[@(UIControlStateNormal)];
    }
    return color;
}

- (void)fillBackgroundPath {

    UIBezierPath *bezierPath = [self bezierPathForControlState:self.state];
    NSDictionary *values = self.pathFillValues[@(self.state)];
    UIColor *color = values[@"color"];

    if (color != nil) {
        [color setFill];
        [bezierPath fill];
    }
}

- (void)strokeBackgroundPath {
    UIBezierPath *bezierPath = [self bezierPathForControlState:self.state];
    NSDictionary *values = self.pathStrokeValues[@(self.state)];
    UIColor *color = values[@"color"];

    if (color != nil) {
        [color setStroke];
        [bezierPath stroke];
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {

    [self fillBackgroundPath];
    [self strokeBackgroundPath];

    [super drawRect:rect];
}

@end
