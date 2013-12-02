//
//  PBListViewController.h
//  PBFoundation
//
//  Created by Nick Bolton on 11/4/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TCTimePeriodSelectorView;

extern NSString * const kPBListCellID;
extern NSString * const kPBListSpacerCellID;
extern NSString * const kPBListActionCellID;

@interface PBListViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) PBActionDelegate *actionDelegate;
@property (nonatomic) BOOL initialized;
@property (nonatomic, getter = isModal) BOOL modal;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *valueColor;
@property (nonatomic, strong) UIColor *actionColor;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIFont *valueFont;
@property (nonatomic, strong) UIFont *actionFont;
@property (nonatomic, strong) UIColor *cellBackgroundColor;
@property (nonatomic, strong) UIColor *spacerCellBackgroundColor;
@property (nonatomic, strong) UIColor *tableBackgroundColor;

- (id)initWithItems:(NSArray *)items;

- (void)setupNotifications;
- (void)setupTableView;
- (void)reloadDataSource;
- (void)reloadData;
- (void)setupNavigationBar;
- (void)reloadTableRow:(NSUInteger)row;
- (void)reloadTableRow:(NSUInteger)row
         withAnimation:(UITableViewRowAnimation)animation;

@end
