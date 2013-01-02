//
//  PBFoundation.h
//  MotionMouse
//
//  Created by Nick Bolton on 1/1/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#ifndef MotionMouse_PBFoundation_h
#define MotionMouse_PBFoundation_h

#import "NSString+PBFoundation.h"
#import "NSArray+PBFoundation.h"

#if TARGET_OS_IPHONE
#import "PBActionDelegate.h"
#import "UIAlertView+PBFoundation.h"
#import "UIColor+PBFoundation.h"
#import "UIImage+PBFoundation.h"
#import "UIView+PBFoundation.h"
#else
#import "NSAlert+PBFoundation.h"
#import "NSImage+PBFoundation.h"
#import "NSTask+PBFoundation.h"
#import "NSWindow+PBFoundation.h"
#import "PBAnimator.h"
#endif

#define PBLoc(key) NSLocalizedString(key, nil)
#define PBLocalizedString(key, comment) NSLocalizedStringFromTableInBundle(key, @"pixelbleed", [NSBundle bundleForClass: [PBDummyClass class]], comment)

#endif
