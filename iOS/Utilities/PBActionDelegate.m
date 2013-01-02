//
//  TCCalendarActionDelegate.m
//  Timecop-iOS
//
//  Created by Nick Bolton on 11/26/12.
//  Copyright (c) 2012 Pixelbleed LLC. All rights reserved.
//

#import "TCCalendarActionDelegate.h"

@interface TCCalendarActionDelegate()

@property (nonatomic, retain) NSMutableDictionary *targetMap;
@property (nonatomic, retain) NSMutableDictionary *actionMap;

@end

@implementation TCCalendarActionDelegate

- (id)init {

    self = [super init];

    if (self != nil) {
        self.targetMap = [NSMutableDictionary dictionary];
        self.actionMap = [NSMutableDictionary dictionary];
    }

    return self;
}

- (void)dealloc {
    [_targetMap release], _targetMap = nil;
    [_actionMap release], _actionMap = nil;
    [super dealloc];
}


- (void)addTarget:(id)target action:(SEL)action toButton:(NSInteger)buttonIndex {
    NSValue *selectorAsValue = [NSValue valueWithPointer:action];
    [_targetMap setObject:target forKey:@(buttonIndex)];
    [_actionMap setObject:selectorAsValue forKey:@(buttonIndex)];
}

- (void)actionSheet:(UIActionSheet *)actionSheet
didDismissWithButtonIndex:(NSInteger)buttonIndex {

    id target = [_targetMap objectForKey:@(buttonIndex)];

    if (target != nil) {

        NSValue *selectorValue = [_actionMap objectForKey:@(buttonIndex)];

        SEL sel = selectorValue.pointerValue;
        [target performSelector:sel];
    }
}

@end
