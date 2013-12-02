//
//  PBListViewItem.h
//  Sometime
//
//  Created by Nick Bolton on 12/2/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PBListType) {

    PBListTypeDefault = 0,
    PBListTypeAction,
    PBListTypeSpacer,
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
@property (nonatomic, getter = isDeletable) BOOL deletable;
@property (nonatomic) CGFloat rowHeight;
@property (nonatomic, copy) UIViewController *(^selectActionBlock)(id sender);
@property (nonatomic, copy) UIViewController *(^deleteActionBlock)(id sender);
@property (nonatomic) PBListType listType;
@property (nonatomic) UITableViewCellSelectionStyle selectionStyle;
@property (nonatomic) NSTextAlignment titleAlignment;

+ (instancetype)selectionItemWithTitle:(NSString *)title
                                 value:(NSString *)value
                              listType:(PBListType)listType
                         hasDisclosure:(BOOL)hasDisclosure
                          selectAction:(UIViewController *(^)(PBListViewController *viewController))selectActionBlock
                          deleteAction:(UIViewController *(^)(PBListViewController *viewController))deleteActionBlock;

@end
