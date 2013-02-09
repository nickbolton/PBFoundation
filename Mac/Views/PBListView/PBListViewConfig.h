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

typedef NS_ENUM(NSInteger, PBListViewFont) {
    PBListViewFontSmall = 0,
    PBListViewFontSmallBold,
    PBListViewFontMedium,
    PBListViewFontMediumBold,
    PBListViewFontLarge,
    PBListViewFontLargeBold,
    PBListViewFontExtraLarge,
    PBListViewFontExtraLargeBold,
};

typedef NS_ENUM(NSInteger, PBListViewTextColor) {
    PBListViewTextColorLight = 0,
    PBListViewTextColorDark,
};

@interface PBListViewConfig : NSObject

+ (PBListViewConfig *)sharedInstance;

@property (nonatomic) CGFloat leftMargin;
@property (nonatomic) CGFloat rightMargin;
@property (nonatomic) NSSize minSize;
@property (nonatomic) NSSize maxSize;
@property (nonatomic, strong) NSColor *rowDividerLineColor;
@property (nonatomic) CGFloat rowDividerLineHeight;

- (void)registerBackgroundImage:(NSImage *)image
                  forEntityType:(Class)entityType
                     atPosition:(PBListViewPositionType)positionType;
- (NSImage *)backgroundImageForEntityType:(Class)entityType
                               atPosition:(PBListViewPositionType)positionType;

- (void)registerDefaultFont:(NSFont *)font forType:(PBListViewFont)fontType;
- (NSFont *)defaultFontForType:(PBListViewFont)fontType;

- (void)registerDefaultTextColor:(NSColor *)color
                     shadowColor:(NSColor *)shadowColor
                         forType:(PBListViewTextColor)colorType;
- (NSColor *)defaultTextColorForType:(PBListViewTextColor)colorType;
- (NSColor *)defaultTextShadowColorForType:(PBListViewTextColor)colorType;

- (void)registerRowHeight:(CGFloat)rowHeight forEntityType:(Class)entityType;
- (CGFloat)rowHeightForEntityType:(Class)entityType;

@end
