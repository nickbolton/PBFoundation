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

    BOOL _sectioned;
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

    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    UINib *nib =
    [UINib
     nibWithNibName:NSStringFromClass([PBListCell class])
     bundle:nil];

    [self.tableView
     registerNib:nib
     forCellReuseIdentifier:kPBListCellID];

    [self.tableView
     registerClass:[PBListViewDefaultCell class]
     forCellReuseIdentifier:kPBListSpacerCellID];

    [self.tableView
     registerClass:[PBListViewDefaultCell class]
     forCellReuseIdentifier:kPBListActionCellID];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationBar];
    [self setupNotifications];
    [self setupTableView];

    self.tableView.backgroundColor = self.tableBackgroundColor;

    [self reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    self.tableView.editing = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Getters and Setters

- (void)setDataSource:(NSArray *)dataSource {
    _dataSource = dataSource;
    _sectioned = [dataSource.firstObject isKindOfClass:[NSArray class]];
}

#pragma mark - Actions

#pragma mark -

- (NSArray *)rowArrayAtSection:(NSInteger)section {

    if (_sectioned) {

        if (section < self.dataSource.count) {
            return self.dataSource[section];
        }

        return nil;
    }

    return self.dataSource;
}

- (PBListViewItem *)itemAtIndexPath:(NSIndexPath *)indexPath {

    NSArray *rowArray = [self rowArrayAtSection:indexPath.section];
    return [self itemAtRow:indexPath.row inRowArray:rowArray];
}

- (PBListViewItem *)itemAtRow:(NSInteger)row inRowArray:(NSArray *)rowArray {

    PBListViewItem *item = nil;

    if (row < rowArray.count) {
        item = rowArray[row];

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

    if (_sectioned) {

        for (NSArray *section in self.dataSource) {
            [self reloadDataSourceSection:section];
        }

    } else {

        [self reloadDataSourceSection:self.dataSource];
    }
}

- (void)reloadDataSourceSection:(NSArray *)sectionArray {

    for (PBListViewItem *item in sectionArray) {

        if (item.itemType == PBItemTypeCustom) {

            NSAssert(item.cellID != nil, @"No cellID configured");
            NSAssert(item.cellNib != nil || item.cellClass != nil, @"No cellNib or cellClass configured");

            if (item.cellNib != nil) {

                [self.tableView
                 registerNib:item.cellNib
                 forCellReuseIdentifier:item.cellID];

                NSArray *views =
                [item.cellNib instantiateWithOwner:self options:nil];

                if (views.count > 0) {
                    UIView *cell = views[0];

                    item.rowHeight = CGRectGetHeight(cell.frame);
                }

            } else {

                [self.tableView
                 registerClass:item.cellClass
                 forCellReuseIdentifier:item.cellID];
            }
        }
    }
}

- (void)reloadData {
    [self reloadDataSource];

    if (_sectioned) {

        for (NSArray *section in self.dataSource) {
            [self clearSectionConfigured:section];
        }

    } else {

        [self clearSectionConfigured:self.dataSource];
    }

    [self.tableView reloadData];
}

- (void)clearSectionConfigured:(NSArray *)sectionArray {

    for (PBListViewItem *item in sectionArray) {
        item.itemConfigured = NO;
    }
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
    
    NSArray *rowArray = [self rowArrayAtSection:section];
    return rowArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    if (_sectioned) {
        return self.dataSource.count;
    }

    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    PBListViewItem *item = [self itemAtIndexPath:indexPath];

    UITableViewCell *cell;

    switch (item.itemType) {

        case PBItemTypeAction: {

            cell = [tableView dequeueReusableCellWithIdentifier:kPBListActionCellID];
            [self configureActionCell:cell withItem:item];

        } break;

        case PBItemTypeSpacer: {

            cell = [tableView dequeueReusableCellWithIdentifier:kPBListSpacerCellID];
            [self configureActionCell:cell withItem:item];

        } break;

        case PBItemTypeCustom: {

            cell = [tableView dequeueReusableCellWithIdentifier:item.cellID];
            
            if (item.configureBlock != nil && item.itemConfigured == NO) {

                item.configureBlock(self, item, cell);
                item.itemConfigured = YES;
            }

            NSAssert(item.bindingBlock != nil, @"No binding block!");

            item.bindingBlock(self, indexPath, item, cell);

        } break;

        default: {

            cell = [tableView dequeueReusableCellWithIdentifier:kPBListCellID];
            [self configureDefaultCell:(id)cell withItem:item];
            
        } break;
    }

    if ([cell isKindOfClass:[PBListViewDefaultCell class]]) {
        ((PBListViewDefaultCell *)cell).item = item;
    }

    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate Conformance

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    PBListViewItem *item = [self itemAtIndexPath:indexPath];

    if (item.selectActionBlock != nil) {
        item.selectActionBlock(self);
    }
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    PBListViewItem *item = [self itemAtIndexPath:indexPath];

    if (item != nil && tableView.style == UITableViewStyleGrouped && [cell respondsToSelector:@selector(tintColor)]) {
        if (tableView == self.tableView) {
            CGFloat cornerRadius = 4.f;
            cell.backgroundColor = UIColor.clearColor;
            CAShapeLayer *layer = [[CAShapeLayer alloc] init];
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGRect bounds = CGRectInset(cell.bounds, 10, 0);
            BOOL addLine = NO;
            if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
                CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
            } else if (indexPath.row == 0) {
                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
                addLine = YES;
            } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
            } else {
                CGPathAddRect(pathRef, nil, bounds);
                addLine = YES;
            }
            layer.path = pathRef;
            CFRelease(pathRef);
            layer.fillColor = item.backgroundColor.CGColor;

            if (addLine == YES) {
                CALayer *lineLayer = [[CALayer alloc] init];
                CGFloat lineHeight = (1.f / [UIScreen mainScreen].scale);
                lineLayer.frame = CGRectMake(CGRectGetMinX(bounds)+10, bounds.size.height-lineHeight, bounds.size.width-10, lineHeight);
                lineLayer.backgroundColor = tableView.separatorColor.CGColor;
                [layer addSublayer:lineLayer];
            }
            UIView *testView = [[UIView alloc] initWithFrame:bounds];
            [testView.layer insertSublayer:layer atIndex:0];
            testView.backgroundColor = UIColor.clearColor;
            cell.backgroundView = testView;
        }
    }
}

@end
