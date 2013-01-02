//
//  NSString+PBFoundation.m
//  MotionMouse
//
//  Created by Nick Bolton on 1/1/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "NSString+PBFoundation.h"
#import <Carbon/Carbon.h>

@implementation NSString (PBFoundation)

+ (NSString *)machineName {
#if TARGET_OS_IPHONE
    return [[UIDevice currentDevice] name];
#else
    return (__bridge NSString *)CSCopyMachineName();
#endif
}

@end
