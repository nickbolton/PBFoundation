//
//  NSLayoutConstraint+PBFoundation.m
//  PBFoundation
//
//  Created by Nick Bolton on 2/9/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "NSLayoutConstraint+PBFoundation.h"

@implementation NSLayoutConstraint (PBFoundation)

#if TARGET_OS_IPHONE
+ (void)addMinWidthConstraint:(CGFloat)minWidth toView:(UIView *)view {
#else
+ (void)addMinWidthConstraint:(CGFloat)minWidth toView:(NSView *)view {
#endif
    if (minWidth < 0) {
        NSLog(@"ZZZ");
    }
    NSLayoutConstraint *constraint =
    [NSLayoutConstraint
     constraintWithItem:view
     attribute:NSLayoutAttributeWidth
     relatedBy:NSLayoutRelationGreaterThanOrEqual
     toItem:nil
     attribute:0
     multiplier:1.0f
     constant:minWidth];
    [view addConstraint:constraint];
}

#if TARGET_OS_IPHONE
+ (void)addMaxWidthConstraint:(CGFloat)maxWidth toView:(UIView *)view {
#else
+ (void)addMaxWidthConstraint:(CGFloat)maxWidth toView:(NSView *)view {
#endif
    if (maxWidth == 0) {
        NSLog(@"ZZZ");
    }
    NSLayoutConstraint *constraint =
    [NSLayoutConstraint
     constraintWithItem:view
     attribute:NSLayoutAttributeWidth
     relatedBy:NSLayoutRelationLessThanOrEqual
     toItem:nil
     attribute:0
     multiplier:1.0f
     constant:maxWidth];
    [view addConstraint:constraint];
}

#if TARGET_OS_IPHONE
+ (void)addWidthConstraint:(CGFloat)width toView:(UIView *)view {
#else
+ (void)addWidthConstraint:(CGFloat)width toView:(NSView *)view {
#endif
    if (width < 0) {
        NSLog(@"ZZZ");
    }
    NSLayoutConstraint *constraint =
    [NSLayoutConstraint
     constraintWithItem:view
     attribute:NSLayoutAttributeWidth
     relatedBy:NSLayoutRelationEqual
     toItem:nil
     attribute:0
     multiplier:1.0f
     constant:width];
    [view addConstraint:constraint];
}

#if TARGET_OS_IPHONE
+ (void)addMinWidthConstraint:(CGFloat)minWidth maxWidthConstraint:(CGFloat)maxWidth toView:(UIView *)view {
#else
+ (void)addMinWidthConstraint:(CGFloat)minWidth maxWidthConstraint:(CGFloat)maxWidth toView:(NSView *)view {
#endif

    if (minWidth == maxWidth) {
        [self addWidthConstraint:minWidth toView:view];
    } else {
        [self addMinWidthConstraint:minWidth toView:view];
        [self addMaxWidthConstraint:maxWidth toView:view];
    }
}

#if TARGET_OS_IPHONE
+ (void)addMinHeightConstraint:(CGFloat)minHeight toView:(UIView *)view {
#else
+ (void)addMinHeightConstraint:(CGFloat)minHeight toView:(NSView *)view {
#endif
    if (minHeight < 0) {
        NSLog(@"ZZZ");
    }
    NSLayoutConstraint *constraint =
    [NSLayoutConstraint
     constraintWithItem:view
     attribute:NSLayoutAttributeHeight
     relatedBy:NSLayoutRelationGreaterThanOrEqual
     toItem:nil
     attribute:0
     multiplier:1.0f
     constant:minHeight];
    [view addConstraint:constraint];
}

#if TARGET_OS_IPHONE
+ (void)addMaxHeightConstraint:(CGFloat)maxHeight toView:(UIView *)view {
#else
+ (void)addMaxHeightConstraint:(CGFloat)maxHeight toView:(NSView *)view {
#endif
    if (maxHeight < 0) {
        NSLog(@"ZZZ");
    }
    NSLayoutConstraint *constraint =
    [NSLayoutConstraint
     constraintWithItem:view
     attribute:NSLayoutAttributeHeight
     relatedBy:NSLayoutRelationLessThanOrEqual
     toItem:nil
     attribute:0
     multiplier:1.0f
     constant:maxHeight];
    [view addConstraint:constraint];
}

#if TARGET_OS_IPHONE
+ (void)addHeightConstraint:(CGFloat)height toView:(UIView *)view {
#else
+ (void)addHeightConstraint:(CGFloat)height toView:(NSView *)view {
#endif
    if (height < 0) {
        NSLog(@"ZZZ");
    }
    NSLayoutConstraint *constraint =
    [NSLayoutConstraint
     constraintWithItem:view
     attribute:NSLayoutAttributeHeight
     relatedBy:NSLayoutRelationEqual
     toItem:nil
     attribute:0
     multiplier:1.0f
     constant:height];
    [view addConstraint:constraint];
}

#if TARGET_OS_IPHONE
+ (void)addMinHeightConstraint:(CGFloat)minHeight maxHeightConstraint:(CGFloat)maxHeight toView:(UIView *)view {
#else
+ (void)addMinHeightConstraint:(CGFloat)minHeight maxHeightConstraint:(CGFloat)maxHeight toView:(NSView *)view {
#endif
    
    if (minHeight == maxHeight) {
        [self addHeightConstraint:minHeight toView:view];
    } else {
        [self addMinHeightConstraint:minHeight toView:view];
        [self addMaxHeightConstraint:maxHeight toView:view];
    }
}

#if TARGET_OS_IPHONE
+ (void)horizontallyCenterView:(UIView *)view {
#else
+ (void)horizontallyCenterView:(NSView *)view {
#endif
    NSLayoutConstraint *constraint =
    [NSLayoutConstraint
     constraintWithItem:view
     attribute:NSLayoutAttributeCenterX
     relatedBy:NSLayoutRelationEqual
     toItem:view.superview
     attribute:NSLayoutAttributeCenterX
     multiplier:1.0f
     constant:0.0f];
    [view.superview addConstraint:constraint];
}

#if TARGET_OS_IPHONE
+ (void)verticallyCenterView:(UIView *)view {
#else
+ (void)verticallyCenterView:(NSView *)view {
#endif
    NSLayoutConstraint *constraint =
    [NSLayoutConstraint
     constraintWithItem:view
     attribute:NSLayoutAttributeCenterY
     relatedBy:NSLayoutRelationEqual
     toItem:view.superview
     attribute:NSLayoutAttributeCenterY
     multiplier:1.0f
     constant:0.0f];
    [view.superview addConstraint:constraint];
}

#if TARGET_OS_IPHONE
+ (void)expandWidthToSuperview:(UIView *)view {
#else
+ (void)expandWidthToSuperview:(NSView *)view {
#endif
    NSArray *constraints =
    [NSLayoutConstraint
     constraintsWithVisualFormat:@"H:|-(0)-[v]-(0)-|"
     options:NSLayoutFormatAlignAllCenterX
     metrics:nil
     views:@{@"v" : view}];
    [view.superview addConstraints:constraints];
}

#if TARGET_OS_IPHONE
+ (void)expandHeightToSuperview:(UIView *)view {
#else
+ (void)expandHeightToSuperview:(NSView *)view {
#endif
    NSArray *constraints =
    [NSLayoutConstraint
     constraintsWithVisualFormat:@"V:|-(0)-[v]-(0)-|"
     options:NSLayoutFormatAlignAllCenterY
     metrics:nil
     views:@{@"v" : view}];
    [view.superview addConstraints:constraints];
}

#if TARGET_OS_IPHONE
+ (void)expandToSuperview:(UIView *)view {
#else
+ (void)expandToSuperview:(NSView *)view {
#endif
    [self expandWidthToSuperview:view];
    [self expandHeightToSuperview:view];
}

#if TARGET_OS_IPHONE
+ (void)alignToTop:(UIView *)view withPadding:(CGFloat)padding {
#else
+ (void)alignToTop:(NSView *)view withPadding:(CGFloat)padding {
#endif
    NSLayoutConstraint *constraint =
    [NSLayoutConstraint
     constraintWithItem:view
     attribute:NSLayoutAttributeTop
     relatedBy:NSLayoutRelationEqual
     toItem:view.superview
     attribute:NSLayoutAttributeTop
     multiplier:1.0f
     constant:padding];
    [view.superview addConstraint:constraint];
}

#if TARGET_OS_IPHONE
+ (void)alignToBottom:(UIView *)view withPadding:(CGFloat)padding {
#else
+ (void)alignToBottom:(NSView *)view withPadding:(CGFloat)padding {
#endif
    NSLayoutConstraint *constraint =
    [NSLayoutConstraint
     constraintWithItem:view
     attribute:NSLayoutAttributeBottom
     relatedBy:NSLayoutRelationEqual
     toItem:view.superview
     attribute:NSLayoutAttributeBottom
     multiplier:1.0f
     constant:padding];
    [view.superview addConstraint:constraint];
}

#if TARGET_OS_IPHONE
+ (void)alignToLeft:(UIView *)view withPadding:(CGFloat)padding {
#else
+ (void)alignToLeft:(NSView *)view withPadding:(CGFloat)padding {
#endif
    NSLayoutConstraint *constraint =
    [NSLayoutConstraint
     constraintWithItem:view
     attribute:NSLayoutAttributeLeft
     relatedBy:NSLayoutRelationEqual
     toItem:view.superview
     attribute:NSLayoutAttributeLeft
     multiplier:1.0f
     constant:padding];
    [view.superview addConstraint:constraint];
}

#if TARGET_OS_IPHONE
+ (void)alignToRight:(UIView *)view withPadding:(CGFloat)padding {
#else
+ (void)alignToRight:(NSView *)view withPadding:(CGFloat)padding {
#endif
    NSLayoutConstraint *constraint =
    [NSLayoutConstraint
     constraintWithItem:view
     attribute:NSLayoutAttributeRight
     relatedBy:NSLayoutRelationEqual
     toItem:view.superview
     attribute:NSLayoutAttributeRight
     multiplier:1.0f
     constant:padding];
    [view.superview addConstraint:constraint];
}

@end
