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

#if TARGET_OS_IPHONE
#import "PBActionDelegate.h"
#import "UIAlertView+PBFoundation.h"
#import "UIColor+PBFoundation.h"
#import "UIImage+PBFoundation.h"
#import "UIView+PBFoundation.h"
#endif

#define PBLoc(key) NSLocalizedString(key, nil)

#endif
