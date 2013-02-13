//
//  PBListViewUIElementMeta.h
//  PBListView
//
//  Created by Nick Bolton on 2/5/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Foundation/Foundation.h>

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
@property (nonatomic) BOOL rightJustified;
@property (nonatomic) BOOL hoverAlphaEnabled;
@property (nonatomic) CGFloat hoverOffAlpha;
@property (nonatomic, strong) NSImage *image;
@property (nonatomic, strong) NSImage *pressedImage;
@property (nonatomic, strong) NSImage *onImage;
@property (nonatomic, strong) NSImage *disabledImage;

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
