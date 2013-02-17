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

@end
