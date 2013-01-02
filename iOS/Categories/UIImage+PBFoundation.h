//
//  UIImage+PBFoundation.h
//  PBFoundation
//
//  Created by Nick Bolton on 12/12/12.
//  Copyright (c) 2012 Pixelbleed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (PBFoundation)

- (UIColor *)colorAtPoint:(CGPoint)point;
- (NSArray *)colorsForStripAtX:(NSUInteger)x;
- (NSArray *)colorsForStripAtY:(NSUInteger)y;

@end
