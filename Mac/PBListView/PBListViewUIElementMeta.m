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
@property (nonatomic, readwrite) PBUIGlobalConfigurationHandler globalConfigurationHandler;
@property (nonatomic, readwrite) BOOL hiddenWhenMouseNotInRow;
@property (nonatomic, readwrite) NSMutableArray *commands;
@property (nonatomic, readwrite) NSMutableDictionary *imageCache;

@end

@implementation PBListViewUIElementMeta

+ (PBListViewUIElementMeta *)uiElementMetaWithEntityType:(Class)entityType
                                                 keyPath:(NSString *)keyPath
                                                   depth:(NSInteger)depth
                                              binderType:(Class)binderType
                                 hiddenWhenMouseNotInRow:(BOOL)hiddenWhenMouseNotInRow
                                     globalConfiguration:(PBUIGlobalConfigurationHandler)globalConfiguration {

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
     globalConfiguration:globalConfiguration];
}

+ (PBListViewUIElementMeta *)uiElementMetaWithEntityType:(Class)entityType
                                                 keyPath:(NSString *)keyPath
                                              binderType:(Class)binderType
                                 hiddenWhenMouseNotInRow:(BOOL)hiddenWhenMouseNotInRow
                                     globalConfiguration:(PBUIGlobalConfigurationHandler)globalConfiguration {
    return
    [self
     uiElementMetaWithEntityType:entityType
     keyPath:keyPath
     depth:NSNotFound
     binderType:binderType
     hiddenWhenMouseNotInRow:hiddenWhenMouseNotInRow
     globalConfiguration:globalConfiguration];
}

+ (PBListViewUIElementMeta *)uiElementMetaWithEntityType:(Class)entityType
                                                 keyPath:(NSString *)keyPath
                                                   depth:(NSInteger)depth
                                              binderType:(Class)binderType
                                     globalConfiguration:(PBUIGlobalConfigurationHandler)globalConfiguration {
    return
    [self
     uiElementMetaWithEntityType:entityType
     keyPath:keyPath
     depth:depth
     binderType:binderType
     hiddenWhenMouseNotInRow:NO
     globalConfiguration:globalConfiguration];
}

+ (PBListViewUIElementMeta *)uiElementMetaWithEntityType:(Class)entityType
                                                 keyPath:(NSString *)keyPath
                                              binderType:(Class)binderType
                                     globalConfiguration:(PBUIGlobalConfigurationHandler)globalConfiguration {
    return
    [self
     uiElementMetaWithEntityType:entityType
     keyPath:keyPath
     depth:NSNotFound
     binderType:binderType
     hiddenWhenMouseNotInRow:NO
     globalConfiguration:globalConfiguration];
}

- (id)initWithEntityType:(Class)entityType
                 keyPath:(NSString *)keyPath
                   depth:(NSInteger)depth
                  binder:(PBListViewUIElementBinder *)binder
 hiddenWhenMouseNotInRow:(BOOL)hiddenWhenMouseNotInRow
     globalConfiguration:(PBUIGlobalConfigurationHandler)globalConfigurationHandler {

    self = [super init];
    if (self != nil) {

        self.keyPath = keyPath;
        self.entityType = entityType;
        self.depth = depth;
        self.binder = binder;
        self.globalConfigurationHandler = globalConfigurationHandler;
        self.fixedPosition = YES;
        self.hiddenWhenMouseNotInRow = hiddenWhenMouseNotInRow;
        self.textColor = [NSColor blackColor];
        self.textShadowColor = [NSColor whiteColor];
        self.textFont = [NSFont fontWithName:@"HelveticaNeue-Bold" size:13.0];
        self.shadowOffset = NSMakeSize(0.0f, -1.0f);
        self.hoverOffAlpha = .6f;
        self.size = NSZeroSize;
        self.autoBuildContextualMenu = YES;
        self.imageCache = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Getters and Setters

- (void)setImage:(NSImage *)image {
    _image = image;
    self.size = image.size;
}

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
        _actionHandler(sender, entity, self, _listView);
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
