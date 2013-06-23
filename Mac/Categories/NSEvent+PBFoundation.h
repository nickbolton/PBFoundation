//
//  NSEvent+PBFoundation.h
//  PBFoundation
//
//  Created by Nick Bolton on 1/16/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSInteger const kPBEventAllModifiersMask;

@interface NSEvent (PBFoundation)

+ (BOOL)isCurrentModifiersEqualsTo:(NSInteger)modifierMask;
+ (BOOL)isCurrentModifiersNone;
+ (BOOL)currentModifiersContains:(NSInteger)modifierMask;

- (BOOL)isModifiersEqualsTo:(NSInteger)modifierMask;
- (BOOL)isModifiersNone;
- (BOOL)modifiersContains:(NSInteger)modifierMask;

@end
