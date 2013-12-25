//
//  PBFoundation.h
//  PBFoundation
//
//  Created by Nick Bolton on 1/1/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#ifndef PBFoundation_PBFoundation_h
#define PBFoundation_PBFoundation_h

# define PBDebugLog(...) if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"debugMode"] boolValue] == YES) { NSLog(@"[%@:%d (%p)]: %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, self, [NSString stringWithFormat:__VA_ARGS__]); }

#if DEBUG
#define PBLog(...) NSLog(__VA_ARGS__)
#else
#define PBLog(...) do { } while (0)
#endif

// add -DTCDEBUG to Other C Flags for Debug

#define PBLogOff(...) do { } while (0)
#define PBLogOn(...) NSLog(__VA_ARGS__)

#import "NSString+PBFoundation.h"
#import "NSArray+PBFoundation.h"
#import "NSObject+PBFoundation.h"
#import "NSLayoutConstraint+PBFoundation.h"
#import "NSNotification+PBFoundation.h"
#import "PBDateRange.h"
#import "PBCalendarManager.h"
#import "NSDate+PBFoundation.h"

#if TARGET_OS_IPHONE
#import "PBActionDelegate.h"
#import "UIAlertView+PBFoundation.h"
#import "UIColor+PBFoundation.h"
#import "UIImage+PBFoundation.h"
#import "UIView+PBFoundation.h"
#import "UIButton+PBFoundation.h"
#import "UIBezierView.h"
#import "UIBezierButton.h"
#import "UINavigationController+PBFoundation.h"
#else

#define PB_WINDOW_ANIMATION_DURATION 0.25f
#define PB_EASE_IN ([CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn])
#define PB_EASE_OUT ([CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut])
#define PB_EASE_INOUT ([CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut])

#import "NSColor+PBFoundation.h"
#import "NSAlert+PBFoundation.h"
#import "NSImage+PBFoundation.h"
#import "NSAppleScript+PBFoundation.h"
#import "NSAttributedString+PBFoundation.h"
#import "NSTask+PBFoundation.h"
#import "NSWindow+PBFoundation.h"
#import "NSView+PBFoundation.h"
#import "NSButton+PBFoundation.h"
#import "NSFileManager+PBFoundation.h"
#import "NSUserNotification+PBFoundation.h"
#import "NSEvent+PBFoundation.h"
#import "NSTextField+PBFoundation.h"
#import "PBMainWindow.h"
#import "PBAnimator.h"
#import "PBClickableLabel.h"
#import "PBClickableView.h"
#import "PBApplication.h"

#endif

#define PBLoc(key) NSLocalizedString(key, nil)
#define PBLocalizedString(key, comment) NSLocalizedStringFromTableInBundle(key, @"pixelbleed", [NSBundle bundleForClass: [PBDummyClass class]], comment)

#endif
