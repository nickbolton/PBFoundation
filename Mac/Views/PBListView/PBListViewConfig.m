//
//  PBListViewConfig.m
//  PBListView
//
//  Created by Nick Bolton on 2/9/13.
//  Copyright 2013 Pixelbleed. All rights reserved.
//

#import "PBListViewConfig.h"

@interface PBListViewConfig()

@property (nonatomic, strong) NSMutableDictionary *rowHeightRegistry;
@property (nonatomic, strong) NSMutableDictionary *rowBackgroundImageRegistry;
@property (nonatomic, strong) NSMutableDictionary *fontRegistry;
@property (nonatomic, strong) NSMutableDictionary *textColorRegistry;
@property (nonatomic, strong) NSMutableDictionary *textShadowColorRegistry;

@end


@implementation PBListViewConfig

- (id)init {
    self = [super init];

    if (self != nil) {
        self.rowHeightRegistry = [NSMutableDictionary dictionary];
        self.rowBackgroundImageRegistry = [NSMutableDictionary dictionary];
        self.fontRegistry = [NSMutableDictionary dictionary];
        self.textColorRegistry = [NSMutableDictionary dictionary];
        self.textShadowColorRegistry = [NSMutableDictionary dictionary];
        self.leftMargin = 10.0f;
        self.rightMargin = 10.0f;
        self.minSize = NSMakeSize(300.0f, 300.0f);
        self.maxSize = NSMakeSize(MAXFLOAT, MAXFLOAT);
        self.rowDividerLineColor = nil;
        self.rowDividerLineHeight = 1.0f;

        [self
         registerDefaultFont:[NSFont fontWithName:@"HelveticaNeue" size:10.0f]
         forType:PBListViewFontSmall];
        [self
         registerDefaultFont:[NSFont fontWithName:@"HelveticaNeue-Bold" size:10.0f]
         forType:PBListViewFontSmallBold];
        [self
         registerDefaultFont:[NSFont fontWithName:@"HelveticaNeue" size:13.0f]
         forType:PBListViewFontMedium];
        [self
         registerDefaultFont:[NSFont fontWithName:@"HelveticaNeue-Bold" size:13.0f]
         forType:PBListViewFontMediumBold];
        [self
         registerDefaultFont:[NSFont fontWithName:@"HelveticaNeue" size:16.0f]
         forType:PBListViewFontLarge];
        [self
         registerDefaultFont:[NSFont fontWithName:@"HelveticaNeue-Bold" size:16.0f]
         forType:PBListViewFontLargeBold];
        [self
         registerDefaultFont:[NSFont fontWithName:@"HelveticaNeue" size:20.0f]
         forType:PBListViewFontExtraLarge];
        [self
         registerDefaultFont:[NSFont fontWithName:@"HelveticaNeue-Bold" size:20.0f]
         forType:PBListViewFontExtraLargeBold];
        [self
         registerDefaultTextColor:[NSColor whiteColor]
         shadowColor:[NSColor blackColor]
         forType:PBListViewTextColorLight];
        [self
         registerDefaultTextColor:[NSColor blackColor]
         shadowColor:[NSColor whiteColor]
         forType:PBListViewTextColorDark];
    }

    return self;
}

- (void)registerDefaultFont:(NSFont *)font forType:(PBListViewFont)fontType {
    if (font != nil) {
        [_fontRegistry setObject:font forKey:@(fontType)];
    }
}

- (NSFont *)defaultFontForType:(PBListViewFont)fontType {
    return [_fontRegistry objectForKey:@(fontType)];
}

- (void)registerDefaultTextColor:(NSColor *)color
                     shadowColor:(NSColor *)shadowColor
                         forType:(PBListViewTextColor)colorType {
    if (color != nil) {
        [_textColorRegistry setObject:color forKey:@(colorType)];
    }
    if (shadowColor != nil) {
        [_textShadowColorRegistry setObject:shadowColor forKey:@(colorType)];
    }
}

- (NSColor *)defaultTextColorForType:(PBListViewTextColor)colorType {
    return [_textColorRegistry objectForKey:@(colorType)];
}

- (NSColor *)defaultTextShadowColorForType:(PBListViewTextColor)colorType {
    return [_textShadowColorRegistry objectForKey:@(colorType)];
}

- (void)registerBackgroundImage:(NSImage *)image
                  forEntityType:(Class)entityType
                     atPosition:(PBListViewPositionType)positionType {

    NSAssert(positionType < PBListViewPositionTypeCount,
             @"positionType is out of range %ld > %ld", positionType, PBListViewPositionTypeCount);
    
    NSString *key = NSStringFromClass(entityType);
    NSMutableArray *backgroundImages =
    [_rowBackgroundImageRegistry objectForKey:key];

    if (backgroundImages == nil) {
        backgroundImages = [NSMutableArray arrayWithCapacity:PBListViewPositionTypeCount];

        for (NSInteger i = 0; i < PBListViewPositionTypeCount; i++) {
            [backgroundImages addObject:image];
        }

        [_rowBackgroundImageRegistry setObject:backgroundImages forKey:key];
    } else {
        [backgroundImages replaceObjectAtIndex:positionType withObject:image];
    }
}

- (NSImage *)backgroundImageForEntityType:(Class)entityType
                               atPosition:(PBListViewPositionType)positionType {

    NSAssert(positionType < PBListViewPositionTypeCount,
             @"positionType is out of range %ld > %ld", positionType, PBListViewPositionTypeCount);

    NSString *key = NSStringFromClass(entityType);
    NSArray *backgroundImages =
    [_rowBackgroundImageRegistry objectForKey:key];

    if (backgroundImages != nil) {
        return backgroundImages[positionType];
    }
    
    return nil;
}

- (void)registerRowHeight:(CGFloat)rowHeight forEntityType:(Class)entityType {
    NSString *key = NSStringFromClass(entityType);
    [_rowHeightRegistry setObject:@(rowHeight) forKey:key];
}

- (CGFloat)rowHeightForEntityType:(Class)entityType {
    NSString *key = NSStringFromClass(entityType);
    return [[_rowHeightRegistry objectForKey:key] floatValue];
}

#pragma mark - Singleton Methods

static dispatch_once_t predicate_;
static PBListViewConfig *sharedInstance_ = nil;

+ (id)sharedInstance {
    
    dispatch_once(&predicate_, ^{
        sharedInstance_ = [PBListViewConfig alloc];
        sharedInstance_ = [sharedInstance_ init];
    });
    
    return sharedInstance_;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
