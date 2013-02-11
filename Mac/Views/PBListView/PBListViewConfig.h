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

@interface PBListViewConfig : NSObject

@property (nonatomic) CGFloat leftMargin;
@property (nonatomic) CGFloat rightMargin;
@property (nonatomic) NSSize minSize;
@property (nonatomic) NSSize maxSize;
@property (nonatomic, strong) NSColor *rowDividerLineColor;
@property (nonatomic) CGFloat rowDividerLineHeight;

@property (nonatomic, strong) NSColor *selectedBackgroundColor;
@property (nonatomic, strong) NSColor *selectedBorderColor;
@property (nonatomic) CGFloat selectedBorderRadius;

- (void)registerUIElementMeta:(PBListViewUIElementMeta *)meta;
- (NSArray *)metaListForEntityType:(Class)entityType
                           atDepth:(NSUInteger)depth;

- (void)registerBackgroundImage:(NSImage *)image
                  forEntityType:(Class)entityType
                     atPosition:(PBListViewPositionType)positionType;
- (void)registerBackgroundImage:(NSImage *)image
                  forEntityType:(Class)entityType
                        atDepth:(NSUInteger)depth
                     atPosition:(PBListViewPositionType)positionType;

- (NSImage *)backgroundImageForEntityType:(Class)entityType
                                  atDepth:(NSUInteger)depth
                               atPosition:(PBListViewPositionType)positionType;

- (void)registerRowHeight:(CGFloat)rowHeight forEntityType:(Class)entityType;
- (CGFloat)rowHeightForEntityType:(Class)entityType;

@end