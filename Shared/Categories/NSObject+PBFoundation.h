//
//  NSObject+PBFoundation.h
//  SocialScreen
//
//  Created by Nick Bolton on 1/5/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (PBFoundation)

- (id)performIfRespondsToSelector:(SEL)aSelector;
- (void)performIfRespondsToSelector:(SEL)aSelector
                         afterDelay:(NSTimeInterval)delay;
- (id)performIfRespondsToSelector:(SEL)aSelector
                       withObject:(id)object;
- (void)performIfRespondsToSelector:(SEL)aSelector
                         withObject:(id)object
                         afterDelay:(NSTimeInterval)delay;
- (id)performIfRespondsToSelector:(SEL)aSelector
                       withObject:(id)object1
                       withObject:(id)object2;

@end
