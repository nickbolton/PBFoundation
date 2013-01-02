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
    [_targetMap setObject:target forKey:@(buttonIndex)];
    [_actionMap setObject:selectorAsValue forKey:@(buttonIndex)];
    if (userContext != nil) {
        [_userContextMap setObject:userContext forKey:@(buttonIndex)];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet
didDismissWithButtonIndex:(NSInteger)buttonIndex {

    id target = [_targetMap objectForKey:@(buttonIndex)];

    if (target != nil) {

        NSValue *selectorValue = [_actionMap objectForKey:@(buttonIndex)];

        id userContext = [_userContextMap objectForKey:@(buttonIndex)];

        SEL sel = selectorValue.pointerValue;
        [target performSelector:sel withObject:userContext];
    }
}

@end
