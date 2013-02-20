//
//  PBListViewButtonBinder.m
//  PBListView
//
//  Created by Nick Bolton on 2/9/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBListViewButtonBinder.h"
#import "PBShadowButtonCell.h"
#import "PBListViewConfig.h"
#import "PBListViewUIElementMeta.h"
#import "PBListView.h"

@implementation PBListViewButtonBinder

- (id)buildUIElement:(PBListView *)listView {
    PBButton *button = [[PBButton alloc] initWithFrame:NSZeroRect];

    button.buttonType = NSMomentaryChangeButton;

    PBShadowButtonCell *cell = [[PBShadowButtonCell alloc] init];
    cell.textShadowOffset = NSMakeSize(0.0f, -1.0f);
    cell.highlightsBy = NSCellHasOverlappingImage;

    button.cell = cell;

    button.bezelStyle = 0;
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.bordered = NO;
    button.title = nil;
    button.alternateTitle = nil;
    button.allowsMixedState = NO;
    button.imagePosition = NSImageLeft;

    return button;
}

- (void)runtimeConfiguration:(PBListView *)listView
                        meta:(PBListViewUIElementMeta *)meta
                        view:(PBButton *)button
                         row:(NSInteger)row {
    [super
     runtimeConfiguration:listView
     meta:meta
     view:button
     row:row];

    NSAssert([button isKindOfClass:[PBButton class]], @"view is not a PBButton");

    meta.size = meta.image != nil ? meta.image.size : meta.onImage.size;
    button.image = meta.image;
    button.onImage = meta.onImage;
    button.disabledImage = meta.disabledImage;
    button.alternateImage = meta.pressedImage;

    button.hoverAlphaEnabled = meta.hoverAlphaEnabled;
    button.offAlphaValue = meta.hoverOffAlpha;

    PBShadowButtonCell *cell = button.cell;

    cell.textShadowColor = meta.textShadowColor;
    cell.textShadowOffset = meta.shadowOffset;

}

- (void)bindEntity:(id)entity
          withView:(NSButton *)button
             atRow:(NSInteger)row
         usingMeta:(PBListViewUIElementMeta *)meta {

    [super bindEntity:entity withView:button atRow:row usingMeta:meta];

    NSAssert([button isKindOfClass:[NSButton class]],
             @"view is not of type NSButton");

    NSAssert([meta isKindOfClass:[PBListViewUIElementMeta class]],
             @"meta is not of type PBListViewUIElementMeta");

    NSString *text = @"";

    if (meta.keyPath != nil) {
        id value = [entity valueForKeyPath:meta.keyPath];
        if (value != nil) {

            if (meta.valueTransformer != nil) {
                value = meta.valueTransformer(value);
            }

            if ([value isKindOfClass:[NSString class]]) {
                text = value;
            }
        }
    }

    button.title = text;
}

@end
