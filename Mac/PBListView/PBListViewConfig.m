//
//  PBListViewConfig.m
//  PBListView
//
//  Created by Nick Bolton on 2/9/13.
//  Copyright 2013 Pixelbleed. All rights reserved.
//

#import "PBListViewConfig.h"
#import "PBListViewUIElementMeta.h"
#import "PBListViewRowMeta.h"
#import "PBMenu.h"
#import "PBListViewCommand.h"
#import "PBEndMarker.h"

@interface PBListViewConfig()

@property (nonatomic, strong) NSMutableDictionary *metaListRegistry;
@property (nonatomic, strong) NSMutableDictionary *rowMetaRegistry;
@property (nonatomic, strong) NSMutableDictionary *rowDefaultBackgroundImageRegistry;
@property (nonatomic, strong) NSMutableDictionary *rowDefaultHoveringBackgroundImageRegistry;
@property (nonatomic, strong) NSMutableDictionary *rowSelectedBackgroundImageRegistry;
@property (nonatomic, strong) NSMutableDictionary *rowSelectedHoveringBackgroundImageRegistry;
@property (nonatomic, strong) NSMutableDictionary *rowExpandedBackgroundImageRegistry;
@property (nonatomic, strong) NSMutableDictionary *rowExpandedHoveringBackgroundImageRegistry;

@end

@implementation PBListViewConfig

- (id)init {
    self = [super init];

    if (self != nil) {
        self.metaListRegistry = [NSMutableDictionary dictionary];
        self.rowMetaRegistry = [NSMutableDictionary dictionary];
        self.rowDefaultBackgroundImageRegistry = [NSMutableDictionary dictionary];
        self.rowSelectedBackgroundImageRegistry = [NSMutableDictionary dictionary];
        self.rowDefaultHoveringBackgroundImageRegistry = [NSMutableDictionary dictionary];
        self.rowSelectedHoveringBackgroundImageRegistry = [NSMutableDictionary dictionary];
        self.rowExpandedBackgroundImageRegistry = [NSMutableDictionary dictionary];
        self.rowExpandedHoveringBackgroundImageRegistry = [NSMutableDictionary dictionary];
        self.leftMargin = 10.0f;
        self.rightMargin = 10.0f;
        self.minSize = NSMakeSize(300.0f, 300.0f);
        self.maxSize = NSMakeSize(MAXFLOAT, MAXFLOAT);
        self.rowDividerLineColor = nil;
        self.rowDividerLineHeight = 1.0f;
        self.selectedBackgroundColor = nil; //[NSColor colorWithRGBHex:0xD7E4F1];
        self.selectedBorderColor = nil; // [NSColor colorWithRGBHex:0x3775BC alpha:1.0f];
        self.selectedBorderRadius = 10.0f;
        self.autoBuildContextualMenu = YES;
    }

    return self;
}

#pragma mark - Meta registering

- (void)registerEndMarkerRowWithHeight:(CGFloat)rowHeight
                                 image:(NSImage *)image
                           imageAnchor:(PBListViewAnchorPosition)imageAnchor {
    [self
     registerEndMarkerRowWithHeight:rowHeight
     image:image
     imageAnchor:imageAnchor
     atDepth:NSNotFound];
}

- (void)registerEndMarkerRowWithHeight:(CGFloat)rowHeight
                                 image:(NSImage *)image
                           imageAnchor:(PBListViewAnchorPosition)imageAnchor
                               atDepth:(NSUInteger)depth {

    Class entityType = [PBEndMarker class];

    PBListViewRowMeta *rowMeta = [PBListViewRowMeta rowMeta];
    rowMeta.rowHeight = rowHeight;
    [_listView.listViewConfig
     registerRowMeta:rowMeta
     forEntityType:entityType
     atDepth:depth];

    [self
     registerUIElementMeta:
     [PBListViewUIElementMeta
      uiElementMetaWithEntityType:entityType
      keyPath:nil
      depth:depth
      binderType:[PBListViewImageBinder class]
      globalConfiguration:^(NSImageView *imageView, PBListViewUIElementMeta *meta) {
          meta.image = image;
          meta.fixedPosition = YES;
          meta.ignoreMargins = YES;
          meta.anchorPosition = imageAnchor;
      }]];
}

- (void)registerRowMeta:(PBListViewRowMeta *)rowMeta
          forEntityType:(Class)entityType {

    rowMeta.listView = _listView;

    [self
     registerRowMeta:rowMeta
     forEntityType:entityType
     atDepth:NSNotFound];
}

- (void)registerRowMeta:(PBListViewRowMeta *)rowMeta
          forEntityType:(Class)entityType
                atDepth:(NSUInteger)depth {
    if (rowMeta != nil) {
        NSString *key;

        if (depth != NSNotFound) {
            key =
            [NSString stringWithFormat:@"%@-%lu",
             NSStringFromClass(entityType), depth];
        } else {
            key = NSStringFromClass(entityType);
        }

        [_rowMetaRegistry setObject:rowMeta forKey:key];

        if (_autoBuildContextualMenu) {

            PBMenu *menu = [[PBMenu alloc] initWithTitle:@""];

            NSIndexSet *separatorIndexSet =
            rowMeta.contextMenuSeparatorPositions;

            for (PBListViewCommand *command in rowMeta.commands) {

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

            rowMeta.contextMenu = menu;
        }
    }
}

- (PBListViewRowMeta *)rowMetaForEntityType:(Class)entityType
                                    atDepth:(NSUInteger)depth {
    NSString *key =
    [NSString stringWithFormat:@"%@-%lu",
     NSStringFromClass(entityType), depth];
    PBListViewRowMeta *rowMeta = [_rowMetaRegistry objectForKey:key];
    if (rowMeta == nil) {
        key = NSStringFromClass(entityType);
        rowMeta = [_rowMetaRegistry objectForKey:key];
    }
    return rowMeta;
}

- (NSArray *)metaListForEntityType:(Class)entityType
                           atDepth:(NSUInteger)depth {
    return
    [self
     metaListForEntityType:entityType
     atDepth:depth
     defaultOnEmptyList:YES];
}

- (void)removeAllUIElementMetaForEntityType:(Class)entityType
                                    atDepth:(NSUInteger)depth {
    NSMutableArray *metaList =
    (NSMutableArray *)[self metaListForEntityType:entityType
                                          atDepth:depth
                               defaultOnEmptyList:NO];
    [metaList removeAllObjects];
}

- (NSArray *)metaListForEntityType:(Class)entityType
                           atDepth:(NSUInteger)depth
                defaultOnEmptyList:(BOOL)defaultOnEmptyList {

    NSString *key = NSStringFromClass(entityType);
    NSMutableDictionary *depths =
    [_metaListRegistry objectForKey:key];

    if (depths == nil) {
        depths = [NSMutableDictionary dictionary];
        [_metaListRegistry setObject:depths forKey:key];
        [depths setObject:[NSMutableArray array] forKey:@(NSNotFound)]; // global value
    }

    NSMutableArray *metaList = [depths objectForKey:@(depth)];
    if (metaList == nil) {
        metaList = [NSMutableArray array];
        [depths setObject:metaList forKey:@(depth)];
    }

    if (defaultOnEmptyList && metaList.count == 0) {
        metaList = [depths objectForKey:@(NSNotFound)];
    }
    return metaList;

}

- (void)registerUIElementMeta:(PBListViewUIElementMeta *)meta {

    if (meta != nil) {
        NSAssert(meta.entityType != nil, @"Meta is missing entityType");

        meta.listView = _listView;

        NSMutableArray *metaList =
        (NSMutableArray *)[self metaListForEntityType:meta.entityType
                                              atDepth:meta.depth
                                   defaultOnEmptyList:NO];
        [metaList addObject:meta];
    }
}

- (void)registerDefaultBackgroundImage:(NSImage *)defaultBackgroundImage
        defaultHoveringBackgroundImage:(NSImage *)defaultHoveringBackgroundImage
               selectedBackgroundImage:(NSImage *)selectedBackgroundImage
       selectedHoveringBackgroundImage:(NSImage *)selectedHoveringBackgroundImage
               expandedBackgroundImage:(NSImage *)expandedBackgroundImage
       expandedHoveringBackgroundImage:(NSImage *)expandedHoveringBackgroundImage
                         forEntityType:(Class)entityType
                     atPosition:(PBListViewPositionType)positionType {
    [self
     registerDefaultBackgroundImage:defaultBackgroundImage
     defaultHoveringBackgroundImage:defaultHoveringBackgroundImage
     selectedBackgroundImage:selectedBackgroundImage
     selectedHoveringBackgroundImage:selectedHoveringBackgroundImage
     expandedBackgroundImage:expandedBackgroundImage
     expandedHoveringBackgroundImage:expandedHoveringBackgroundImage
     forEntityType:entityType
     atDepth:NSNotFound
     atPosition:positionType];
}

- (void)registerDefaultBackgroundImage:(NSImage *)defaultBackgroundImage
        defaultHoveringBackgroundImage:(NSImage *)defaultHoveringBackgroundImage
               selectedBackgroundImage:(NSImage *)selectedBackgroundImage
       selectedHoveringBackgroundImage:(NSImage *)selectedHoveringBackgroundImage
               expandedBackgroundImage:(NSImage *)expandedBackgroundImage
       expandedHoveringBackgroundImage:(NSImage *)expandedHoveringBackgroundImage
                         forEntityType:(Class)entityType
                               atDepth:(NSUInteger)depth
                            atPosition:(PBListViewPositionType)positionType {

    [self
     registerBackgroundImage:defaultBackgroundImage
     forEntityType:entityType
     atDepth:depth
     atPosition:positionType
     selected:NO
     hovering:NO
     expanded:NO];

    [self
     registerBackgroundImage:selectedBackgroundImage
     forEntityType:entityType
     atDepth:depth
     atPosition:positionType
     selected:YES
     hovering:NO
     expanded:NO];

    [self
     registerBackgroundImage:defaultHoveringBackgroundImage
     forEntityType:entityType
     atDepth:depth
     atPosition:positionType
     selected:NO
     hovering:YES
     expanded:NO];

    [self
     registerBackgroundImage:selectedHoveringBackgroundImage
     forEntityType:entityType
     atDepth:depth
     atPosition:positionType
     selected:YES
     hovering:YES
     expanded:NO];

    [self
     registerBackgroundImage:expandedBackgroundImage
     forEntityType:entityType
     atDepth:depth
     atPosition:positionType
     selected:NO
     hovering:NO
     expanded:YES];

    [self
     registerBackgroundImage:expandedHoveringBackgroundImage
     forEntityType:entityType
     atDepth:depth
     atPosition:positionType
     selected:NO
     hovering:YES
     expanded:YES];

}

- (void)registerBackgroundImage:(NSImage *)backgroundImage
                  forEntityType:(Class)entityType
                        atDepth:(NSUInteger)depth
                     atPosition:(PBListViewPositionType)positionType
                       selected:(BOOL)selected
                       hovering:(BOOL)hovering
                       expanded:(BOOL)expanded {

    NSAssert(positionType < PBListViewPositionTypeCount,
             @"positionType is out of range %ld > %ld", positionType, PBListViewPositionTypeCount);

    if (backgroundImage != nil) {
        NSMutableArray *backgroundImages =
        [self
         backgroundImagesForEntityType:entityType
         atDepth:depth
         selected:selected
         hovering:hovering
         expanded:expanded
         defaultOnEmptyList:NO];

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
                                 hovering:(BOOL)hovering
                                 expanded:(BOOL)expanded {

    NSAssert(positionType < PBListViewPositionTypeCount,
             @"positionType is out of range %ld > %ld", positionType, PBListViewPositionTypeCount);

    NSMutableArray *backgroundImages =
    [self
     backgroundImagesForEntityType:entityType
     atDepth:depth
     selected:selected
     hovering:hovering
     expanded:expanded
     defaultOnEmptyList:YES];
    
    if (positionType < backgroundImages.count) {
        return backgroundImages[positionType];
    }
    
    return nil;
}

- (NSMutableArray *)backgroundImagesForEntityType:(Class)entityType
                                          atDepth:(NSUInteger)depth
                                         selected:(BOOL)selected
                                         hovering:(BOOL)hovering
                                         expanded:(BOOL)expanded
                               defaultOnEmptyList:(BOOL)defaultOnEmptyList {

    NSMutableDictionary *backgroundImageRegistry;

    if (expanded) {
        if (hovering) {
            backgroundImageRegistry = _rowExpandedHoveringBackgroundImageRegistry;
        } else {
            backgroundImageRegistry = _rowExpandedBackgroundImageRegistry;
        }
    } else if (selected) {
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
    NSMutableDictionary *depths =
    [backgroundImageRegistry objectForKey:key];

    if (depths == nil) {
        depths = [NSMutableDictionary dictionary];
        [backgroundImageRegistry setObject:depths forKey:key];
        [depths setObject:[NSMutableArray array] forKey:@(NSNotFound)]; // global value
    }

    NSMutableArray *backgroundImages = [depths objectForKey:@(depth)];
    if (backgroundImages == nil) {
        backgroundImages = [NSMutableArray array];
        [depths setObject:backgroundImages forKey:@(depth)];
    }
    
    if (defaultOnEmptyList && backgroundImages.count == 0) {
        backgroundImages = [depths objectForKey:@(NSNotFound)];
    }
    return backgroundImages;
}

@end
