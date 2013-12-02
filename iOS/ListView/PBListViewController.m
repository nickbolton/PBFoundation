//
//  PBListViewController.m
//  PBFoundation
//
//  Created by Nick Bolton on 11/4/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBListViewController.h"
#import "PBListViewItem.h"
#import "PBListCell.h"

NSString * const kPBListCellID = @"default-cell-id";
NSString * const kPBListSpacerCellID = @"spacer-cell-id";
NSString * const kPBListActionCellID = @"action-cell-id";

static NSInteger const kPBListSeparatorCellTag = 98;
static NSInteger const kPBListSeparatorTag = 99;
static NSInteger const kPBListActionTag = 101;
static NSInteger const kPBListDefaultTag = 103;

@interface PBListViewController () {
}

@end

@implementation PBListViewController

- (id)initWithItems:(NSArray *)items {

    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        self.dataSource = items;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Setup

- (void)setupNotifications {
}

- (void)setupNavigationBar {
}

- (void)setupTableView {

    UINib *nib =
    [UINib
     nibWithNibName:NSStringFromClass([PBListCell class])
     bundle:nil];

    [self.tableView
     registerNib:nib
     forCellReuseIdentifier:kPBListCellID];

    [self.tableView
     registerClass:[UITableViewCell class]
     forCellReuseIdentifier:kPBListSpacerCellID];

    [self.tableView
     registerClass:[UITableViewCell class]
     forCellReuseIdentifier:kPBListActionCellID];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationBar];
    [self setupNotifications];
    [self setupTableView];

    self.tableView.backgroundColor = self.tableBackgroundColor;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    self.tableView.editing = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Getters and Setters

#pragma mark - Actions

#pragma mark -

- (PBListViewItem *)itemAtIndexPath:(NSIndexPath *)indexPath {

    PBListViewItem *item = nil;

    if (indexPath.row < self.dataSource.count) {
        item = self.dataSource[indexPath.row];

        NSAssert([item isKindOfClass:[PBListViewItem class]],
                 @"item not a PBListViewItem");
    }

    return item;
}

- (void)reloadTableRow:(NSUInteger)row {
    [self reloadTableRow:row withAnimation:UITableViewRowAnimationAutomatic];
}

- (void)reloadTableRow:(NSUInteger)row
         withAnimation:(UITableViewRowAnimation)animation {

    [self.tableView
     reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]]
     withRowAnimation:animation];
}

- (void)reloadDataSource {
}

- (void)reloadData {
    [self reloadDataSource];
    [self.tableView reloadData];
}

- (void)addSeparatorToCell:(UITableViewCell *)cell
                      item:(PBListViewItem *)item {

    UIView *separator = [cell viewWithTag:kPBListSeparatorTag];

    if (separator == nil) {
        separator = [[UIView alloc] init];
        separator.backgroundColor = item.separatorColor;
        separator.tag = kPBListSeparatorTag;
        [cell addSubview:separator];
    }

    CGFloat scale = [[UIScreen mainScreen] scale];

    CGFloat height = 1.0f / scale;

    CGRect frame =
    CGRectMake(item.separatorInsets.left,
               item.rowHeight-height,
               CGRectGetWidth(self.tableView.frame) - item.separatorInsets.left - item.separatorInsets.right,
               height);

    separator.frame = frame;
}

- (void)configureSpacerCell:(UITableViewCell *)cell
                   withItem:(PBListViewItem *)item {

    if (cell.tag != kPBListSeparatorCellTag) {
        cell.tag = kPBListSeparatorCellTag;
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        if (item.separatorColor != nil) {
            [self addSeparatorToCell:cell item:item];
        }
    }
}

- (void)configureActionCell:(UITableViewCell *)cell
                   withItem:(PBListViewItem *)item {

    if (cell.tag != kPBListActionTag) {
        cell.tag = kPBListActionTag;

        cell.textLabel.textColor =
        item.titleColor != nil ? item.titleColor : self.actionColor;

        cell.textLabel.font =
        item.titleFont != nil ? item.titleFont : self.actionFont;

        cell.backgroundColor =
        item.backgroundColor != nil ? item.backgroundColor : self.cellBackgroundColor;

        cell.selectionStyle = item.selectionStyle;

        cell.textLabel.textAlignment = item.titleAlignment;

        [self addSeparatorToCell:cell item:item];
    }

    cell.textLabel.text = item.title;
}

- (void)configureDefaultCell:(PBListCell *)cell
                    withItem:(PBListViewItem *)item {

    if (cell.tag != kPBListDefaultTag) {

        cell.tag = kPBListDefaultTag;

        cell.titleLabel.textColor =
        item.titleColor != nil ? item.titleColor : self.titleColor;

        cell.valueLabel.textColor =
        item.valueColor != nil ? item.valueColor : self.valueColor;

        cell.titleLabel.font =
        item.titleFont != nil ? item.titleFont : self.titleFont;

        cell.valueLabel.font =
        item.valueFont != nil ? item.valueFont : self.valueFont;

        cell.backgroundColor =
        item.backgroundColor != nil ? item.backgroundColor : self.cellBackgroundColor;

        cell.selectionStyle = item.selectionStyle;

        cell.titleLabel.textAlignment = item.titleAlignment;

        if (item.hasDisclosure) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }


        [self addSeparatorToCell:cell item:item];
    }

    cell.titleLabel.text = item.title;
    cell.valueLabel.text = item.value;
}

#pragma mark -
#pragma mark UITableViewDataSource Conformance

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

    PBListViewItem *item = [self itemAtIndexPath:indexPath];
    return item.isDeletable;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    PBListViewItem *item = [self itemAtIndexPath:indexPath];

    UITableViewCell *cell;

    switch (item.listType) {

        case PBListTypeAction: {

            cell = [tableView dequeueReusableCellWithIdentifier:kPBListActionCellID];
            [self configureActionCell:cell withItem:item];

        } break;

        case PBListTypeSpacer: {

            cell = [tableView dequeueReusableCellWithIdentifier:kPBListSpacerCellID];
            [self configureActionCell:cell withItem:item];

        } break;

        default: {

            cell = [tableView dequeueReusableCellWithIdentifier:kPBListCellID];
            [self configureDefaultCell:(id)cell withItem:item];
            
        } break;
    }

    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate Conformance

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {

        PBListViewItem *item = [self itemAtIndexPath:indexPath];
        item.deleteActionBlock(self);
        [tableView setEditing:NO animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    PBListViewItem *item = [self itemAtIndexPath:indexPath];
    return item.rowHeight;
}

@end
