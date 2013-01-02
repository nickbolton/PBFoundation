//
//  UIView+PBFoundation.h
//  PBFoundation
//
//  Created by Nick Bolton on 4/1/12.
//  Copyright (c) 2012 Pixelbleed LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (PBFoundation)

- (void)removeAllSubviews;
- (void)DEBUG_colorizeSelfAndSubviews;
- (void)fadeOutInWithDuration:(CGFloat)duration andBlock:(void(^)(void))block;
- (UIImage *)snapshot;
- (void)addFadingMaskWithEdgeInsets:(UIEdgeInsets)edgeInsets;
- (void)disableGesturesOfType:(Class)gestureType recurse:(BOOL)recurse;

@end
