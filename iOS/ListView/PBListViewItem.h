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
    PBItemTypeCustom,
};

extern CGFloat const kPBListRowHeight;
extern CGFloat const kPBListSpacerRowHeight;
extern CGFloat const kPBListActionRowHeight;

@class PBListViewController;

@interface PBListViewItem : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *valueColor;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIFont *valueFont;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *separatorColor;
@property (nonatomic) UIEdgeInsets separatorInsets;
@property (nonatomic) BOOL hasDisclosure;
@property (nonatomic) BOOL itemConfigured;
@property (nonatomic, getter = isDeletable) BOOL deletable;
@property (nonatomic) CGFloat rowHeight;
@property (nonatomic) NSString *cellID;
@property (nonatomic) UINib *cellNib;
@property (nonatomic) id userContext;
@property (nonatomic, copy) UIViewController *(^selectActionBlock)(id sender);
@property (nonatomic, copy) void(^deleteActionBlock)(id sender);
@property (nonatomic, copy) void(^configureBlock)(id sender, PBListViewItem *item, id cell);
@property (nonatomic, copy) void(^bindingBlock)(id sender, PBListViewItem *item, id cell);
@property (nonatomic) PBItemType itemType;
@property (nonatomic) UITableViewCellSelectionStyle selectionStyle;
@property (nonatomic) NSTextAlignment titleAlignment;

+ (instancetype)selectionItemWithTitle:(NSString *)title
                                 value:(NSString *)value
                              itemType:(PBItemType)itemType
                         hasDisclosure:(BOOL)hasDisclosure
                          selectAction:(UIViewController *(^)(PBListViewController *viewController))selectActionBlock
                          deleteAction:(void(^)(PBListViewController *viewController))deleteActionBlock;

+ (instancetype)customItemWithUserContext:(id)userContext
                                   cellID:(NSString *)cellID
                                  cellNib:(UINib *)cellNib
                                configure:(void(^)(PBListViewController *viewController, PBListViewItem *item, id cell))configureBlock
                                  binding:(void(^)(PBListViewController *viewController, PBListViewItem *item, id cell))bindingBlock
                             selectAction:(UIViewController *(^)(PBListViewController *viewController))selectActionBlock
                             deleteAction:(void(^)(PBListViewController *viewController))deleteActionBlock;

@end
