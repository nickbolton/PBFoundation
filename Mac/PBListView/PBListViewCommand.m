//
//  PBListViewCommand.m
//  PBListView
//
//  Created by Nick Bolton on 2/11/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBListViewCommand.h"
#import "PBSRCommon.h"

@interface PBListViewCommand()

@property (nonatomic, readwrite) NSString *title;
@property (nonatomic, readwrite) NSUInteger keyCode;
@property (nonatomic, readwrite) NSString *keyEquivalent;
@property (nonatomic, readwrite) NSUInteger modifierMask;
@property (nonatomic, readwrite) PBCommandActionHandler actionHandler;

@end

@implementation PBListViewCommand

+ (PBListViewCommand *)commandWithTitle:(NSString *)title
                                keyCode:(NSUInteger)keyCode
                           modifierMask:(NSUInteger)modifierMask
                          actionHandler:(PBCommandActionHandler)actionHandler {

    NSAssert(actionHandler != NULL, @"PBListViewCommand missing actionHandler");
    NSAssert(title.length > 0, @"PBListViewCommand has no title");

    PBListViewCommand *command = [[PBListViewCommand alloc] init];

    command.title = [NSString safeString:title];
    command.keyCode = keyCode;
    command.keyEquivalent = PBSRStringForKeyCode(keyCode);
    command.modifierMask = modifierMask;
    command.actionHandler = actionHandler;


    if ((modifierMask & NSShiftKeyMask) == 0) {
        command.keyEquivalent = [command.keyEquivalent lowercaseString];
    }

    return command;
}

@end
