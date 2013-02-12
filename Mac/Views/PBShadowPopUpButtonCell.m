//
//  PBShadowPopUpButtonCell.m
//  PBListView
//
//  Created by Nick Bolton on 2/9/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBShadowPopUpButtonCell.h"

@interface PBShadowPopUpButtonCell()

@property (nonatomic, strong) NSImage *_image;
@property (nonatomic, strong) NSImage *_altImage;

@end


@implementation PBShadowPopUpButtonCell

- (NSRect)drawTitle:(NSAttributedString *)title
          withFrame:(NSRect)frame
             inView:(NSView *)controlView {

    if (_textShadowColor != nil) {
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowColor = _textShadowColor;
        shadow.shadowOffset = _textShadowOffset;
        shadow.shadowBlurRadius = 0.0f;
        [shadow set];
    }

    frame.origin.y += _yOffset;

    return
    [super
     drawTitle:title
     withFrame:frame
     inView:controlView];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    [super drawWithFrame:cellFrame inView:controlView];
}

- (void)setImage:(NSImage *)image {
    self._image = image;
}

- (NSImage *)image {
    return __image;
}

- (void)setAlternateImage:(NSImage *)image {
    self._altImage = image;
}

- (NSImage *)alternateImage {
    return __altImage;
}

- (void)drawImageWithFrame:(NSRect)cellRect inView:(NSView *)controlView{
    NSImage *image = self.image;
    if([self isHighlighted] && self.alternateImage) {
        image = self.alternateImage;
    }

    //TODO: respect -(NSCellImagePosition)imagePosition
    NSRect imageRect = NSZeroRect;
    imageRect.origin.y = (CGFloat)round(cellRect.size.height*0.5f-image.size.height*0.5f);
    imageRect.origin.x = (CGFloat)round(cellRect.size.width*0.5f-image.size.width*0.5f);
    imageRect.size = image.size;

    [image drawInRect:imageRect
             fromRect:NSZeroRect
            operation:NSCompositeSourceOver
             fraction:1.0f
       respectFlipped:YES
                hints:nil];
}

@end
