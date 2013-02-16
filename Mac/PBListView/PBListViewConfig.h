//
//  PBListViewConfig.h
//  PBListView
//
//  Created by Nick Bolton on 2/9/13.
//  Copyright 2013 Pixelbleed. All rights reserved.
//

typedef NS_ENUM(NSInteger, PBListViewPositionType) {

    PBListViewPositionTypeFirst = 0,
    PBListViewPositionTypeMiddle,
    PBListViewPositionTypeLast,
    PBListViewPositionTypeOnly,
    PBListViewPositionTypeCount, // used internally
};

typedef NS_ENUM(NSInteger, PBListViewUIElementType) {

    PBListViewUIElementTypeText = 0,
    PBListViewUIElementTypeButton,
    PBListViewUIElementTypeImage,
};

@class PBListViewUIElementMeta;
@class PBListViewRowMeta;
@class PBMenu;
@class PBListView;

@interface PBListViewConfig : NSObject

@property (nonatomic, weak) PBListView *listView;

@property (nonatomic) CGFloat leftMargin;
@property (nonatomic) CGFloat rightMargin;
@property (nonatomic) NSSize minSize;
@property (nonatomic) NSSize maxSize;
@property (nonatomic, strong) NSColor *rowDividerLineColor;
@property (nonatomic) CGFloat rowDividerLineHeight;
@property (nonatomic, strong) NSColor *selectedBackgroundColor;
@property (nonatomic, strong) NSColor *selectedBorderColor;
@property (nonatomic) CGFloat selectedBorderRadius;
@property (nonatomic) BOOL autoBuildContextualMenu;

- (void)registerUIElementMeta:(PBListViewUIElementMeta *)meta;
- (NSArray *)metaListForEntityType:(Class)entityType
                           atDepth:(NSUInteger)depth;

- (void)registerDefaultBackgroundImage:(NSImage *)defaultBackgroundImage
        defaultHoveringBackgroundImage:(NSImage *)defaultHoveringBackgroundImage
               selectedBackgroundImage:(NSImage *)selectedBackgroundImage
       selectedHoveringBackgroundImage:(NSImage *)selectedHoveringBackgroundImage
               expandedBackgroundImage:(NSImage *)expandedBackgroundImage
       expandedHoveringBackgroundImage:(NSImage *)expandedHoveringBackgroundImage
                  forEntityType:(Class)entityType
                     atPosition:(PBListViewPositionType)positionType;
- (void)registerDefaultBackgroundImage:(NSImage *)defaultBackgroundImage
        defaultHoveringBackgroundImage:(NSImage *)defaultHoveringBackgroundImage
               selectedBackgroundImage:(NSImage *)selectedBackgroundImage
       selectedHoveringBackgroundImage:(NSImage *)selectedHoveringBackgroundImage
               expandedBackgroundImage:(NSImage *)expandedBackgroundImage
       expandedHoveringBackgroundImage:(NSImage *)expandedHoveringBackgroundImage
                         forEntityType:(Class)entityType
                        atDepth:(NSUInteger)depth
                     atPosition:(PBListViewPositionType)positionType;
- (void)registerBackgroundImage:(NSImage *)backgroundImage
                  forEntityType:(Class)entityType
                        atDepth:(NSUInteger)depth
                     atPosition:(PBListViewPositionType)positionType
                       selected:(BOOL)selected
                       hovering:(BOOL)hovering
                       expanded:(BOOL)expanded;

- (NSImage *)backgroundImageForEntityType:(Class)entityType
                                  atDepth:(NSUInteger)depth
                               atPosition:(PBListViewPositionType)positionType
                                 selected:(BOOL)selected
                                 hovering:(BOOL)hovering
                                 expanded:(BOOL)expanded;

- (void)registerRowMeta:(PBListViewRowMeta *)rowMeta
          forEntityType:(Class)entityType;
- (void)registerRowMeta:(PBListViewRowMeta *)rowMeta
          forEntityType:(Class)entityType
                atDepth:(NSUInteger)depth;
- (PBListViewRowMeta *)rowMetaForEntityType:(Class)entityType
                                    atDepth:(NSUInteger)depth;

@end
