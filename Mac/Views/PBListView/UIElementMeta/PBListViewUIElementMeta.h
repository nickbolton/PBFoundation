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

typedef void(^PBUIConfigurationHandler)(id view, PBListViewUIElementMeta *meta);

@interface PBListViewUIElementMeta : NSObject

@property (nonatomic, readonly) NSString *keyPath;
@property (nonatomic, readonly) Class entityType;
@property (nonatomic, readwrite) CGFloat leftPadding;
@property (nonatomic, readwrite) NSSize size;
@property (nonatomic, strong) NSImage *image;
@property (nonatomic, strong) NSImage *alternateImage;
@property (nonatomic, strong) NSImage *hoverImage;
@property (nonatomic, weak) id target;
@property (nonatomic) SEL action;
@property (nonatomic, readonly) PBListViewUIElementBinder *binder;
@property (nonatomic, readonly) PBUIConfigurationHandler configurationHandler;

+ (PBListViewUIElementMeta *)uiElementMetaWithEntityType:(Class)entityType
                                                 keyPath:(NSString *)keyPath
                                              binderType:(Class)binderType
                                           configuration:(PBUIConfigurationHandler)configuration;

@end
