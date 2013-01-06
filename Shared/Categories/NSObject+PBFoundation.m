//
//  NSObject+PBFoundation.m
//  SocialScreen
//
//  Created by Nick Bolton on 1/5/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "NSObject+PBFoundation.h"

@implementation NSObject (PBFoundation)

- (id)performIfRespondsToSelector:(SEL)sel {
    if ([self respondsToSelector:sel] == YES) {
        return [self performSelector:sel];
    }
    return nil;
}

- (void)performIfRespondsToSelector:(SEL)sel afterDelay:(NSTimeInterval)delay {
    if ([self respondsToSelector:sel] == YES) {
        [self performSelector:sel withObject:nil afterDelay:delay];
    }
}

- (id)performIfRespondsToSelector:(SEL)sel withObject:(id)object {
    if ([self respondsToSelector:sel] == YES) {
        return [self performSelector:sel withObject:object];
    }
    return nil;
}

- (void)performIfRespondsToSelector:(SEL)sel
                         withObject:(id)object
                         afterDelay:(NSTimeInterval)delay {
    if ([self respondsToSelector:sel] == YES) {
        [self performSelector:sel withObject:object afterDelay:delay];
    }
}

- (id)performIfRespondsToSelector:(SEL)sel withObject:(id)object1 withObject:(id)object2 {
    if ([self respondsToSelector:sel] == YES) {
        return [self performSelector:sel withObject:object1 withObject:object2];
    }
    return nil;
}

@end
