//
//  PBListViewUIElementMeta.m
//  PBListView
//
//  Created by Nick Bolton on 2/5/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBListViewUIElementMeta.h"
#import "PBListViewUIElementBinder.h"
#import "PBListViewCommand.h"
#import "PBMenu.h"

@interface PBListViewUIElementMeta()

@property (nonatomic, readwrite) NSString *keyPath;
@property (nonatomic, readwrite) Class entityType;
@property (nonatomic, readwrite) NSInteger depth;
@property (nonatomic, readwrite) PBListViewUIElementBinder *binder;
@property (nonatomic, readwrite) PBUIConfigurationHandler configurationHandler;
@property (nonatomic, readwrite) BOOL hiddenWhenMouseNotInRow;
@property (nonatomic, readwrite) NSMutableArray *commands;

@end

@implementation PBListViewUIElementMeta

+ (PBListViewUIElementMeta *)uiElementMetaWithEntityType:(Class)entityType
                                                 keyPath:(NSString *)keyPath
                                                   depth:(NSInteger)depth
                                              binderType:(Class)binderType
                                 hiddenWhenMouseNotInRow:(BOOL)hiddenWhenMouseNotInRow
                                           configuration:(PBUIConfigurationHandler)configuration {

    PBListViewUIElementBinder *binder = [[binderType alloc] init];

    NSAssert([binder isKindOfClass:[PBListViewUIElementBinder class]],
             @"binderType is not a PBListViewUIElementBinder type");

    return
    [[PBListViewUIElementMeta alloc]
     initWithEntityType:entityType
     keyPath:keyPath
     depth:depth
     binder:binder
     hiddenWhenMouseNotInRow:hiddenWhenMouseNotInRow
     configuration:configuration];
}

+ (PBListViewUIElementMeta *)uiElementMetaWithEntityType:(Class)entityType
                                                 keyPath:(NSString *)keyPath
                                              binderType:(Class)binderType
                                 hiddenWhenMouseNotInRow:(BOOL)hiddenWhenMouseNotInRow
                                           configuration:(PBUIConfigurationHandler)configuration {
    return
    [self
     uiElementMetaWithEntityType:entityType
     keyPath:keyPath
     depth:0
     binderType:binderType
     hiddenWhenMouseNotInRow:hiddenWhenMouseNotInRow
     configuration:configuration];
}

+ (PBListViewUIElementMeta *)uiElementMetaWithEntityType:(Class)entityType
                                                 keyPath:(NSString *)keyPath
                                                   depth:(NSInteger)depth
                                              binderType:(Class)binderType
                                           configuration:(PBUIConfigurationHandler)configuration {
    return
    [self
     uiElementMetaWithEntityType:entityType
     keyPath:keyPath
     depth:depth
     binderType:binderType
     hiddenWhenMouseNotInRow:NO
     configuration:configuration];
}

+ (PBListViewUIElementMeta *)uiElementMetaWithEntityType:(Class)entityType
                                                 keyPath:(NSString *)keyPath
                                              binderType:(Class)binderType
                                           configuration:(PBUIConfigurationHandler)configuration {
    return
    [self
     uiElementMetaWithEntityType:entityType
     keyPath:keyPath
     depth:0
     binderType:binderType
     hiddenWhenMouseNotInRow:NO
     configuration:configuration];
}

- (id)initWithEntityType:(Class)entityType
                 keyPath:(NSString *)keyPath
                   depth:(NSInteger)depth
                  binder:(PBListViewUIElementBinder *)binder
 hiddenWhenMouseNotInRow:(BOOL)hiddenWhenMouseNotInRow
           configuration:(PBUIConfigurationHandler)configurationHandler {

    self = [super init];
    if (self != nil) {

        self.keyPath = keyPath;
        self.entityType = entityType;
        self.depth = depth;
        self.binder = binder;
        self.configurationHandler = configurationHandler;
        self.fixedPosition = YES;
        self.hiddenWhenMouseNotInRow = hiddenWhenMouseNotInRow;
        self.textColor = [NSColor blackColor];
        self.textShadowColor = [NSColor whiteColor];
        self.textFont = [NSFont fontWithName:@"HelveticaNeue-Bold" size:13.0];
        self.shadowOffset = NSMakeSize(0.0f, -1.0f);
        self.hoverOffAlpha = .6f;
        self.size = NSMakeSize(100.0f, 17.0f);
        self.autoBuildContextualMenu = YES;
    }
    return self;
}

#pragma mark - Getters and Setters

- (void)setMenu:(PBMenu *)menu {
    NSAssert([menu isKindOfClass:[PBMenu class]], @"menu is not a PBMenu");
    _menu = menu;
}

- (id)findEntity:(NSView *)view {

    id entity = nil;
    NSTableCellView *cellView =
    [view findFirstParentOfType:[NSTableCellView class]];

    if (cellView != nil) {
        entity = cellView.objectValue;
    }

    NSAssert(entity != nil, @"No entity for action");

    return entity;
}

- (void)invokeAction:(id)sender {
    if (_actionHandler != nil) {

        id entity = [self findEntity:sender];
        _actionHandler(sender, entity, self);
    }
}

- (void)invokeCommand:(id)sender {

    NSMenuItem *menuItem = sender;
    PBListViewCommand *command = menuItem.representedObject;
    PBMenu *menu = (id)menuItem.menu;

    NSAssert([menu isKindOfClass:[PBMenu class]], @"menu is not a PBMenu");

    id entity = [self findEntity:((PBMenu *)menuItem.menu).attachedView];

    command.actionHandler(@[entity]);
}

- (void)addEntityCommand:(PBListViewCommand *)command {

    if (_autoBuildContextualMenu) {
        if (_menu == nil) {
            self.menu = [[PBMenu alloc] initWithTitle:@""];
        }

        NSInteger menuItemCount = _menu.itemArray.count;

        if (menuItemCount > 0 && [_menuSeparatorIndexes containsIndex:menuItemCount]) {
            [_menu addItem:[NSMenuItem separatorItem]];
        }
        
        NSMenuItem *menuItem =
        [[NSMenuItem alloc]
         initWithTitle:command.title
         action:@selector(invokeCommand:)
         keyEquivalent:command.keyEquivalent];
        menuItem.target = self;
        menuItem.keyEquivalentModifierMask = command.modifierMask;
        menuItem.representedObject = command;
        [_menu addItem:menuItem];
    }

    if (_commands == nil) {
        self.commands = [NSMutableArray array];
    }

    [(NSMutableArray *)_commands addObject:command];
}

@end
