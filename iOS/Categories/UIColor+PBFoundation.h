//
//  UIColor+PBFoundation.h
//  PBFoundation
//
//  Created by Nick Bolton on 3/24/12.
//  Copyright (c) 2012 Pixelbleed LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (PBFoundation)

+ (UIColor *)randomColor;
+ (UIColor *)colorWithRGBHex:(UInt32)hex;
+ (UIColor *)colorWithRGBHex:(UInt32)hex alpha:(CGFloat)alpha;

- (UIColor *)colorWithAlpha:(CGFloat)alpha;
- (UIColor *)contrastingColor;

@end
