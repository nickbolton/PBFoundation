//
//  PBListViewExpandButtonBinder.m
//  PBListView
//
//  Created by Nick Bolton on 2/17/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBListViewExpandButtonBinder.h"
#import "PBButton.h"
#import "PBListViewUIElementMeta.h"
#import "PBListView.h"

NSString * const kPBButtonBinderOriginalImageKey = @"original-image";
NSString * const kPBButtonBinderOriginalOnImageKey = @"original-onImage";

@implementation PBListViewExpandButtonBinder

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
         setObject:meta.image forKey:kPBButtonBinderOriginalImageKey];
    }

    if (meta.onImage != nil) {
        [meta.imageCache
         setObject:meta.onImage forKey:kPBButtonBinderOriginalOnImageKey];
    }
}

- (void)runtimeConfiguration:(PBListViewUIElementMeta *)meta
                        view:(PBButton *)button {

    [super runtimeConfiguration:meta view:button];

    meta.actionHandler = ^(PBButton *button, id <PBListViewEntity> entity, PBListViewUIElementMeta *meta, PBListView *listView) {

        NSInteger row = [listView rowForView:button];

        if (row >= 0) {

            [NSAnimationContext beginGrouping];

            CGFloat targetAngle;
            NSImage *endImage;
            NSImage *startImage = button.image;

            if ([listView isRowExpanded:row]) {
                [listView collapseRow:row animate:YES completion:nil];
                targetAngle = 0.0f;
                endImage = [meta.imageCache objectForKey:kPBButtonBinderOriginalImageKey];
            } else {
                [listView expandRow:row animate:YES completion:nil];
                targetAngle = -90.0f;
                endImage = [meta.imageCache objectForKey:kPBButtonBinderOriginalOnImageKey];
            }

            button.image = endImage;
            button.onImage = startImage;

            NSAnimationContext.currentContext.completionHandler = ^{
                button.frameCenterRotation = 0.0f;
                meta.image = button.image;
                meta.onImage = button.onImage;
            };

            button.frameCenterRotation = targetAngle;

            [NSAnimationContext endGrouping];
        }
    };

}

@end
