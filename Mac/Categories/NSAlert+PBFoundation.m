//
//  NSAlert+PBFoundation.m
//  PBFoundation
//
//  Created by Nick Bolton on 12/26/11.
//  Copyright (c) 2011 Pixelbleed LLC. All rights reserved.
//

#import "NSAlert+PBFoundation.h"

@implementation NSAlert (PBFoundation)

+ (NSAlert *)showErrorAlertModal:(NSString *)title message:(NSString *)message {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:PBLoc(@"Ok")];
    [alert setMessageText:title];
    [alert setInformativeText:message];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert runModal];
    return alert;
}

+ (NSAlert *)showInfoAlertModal:(NSString *)title message:(NSString *)message {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:PBLoc(@"Ok")];
    [alert setMessageText:title];
    [alert setInformativeText:message];
    [alert setAlertStyle:NSInformationalAlertStyle];
    [alert runModal];
    return alert;
}

+ (NSAlert *)showCriticalAlertModal:(NSString *)title message:(NSString *)message {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:PBLoc(@"Ok")];
    [alert setMessageText:title];
    [alert setInformativeText:message];
    [alert setAlertStyle:NSCriticalAlertStyle];
    [alert runModal];
    return alert;
}

+ (void)showErrorSheetModal:(NSWindow *)window title:(NSString *)title message:(NSString *)message chainSheets:(BOOL)chainSheets {
    [NSAlert showErrorSheetModal:window title:title message:message delegate:nil dismissedSelector:nil chainSheets:chainSheets];
}

+ (void)showErrorSheetModal:(NSWindow *)window title:(NSString *)title message:(NSString *)message delegate:(id)delegate dismissedSelector:(SEL)dismissedSelector chainSheets:(BOOL)chainSheets {

    if (window.attachedSheet != nil) {
        if (chainSheets == YES) {
            window = window.attachedSheet;
        } else {
            return;
        }
    }
    
    NSBeginAlertSheet(title,
                      PBLoc(@"Ok"),
                      nil,
                      @"",
                      window, 
                      delegate, 
                      dismissedSelector,
                      dismissedSelector,
                      nil,
                      message);
}

+ (void)showInfoSheetModal:(NSWindow *)window title:(NSString *)title message:(NSString *)message chainSheets:(BOOL)chainSheets {
    [NSAlert showInfoSheetModal:window title:title message:message delegate:nil dismissedSelector:nil chainSheets:chainSheets];
}

+ (void)showInfoSheetModal:(NSWindow *)window title:(NSString *)title message:(NSString *)message delegate:(id)delegate dismissedSelector:(SEL)dismissedSelector chainSheets:(BOOL)chainSheets {

    if (window.attachedSheet != nil) {
        if (chainSheets == YES) {
            window = window.attachedSheet;
        } else {
            return;
        }
    }
    
    NSBeginInformationalAlertSheet(title,
                                   PBLoc(@"Ok"),
                                   nil,
                                   @"",
                                   window, 
                                   delegate, 
                                   dismissedSelector,
                                   dismissedSelector,
                                   nil,
                                   message);
}

+ (void)showCriticalSheetModal:(NSWindow *)window title:(NSString *)title message:(NSString *)message chainSheets:(BOOL)chainSheets {
    [NSAlert showCriticalSheetModal:window title:title message:message delegate:nil dismissedSelector:nil chainSheets:chainSheets];
}

+ (void)showCriticalSheetModal:(NSWindow *)window title:(NSString *)title message:(NSString *)message delegate:(id)delegate dismissedSelector:(SEL)dismissedSelector chainSheets:(BOOL)chainSheets {

    if (window.attachedSheet != nil) {
        if (chainSheets == YES) {
            window = window.attachedSheet;
        } else {
            return;
        }
    }

    NSBeginCriticalAlertSheet(title,
                              PBLoc(@"Ok"),
                              nil,
                              @"",
                              window, 
                              delegate, 
                              dismissedSelector,
                              dismissedSelector,
                              nil,
                              message);
}

@end
