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
#import "PBTitleCell.h"

NSString * const kPBListCellID = @"default-cell-id";
NSString * const kPBListSpacerCellID = @"spacer-cell-id";
NSString * const kPBListActionCellID = @"action-cell-id";
NSString * const kPBListTitleCellID = @"title-cell-id";

static NSInteger const kPBListSeparatorCellTag = 98;
static NSInteger const kPBListSeparatorTag = 99;
static NSInteger const kPBListActionTag = 101;
static NSInteger const kPBListCheckedTag = 103;
static NSInteger const kPBListDefaultTag = 105;

@interface PBListViewController () <UITableViewDataSource, UITableViewDelegate> {

    BOOL _sectioned;
    BOOL _createTable;
}

@property (nonatomic, strong) PBListViewItem *selectAllItem;
@property (nonatomic, strong) NSArray *selectedRowIndexes;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeGesture;

@end

@implementation PBListViewController

- (id)initWithNib {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        self.reloadDataOnViewLoad = YES;
    }
    return self;
}

- (id)initWithItems:(NSArray *)items {

    self = [super init];
    if (self) {
        self.dataSource = items;
        self.reloadDataOnViewLoad = YES;
        _createTable = YES;
    }
    return self;
}

- (id)init {
    return [self initWithItems:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Setup

- (void)setupNotifications {

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillHide:)
     name:UIKeyboardWillHideNotification
     object:nil];

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillShow:)
     name:UIKeyboardWillShowNotification
     object:nil];
}

- (void)setupNavigationBar {

    if (self.hasCancelNavigationBarItem) {

        UIBarButtonItem *cancelItem =
        [[UIBarButtonItem alloc]
         initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
         target:self
         action:@selector(cancelPressed:)];

        self.navigationItem.leftBarButtonItem = cancelItem;
    }

    if (self.isMultiSelect || self.tableView.allowsMultipleSelection) {

        if (self.doneTarget != nil &&
            self.doneSelector != nil) {

            UIBarButtonItem *doneItem =
            [[UIBarButtonItem alloc]
             initWithBarButtonSystemItem:UIBarButtonSystemItemDone
             target:self.doneTarget
             action:self.doneSelector];

            self.navigationItem.rightBarButtonItem = doneItem;

        } else if (self.dismissOnDone) {

            UIBarButtonItem *doneItem =
            [[UIBarButtonItem alloc]
             initWithBarButtonSystemItem:UIBarButtonSystemItemDone
             target:self
             action:@selector(cancelPressed:)];

            self.navigationItem.rightBarButtonItem = doneItem;
        }
    }
}

- (void)createTableViewIfNecessary {

    if (self.tableView == nil) {
        self.tableView = [[UITableView alloc] init];
        self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;

        [self.view addSubview:self.tableView];
        [NSLayoutConstraint expandToSuperview:self.tableView];
    }
}

- (void)setupTableView {

    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

    UINib *nib =
    [UINib
     nibWithNibName:NSStringFromClass([PBListCell class])
     bundle:nil];

    UINib *titleNib =
    [UINib
     nibWithNibName:NSStringFromClass([PBTitleCell class])
     bundle:nil];

    [self.tableView
     registerNib:nib
     forCellReuseIdentifier:kPBListCellID];

    [self.tableView
     registerNib:titleNib
     forCellReuseIdentifier:kPBListTitleCellID];

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

    if (self.backgroundColor != nil) {
        self.view.backgroundColor = self.backgroundColor;
    } else {
        self.view.backgroundColor = [UIColor clearColor];
    }

    [self createTableViewIfNecessary];
    [self setupNavigationBar];
    [self setupNotifications];
    [self setupTableView];

    if (self.tableBackgroundColor != nil) {
        self.tableView.backgroundColor = self.tableBackgroundColor;
    } else {
        self.tableView.backgroundColor = [UIColor clearColor];
    }

    if (self.reloadDataOnViewLoad) {
        [self reloadData];
    }
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

    NSMutableArray *selectedIndexes = [NSMutableArray array];

    if (_sectioned) {

        NSInteger section = 0;

        for (NSArray *rowArray in self.dataSource) {

            NSInteger row = 0;

            for (PBListViewItem *item in rowArray) {

                if (item.isSelected) {

                    NSIndexPath *indexPath =
                    [NSIndexPath indexPathForRow:row inSection:section];

                    [selectedIndexes addObject:indexPath];
                }

                row++;
            }

            section++;
        }

    } else {

        NSInteger row = 0;

        for (PBListViewItem *item in self.dataSource) {

            if (item.isSelected) {

                NSIndexPath *indexPath =
                [NSIndexPath indexPathForRow:row inSection:0];

                [selectedIndexes addObject:indexPath];
            }

            row++;
        }
    }

    self.selectedRowIndexes = selectedIndexes;
}

#pragma mark - Actions

- (void)cancelPressed:(id)sender {

    if (self.navigationController != nil && self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark -

- (void)selectItems:(NSArray *)items inSection:(NSInteger)section {

    for (PBListViewItem *item in items) {

        NSArray *rowArray = [self rowArrayAtSection:section];

        NSInteger index =
        [rowArray indexOfObject:item];

        NSIndexPath *indexPath =
        [NSIndexPath indexPathForRow:index inSection:section];

        [self.tableView
         selectRowAtIndexPath:indexPath
         animated:YES
         scrollPosition:UITableViewScrollPositionNone];

        index++;
    }
}

- (void)deselectItems:(NSArray *)items inSection:(NSInteger)section {

    for (PBListViewItem *item in items) {

        NSArray *rowArray = [self rowArrayAtSection:section];

        NSInteger index =
        [rowArray indexOfObject:item];

        NSIndexPath *indexPath =
        [NSIndexPath indexPathForRow:index inSection:section];

        [self.tableView
         deselectRowAtIndexPath:indexPath
         animated:YES];

        index++;
    }
}

- (void)delselectOtherItems:(PBListViewItem *)targetItem inSection:(NSInteger)section {

    NSMutableArray *items = [NSMutableArray array];

    for (PBListViewItem *item in [self rowArrayAtSection:section]) {

        if (item != targetItem) {
            [items addObject:item];
        }
    }

    [self deselectItems:items inSection:section];
}

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

        } else if (item.itemType == PBItemTypeSelectAll) {

            self.selectAllItem = item;
            self.tableView.allowsMultipleSelection = YES;
        }
    }

    if (self.tableView.allowsMultipleSelection == NO && self.isMultiSelect) {
        self.tableView.allowsMultipleSelection = YES;
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

    [self setSelectionDisabled:YES forItemIndexes:self.selectedRowIndexes];

    for (NSIndexPath *indexPath in self.selectedRowIndexes) {

        [self.tableView
         selectRowAtIndexPath:indexPath
         animated:NO
         scrollPosition:UITableViewScrollPositionNone];
    }
}

- (void)setSelectionDisabled:(BOOL)selectionDisabled
                 forItemIndexes:(NSArray *)itemIndexes {

    for (NSIndexPath *indexPath in itemIndexes) {

        NSArray *rowArray = [self rowArrayAtSection:indexPath.section];

        if (indexPath.row < rowArray.count) {
            PBListViewItem *item = rowArray[indexPath.row];
            item.selectionDisabled = selectionDisabled;
        }
    }
}

- (void)clearSectionConfigured:(NSArray *)sectionArray {

    for (PBListViewItem *item in sectionArray) {
        item.itemConfigured = NO;
    }
}

//- (void)addSeparatorToCell:(UITableViewCell *)cell
//                      item:(PBListViewItem *)item {
//
//    UIView *separator = [cell viewWithTag:kPBListSeparatorTag];
//
//    if (separator == nil) {
//        separator = [[UIView alloc] init];
//        separator.backgroundColor = item.separatorColor;
//        separator.tag = kPBListSeparatorTag;
//        [cell addSubview:separator];
//    }
//
//    CGFloat scale = [[UIScreen mainScreen] scale];
//
//    CGFloat height = 1.0f / scale;
//
//    CGFloat width = 0.0f;
//
//    if (CGRectGetWidth(self.tableView.frame) > 0) {
//        width =
//        CGRectGetWidth(self.tableView.frame) -
//        item.separatorInsets.left -
//        item.separatorInsets.right;
//    }
//
//    CGRect frame =
//    CGRectMake(item.separatorInsets.left,
//               item.rowHeight-height,
//               width,
//               height);
//
//    separator.frame = frame;
//    separator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//}

- (void)configureSpacerCell:(UITableViewCell *)cell
                   withItem:(PBListViewItem *)item {

    if (cell.tag != kPBListSeparatorCellTag) {

        cell.tag = kPBListSeparatorCellTag;

        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    cell.separatorInset = item.separatorInsets;
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
    }

    cell.separatorInset = item.separatorInsets;
    cell.textLabel.text = item.title;
}

- (void)configureCheckedCell:(PBListCell *)cell
                    withItem:(PBListViewItem *)item {

    if (cell.tag != kPBListCheckedTag) {

        cell.tag = kPBListCheckedTag;

        cell.titleLabel.textColor =
        item.titleColor != nil ? item.titleColor : self.titleColor;

        cell.titleLabel.font =
        item.titleFont != nil ? item.titleFont : self.titleFont;

        cell.backgroundColor =
        item.backgroundColor != nil ? item.backgroundColor : self.cellBackgroundColor;

        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        cell.titleLabel.textAlignment = item.titleAlignment;
    }

    cell.titleLabel.text = item.title;
    cell.valueLabel.text = nil;
    cell.separatorInset = item.separatorInsets;

    if (item.isSelected) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
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

        if (item.hasDisclosure == NO) {

            CGRect frame = cell.valueLabel.frame;
            frame.origin.x -= item.valueMargin;
            cell.valueLabel.frame = frame;
        }
    }

    cell.separatorInset = item.separatorInsets;
    cell.titleLabel.text = item.title;
    cell.valueLabel.text = item.value;
}

#pragma mark - Keyboard Handling

- (void)keyboardWillShow:(NSNotification *)notification {

    self.swipeGesture =
    [[UISwipeGestureRecognizer alloc]
     initWithTarget:self action:@selector(dismissKeyboard:)];

    self.tableView.scrollEnabled = NO;
    self.swipeGesture.direction = UISwipeGestureRecognizerDirectionDown;
    [self.tableView addGestureRecognizer:self.swipeGesture];
}

- (void)keyboardWillHide:(NSNotification *)notification {

    [self.tableView removeGestureRecognizer:self.swipeGesture];
    self.swipeGesture = nil;
    self.tableView.scrollEnabled = YES;
}

- (void)dismissKeyboard:(UISwipeGestureRecognizer *)gesture {

    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self dismissKeyboard];
    }
}

- (void)dismissKeyboard {
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
    item.indexPath = indexPath;

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

            NSAssert([cell isKindOfClass:[PBListViewDefaultCell class]],
                     @"custom cells must extend from PBListViewDefaultCell");

            PBListViewDefaultCell *defaultCell = (id)cell;

            if (item.configureBlock != nil &&
                (defaultCell.cellConfigured == NO ||
                item.itemConfigured == NO)) {

                cell.selectionStyle = item.selectionStyle;
                cell.separatorInset = item.separatorInsets;

                item.configureBlock(self, item, cell);
                defaultCell.cellConfigured = YES;
                item.itemConfigured = YES;

            }

            NSAssert(item.bindingBlock != nil, @"No binding block!");

            item.bindingBlock(self, indexPath, item, cell);

        } break;

        case PBItemTypeTitle: {

            cell = [tableView dequeueReusableCellWithIdentifier:kPBListTitleCellID];
            [self configureDefaultCell:(id)cell withItem:item];

        } break;

        case PBItemTypeSelectAll:
        case PBItemTypeChecked: {

            cell = [tableView dequeueReusableCellWithIdentifier:kPBListCellID];
            [self configureCheckedCell:(id)cell withItem:item];

        } break;

        default: {

            cell = [tableView dequeueReusableCellWithIdentifier:kPBListCellID];
            [self configureDefaultCell:(id)cell withItem:item];
            
        } break;
    }

    if ([cell isKindOfClass:[PBListViewDefaultCell class]]) {
        ((PBListViewDefaultCell *)cell).item = item;
        ((PBListViewDefaultCell *)cell).viewController = self;
    }

    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate Conformance

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    PBListViewItem *item = [self itemAtIndexPath:indexPath];

    if (self.tableView.allowsMultipleSelection == NO) {

        if (item.itemType != PBItemTypeChecked && item.itemType != PBItemTypeSelectAll) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }

    if (item == self.selectAllItem) {

        [self
         delselectOtherItems:self.selectAllItem
         inSection:indexPath.section];

    } else if (self.selectAllItem != nil) {

        NSInteger selectionCount = 0;

        for (PBListViewItem *item in [self rowArrayAtSection:indexPath.section]) {

            if (item.isSelected) {
                selectionCount++;
            }
        }

        if (selectionCount == 0) {
            [self selectItems:@[self.selectAllItem] inSection:indexPath.section];
        } else {
            [self deselectItems:@[self.selectAllItem] inSection:indexPath.section];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (self.selectAllItem != nil) {

        NSInteger selectionCount = 0;

        for (PBListViewItem *item in [self rowArrayAtSection:indexPath.section]) {

            if (item.isSelected) {
                selectionCount++;
            }
        }

        if (selectionCount == 0) {
            [self selectItems:@[self.selectAllItem] inSection:indexPath.section];
        } else {
            [self deselectItems:@[self.selectAllItem] inSection:indexPath.section];
        }
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    PBListViewItem *item = [self itemAtIndexPath:indexPath];

    if (item != nil) {

        if (item.isSelected) {

            if (item.isDeselectable == NO) {
                return nil;
            }

            if (tableView.allowsMultipleSelection == NO) {

                PBListViewDefaultCell *cell =
                (id)[tableView cellForRowAtIndexPath:indexPath];

                if ([cell isKindOfClass:[PBListViewDefaultCell class]]) {
                    [cell updateForSelectedState];
                    return nil;
                }
            }
        }
    }

    return indexPath;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {

    PBListViewItem *item = [self itemAtIndexPath:indexPath];

    if (item != nil &&
        item.isSelected &&
        item.isDeselectable == NO) {
        return nil;
    }

    return indexPath;
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
