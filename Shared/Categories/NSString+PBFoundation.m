//
//  NSString+PBFoundation.m
//  PBFoundation
//
//  Created by Nick Bolton on 1/1/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "NSString+PBFoundation.h"

@implementation NSString (PBFoundation)

+ (NSString *)machineName {
#if TARGET_OS_IPHONE
    return [[UIDevice currentDevice] name];
#else
    return (__bridge NSString *)CSCopyMachineName();
#endif
}

+ (NSString *)safeString:(NSString *)value {
    if (value != nil) {
        return value;
    }
    return @"";
}

- (NSString *)trimmedValue {
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];

    return [self stringByTrimmingCharactersInSet:whitespace];
}

@end
