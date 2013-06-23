//
//  NSEvent+PBFoundation.m
//  PBFoundation
//
//  Created by Nick Bolton on 1/16/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "NSEvent+PBFoundation.h"

NSInteger const kPBEventAllModifiersMask = NSNumericPadKeyMask | NSAlphaShiftKeyMask | NSHelpKeyMask | NSCommandKeyMask | NSAlternateKeyMask | NSControlKeyMask | NSShiftKeyMask | NSFunctionKeyMask;

@implementation NSEvent (PBFoundation)

+ (BOOL)isCurrentModifiersExactly:(NSUInteger)modifiers {
    return (kPBEventAllModifiersMask & [NSEvent modifierFlags]) == modifiers;
}

- (BOOL)isModifiersExactly:(NSUInteger)modifiers {
    return (kPBEventAllModifiersMask & [self modifierFlags]) == modifiers;
}

+ (BOOL)isCurrentModifiersEqualsTo:(NSInteger)modifierMask {
    return ([NSEvent modifierFlags] & kPBEventAllModifiersMask) == modifierMask;
}

+ (BOOL)isCurrentModifiersNone {
    return ([NSEvent modifierFlags] & kPBEventAllModifiersMask) == 0;
}

+ (BOOL)currentModifiersContains:(NSInteger)modifierMask {
    return ([NSEvent modifierFlags] & modifierMask) != 0;
}

- (BOOL)isModifiersEqualsTo:(NSInteger)modifierMask {
    return (self.modifierFlags & kPBEventAllModifiersMask) == modifierMask;
}

- (BOOL)isModifiersNone {
    return (self.modifierFlags & kPBEventAllModifiersMask) == 0;
}

- (BOOL)modifiersContains:(NSInteger)modifierMask {
    return (self.modifierFlags & modifierMask) != 0;
}

@end
