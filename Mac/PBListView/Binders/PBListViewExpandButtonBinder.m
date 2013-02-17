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

    [super postGlobalConfiguration:listView meta:meta view:button];
    
    meta.actionHandler = ^(PBButton *button, id <PBListViewEntity> entity, PBListViewUIElementMeta *meta, PBListView *listView) {

        NSInteger row = [listView rowForView:button];

        if (row >= 0) {

            [NSAnimationContext beginGrouping];

            CGFloat targetAngle;
            NSImage *endImage = meta.onImage;

            if ([listView isRowExpanded:row]) {
                [listView collapseRow:row animate:YES];
                targetAngle = 0.0f;
            } else {
                [listView expandRow:row animate:YES];
                targetAngle = -90.0f;
            }

            NSAnimationContext.currentContext.completionHandler = ^{
                button.onImage = button.image;
                button.image = endImage;
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
