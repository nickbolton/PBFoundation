//
//  UIAlertView+PBFoundation.m
//  PBFoundation
//
//  Created by Nick Bolton on 7/20/12.
//  Copyright (c) 2012 Pixelbleed LLC. All rights reserved.
//
#import "UIAlertView+PBFoundation.h"

@implementation UIAlertView (PBFoundation)

+ (void)presentOKAlertWithTitle:(NSString *)title 
                     andMessage:(NSString *)message {
    
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:title
                                                   message:message
                                                  delegate:nil 
                                         cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                         otherButtonTitles: nil];
    [alert show];
}

+ (BOOL)showHint:(NSString *)hintKey
           title:(NSString *)title
         message:(NSString *)message {

    BOOL seenHint =
    [[NSUserDefaults standardUserDefaults] boolForKey:hintKey];

    if (seenHint == NO) {

        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:hintKey];

        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:title
                                   message:message
                                  delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil)
                         otherButtonTitles:nil];
        [alertView show];
    }

    return seenHint == NO;
}

@end
