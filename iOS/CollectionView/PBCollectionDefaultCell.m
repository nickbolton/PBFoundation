//
//  PBCollectionDefaultCell.m
//  PBFoundation
//
//  Created by Nick Bolton on 11/12/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBCollectionDefaultCell.h"
#import "PBCollectionItem.h"
#import "PBCollectionSupplimentaryImageItem.h"

@interface PBCollectionDefaultCell() {
}

@property (nonatomic, readwrite) IBOutlet UIImageView *backgroundImageView;

@end

@implementation PBCollectionDefaultCell

- (void)prepareForReuse {
    [super prepareForReuse];
    self.item = nil;

    _backgroundImageView.image = nil;
}

- (UIImageView *)backgroundImageView {

    if (_backgroundImageView == nil) {

        self.backgroundImageView =
        [[UIImageView alloc]
         initWithImage:self.item.backgroundImage];

        self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundView.alpha = 0.0;
        self.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.backgroundImageView];
        [NSLayoutConstraint expandToSuperview:self.backgroundImageView];
    }

    return _backgroundImageView;
}

- (void)updateForSelectedState {

    [self updateBackoundImage];

    self.item.selected = self.isSelected;

    if (self.isSelected &&
        self.item.selectionDisabled == NO &&
        self.item.selectActionBlock != nil) {
        self.item.selectActionBlock(self);
    }

    self.item.selectionDisabled = NO;
}

- (void)setSelected:(BOOL)selected {

    if (self.isSelected != selected) {

        [super setSelected:selected];
        [self updateForSelectedState];
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self updateBackoundImage];
}

- (void)updateBackoundImage {

    if (self.isHighlighted) {

        if (self.isSelected) {

            if (self.item.highlightedSelectedBackgroundImage != nil) {

                self.backgroundImageView.image =
                self.item.highlightedSelectedBackgroundImage;
            }

        } else {

            if (self.item.hightlightedBackgroundImage != nil) {

                self.backgroundImageView.image =
                self.item.hightlightedBackgroundImage;
            }
        }

    } else {

        if (self.isSelected) {

            if (self.item.selectedBackgroundImage != nil) {

                self.backgroundImageView.image =
                self.item.selectedBackgroundImage;
            }

        } else {

            if (self.item.backgroundImage != nil) {

                self.backgroundImageView.image =
                self.item.backgroundImage;
            }
        }
    }
}

@end
