//
//  UIButton+PBFoundation.m
//  Pods
//
//  Created by Nick Bolton on 12/25/13.
//
//

#import "UIButton+PBFoundation.h"
#import "UIView+PBFoundation.h"

@implementation UIButton (PBFoundation)

- (void)bindWithWiggleAnimation:(id)target action:(SEL)action {

    [self
     addTarget:target
     action:action
     forControlEvents:UIControlEventTouchDown];

    [self
     addTarget:self
     action:@selector(stopWiggleAnimation)
     forControlEvents:UIControlEventTouchUpOutside];

    [self
     addTarget:self
     action:@selector(stopWiggleAnimation)
     forControlEvents:UIControlEventTouchCancel];
}

@end
