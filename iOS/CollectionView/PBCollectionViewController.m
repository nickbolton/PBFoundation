//
//  PBCollectionViewController.m
//  PBFoundation
//
//  Created by Nick Bolton on 11/12/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBCollectionViewController.h"
#import "PBCollectionLayout.h"
#import "PBCollectionItem.h"
#import "PBCollectionDefaultCell.h"

NSString * const kPBCollectionViewCellKind = @"kPBCollectionViewCellKind";
NSString * const kPBCollectionViewSupplimentaryKind = @"kPBCollectionViewSupplimentaryKind";
NSString * const kPBCollectionViewDecorationKind = @"kPBCollectionViewDecorationKind";

@interface PBCollectionViewController () {
}

@property (nonatomic, strong) IBOutlet PBCollectionLayout *collectionLayout;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeGesture;
@property (nonatomic, strong) NSArray *selectedItemIndexes;
@property (nonatomic, strong) PBCollectionItem *selectAllItem;
@property (nonatomic, getter = isSectioned, readwrite) BOOL sectioned;

@end

@implementation PBCollectionViewController

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

    if (self.collectionView.allowsMultipleSelection) {

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

- (void)createCollectionViewIfNecessary {

    if (self.collectionView == nil) {
        self.collectionView = [[UICollectionView alloc] init];
        self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;

        [self.view addSubview:self.collectionView];
        [NSLayoutConstraint expandToSuperview:self.collectionView];
    }
}

- (void)setupCollectionView {

    self.collectionLayout = [[PBCollectionLayout alloc] init];
    self.collectionView.collectionViewLayout = self.collectionLayout;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionLayout.viewController = self;

    if (self.collectionBackgroundColor != nil) {
        self.collectionView.backgroundColor = self.collectionBackgroundColor;
    } else {
        self.collectionView.backgroundColor = [UIColor clearColor];
    }
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.backgroundColor != nil) {
        self.view.backgroundColor = self.backgroundColor;
    } else {
        self.view.backgroundColor = [UIColor clearColor];
    }

    [self createCollectionViewIfNecessary];
    [self setupNavigationBar];
    [self setupNotifications];
    [self setupCollectionView];

    if (self.reloadDataOnViewLoad) {
        [self reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (void)cancelPressed:(id)sender {

    if (self.navigationController != nil && self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Keyboard Handling

- (void)keyboardWillShow:(NSNotification *)notification {

    self.swipeGesture =
    [[UISwipeGestureRecognizer alloc]
     initWithTarget:self action:@selector(dismissKeyboard:)];

    self.collectionView.scrollEnabled = NO;
    self.swipeGesture.direction = UISwipeGestureRecognizerDirectionDown;
    [self.collectionView addGestureRecognizer:self.swipeGesture];
}

- (void)keyboardWillHide:(NSNotification *)notification {

    [self.collectionView removeGestureRecognizer:self.swipeGesture];
    self.swipeGesture = nil;
    self.collectionView.scrollEnabled = YES;
}

- (void)dismissKeyboard:(UISwipeGestureRecognizer *)gesture {

    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self dismissKeyboard];
    }
}

- (void)dismissKeyboard {
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

            for (PBCollectionItem *item in rowArray) {

                if (item.isSelected) {

                    NSIndexPath *indexPath =
                    [NSIndexPath indexPathForRow:row inSection:section];

                    [selectedIndexes addObject:indexPath];
                }

                if ([item.supplimentaryItem.kind isEqualToString:kPBCollectionViewSupplimentaryKind]) {
                    [self.collectionView
                     registerClass:[PBCollectionDefaultCell class]
                     forSupplementaryViewOfKind:kPBCollectionViewSupplimentaryKind
                     withReuseIdentifier:item.supplimentaryItem.reuseIdentifier];

                    if (item.supplimentaryItem.backgroundImage != nil) {
                        item.supplimentaryItem.size = item.supplimentaryItem.backgroundImage.size;
                    }
                }

                if ([item.decorationItem.kind isEqualToString:kPBCollectionViewDecorationKind]) {
                    [self.collectionView
                     registerClass:[PBCollectionDefaultCell class]
                     forSupplementaryViewOfKind:kPBCollectionViewDecorationKind
                     withReuseIdentifier:item.decorationItem.reuseIdentifier];

                    if (item.decorationItem.backgroundImage != nil) {
                        item.decorationItem.size = item.decorationItem.backgroundImage.size;
                    }
                }

                if (item.backgroundImage != nil) {
                    item.size = item.backgroundImage.size;
                }

                row++;
            }

            section++;
        }

    } else {

        NSInteger row = 0;

        for (PBCollectionItem *item in self.dataSource) {

            if (item.isSelected) {

                NSIndexPath *indexPath =
                [NSIndexPath indexPathForRow:row inSection:0];
                
                [selectedIndexes addObject:indexPath];
            }

            if ([item.supplimentaryItem.kind isEqualToString:kPBCollectionViewSupplimentaryKind]) {
                [self.collectionView
                 registerClass:[PBCollectionDefaultCell class]
                 forSupplementaryViewOfKind:kPBCollectionViewSupplimentaryKind
                 withReuseIdentifier:item.supplimentaryItem.reuseIdentifier];

                if (item.supplimentaryItem.backgroundImage != nil) {
                    item.supplimentaryItem.size = item.supplimentaryItem.backgroundImage.size;
                }
            }

            if ([item.decorationItem.kind isEqualToString:kPBCollectionViewDecorationKind]) {
                [self.collectionView
                 registerClass:[PBCollectionDefaultCell class]
                 forSupplementaryViewOfKind:kPBCollectionViewDecorationKind
                 withReuseIdentifier:item.decorationItem.reuseIdentifier];

                if (item.decorationItem.backgroundImage != nil) {
                    item.decorationItem.size = item.decorationItem.backgroundImage.size;
                }
            }

            if (item.backgroundImage != nil) {
                item.size = item.backgroundImage.size;
            }

            row++;
        }
    }

    self.selectedItemIndexes = selectedIndexes;

    [self.collectionLayout invalidateLayout];
}

#pragma mark - 


- (void)selectItems:(NSArray *)items inSection:(NSInteger)section {

    for (PBCollectionItem *item in items) {

        NSArray *rowArray = [self rowArrayAtSection:section];

        NSInteger index =
        [rowArray indexOfObject:item];

        NSIndexPath *indexPath =
        [NSIndexPath indexPathForRow:index inSection:section];

        [self.collectionView
         selectItemAtIndexPath:indexPath
         animated:YES
         scrollPosition:item.scrollPosition];

        index++;
    }
}

- (void)deselectItems:(NSArray *)items inSection:(NSInteger)section {

    for (PBCollectionItem *item in items) {

        NSArray *rowArray = [self rowArrayAtSection:section];

        NSInteger index =
        [rowArray indexOfObject:item];

        NSIndexPath *indexPath =
        [NSIndexPath indexPathForRow:index inSection:section];

        [self.collectionView
         deselectItemAtIndexPath:indexPath
         animated:YES];

        index++;
    }
}

- (void)delselectOtherItems:(PBCollectionItem *)targetItem inSection:(NSInteger)section {

    NSMutableArray *items = [NSMutableArray array];

    for (PBCollectionItem *item in [self rowArrayAtSection:section]) {

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

- (PBCollectionItem *)itemAtIndexPath:(NSIndexPath *)indexPath {

    NSArray *rowArray = [self rowArrayAtSection:indexPath.section];
    return [self itemAtPosition:indexPath.row inRowArray:rowArray];
}

- (PBCollectionItem *)itemAtPosition:(NSInteger)position inRowArray:(NSArray *)rowArray {

    PBCollectionItem *item = nil;

    if (position < rowArray.count) {
        item = rowArray[position];

        NSAssert([item isKindOfClass:[PBCollectionItem class]],
                 @"item not a PBListViewItem");
    }

    return item;
}

- (void)reloadCollectionItem:(PBCollectionItem *)item {

    if (item != nil) {
        [self.collectionView reloadItemsAtIndexPaths:@[item.indexPath]];
    }
}

- (void)reloadCollectionItemAtIndexPath:(NSIndexPath *)indexPath {

    PBCollectionItem *item = [self itemAtIndexPath:indexPath];

    if (item != nil) {
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    }
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

    for (PBCollectionItem *item in sectionArray) {

        NSAssert(item.reuseIdentifier != nil, @"No reuseIdentifier configured");
        NSAssert(item.cellNib != nil, @"No cellNib configured");

        [self.collectionView
         registerNib:item.cellNib
         forCellWithReuseIdentifier:item.reuseIdentifier];

        NSArray *views =
        [item.cellNib instantiateWithOwner:self options:nil];

        if (views.count > 0) {
            UIView *cell = views[0];
            item.size = cell.frame.size;
        }

        if (item.selectAllItem) {

            NSAssert(self.selectAllItem == nil,
                     @"Multiple select all items are configured.");
            self.collectionView.allowsMultipleSelection = YES;
            self.selectAllItem = item;
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

    [self.collectionView reloadData];

    [self setSelectionDisabled:YES forItemIndexes:self.selectedItemIndexes];

    for (NSIndexPath *indexPath in self.selectedItemIndexes) {

        [self.collectionView
         selectItemAtIndexPath:indexPath
         animated:NO
         scrollPosition:UICollectionViewScrollPositionNone];
    }
}

- (void)setSelectionDisabled:(BOOL)selectionDisabled
              forItemIndexes:(NSArray *)itemIndexes {

    for (NSIndexPath *indexPath in itemIndexes) {

        NSArray *rowArray = [self rowArrayAtSection:indexPath.section];
        
        if (indexPath.row < rowArray.count) {
            PBCollectionItem *item = rowArray[indexPath.row];
            item.selectionDisabled = selectionDisabled;
        }
    }
}

- (void)clearSectionConfigured:(NSArray *)sectionArray {
    
    for (PBCollectionItem *item in sectionArray) {
        item.itemConfigured = NO;
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    if (_sectioned) {
        return self.dataSource.count;
    }

    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {

    NSArray *rowArray = [self rowArrayAtSection:section];
    return rowArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    PBCollectionItem *item = [self itemAtIndexPath:indexPath];
    item.indexPath = indexPath;

    UICollectionViewCell *cell =
    [collectionView
     dequeueReusableCellWithReuseIdentifier:item.reuseIdentifier
     forIndexPath:indexPath];

    NSAssert([cell isKindOfClass:[PBCollectionDefaultCell class]],
             @"custom cells must extend from PBCollectionDefaultCell");

    PBCollectionDefaultCell *defaultCell = (id)cell;

    if (item.configureBlock != nil &&
        (defaultCell.cellConfigured == NO ||
         item.itemConfigured == NO)) {

        item.configureBlock(self, item, cell);
        defaultCell.cellConfigured = YES;
        item.itemConfigured = YES;
    }

    NSAssert(item.bindingBlock != nil, @"No binding block!");

    if ([cell isKindOfClass:[PBCollectionDefaultCell class]]) {
        ((PBCollectionDefaultCell *)cell).item = item;
        ((PBCollectionDefaultCell *)cell).indexPath = indexPath;
        ((PBCollectionDefaultCell *)cell).viewController = self;
    }

    item.bindingBlock(self, indexPath, item, cell);

    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {

    PBCollectionItem *item = [self itemAtIndexPath:indexPath];


    if ([item.supplimentaryItem.kind isEqualToString:kind]) {
        item = item.supplimentaryItem;
    } else if ([item.decorationItem.kind isEqualToString:kind]) {
        item = item.decorationItem;
    } else {
        NSAssert(NO, @"No PBCollectionItem supplimentaryItem or decorationItem specified");
    }

    UICollectionViewCell *cell =
    [collectionView
     dequeueReusableSupplementaryViewOfKind:kind
     withReuseIdentifier:item.reuseIdentifier
     forIndexPath:indexPath];

    NSAssert([cell isKindOfClass:[PBCollectionDefaultCell class]],
             @"custom cells must extend from PBCollectionDefaultCell");

    PBCollectionDefaultCell *defaultCell = (id)cell;

    if (item.configureBlock != nil &&
        (defaultCell.cellConfigured == NO ||
         item.itemConfigured == NO)) {

            item.configureBlock(self, item, cell);
            defaultCell.cellConfigured = YES;
            item.itemConfigured = YES;

        }

    if ([cell isKindOfClass:[PBCollectionDefaultCell class]]) {
        ((PBCollectionDefaultCell *)cell).item = item;
        ((PBCollectionDefaultCell *)cell).indexPath = indexPath;
        ((PBCollectionDefaultCell *)cell).viewController = self;
        ((PBCollectionDefaultCell *)cell).backgroundImageView.image = item.backgroundImage;
    }

    if (item.bindingBlock != nil) {
        item.bindingBlock(self, indexPath, item, cell);
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    if (collectionView.allowsMultipleSelection == NO) {
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    }

    PBCollectionItem *item = [self itemAtIndexPath:indexPath];

    if (item == self.selectAllItem) {

        [self
         delselectOtherItems:self.selectAllItem
         inSection:indexPath.section];

    } else if (self.selectAllItem != nil) {

        NSInteger selectionCount = 0;

        for (PBCollectionItem *item in [self rowArrayAtSection:indexPath.section]) {

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

        for (PBCollectionItem *item in [self rowArrayAtSection:indexPath.section]) {

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

    PBCollectionItem *item = [self itemAtIndexPath:indexPath];

    if (item != nil) {

        if (item.isSelected) {

            if (item.isDeselectable == NO) {
                return nil;
            }

            if (tableView.allowsMultipleSelection == NO) {

                PBCollectionDefaultCell *cell =
                (id)[tableView cellForRowAtIndexPath:indexPath];

                if ([cell isKindOfClass:[PBCollectionDefaultCell class]]) {
                    [cell updateForSelectedState];
                    return nil;
                }
            }
        }
    }

    return indexPath;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {

    PBCollectionItem *item = [self itemAtIndexPath:indexPath];
    
    if (item != nil &&
        item.isSelected &&
        item.isDeselectable == NO) {
        return nil;
    }
    
    return indexPath;
}

@end
