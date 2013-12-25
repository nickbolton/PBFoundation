//
//  UIButton+PBFoundation.m
//  Pods
//
//  Created by Nick Bolton on 12/25/13.
//
//

#import "UIButton+PBFoundation.h"
#import "UIView+PBFoundation.h"
#import <objc/runtime.h>

static char kPBWiggleAnimationRotationObjectKey;
static char kPBWiggleAnimationTranslationObjectKey;
static char kPBWiggleAnimationTargetViewObjectKey;

@implementation UIButton (PBFoundation)

- (UIView *)pb_wiggleAnimationTargetView {
    return (UIView *)objc_getAssociatedObject(self, &kPBWiggleAnimationTargetViewObjectKey);
}

- (void)pb_setWiggleAnimationTargetView:(UIView *)view {
    objc_setAssociatedObject(self, &kPBWiggleAnimationTargetViewObjectKey, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)pb_wiggleAnimationRotation {
    return (NSNumber *)objc_getAssociatedObject(self, &kPBWiggleAnimationRotationObjectKey);
}

- (void)pb_setWiggleAnimationRotation:(NSNumber *)rotation {
    objc_setAssociatedObject(self, &kPBWiggleAnimationRotationObjectKey, rotation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSValue *)pb_wiggleAnimationTranslation {
    return (NSValue *)objc_getAssociatedObject(self, &kPBWiggleAnimationTranslationObjectKey);
}

- (void)pb_setWiggleAnimationTranslation:(NSValue *)translation {
    objc_setAssociatedObject(self, &kPBWiggleAnimationTranslationObjectKey, translation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)bindWiggleAnimationWithView:(UIView *)view
                       withRotation:(CGFloat)rotation
                        translation:(CGPoint)translation
                stopOnTouchUpInside:(BOOL)stopOnTouchUpInside {

    [self pb_setWiggleAnimationTargetView:view];
    [self pb_setWiggleAnimationRotation:@(rotation)];
    [self pb_setWiggleAnimationTranslation:[NSValue valueWithCGPoint:translation]];

    [self
     addTarget:self
     action:@selector(pb_startWiggleAnimation:)
     forControlEvents:UIControlEventTouchDown];

    [self
     addTarget:view
     action:@selector(stopWiggleAnimation)
     forControlEvents:UIControlEventTouchUpOutside];

    [self
     addTarget:view
     action:@selector(stopWiggleAnimation)
     forControlEvents:UIControlEventTouchCancel];

    if (stopOnTouchUpInside) {

        [self
         addTarget:view
         action:@selector(stopWiggleAnimation)
         forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)pb_startWiggleAnimation:(id)sender {

    UIView *view = [self pb_wiggleAnimationTargetView];
    NSNumber *rotaton = [self pb_wiggleAnimationRotation];
    NSValue *translationValue = [self pb_wiggleAnimationTranslation];

    if (view != nil && rotaton != nil && translationValue != nil) {

        [view
         startWiggleAnimationWithRotation:rotaton.floatValue
         translation:translationValue.CGPointValue];
    }
}

@end
