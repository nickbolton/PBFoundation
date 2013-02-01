//
//  NSEvent+PBFoundation.m
//  PBFoundation
//
//  Created by Nick Bolton on 1/16/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "NSEvent+PBFoundation.h"

@implementation NSEvent (PBFoundation)

+ (BOOL)isCurrentModifiersExactly:(NSUInteger)modifiers {
    NSUInteger allModifiers =
    (NSCommandKeyMask | NSAlternateKeyMask | NSControlKeyMask | NSShiftKeyMask | NSFunctionKeyMask);
    return (allModifiers & [NSEvent modifierFlags]) == modifiers;
}

- (BOOL)isModifiersExactly:(NSUInteger)modifiers {
    NSUInteger allModifiers =
    (NSCommandKeyMask | NSAlternateKeyMask | NSControlKeyMask | NSShiftKeyMask | NSFunctionKeyMask);
    return (allModifiers & [self modifierFlags]) == modifiers;
}

@end
