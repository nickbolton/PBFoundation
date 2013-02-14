//
//  NSLayoutConstraint+PBFoundation.h
//  PBFoundation
//
//  Created by Nick Bolton on 2/9/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSLayoutConstraint (PBFoundation)

#if TARGET_OS_IPHONE
+ (void)addMinWidthConstraint:(CGFloat)minWidth toView:(UIView *)view;
+ (void)addMaxWidthConstraint:(CGFloat)maxWidth toView:(UIView *)view;
+ (void)addWidthConstraint:(CGFloat)width toView:(UIView *)view;
+ (void)addMinWidthConstraint:(CGFloat)minWidth maxWidthConstraint:(CGFloat)maxWidth toView:(UIView *)view;
+ (void)addMinHeightConstraint:(CGFloat)minHeight toView:(UIView *)view;
+ (void)addMaxHeightConstraint:(CGFloat)maxHeight toView:(UIView *)view;
+ (void)addHeightConstraint:(CGFloat)height toView:(UIView *)view;
+ (void)addMinHeightConstraint:(CGFloat)minHeight maxHeightConstraint:(CGFloat)maxHeight toView:(UIView *)view;
+ (void)horizontallyCenterView:(UIView *)view;
+ (void)verticallyCenterView:(UIView *)view;
+ (void)expandWidthToSuperview:(UIView *)view;
+ (void)expandHeightToSuperview:(UIView *)view;
+ (void)expandToSuperview:(UIView *)view;
+ (void)alignToTop:(UIView *)view withPadding:(CGFloat)padding;
+ (void)alignToBottom:(UIView *)view withPadding:(CGFloat)padding;
+ (void)alignToLeft:(UIView *)view withPadding:(CGFloat)padding;
+ (void)alignToRight:(UIView *)view withPadding:(CGFloat)padding;
#else
+ (void)addMinWidthConstraint:(CGFloat)minWidth toView:(NSView *)view;
+ (void)addMaxWidthConstraint:(CGFloat)maxWidth toView:(NSView *)view;
+ (void)addWidthConstraint:(CGFloat)width toView:(NSView *)view;
+ (void)addMinWidthConstraint:(CGFloat)minWidth maxWidthConstraint:(CGFloat)maxWidth toView:(NSView *)view;
+ (void)addMinHeightConstraint:(CGFloat)minHeight toView:(NSView *)view;
+ (void)addMaxHeightConstraint:(CGFloat)maxHeight toView:(NSView *)view;
+ (void)addHeightConstraint:(CGFloat)height toView:(NSView *)view;
+ (void)addMinHeightConstraint:(CGFloat)minHeight maxHeightConstraint:(CGFloat)maxHeight toView:(NSView *)view;
+ (void)horizontallyCenterView:(NSView *)view;
+ (void)verticallyCenterView:(NSView *)view;
+ (void)expandWidthToSuperview:(NSView *)view;
+ (void)expandHeightToSuperview:(NSView *)view;
+ (void)expandToSuperview:(NSView *)view;
+ (void)alignToTop:(NSView *)view withPadding:(CGFloat)padding;
+ (void)alignToBottom:(NSView *)view withPadding:(CGFloat)padding;
+ (void)alignToLeft:(NSView *)view withPadding:(CGFloat)padding;
+ (void)alignToRight:(NSView *)view withPadding:(CGFloat)padding;
#endif


@end
