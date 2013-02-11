//
//  PBListViewConfig.m
//  PBListView
//
//  Created by Nick Bolton on 2/9/13.
//  Copyright 2013 Pixelbleed. All rights reserved.
//

#import "PBListViewConfig.h"
#import "PBListViewUIElementMeta.h"

@interface PBListViewConfig()

@property (nonatomic, strong) NSMutableDictionary *metaListRegistry;
@property (nonatomic, strong) NSMutableDictionary *rowHeightRegistry;
@property (nonatomic, strong) NSMutableDictionary *rowBackgroundImageRegistry;

@end

@implementation PBListViewConfig

- (id)init {
    self = [super init];

    if (self != nil) {
        self.metaListRegistry = [NSMutableDictionary dictionary];
        self.rowHeightRegistry = [NSMutableDictionary dictionary];
        self.rowBackgroundImageRegistry = [NSMutableDictionary dictionary];
        self.leftMargin = 10.0f;
        self.rightMargin = 10.0f;
        self.minSize = NSMakeSize(300.0f, 300.0f);
        self.maxSize = NSMakeSize(MAXFLOAT, MAXFLOAT);
        self.rowDividerLineColor = nil;
        self.rowDividerLineHeight = 1.0f;
        self.selectedBackgroundColor = [NSColor colorWithRGBHex:0xD7E4F1];
        self.selectedBorderColor = [NSColor colorWithRGBHex:0x3775BC alpha:1.0f];
        self.selectedBorderRadius = 10.0f;

    }

    return self;
}

#pragma mark - Meta registering

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

- (void)registerBackgroundImage:(NSImage *)image
                  forEntityType:(Class)entityType
                     atPosition:(PBListViewPositionType)positionType {
    [self
     registerBackgroundImage:image
     forEntityType:entityType
     atDepth:0
     atPosition:positionType];
}

- (void)registerBackgroundImage:(NSImage *)image
                  forEntityType:(Class)entityType
                        atDepth:(NSUInteger)depth
                     atPosition:(PBListViewPositionType)positionType {

    NSAssert(positionType < PBListViewPositionTypeCount,
             @"positionType is out of range %ld > %ld", positionType, PBListViewPositionTypeCount);
    
    NSMutableArray *backgroundImages =
    [self
     backgroundImagesForEntityType:entityType
     atDepth:depth];

    if (backgroundImages.count == 0) {

        for (NSInteger i = 0; i < PBListViewPositionTypeCount; i++) {
            [backgroundImages addObject:image];
        }

    } else {
        [backgroundImages replaceObjectAtIndex:positionType withObject:image];
    }
}

- (NSImage *)backgroundImageForEntityType:(Class)entityType
                                  atDepth:(NSUInteger)depth
                               atPosition:(PBListViewPositionType)positionType {

    NSAssert(positionType < PBListViewPositionTypeCount,
             @"positionType is out of range %ld > %ld", positionType, PBListViewPositionTypeCount);

    NSMutableArray *backgroundImages =
    [self backgroundImagesForEntityType:entityType atDepth:depth];
    
    if (positionType < backgroundImages.count) {
        return backgroundImages[positionType];
    }
    
    return nil;
}

- (NSMutableArray *)backgroundImagesForEntityType:(Class)entityType
                                          atDepth:(NSUInteger)depth {
    NSString *key = NSStringFromClass(entityType);
    NSMutableArray *depths =
    [_rowBackgroundImageRegistry objectForKey:key];

    if (depths == nil) {
        depths = [NSMutableArray array];
        [_rowBackgroundImageRegistry setObject:depths forKey:key];
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
