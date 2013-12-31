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
static char kPBWiggleAnimationStopDelayObjectKey;

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

- (NSNumber *)pb_wiggleAnimationStopDelay {
    return (NSNumber *)objc_getAssociatedObject(self, &kPBWiggleAnimationStopDelayObjectKey);
}

- (void)pb_setWiggleAnimationStopDelay:(NSNumber *)stopDelay {
    objc_setAssociatedObject(self, &kPBWiggleAnimationStopDelayObjectKey, stopDelay, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)bindWiggleAnimationWithView:(UIView *)view
                       withRotation:(CGFloat)rotation
                        translation:(CGPoint)translation
           stopDelayOnTouchUpInside:(NSTimeInterval)stopDelayOnTouchUpInside {

    [self pb_setWiggleAnimationTargetView:view];
    [self pb_setWiggleAnimationRotation:@(rotation)];
    [self pb_setWiggleAnimationTranslation:[NSValue valueWithCGPoint:translation]];
    [self pb_setWiggleAnimationStopDelay:@(stopDelayOnTouchUpInside)];

    [self
     addTarget:self
     action:@selector(pb_startWiggleAnimation:)
     forControlEvents:UIControlEventTouchDown];

    [self
     addTarget:self
     action:@selector(pb_startWiggleAnimation:)
     forControlEvents:UIControlEventTouchDragInside];

    [self
     addTarget:view
     action:@selector(stopWiggleAnimation)
     forControlEvents:UIControlEventTouchUpOutside];

    [self
     addTarget:view
     action:@selector(stopWiggleAnimation)
     forControlEvents:UIControlEventTouchDragOutside];

    [self
     addTarget:view
     action:@selector(stopWiggleAnimation)
     forControlEvents:UIControlEventTouchCancel];

    [self
     addTarget:self
     action:@selector(pb_stopWiggleAnimation:)
     forControlEvents:UIControlEventTouchUpInside];
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

- (void)pb_stopWiggleAnimation:(id)sender {

    UIView *view = [self pb_wiggleAnimationTargetView];
    NSNumber *stopDelay = [self pb_wiggleAnimationStopDelay];

    if (view != nil && stopDelay != nil) {

        if (stopDelay.floatValue > 0.0f) {

            NSTimeInterval delayInSeconds = stopDelay.floatValue;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [view stopWiggleAnimation];
            });

        } else {
            [view stopWiggleAnimation];
        }
    }
}

@end
