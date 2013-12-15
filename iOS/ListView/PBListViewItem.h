//
//  PBListViewItem.h
//  Sometime
//
//  Created by Nick Bolton on 12/2/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PBItemType) {

    PBItemTypeDefault = 0,
    PBItemTypeAction,
    PBItemTypeSpacer,
    PBItemTypeChecked,
    PBItemTypeSelectAll,
    PBItemTypeCustom,
};

extern CGFloat const kPBListRowHeight;
extern CGFloat const kPBListSpacerRowHeight;
extern CGFloat const kPBListActionRowHeight;

@class PBListViewController;

@interface PBListViewItem : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic) CGFloat titleMargin;
@property (nonatomic) CGFloat valueMargin;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *valueColor;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIFont *valueFont;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *separatorColor;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) UIImage *selectedBackgroundImage;
@property (nonatomic, strong) UIImage *hightlightedBackgroundImage;
@property (nonatomic, strong) UIImage *highlightedSelectedBackgroundImage;

@property (nonatomic) UIEdgeInsets separatorInsets;
@property (nonatomic) BOOL hasDisclosure;
@property (nonatomic) BOOL itemConfigured;
@property (nonatomic) BOOL selectionDisabled;
@property (nonatomic, getter = isSelected) BOOL selected;
@property (nonatomic, getter = isDeselectable) BOOL deselectable;
@property (nonatomic, getter = isDeletable) BOOL deletable;
@property (nonatomic) CGFloat rowHeight;
@property (nonatomic) NSString *cellID;
@property (nonatomic) UINib *cellNib;
@property (nonatomic) Class cellClass;
@property (nonatomic) id userContext;
@property (nonatomic, copy) void(^selectActionBlock)(id sender);
@property (nonatomic, copy) void(^deleteActionBlock)(id sender);
@property (nonatomic, copy) void(^configureBlock)(id sender, PBListViewItem *item, id cell);
@property (nonatomic, copy) void(^bindingBlock)(id sender, NSIndexPath *indexPath, PBListViewItem *item, id cell);
@property (nonatomic) PBItemType itemType;
@property (nonatomic) UITableViewCellSelectionStyle selectionStyle;
@property (nonatomic) NSTextAlignment titleAlignment;

+ (instancetype)selectionItemWithTitle:(NSString *)title
                                 value:(NSString *)value
                              itemType:(PBItemType)itemType
                         hasDisclosure:(BOOL)hasDisclosure
                          selectAction:(void(^)(PBListViewController *viewController))selectActionBlock
                          deleteAction:(void(^)(PBListViewController *viewController))deleteActionBlock;

+ (instancetype)selectAllItemWithTitle:(NSString *)title
                          selectAction:(void(^)(PBListViewController *viewController))selectActionBlock
                          deleteAction:(void(^)(PBListViewController *viewController))deleteActionBlock;

+ (instancetype)customNibItemWithUserContext:(id)userContext
                                      cellID:(NSString *)cellID
                                     cellNib:(UINib *)cellNib
                                   configure:(void(^)(PBListViewController *viewController, PBListViewItem *item, id cell))configureBlock
                                     binding:(void(^)(PBListViewController *viewController, NSIndexPath *indexPath, PBListViewItem *item, id cell))bindingBlock
                                selectAction:(void(^)(PBListViewController *viewController))selectActionBlock
                                deleteAction:(void(^)(PBListViewController *viewController))deleteActionBlock;

+ (instancetype)customClassItemWithUserContext:(id)userContext
                                        cellID:(NSString *)cellID
                                     cellClass:(Class)cellClass
                                     configure:(void(^)(PBListViewController *viewController, PBListViewItem *item, id cell))configureBlock
                                       binding:(void(^)(PBListViewController *viewController, NSIndexPath *indexPath, PBListViewItem *item, id cell))bindingBlock
                                  selectAction:(void(^)(PBListViewController *viewController))selectActionBlock
                                  deleteAction:(void(^)(PBListViewController *viewController))deleteActionBlock;

@end
