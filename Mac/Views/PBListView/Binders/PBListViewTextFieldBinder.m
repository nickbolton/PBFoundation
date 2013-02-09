//
//  PBListViewTextFieldBinder.m
//  PBListView
//
//  Created by Nick Bolton on 2/5/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBListView.h"
#import "PBListViewTextFieldBinder.h"
#import "PBShadowTextFieldCell.h"
#import "PBListViewUIElementMeta.h"
#import "PBListViewConfig.h"

@implementation PBListViewTextFieldBinder

- (id)buildUIElementWithMeta:(PBListViewUIElementMeta *)meta {
    NSTextField *textField = [[NSTextField alloc] initWithFrame:NSZeroRect];
    PBShadowTextFieldCell *cell = [[PBShadowTextFieldCell alloc] init];
    cell.yoffset = -2.0f;
    textField.cell = cell;

    textField.font = [[PBListViewConfig sharedInstance] defaultFontForType:PBListViewFontMedium];
    textField.textColor = [[PBListViewConfig sharedInstance] defaultTextColorForType:PBListViewTextColorDark];
    cell.textShadowColor = [[PBListViewConfig sharedInstance] defaultTextShadowColorForType:PBListViewTextColorDark];
    cell.textShadowOffset = NSMakeSize(0.0f, -1.0f);
    textField.alignment = NSLeftTextAlignment;
    textField.bezeled = NO;
    textField.editable = NO;
    textField.selectable = NO;
    textField.drawsBackground = NO;
    textField.backgroundColor = [NSColor redColor];
    textField.drawsBackground = YES;
    ((NSTextFieldCell *)textField.cell).lineBreakMode = NSLineBreakByTruncatingTail;

    return textField;
}

- (void)bindEntity:(id)entity
          withView:(NSTextField *)textField
         usingMeta:(PBListViewUIElementMeta *)meta {

    NSAssert([textField isKindOfClass:[NSTextField class]],
             @"view is not of type NSTextField");

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

    textField.stringValue = text;
}

@end
