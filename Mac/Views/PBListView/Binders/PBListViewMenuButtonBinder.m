//
//  PBListViewMenuButtonBinder.m
//  PBListView
//
//  Created by Nick Bolton on 2/10/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBListViewMenuButtonBinder.h"
#import "PBShadowPopUpButtonCell.h"
#import "PBListViewUIElementMeta.h"
#import "PBPopUpButton.h"

@implementation PBListViewMenuButtonBinder

- (id)buildUIElement:(PBListView *)listView {
    PBPopUpButton *button = [[PBPopUpButton alloc] initWithFrame:NSZeroRect];

    button.cell = [[PBShadowPopUpButtonCell alloc] init];

    button.buttonType = NSMomentaryChangeButton;
    button.bezelStyle = 0;
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.bordered = NO;
    button.title = nil;
    button.alternateTitle = nil;
    button.allowsMixedState = NO;
    button.imagePosition = NSImageLeft;

    return button;
}

- (void)postClientConfiguration:(PBListView *)listView
                           meta:(PBListViewUIElementMeta *)meta
                           view:(PBPopUpButton *)button
                          index:(NSInteger)index {

    NSAssert([button isKindOfClass:[PBPopUpButton class]], @"view is not a PBPopUpButton");

    meta.size = meta.image.size;
    button.image = meta.image;
    button.alternateImage = meta.pressedImage;

    button.hoverAlphaEnabled = meta.hoverAlphaEnabled;
    button.offAlphaValue = meta.hoverOffAlpha;

    PBShadowPopUpButtonCell *cell = button.cell;
    
    cell.textShadowColor = meta.textShadowColor;
    cell.textShadowOffset = meta.shadowOffset;
}

@end
