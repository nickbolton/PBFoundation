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
@property (nonatomic, strong) NSMutableDictionary *actionBlockMap;

@end

@implementation PBActionDelegate

- (id)init {

    self = [super init];

    if (self != nil) {
        self.targetMap = [NSMutableDictionary dictionary];
        self.actionMap = [NSMutableDictionary dictionary];
        self.actionBlockMap = [NSMutableDictionary dictionary];
        self.userContextMap = [NSMutableDictionary dictionary];
    }

    return self;
}

- (void)dealloc {
    for (NSValue *value in self.actionBlockMap.allValues) {
        CFBridgingRelease(value.pointerValue);
    }
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

- (void)addBlock:(void(^)(void))actionBlock
     userContext:(id)userContext
        toButton:(NSInteger)buttonIndex {

    NSValue *blockValue =
    [NSValue valueWithPointer:CFBridgingRetain(actionBlock)];

    _actionBlockMap[@(buttonIndex)]=blockValue;
    if (userContext != nil) {
        _userContextMap[@(buttonIndex)]=userContext;
    }
}

- (void)performSelectorForButtonIndex:(NSInteger)buttonIndex {
    id target = _targetMap[@(buttonIndex)];
    NSValue *actionValue = _actionBlockMap[@(buttonIndex)];
    id userContext = _userContextMap[@(buttonIndex)];

    if (target != nil) {

        NSValue *selectorValue = _actionMap[@(buttonIndex)];

        SEL sel = selectorValue.pointerValue;
        [target performSelector:sel withObject:userContext];
    } else if (actionValue != nil) {

        void (^actionBlock)(id userContext) = [actionValue pointerValue];
        actionBlock(userContext);
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet
didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self performSelectorForButtonIndex:buttonIndex];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self performSelectorForButtonIndex:buttonIndex];
}

@end
