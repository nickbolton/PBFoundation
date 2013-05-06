//
//  PBActionDelegate.m
//  PBFoundation
//
//  Created by Nick Bolton on 11/26/12.
//  Copyright (c) 2012 Pixelbleed LLC. All rights reserved.
//

#import "PBActionDelegate.h"

@interface PBActionDelegate()

@property (nonatomic, strong) NSMutableDictionary *targetMap;
@property (nonatomic, strong) NSMutableDictionary *actionMap;
@property (nonatomic, strong) NSMutableDictionary *userContextMap;

@end

@implementation PBActionDelegate

- (id)init {

    self = [super init];

    if (self != nil) {
        self.targetMap = [NSMutableDictionary dictionary];
        self.actionMap = [NSMutableDictionary dictionary];
        self.userContextMap = [NSMutableDictionary dictionary];
    }

    return self;
}

- (void)addTarget:(id)target
           action:(SEL)action
      userContext:(id)userContext
         toButton:(NSInteger)buttonIndex {
    NSValue *selectorAsValue = [NSValue valueWithPointer:action];

    _targetMap[@(buttonIndex)]=target;
    _actionMap[@(buttonIndex)]=selectorAsValue;
    if (userContext != nil) {
        _userContextMap[@(buttonIndex)]=userContext;
    }
}

- (void)performSelectorForButtonIndex:(NSInteger)buttonIndex {
    id target = _targetMap[@(buttonIndex)];

    if (target != nil) {

        NSValue *selectorValue = _actionMap[@(buttonIndex)];

        id userContext = _userContextMap[@(buttonIndex)];

        SEL sel = selectorValue.pointerValue;
        [target performSelector:sel withObject:userContext];
    }

    [_targetMap removeObjectForKey:@(buttonIndex)];
    [_actionMap removeObjectForKey:@(buttonIndex)];
    [_userContextMap removeObjectForKey:@(buttonIndex)];
}

- (void)actionSheet:(UIActionSheet *)actionSheet
didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self performSelectorForButtonIndex:buttonIndex];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self performSelectorForButtonIndex:buttonIndex];
}

@end
