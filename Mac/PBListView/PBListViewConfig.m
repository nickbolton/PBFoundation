//
//  PBListViewConfig.m
//  PBListView
//
//  Created by Nick Bolton on 2/9/13.
//  Copyright 2013 Pixelbleed. All rights reserved.
//

#import "PBListViewConfig.h"
#import "PBListViewUIElementMeta.h"
#import "PBMenu.h"
#import "PBListViewCommand.h"

@interface PBListViewConfig()

@property (nonatomic, strong) NSMutableDictionary *metaListRegistry;
@property (nonatomic, strong) NSMutableDictionary *rowHeightRegistry;
@property (nonatomic, strong) NSMutableDictionary *rowDefaultBackgroundImageRegistry;
@property (nonatomic, strong) NSMutableDictionary *rowSelectedBackgroundImageRegistry;
@property (nonatomic, strong) NSMutableDictionary *rowDefaultHoveringBackgroundImageRegistry;
@property (nonatomic, strong) NSMutableDictionary *rowSelectedHoveringBackgroundImageRegistry;
@property (nonatomic, strong) NSMutableDictionary *entityCommands;
@property (nonatomic, strong) NSMutableDictionary *contextMenuSeparators;
@property (nonatomic, strong) NSMutableDictionary *contextMenus;

@end

@implementation PBListViewConfig

- (id)init {
    self = [super init];

    if (self != nil) {
        self.metaListRegistry = [NSMutableDictionary dictionary];
        self.rowHeightRegistry = [NSMutableDictionary dictionary];
        self.rowDefaultBackgroundImageRegistry = [NSMutableDictionary dictionary];
        self.rowSelectedBackgroundImageRegistry = [NSMutableDictionary dictionary];
        self.rowDefaultHoveringBackgroundImageRegistry = [NSMutableDictionary dictionary];
        self.rowSelectedHoveringBackgroundImageRegistry = [NSMutableDictionary dictionary];
        self.entityCommands = [NSMutableDictionary dictionary];
        self.contextMenuSeparators = [NSMutableDictionary dictionary];
        self.contextMenus = [NSMutableDictionary dictionary];
        self.leftMargin = 10.0f;
        self.rightMargin = 10.0f;
        self.minSize = NSMakeSize(300.0f, 300.0f);
        self.maxSize = NSMakeSize(MAXFLOAT, MAXFLOAT);
        self.rowDividerLineColor = nil;
        self.rowDividerLineHeight = 1.0f;
        self.selectedBackgroundColor = [NSColor colorWithRGBHex:0xD7E4F1];
        self.selectedBorderColor = [NSColor colorWithRGBHex:0x3775BC alpha:1.0f];
        self.selectedBorderRadius = 10.0f;
        self.autoBuildContextualMenu = YES;
    }

    return self;
}

#pragma mark - Meta registering

- (void)registerContextMenuSeparatorPositions:(NSIndexSet *)indexSet
                                forEntityType:(Class)entityType {
    [self
     registerContextMenuSeparatorPositions:indexSet
     forEntityType:entityType
     atDepth:0];
}

- (void)registerContextMenuSeparatorPositions:(NSIndexSet *)indexSet
                                forEntityType:(Class)entityType
                                      atDepth:(NSUInteger)depth {

    NSString *key =
    [NSString stringWithFormat:@"%@-%lu",
     NSStringFromClass(entityType), depth];

    [_contextMenuSeparators setObject:indexSet forKey:key];
}

- (void)registerCommands:(NSArray *)commands
           forEntityType:(Class)entityType {
    [self registerCommands:commands forEntityType:entityType atDepth:0];
}

- (void)registerCommands:(NSArray *)commands
           forEntityType:(Class)entityType
                 atDepth:(NSUInteger)depth {
    NSString *key = [NSString stringWithFormat:@"%@-%lu",
                     NSStringFromClass(entityType), depth];
    [_entityCommands setObject:commands forKey:key];

    if (_autoBuildContextualMenu) {

        PBMenu *menu = [[PBMenu alloc] initWithTitle:@""];

        NSIndexSet *separatorIndexSet = [_contextMenuSeparators objectForKey:key];

        for (PBListViewCommand *command in commands) {

            NSInteger menuItemCount = menu.itemArray.count;

            if (menuItemCount > 0 && [separatorIndexSet containsIndex:menuItemCount]) {
                [menu addItem:[NSMenuItem separatorItem]];
            }

            NSMenuItem *menuItem =
            [[NSMenuItem alloc]
             initWithTitle:command.title
             action:NULL
             keyEquivalent:command.keyEquivalent];
            menuItem.keyEquivalentModifierMask = command.modifierMask;
            menuItem.representedObject = command;
            [menu addItem:menuItem];
        }

        [self registerContextMenu:menu forEntityType:entityType atDepth:depth];
    }
}

- (void)registerContextMenu:(PBMenu *)menu
              forEntityType:(Class)entityType
                    atDepth:(NSUInteger)depth {

    if (menu != nil) {
        NSString *key =
        [NSString stringWithFormat:@"%@-%lu",
         NSStringFromClass(entityType), depth];
        [_contextMenus setObject:menu forKey:key];
    }
}

- (PBMenu *)contextMenuForEntityType:(Class)entityType atDepth:(NSUInteger)depth {
    NSString *key =
    [NSString stringWithFormat:@"%@-%lu",
     NSStringFromClass(entityType), depth];
    return [_contextMenus objectForKey:key];
}

- (NSArray *)commandsForEntityType:(Class)entityType atDepth:(NSUInteger)depth {
    NSString *key = [NSString stringWithFormat:@"%@-%lu",
                     NSStringFromClass(entityType), depth];
    return [_entityCommands objectForKey:key];
}

// this returns an array of depths, each of which is an array of elements
- (NSMutableArray *)metaListDepthsForEntityType:(Class)entityType {

    NSString *key = NSStringFromClass(entityType);

    NSMutableArray *registeredElements =
    [_metaListRegistry objectForKey:key];

    if (registeredElements == nil) {
        registeredElements = [NSMutableArray array];
        [_metaListRegistry setObject:registeredElements forKey:key];
    }

    return registeredElements;
}

- (NSArray *)metaListForEntityType:(Class)entityType
                           atDepth:(NSUInteger)depth {
    NSMutableArray *depths =
    [self metaListDepthsForEntityType:entityType];

    while (depths.count <= depth) {
        [depths addObject:[NSMutableArray array]];
    }

    return depths[depth];
}

- (void)registerUIElementMeta:(PBListViewUIElementMeta *)meta {

    if (meta != nil) {
        NSAssert(meta.entityType != nil, @"Meta is missing entityType");

        NSMutableArray *metaList =
        (NSMutableArray *)[self metaListForEntityType:meta.entityType atDepth:meta.depth];
        [metaList addObject:meta];
    }
}

- (void)registerDefaultBackgroundImage:(NSImage *)defaultBackgroundImage
               selectedBackgroundImage:(NSImage *)selectedBackgroundImage
        defaultHoveringBackgroundImage:(NSImage *)defaultHoveringBackgroundImage
       selectedHoveringBackgroundImage:(NSImage *)selectedHoveringBackgroundImage
                         forEntityType:(Class)entityType
                     atPosition:(PBListViewPositionType)positionType {
    [self
     registerDefaultBackgroundImage:defaultBackgroundImage
     selectedBackgroundImage:selectedBackgroundImage
     defaultHoveringBackgroundImage:defaultHoveringBackgroundImage
     selectedHoveringBackgroundImage:selectedHoveringBackgroundImage
     forEntityType:entityType
     atDepth:0
     atPosition:positionType];
}

- (void)registerDefaultBackgroundImage:(NSImage *)defaultBackgroundImage
               selectedBackgroundImage:(NSImage *)selectedBackgroundImage
        defaultHoveringBackgroundImage:(NSImage *)defaultHoveringBackgroundImage
       selectedHoveringBackgroundImage:(NSImage *)selectedHoveringBackgroundImage
                         forEntityType:(Class)entityType
                               atDepth:(NSUInteger)depth
                            atPosition:(PBListViewPositionType)positionType {

    [self
     registerBackgroundImage:defaultBackgroundImage
     forEntityType:entityType
     atDepth:depth
     atPosition:positionType
     selected:NO
     hovering:NO];

    [self
     registerBackgroundImage:selectedBackgroundImage
     forEntityType:entityType
     atDepth:depth
     atPosition:positionType
     selected:YES
     hovering:NO];

    [self
     registerBackgroundImage:defaultHoveringBackgroundImage
     forEntityType:entityType
     atDepth:depth
     atPosition:positionType
     selected:NO
     hovering:YES];

    [self
     registerBackgroundImage:selectedHoveringBackgroundImage
     forEntityType:entityType
     atDepth:depth
     atPosition:positionType
     selected:YES
     hovering:YES];

}

- (void)registerBackgroundImage:(NSImage *)backgroundImage
                  forEntityType:(Class)entityType
                        atDepth:(NSUInteger)depth
                     atPosition:(PBListViewPositionType)positionType
                       selected:(BOOL)selected
                       hovering:(BOOL)hovering {

    NSAssert(positionType < PBListViewPositionTypeCount,
             @"positionType is out of range %ld > %ld", positionType, PBListViewPositionTypeCount);

    if (backgroundImage != nil) {
        NSMutableArray *backgroundImages =
        [self
         backgroundImagesForEntityType:entityType
         atDepth:depth
         selected:selected
         hovering:hovering];

        if (backgroundImages.count == 0) {

            for (NSInteger i = 0; i < PBListViewPositionTypeCount; i++) {
                [backgroundImages addObject:backgroundImage];
            }

        } else {
            [backgroundImages replaceObjectAtIndex:positionType withObject:backgroundImage];
        }
    }
}

- (NSImage *)backgroundImageForEntityType:(Class)entityType
                                  atDepth:(NSUInteger)depth
                               atPosition:(PBListViewPositionType)positionType
                                 selected:(BOOL)selected
                                 hovering:(BOOL)hovering {

    NSAssert(positionType < PBListViewPositionTypeCount,
             @"positionType is out of range %ld > %ld", positionType, PBListViewPositionTypeCount);

    NSMutableArray *backgroundImages =
    [self
     backgroundImagesForEntityType:entityType
     atDepth:depth
     selected:selected
     hovering:hovering];
    
    if (positionType < backgroundImages.count) {
        return backgroundImages[positionType];
    }
    
    return nil;
}

- (NSMutableArray *)backgroundImagesForEntityType:(Class)entityType
                                          atDepth:(NSUInteger)depth
                                         selected:(BOOL)selected
                                         hovering:(BOOL)hovering {

    NSMutableDictionary *backgroundImageRegistry;

    if (selected) {
        if (hovering) {
            backgroundImageRegistry = _rowSelectedHoveringBackgroundImageRegistry;
        } else {
            backgroundImageRegistry = _rowSelectedBackgroundImageRegistry;
        }
    } else if (hovering) {
        backgroundImageRegistry = _rowDefaultHoveringBackgroundImageRegistry;
    } else {
        backgroundImageRegistry = _rowDefaultBackgroundImageRegistry;
    }

    NSString *key = NSStringFromClass(entityType);
    NSMutableArray *depths =
    [backgroundImageRegistry objectForKey:key];

    if (depths == nil) {
        depths = [NSMutableArray array];
        [backgroundImageRegistry setObject:depths forKey:key];
    }

    while (depths.count <= depth) {
        [depths addObject:[NSMutableArray array]];
    }

    return depths[depth];
}

- (void)registerRowHeight:(CGFloat)rowHeight forEntityType:(Class)entityType {
    NSString *key = NSStringFromClass(entityType);
    [_rowHeightRegistry setObject:@(rowHeight) forKey:key];
}

- (CGFloat)rowHeightForEntityType:(Class)entityType {
    NSString *key = NSStringFromClass(entityType);
    return [[_rowHeightRegistry objectForKey:key] floatValue];
}

@end
