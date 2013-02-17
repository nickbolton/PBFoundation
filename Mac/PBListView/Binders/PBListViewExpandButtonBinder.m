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

@implementation PBListViewExpandButtonBinder

- (void)postGlobalConfiguration:(PBListView *)listView
                           meta:(PBListViewUIElementMeta *)meta
                           view:(PBButton *)button {

    static NSString * const kOriginalImageKey = @"original-image";
    static NSString * const kOriginalOnImageKey = @"original-onImage";

    [super postGlobalConfiguration:listView meta:meta view:button];

    [button.imageCache setObject:meta.image forKey:kOriginalImageKey];
    [button.imageCache setObject:meta.onImage forKey:kOriginalOnImageKey];

    meta.actionHandler = ^(PBButton *button, id <PBListViewEntity> entity, PBListViewUIElementMeta *meta, PBListView *listView) {

        NSInteger row = [listView rowForView:button];

        if (row >= 0) {

            [NSAnimationContext beginGrouping];

            CGFloat targetAngle;
            NSImage *endImage;
            NSImage *startImage = button.image;

            if ([listView isRowExpanded:row]) {
                [listView collapseRow:row animate:YES];
                targetAngle = 0.0f;
                endImage = [button.imageCache objectForKey:kOriginalImageKey];
            } else {
                [listView expandRow:row animate:YES];
                targetAngle = -90.0f;
                endImage = [button.imageCache objectForKey:kOriginalOnImageKey];
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
