//
//  PBListViewDefaultCell.m
//  Pods
//
//  Created by Nick Bolton on 12/9/13.
//
//

#import "PBListViewDefaultCell.h"
#import "PBListViewItem.h"
#import "NSLayoutConstraint+PBFoundation.h"
#import "PBListViewController.h"

@interface PBListViewDefaultCell()

@property (nonatomic, strong) UIImageView *backgroundImageView;

@end

@implementation PBListViewDefaultCell

- (void)prepareForReuse {
    [super prepareForReuse];
    self.item = nil;
    self.backgroundImageView.image = nil;
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

    if (self.item.itemType == PBItemTypeSelectAll ||
        self.item.itemType == PBItemTypeChecked) {

        if (self.isSelected) {
            self.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            self.accessoryType = UITableViewCellAccessoryNone;
        }
    }

    if (self.isSelected &&
        self.item.selectionDisabled == NO &&
        self.item.selectActionBlock != nil) {
        self.item.selectActionBlock(self);
    }

    self.item.selectionDisabled = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    if (self.isSelected != selected) {

        [super setSelected:selected animated:animated];
        [self updateForSelectedState];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
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
