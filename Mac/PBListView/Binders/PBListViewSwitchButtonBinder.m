//
//  PBListViewSwitchButtonBinder.m
//  PBListView
//
//  Created by Nick Bolton on 2/9/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBListViewSwitchButtonBinder.h"
#import "PBListViewUIElementMeta.h"
#import "PBButton.h"

NSString * const kPBSwitchButtonBinderOriginalImageKey = @"original-image";
NSString * const kPBSwitchButtonBinderOriginalOnImageKey = @"original-onImage";
NSString * const kPBSwitchButtonBinderOriginalPressedImageKey = @"original-pressed-image";
NSString * const kPBSwitchButtonBinderOriginalPressedOnImageKey = @"original-pressed-onImage";

@implementation PBListViewSwitchButtonBinder

- (id)buildUIElement:(PBListView *)listView {
    NSButton *button = [super buildUIElement:listView];
    button.buttonType = NSMomentaryChangeButton;
    return button;
}

- (void)configureView:(PBListView *)listView
                 view:(NSView *)view
                 meta:(PBListViewUIElementMeta *)meta
        relativeViews:(NSMutableArray *)relativeViews
     relativeMetaList:(NSMutableArray *)relativeMetaList {

    [super
     configureView:listView
     view:view
     meta:meta
     relativeViews:relativeViews
     relativeMetaList:relativeMetaList];

    if (meta.image != nil) {
        [meta.imageCache
         setObject:meta.image forKey:kPBSwitchButtonBinderOriginalImageKey];
    }

    if (meta.onImage != nil) {
        [meta.imageCache
         setObject:meta.onImage forKey:kPBSwitchButtonBinderOriginalOnImageKey];
    }

    if (meta.pressedImage != nil) {
        [meta.imageCache
         setObject:meta.pressedImage forKey:kPBSwitchButtonBinderOriginalPressedImageKey];
    }

    if (meta.pressedOnImage != nil) {
        [meta.imageCache
         setObject:meta.pressedOnImage  forKey:kPBSwitchButtonBinderOriginalPressedOnImageKey];
    }
}

- (void)bindEntity:(id)entity
          withView:(PBButton *)button
             atRow:(NSInteger)row
         usingMeta:(PBListViewUIElementMeta *)meta {

    [super bindEntity:entity withView:button atRow:row usingMeta:meta];

    NSAssert([button isKindOfClass:[NSButton class]],
             @"view is not of type NSButton");

    NSAssert([meta isKindOfClass:[PBListViewUIElementMeta class]],
             @"meta is not of type PBListViewUIElementMeta");

    NSNumber *switchValue = @NO;

    if (meta.keyPath != nil) {
        id value = [entity valueForKeyPath:meta.keyPath];
        if (value != nil) {

            if (meta.valueTransformer != nil) {
                value = meta.valueTransformer(value);
            }

            NSAssert([value isKindOfClass:[NSNumber class]],
                     @"value of %@ at keyPath '%@' is not an NSNumber",
                     NSStringFromClass([entity class]), meta.keyPath);

            switchValue = value;
        }
    }

    button.on = switchValue.boolValue;

    if (button.isOn) {
        button.image =
        [meta.imageCache objectForKey:kPBSwitchButtonBinderOriginalOnImageKey];
        button.alternateImage =
        [meta.imageCache objectForKey:kPBSwitchButtonBinderOriginalPressedOnImageKey];
    } else {
        button.image =
        [meta.imageCache objectForKey:kPBSwitchButtonBinderOriginalImageKey];
        button.alternateImage =
        [meta.imageCache objectForKey:kPBSwitchButtonBinderOriginalPressedImageKey];
    }

}

@end
