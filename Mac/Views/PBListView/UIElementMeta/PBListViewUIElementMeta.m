//
//  PBListViewUIElementMeta.m
//  PBListView
//
//  Created by Nick Bolton on 2/5/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBListViewUIElementMeta.h"
#import "PBListViewUIElementBinder.h"

@interface PBListViewUIElementMeta()

@property (nonatomic, readwrite) NSString *keyPath;
@property (nonatomic, readwrite) Class entityType;
@property (nonatomic, readwrite) PBListViewUIElementBinder *binder;
@property (nonatomic, readwrite) PBUIConfigurationHandler configurationHandler;

@end

@implementation PBListViewUIElementMeta

+ (PBListViewUIElementMeta *)uiElementMetaWithEntityType:(Class)entityType
                                                 keyPath:(NSString *)keyPath
                                              binderType:(Class)binderType
                                           configuration:(PBUIConfigurationHandler)configuration {

    PBListViewUIElementBinder *binder = [[binderType alloc] init];

    NSAssert([binder isKindOfClass:[PBListViewUIElementBinder class]],
             @"binderType is not a PBListViewUIElementBinder type");

    return
    [[PBListViewUIElementMeta alloc]
     initWithEntityType:entityType
     keyPath:keyPath
     binder:binder
     configuration:configuration];
}

- (id)initWithEntityType:(Class)entityType
                 keyPath:(NSString *)keyPath
                  binder:(PBListViewUIElementBinder *)binder
           configuration:(PBUIConfigurationHandler)configurationHandler {

    self = [super init];
    if (self != nil) {

        self.keyPath = keyPath;
        self.entityType = entityType;
        self.binder = binder;
        self.configurationHandler = configurationHandler;
    }
    return self;
}

- (void)invokeAction:(id)sender {
    if (_actionHandler != nil) {

        id entity = nil;
        NSTableCellView *cellView =
        [(NSView *)sender findFirstParentOfType:[NSTableCellView class]];

        if (cellView != nil) {
            entity = cellView.objectValue;
        }
        _actionHandler(entity);
    }
}

@end
