//
//  NSAlert+PBFoundation.h
//  PBFoundation
//
//  Created by Nick Bolton on 12/26/11.
//  Copyright (c) 2011 Pixelbleed LLC. All rights reserved.
//



@interface NSAlert (PBFoundation)

+ (NSAlert *)showErrorAlertModal:(NSString *)title message:(NSString *)message;
+ (NSAlert *)showInfoAlertModal:(NSString *)title message:(NSString *)message;
+ (NSAlert *)showCriticalAlertModal:(NSString *)title message:(NSString *)message;

+ (void)showErrorSheetModal:(NSWindow *)window title:(NSString *)title message:(NSString *)message chainSheets:(BOOL)chainSheets;
+ (void)showInfoSheetModal:(NSWindow *)window title:(NSString *)title message:(NSString *)message chainSheets:(BOOL)chainSheets;
+ (void)showCriticalSheetModal:(NSWindow *)window title:(NSString *)title message:(NSString *)message chainSheets:(BOOL)chainSheets;

+ (void)showErrorSheetModal:(NSWindow *)window title:(NSString *)title message:(NSString *)message delegate:(id)delegate dismissedSelector:(SEL)dismissedSelector chainSheets:(BOOL)chainSheets;
+ (void)showInfoSheetModal:(NSWindow *)window title:(NSString *)title message:(NSString *)message delegate:(id)delegate dismissedSelector:(SEL)dismissedSelector chainSheets:(BOOL)chainSheets;
+ (void)showCriticalSheetModal:(NSWindow *)window title:(NSString *)title message:(NSString *)message delegate:(id)delegate dismissedSelector:(SEL)dismissedSelector chainSheets:(BOOL)chainSheets;


@end
