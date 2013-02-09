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

@implementation PBListViewButtonBinder

- (id)buildUIElementWithMeta:(PBListViewUIElementMeta *)meta {
    NSButton *button = [[NSButton alloc] initWithFrame:NSZeroRect];

    button.cell = [[PBShadowButtonCell alloc] init];
    ((PBShadowButtonCell *)button.cell).textShadowColor = [[PBListViewConfig sharedInstance] defaultTextShadowColorForType:PBListViewTextColorDark];
    ((PBShadowButtonCell *)button.cell).textShadowOffset = NSMakeSize(0.0f, -1.0f);

    button.buttonType = NSMomentaryChangeButton;
    button.bezelStyle = 0;
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.bordered = NO;
    button.image = meta.image;
    button.alternateImage = meta.alternateImage;
    button.target = meta.target;
    button.action = meta.action;

    return button;
}

- (void)bindEntity:(id)entity
          withView:(NSButton *)button
         usingMeta:(PBListViewUIElementMeta *)meta {

    NSAssert([button isKindOfClass:[NSButton class]],
             @"view is not of type NSButton");

    NSAssert([meta isKindOfClass:[PBListViewUIElementMeta class]],
             @"meta is not of type PBListViewUIElementMeta");

    NSString *text = @"";

    if (meta.keyPath != nil) {
        id value = [entity valueForKeyPath:meta.keyPath];
        if (value != nil) {

            NSAssert([value isKindOfClass:[NSString class]],
                     @"value of %@ at keyPath '%@' is not an NSString",
                     NSStringFromClass([entity class]), meta.keyPath);
            
            text = value;
        }
    }

    button.title = text;
}

@end
