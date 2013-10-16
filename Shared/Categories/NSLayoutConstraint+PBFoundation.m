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
+ (NSLayoutConstraint *)addMinWidthConstraint:(CGFloat)minWidth toView:(UIView *)view {
#else
+ (NSLayoutConstraint *)addMinWidthConstraint:(CGFloat)minWidth toView:(NSView *)view {
#endif
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
    return constraint;
}

#if TARGET_OS_IPHONE
+ (NSLayoutConstraint *)addMaxWidthConstraint:(CGFloat)maxWidth toView:(UIView *)view {
#else
+ (NSLayoutConstraint *)addMaxWidthConstraint:(CGFloat)maxWidth toView:(NSView *)view {
#endif
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
    return constraint;
}

#if TARGET_OS_IPHONE
+ (NSLayoutConstraint *)addWidthConstraint:(CGFloat)width toView:(UIView *)view {
#else
+ (NSLayoutConstraint *)addWidthConstraint:(CGFloat)width toView:(NSView *)view {
#endif
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
    return constraint;
}

#if TARGET_OS_IPHONE
+ (NSArray *)addMinWidthConstraint:(CGFloat)minWidth maxWidthConstraint:(CGFloat)maxWidth toView:(UIView *)view {
#else
+ (NSArray *)addMinWidthConstraint:(CGFloat)minWidth maxWidthConstraint:(CGFloat)maxWidth toView:(NSView *)view {
#endif

    NSMutableArray *constraints = [NSMutableArray array];

    if (minWidth == maxWidth) {
        [constraints addObject:[self addWidthConstraint:minWidth toView:view]];
    } else {
        [constraints addObject:[self addMinWidthConstraint:minWidth toView:view]];
        [constraints addObject:[self addMaxWidthConstraint:maxWidth toView:view]];
    }
    return constraints;
}

#if TARGET_OS_IPHONE
+ (NSLayoutConstraint *)addMinHeightConstraint:(CGFloat)minHeight toView:(UIView *)view {
#else
+ (NSLayoutConstraint *)addMinHeightConstraint:(CGFloat)minHeight toView:(NSView *)view {
#endif
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
    return constraint;
}

#if TARGET_OS_IPHONE
+ (NSLayoutConstraint *)addMaxHeightConstraint:(CGFloat)maxHeight toView:(UIView *)view {
#else
+ (NSLayoutConstraint *)addMaxHeightConstraint:(CGFloat)maxHeight toView:(NSView *)view {
#endif
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
    return constraint;
}

#if TARGET_OS_IPHONE
+ (NSLayoutConstraint *)addHeightConstraint:(CGFloat)height toView:(UIView *)view {
#else
+ (NSLayoutConstraint *)addHeightConstraint:(CGFloat)height toView:(NSView *)view {
#endif
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
    return constraint;
}

#if TARGET_OS_IPHONE
+ (NSArray *)addMinHeightConstraint:(CGFloat)minHeight maxHeightConstraint:(CGFloat)maxHeight toView:(UIView *)view {
#else
+ (NSArray *)addMinHeightConstraint:(CGFloat)minHeight maxHeightConstraint:(CGFloat)maxHeight toView:(NSView *)view {
#endif

    NSMutableArray *constraints = [NSMutableArray array];

    if (minHeight == maxHeight) {
        [constraints addObject:[self addHeightConstraint:minHeight toView:view]];
    } else {
        [constraints addObject:[self addMinHeightConstraint:minHeight toView:view]];
        [constraints addObject:[self addMaxHeightConstraint:maxHeight toView:view]];
    }

    return constraints;
}

#if TARGET_OS_IPHONE
+ (NSLayoutConstraint *)horizontallyCenterView:(UIView *)view {
#else
+ (NSLayoutConstraint *)horizontallyCenterView:(NSView *)view {
#endif
    return [self horizontallyCenterView:view padding:0.0f];
}

#if TARGET_OS_IPHONE
+ (NSLayoutConstraint *)horizontallyCenterView:(UIView *)view padding:(CGFloat)padding {
#else
+ (NSLayoutConstraint *)horizontallyCenterView:(NSView *)view padding:(CGFloat)padding {
#endif
    NSLayoutConstraint *constraint =
    [NSLayoutConstraint
     constraintWithItem:view
     attribute:NSLayoutAttributeCenterX
     relatedBy:NSLayoutRelationEqual
     toItem:view.superview
     attribute:NSLayoutAttributeCenterX
     multiplier:1.0f
     constant:padding];
    [view.superview addConstraint:constraint];
    return constraint;
}

#if TARGET_OS_IPHONE
+ (NSLayoutConstraint *)verticallyCenterView:(UIView *)view {
#else
+ (NSLayoutConstraint *)verticallyCenterView:(NSView *)view {
#endif
    return
    [self verticallyCenterView:view padding:0.0f];
}

#if TARGET_OS_IPHONE
+ (NSLayoutConstraint *)verticallyCenterView:(UIView *)view padding:(CGFloat)padding {
#else
+ (NSLayoutConstraint *)verticallyCenterView:(NSView *)view padding:(CGFloat)padding {
#endif

    NSLayoutConstraint *constraint =
    [NSLayoutConstraint
     constraintWithItem:view
     attribute:NSLayoutAttributeCenterY
     relatedBy:NSLayoutRelationEqual
     toItem:view.superview
     attribute:NSLayoutAttributeCenterY
     multiplier:1.0f
     constant:padding];
    [view.superview addConstraint:constraint];
    return constraint;
}

#if TARGET_OS_IPHONE
+ (NSArray *)expandWidthToSuperview:(UIView *)view {
#else
+ (NSArray *)expandWidthToSuperview:(NSView *)view {
#endif
    NSArray *constraints =
    [NSLayoutConstraint
     constraintsWithVisualFormat:@"H:|-(0)-[v]-(0)-|"
     options:NSLayoutFormatAlignAllCenterX
     metrics:nil
     views:@{@"v" : view}];
    [view.superview addConstraints:constraints];
    return constraints;
}

#if TARGET_OS_IPHONE
+ (NSArray *)expandHeightToSuperview:(UIView *)view {
#else
+ (NSArray *)expandHeightToSuperview:(NSView *)view {
#endif
    NSArray *constraints =
    [NSLayoutConstraint
     constraintsWithVisualFormat:@"V:|-(0)-[v]-(0)-|"
     options:NSLayoutFormatAlignAllCenterY
     metrics:nil
     views:@{@"v" : view}];
    [view.superview addConstraints:constraints];
    return constraints;
}

#if TARGET_OS_IPHONE
+ (NSArray *)expandToSuperview:(UIView *)view {
#else
+ (NSArray *)expandToSuperview:(NSView *)view {
#endif
    NSMutableArray *constraints = [NSMutableArray array];
    [constraints addObjectsFromArray:[self expandWidthToSuperview:view]];
    [constraints addObjectsFromArray:[self expandHeightToSuperview:view]];
    return constraints;
}

#if TARGET_OS_IPHONE
+ (NSLayoutConstraint *)alignToTop:(UIView *)view withPadding:(CGFloat)padding {
#else
+ (NSLayoutConstraint *)alignToTop:(NSView *)view withPadding:(CGFloat)padding {
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
    return constraint;
}

#if TARGET_OS_IPHONE
+ (NSLayoutConstraint *)alignToBottom:(UIView *)view withPadding:(CGFloat)padding {
#else
+ (NSLayoutConstraint *)alignToBottom:(NSView *)view withPadding:(CGFloat)padding {
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
    return constraint;
}

#if TARGET_OS_IPHONE
+ (NSLayoutConstraint *)alignToLeft:(UIView *)view withPadding:(CGFloat)padding {
#else
+ (NSLayoutConstraint *)alignToLeft:(NSView *)view withPadding:(CGFloat)padding {
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
    return constraint;
}

#if TARGET_OS_IPHONE
+ (NSLayoutConstraint *)alignToRight:(UIView *)view withPadding:(CGFloat)padding {
#else
+ (NSLayoutConstraint *)alignToRight:(NSView *)view withPadding:(CGFloat)padding {
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
    return constraint;
}

#if TARGET_OS_IPHONE
+ (NSLayoutConstraint *)verticallySpaceTopView:(UIView *)topView toBottomView:(UIView *)bottomView withPadding:(CGFloat)padding {
#else
+ (NSLayoutConstraint *)verticallySpaceTopView:(NSView *)topView toBottomView:(NSView *)bottomView withPadding:(CGFloat)padding {
#endif
    NSLayoutConstraint *constraint =
    [NSLayoutConstraint
     constraintWithItem:topView
     attribute:NSLayoutAttributeBottom
     relatedBy:NSLayoutRelationEqual
     toItem:bottomView
     attribute:NSLayoutAttributeTop
     multiplier:1.0f
     constant:padding];
    [topView.superview addConstraint:constraint];
    return constraint;
}

#if TARGET_OS_IPHONE
+ (NSLayoutConstraint *)horizontallySpaceLeftView:(UIView *)leftView toRightView:(UIView *)rightView withPadding:(CGFloat)padding {
#else
+ (NSLayoutConstraint *)horizontallySpaceLeftView:(NSView *)leftView toRightView:(NSView *)rightView withPadding:(CGFloat)padding {
#endif
    NSLayoutConstraint *constraint =
    [NSLayoutConstraint
     constraintWithItem:leftView
     attribute:NSLayoutAttributeRight
     relatedBy:NSLayoutRelationEqual
     toItem:rightView
     attribute:NSLayoutAttributeLeft
     multiplier:1.0f
     constant:padding];
    [leftView.superview addConstraint:constraint];
    return constraint;
}

@end
