//
//  NSColor+PBFoundation.h
//  PBFoundation
//
//  Created by Nick Bolton on 1/16/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSColor (PBFoundation)

+ (NSColor *)colorWithRGBHex:(UInt32)hex;
+ (NSColor *)colorWithRGBHex:(UInt32)hex alpha:(CGFloat)alpha;

- (NSColor *)colorWithAlpha:(CGFloat)alpha;

- (CGColorRef)cgColorRef;
- (NSInteger)hexValue;

@end
