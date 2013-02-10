//
//  PBListView.m
//  PBListView
//
//  Created by Nick Bolton on 2/4/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBListView.h"
#import "PBListViewUIElementMeta.h"
#import "PBListViewUIElementBinder.h"
#import "PBListViewConfig.h"

@interface PBListView() <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, strong) NSTreeController *treeController;
@property (nonatomic, readonly) NSArray *sourceArray;
@property (nonatomic, strong) NSMutableDictionary *uiElementRegistry;

@property (nonatomic, strong) NSTableRowView *firstRowView;
@property (nonatomic, strong) NSTableCellView *firstCellView;

@end

@implementation PBListView

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.uiElementRegistry = [NSMutableDictionary dictionary];
}

- (void)awakeFromNib {
    [super awakeFromNib];

    self.delegate = self;
    self.dataSource = self;
    self.allowsColumnReordering = NO;
    self.allowsColumnResizing = YES;
    self.allowsMultipleSelection = YES;
    self.allowsEmptySelection = YES;
    self.allowsColumnSelection = NO;
    self.intercellSpacing = NSZeroSize;
    self.backgroundColor = [NSColor clearColor];
    self.usesAlternatingRowBackgroundColors = NO;
    self.selectionHighlightStyle = NSTableViewSelectionHighlightStyleNone;
    self.gridColor = [NSColor clearColor];
    self.gridStyleMask = NSTableViewGridNone;
    self.headerView = nil;
    self.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;

    [self.tableColumns
     enumerateObjectsWithOptions:NSEnumerationReverse
     usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
         NSTableColumn *column = obj;
         if (idx > 0) {
             [self removeTableColumn:column];
         } else {
             column.resizingMask = NSTableColumnAutoresizingMask;
             column.width = NSWidth(self.frame);
         }
     }];

    NSSize minSize = [[PBListViewConfig sharedInstance] minSize];
    NSSize maxSize = [[PBListViewConfig sharedInstance] maxSize];

    NSScrollView *scrollView = [self findFirstParentOfType:[NSScrollView class]];

    if (scrollView != nil) {
        [NSLayoutConstraint
         addMinWidthConstraint:minSize.width
         maxWidthConstraint:maxSize.width
         toView:scrollView];
        [NSLayoutConstraint
         addMinHeightConstraint:minSize.height
         maxHeightConstraint:maxSize.height
         toView:scrollView];
    }
}

- (void)visualizeConstraints {
//    NSLog(@"rowView: %@ - %@ - %@", NSStringFromRect(_firstCellView.frame), _firstCellView, _firstCellView.constraints);
//    [self.window visualizeConstraints:[_firstRowView constraints]];
}

#pragma mark - Getters and Setters

- (void)setParentEntityType:(Class)parentEntityType {
    _parentEntityType = parentEntityType;
}

- (void)setStaticEntities:(NSArray *)staticEntities {
    _staticEntities = staticEntities;
}

- (NSImage *)backgroundImageForRow:(NSInteger)row {

    NSImage *image = nil;
    id entity = [self entityAtRow:row];

    if (entity != nil) {

        NSArray *sourceArray = self.sourceArray;
        PBListViewPositionType position;

        if (sourceArray.count == 1) {
            position = PBListViewPositionTypeOnly;
        } else if (row == 0) {
            position = PBListViewPositionTypeFirst;
        } else if (row < sourceArray.count - 1) {
            position = PBListViewPositionTypeMiddle;
        } else {
            position = PBListViewPositionTypeLast;
        }

        image = [[PBListViewConfig sharedInstance]
                 backgroundImageForEntityType:[entity class]
                 atPosition:position];
    }

    return image;
}

#pragma mark - UI Element registering

- (NSMutableArray *)registeredUIElementsForEntity:(Class)entityType {

    NSString *key = NSStringFromClass(entityType);
    
    NSMutableArray *registeredElements =
    [_uiElementRegistry objectForKey:key];

    if (registeredElements == nil) {
        registeredElements = [NSMutableArray array];
        [_uiElementRegistry setObject:registeredElements forKey:key];
    }

    return registeredElements;
}

- (void)registerUIElementMeta:(PBListViewUIElementMeta *)meta {

    if (meta != nil) {
        NSAssert(meta.entityType != nil, @"Meta is missing entityType");

        NSMutableArray *registeredElements =
        [self registeredUIElementsForEntity:meta.entityType];
        [registeredElements addObject:meta];
    }
}

#pragma mark - Entity getting

- (NSArray *)sourceArray {
    if (_staticEntities != nil) {
        return _staticEntities;
    }
    return (NSArray *)_treeController.arrangedObjects;
}

- (id)entityAtRow:(NSInteger)row {

    NSArray *sourceArray = self.sourceArray;

    if (row < sourceArray.count) {
        return [sourceArray objectAtIndex:row];
    }

    return nil;
}

#pragma mark - Cell/Row builders

- (NSTableRowView *)buildRowViewForEntity:(id)entity
                                    atRow:(NSInteger)row
                        withTotalEntities:(NSInteger)count {

    NSRect frame = NSMakeRect(0.0f, 0.0f, NSWidth(self.frame), self.rowHeight);
    NSTableRowView *rowView = [[NSTableRowView alloc] initWithFrame:frame];
    rowView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;

    NSImage *backgroundImage =
    [self backgroundImageForRow:row];

    if (backgroundImage != nil) {
        NSRect backgroundImageFrame = frame;
        backgroundImageFrame.size.height = backgroundImage.size.height;
        NSImageView *imageView =
        [[NSImageView alloc] initWithFrame:backgroundImageFrame];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        imageView.image = backgroundImage;
        imageView.imageScaling = NSImageScaleAxesIndependently;
        imageView.imageAlignment = NSImageAlignCenter;

        [rowView addSubview:imageView];

        [NSLayoutConstraint expandToSuperview:imageView];
    }

    NSColor *dividerLineColor =
    [[PBListViewConfig sharedInstance] rowDividerLineColor];
    
    if (row > 0 && dividerLineColor != nil) {

        CGFloat lineHeight = 
        [[PBListViewConfig sharedInstance] rowDividerLineHeight];

        NSRect topLineFrame = frame;
        topLineFrame.size.height = lineHeight;
        NSTextField *topLine = [[NSTextField alloc] initWithFrame:topLineFrame];
        topLine.drawsBackground = YES;
        topLine.translatesAutoresizingMaskIntoConstraints = NO;
        topLine.backgroundColor = dividerLineColor;
        topLine.bordered = NO;

        [rowView addSubview:topLine];

        [NSLayoutConstraint alignToTop:topLine];
        [NSLayoutConstraint expandWidthToSuperview:topLine];
        [NSLayoutConstraint addHeightConstraint:lineHeight toView:topLine];
    }

    return rowView;
}

- (NSTableCellView *)buildCellViewForEntity:(id)entity
                                      atRow:(NSInteger)row {

    NSRect frame = NSMakeRect(0.0f, 0.0f, NSWidth(self.frame), self.rowHeight);
    NSTableCellView *cellView = [[NSTableCellView alloc] initWithFrame:frame];
    cellView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;

    NSArray *subviews = [cellView.subviews copy];
    for (NSView *view in subviews) {
        [view removeFromSuperview];
    }

    NSArray *metaList = [self registeredUIElementsForEntity:[entity class]];
    NSMutableArray *views = [NSMutableArray arrayWithCapacity:metaList.count];

    for (PBListViewUIElementMeta *meta in metaList) {

        NSView *view = [meta.binder buildUIElement];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [cellView addSubview:view];

        [views addObject:view];
    }

    [views enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PBListViewUIElementMeta *meta = metaList[idx];
        [meta.binder
         configureView:self
         views:views
         metaList:metaList
         atIndex:idx];
    }];

    return cellView;
}

#pragma mark - Key Handling

- (void)keyDown:(NSEvent *)event {
    [super keyDown:event];
}

- (void)keyUp:(NSEvent *)event {
    [super keyUp:event];
}

#pragma mark - NSTableViewDataSource/Delegate Conformance

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.sourceArray.count;
}

- (id)tableView:(NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(NSInteger)row {
    return [self entityAtRow:row];
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {

    NSTableCellView *cellView = nil;
    id entity = [self entityAtRow:row];

    if (entity != nil) {

        NSString *reuseKey =
        [NSString stringWithFormat:@"%@-%ld/%ld",
         NSStringFromClass([entity class]),
         (long)row,
         (unsigned long)self.sourceArray.count];

        cellView =
        [tableView
         makeViewWithIdentifier:reuseKey
         owner:self];

        if (cellView == nil) {
            cellView =
            [self
             buildCellViewForEntity:entity
             atRow:row];
            cellView.identifier = reuseKey;
        }

        cellView.objectValue = entity;

        NSInteger uiElementIndex = 0;
        for (PBListViewUIElementMeta *meta in [self registeredUIElementsForEntity:[entity class]]) {
            NSView *uiElement =
            [cellView.subviews objectAtIndex:uiElementIndex];
            [meta.binder bindEntity:entity withView:uiElement atRow:row usingMeta:meta];
            uiElementIndex++;
        }
    }

    if (self.firstCellView == nil) {
        self.firstCellView = cellView;
    }
    
    return cellView;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView
                rowViewForRow:(NSInteger)row {

    NSTableRowView *rowView = nil;
    id entity = [self entityAtRow:row];

    if (entity != nil) {

        NSString *reuseKey =
        [NSString stringWithFormat:@"ROW%@-%ld/%ld",
         NSStringFromClass([entity class]),
         (long)row,
         (unsigned long)self.sourceArray.count];

        rowView =
        [tableView
         makeViewWithIdentifier:reuseKey
         owner:self];

        if (rowView == nil) {
            rowView =
            [self
             buildRowViewForEntity:entity
             atRow:row
             withTotalEntities:self.sourceArray.count];
        }
    }

    if (self.firstRowView == nil) {
        self.firstRowView = rowView;
    }

    return rowView;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {

    CGFloat rowHeight = 0;

    id entity = [self entityAtRow:row];

    if (entity != nil) {

        NSImage *backgroundImage =
        [self backgroundImageForRow:row];

        if (backgroundImage != nil) {
            rowHeight = backgroundImage.size.height;
        } else {
            rowHeight =
            [[PBListViewConfig sharedInstance]
             rowHeightForEntityType:[entity class]];
        }
    }

    if (rowHeight == 0) {
        rowHeight = self.rowHeight;
    }

    return rowHeight;
}

@end
