//
//  PBListViewUIElementMeta.h
//  PBListView
//
//  Created by Nick Bolton on 2/5/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PBListViewAnchorPosition) {

    PBListViewAnchorPositionNone = 0,
    PBListViewAnchorPositionCenter,
    PBListViewAnchorPositionTop,
    PBListViewAnchorPositionBottom,
    PBListViewAnchorPositionLeft,
    PBListViewAnchorPositionRight,
    PBListViewAnchorPositionTopLeft,
    PBListViewAnchorPositionTopRight,
    PBListViewAnchorPositionBottomLeft,
    PBListViewAnchorPositionBottomRight,
};

@class PBListViewUIElementBinder;
@class PBListViewUIElementMeta;
@class PBListViewCommand;
@class PBMenu;

typedef void(^PBUIConfigurationHandler)(id view, PBListViewUIElementMeta *meta);
typedef void(^PBUIActionHandler)(id sender, id entity, PBListViewUIElementMeta *meta);
typedef id(^PBUIValueTransformer)(id value);

@interface PBListViewUIElementMeta : NSObject

@property (nonatomic, readonly) NSString *keyPath;
@property (nonatomic, readonly) Class entityType;
@property (nonatomic, readonly) NSInteger depth;
@property (nonatomic, readonly) PBListViewUIElementBinder *binder;
@property (nonatomic, readonly) PBUIConfigurationHandler configurationHandler;
@property (nonatomic, readonly) BOOL hiddenWhenMouseNotInRow;
@property (nonatomic, readonly) NSArray *commands;

@property (nonatomic, readwrite) CGFloat leftPadding;
@property (nonatomic, readwrite) NSSize size;
@property (nonatomic, strong) NSFont *textFont;
@property (nonatomic, strong) NSColor *textColor;
@property (nonatomic, strong) NSColor *textShadowColor;
@property (nonatomic) NSSize shadowOffset;
@property (nonatomic) BOOL fixedPosition;
@property (nonatomic) BOOL hoverAlphaEnabled;
@property (nonatomic) BOOL ignoreMargins;
@property (nonatomic) CGFloat hoverOffAlpha;
@property (nonatomic) NSString *staticText;
@property (nonatomic, strong) NSImage *image;
@property (nonatomic, strong) NSImage *pressedImage;
@property (nonatomic, strong) NSImage *onImage;
@property (nonatomic, strong) NSImage *disabledImage;

// If an anchor position is other than none, the ui element will
// be positioned as instructed with the given insets.
// It will override any other position property and the element
// is treated as independent of other elements.
// The insets will be applied after any left/right margins though.
@property (nonatomic) PBListViewAnchorPosition anchorPosition;
@property (nonatomic) NSEdgeInsets anchorInsets;

@property (nonatomic, strong) PBMenu *menu;
@property (nonatomic, strong) NSIndexSet *menuSeparatorIndexes;

@property (nonatomic) BOOL autoBuildContextualMenu;

@property (nonatomic, copy) PBUIValueTransformer valueTransformer;
@property (nonatomic, copy) PBUIActionHandler actionHandler;

+ (PBListViewUIElementMeta *)uiElementMetaWithEntityType:(Class)entityType
                                                 keyPath:(NSString *)keyPath
                                                   depth:(NSInteger)depth
                                              binderType:(Class)binderType
                                 hiddenWhenMouseNotInRow:(BOOL)hiddenWhenMouseNotInRow
                                           configuration:(PBUIConfigurationHandler)configuration;

+ (PBListViewUIElementMeta *)uiElementMetaWithEntityType:(Class)entityType
                                                 keyPath:(NSString *)keyPath
                                              binderType:(Class)binderType
                                 hiddenWhenMouseNotInRow:(BOOL)hiddenWhenMouseNotInRow
                                           configuration:(PBUIConfigurationHandler)configuration;

+ (PBListViewUIElementMeta *)uiElementMetaWithEntityType:(Class)entityType
                                                 keyPath:(NSString *)keyPath
                                                   depth:(NSInteger)depth
                                              binderType:(Class)binderType
                                           configuration:(PBUIConfigurationHandler)configuration;

+ (PBListViewUIElementMeta *)uiElementMetaWithEntityType:(Class)entityType
                                                 keyPath:(NSString *)keyPath
                                              binderType:(Class)binderType
                                           configuration:(PBUIConfigurationHandler)configuration;

- (void)invokeAction:(id)sender;

- (void)addEntityCommand:(PBListViewCommand *)command;

@end
