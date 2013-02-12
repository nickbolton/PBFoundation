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
#import "PBTableRowView.h"
#import "PBShadowTextFieldCell.h"
#import "PBEmptyConfiguration.h"

@interface PBListView() <NSTableViewDataSource, NSTableViewDelegate, PBTableRowDelegate> {

    BOOL _sizesSet;
}

@property (nonatomic, strong) NSTreeController *treeController;
@property (nonatomic, readonly) NSArray *sourceArray;
@property (nonatomic, readwrite) PBListViewConfig *listViewConfig;
@property (nonatomic, strong) NSIndexSet *previousSelection;
@property (nonatomic, strong) NSTrackingArea *trackingArea;
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
    self.previousSelection = [NSMutableIndexSet indexSet];
    self.listViewConfig = [[PBListViewConfig alloc] init];

    [_listViewConfig
     registerRowHeight:50.0f
     forEntityType:[PBEmptyConfiguration class]];

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

    NSScrollView *scrollView = [self findFirstParentOfType:[NSScrollView class]];
    scrollView.drawsBackground = NO;
    scrollView.borderType = NSNoBorder;

}

- (void)reloadData {
    if (_sizesSet == NO) {
        NSSize minSize = _listViewConfig.minSize;
        NSSize maxSize = _listViewConfig.maxSize;

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
        _sizesSet = YES;
    }

    [super reloadData];
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

        image = [_listViewConfig
                 backgroundImageForEntityType:[entity class]
                 atDepth:[entity listViewEntityDepth]
                 atPosition:position];
    }

    return image;
}

#pragma mark - Entity getting

- (NSArray *)sourceArray {
    if (_staticEntities != nil) {
        return _staticEntities;
    }
    return (NSArray *)_treeController.arrangedObjects;
}

- (id <PBListViewEntity>)entityAtRow:(NSInteger)row {

    NSArray *sourceArray = self.sourceArray;

    if (row >= 0 && row < sourceArray.count) {
        id <PBListViewEntity> entity = [sourceArray objectAtIndex:row];

        NSAssert([entity conformsToProtocol:@protocol(PBListViewEntity)],
                 @"List view entities must conform to PBListViewEntity");

        return entity;
    }

    return nil;
}

#pragma mark - Cell/Row builders

- (NSArray *)noUIElementsConfiguredMetaList:(Class)entityType depth:(NSUInteger)depth row:(NSInteger)row {

    CGFloat width = NSWidth(self.frame);
    CGFloat rowHeight =
    [self tableView:self heightOfRow:row];

    [_listViewConfig
     registerUIElementMeta:
     [PBListViewUIElementMeta
      uiElementMetaWithEntityType:[PBEmptyConfiguration class]
      keyPath:@"title"
      depth:depth
      binderType:[PBListViewTextFieldBinder class]
      configuration:^(NSTextField *textField, PBListViewUIElementMeta *meta) {

          meta.size = NSMakeSize(width, rowHeight);
          textField.textColor = [NSColor redColor];
          textField.alignment = NSCenterTextAlignment;
      }]];

    return [_listViewConfig metaListForEntityType:[PBEmptyConfiguration class] atDepth:depth];
}

- (NSTableRowView *)buildRowViewForEntity:(id)entity
                                    atRow:(NSInteger)row
                        withTotalEntities:(NSInteger)count {

    NSRect frame = NSMakeRect(0.0f, 0.0f, NSWidth(self.frame), self.rowHeight);
    PBTableRowView *rowView = [[PBTableRowView alloc] initWithFrame:frame];
    rowView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    rowView.delegate = self;

    NSColor *dividerLineColor = _listViewConfig.rowDividerLineColor;
    
    if (row > 0 && dividerLineColor != nil) {

        CGFloat lineHeight = _listViewConfig.rowDividerLineHeight;

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

- (NSTableCellView *)buildCellView {
    NSRect frame = NSMakeRect(0.0f, 0.0f, NSWidth(self.frame), self.rowHeight);
    NSTableCellView *cellView = [[NSTableCellView alloc] initWithFrame:frame];
    cellView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;

    NSArray *subviews = [cellView.subviews copy];
    for (NSView *view in subviews) {
        [view removeFromSuperview];
    }
    return cellView;
}

- (NSTableCellView *)buildCellViewForEntity:(id <PBListViewEntity>)entity
                                      atRow:(NSInteger)row {

    NSTableCellView *cellView = [self buildCellView];

    NSArray *metaList =
    [_listViewConfig
     metaListForEntityType:[entity class]
     atDepth:[entity listViewEntityDepth]];
    
    NSMutableArray *views = [NSMutableArray arrayWithCapacity:metaList.count];

    NSInteger index = 0;
    for (PBListViewUIElementMeta *meta in metaList) {

        // only the last most element can be right-justified
        if (index < (metaList.count - 1)) {
            meta.rightJustified = NO;
        }

        NSView *view = [meta.binder buildUIElement:self];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [cellView addSubview:view];

        [views addObject:view];
        index++;
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

        PBTableRowView *rowView = [self rowViewAtRow:row makeIfNecessary:NO];

        Class entityType = [entity class];
        NSUInteger entityDepth = [entity listViewEntityDepth];

        NSArray *metaList =
        [_listViewConfig
         metaListForEntityType:entityType
         atDepth:entityDepth];

#if DEBUG
        if (metaList.count == 0) {

            NSString *emptyTitle =
            [NSString stringWithFormat:
             NSLocalizedString(@"UI element not defined for entity '%@' at depth %ld", nil),
             NSStringFromClass(entityType), entityDepth];

            entity =
            [PBEmptyConfiguration
             emptyConfigurationWithTitle:emptyTitle
             depth:entityDepth];
            entityType = [entity class];

            metaList =
            [_listViewConfig
             metaListForEntityType:[PBEmptyConfiguration class]
             atDepth:entityDepth];

            rowView.backgroundColor = [NSColor whiteColor];
        }

        if (metaList.count == 0) {
            metaList =
            [self
             noUIElementsConfiguredMetaList:entityType
             depth:entityDepth
             row:row];
        }
#endif
        NSString *reuseKey =
        [NSString stringWithFormat:@"%@-%lu",
         NSStringFromClass(entityType), entityDepth];

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

        BOOL startMouseEnteredEvents = NO;

        for (PBListViewUIElementMeta *meta in metaList) {
            NSView *uiElement =
            [cellView.subviews objectAtIndex:uiElementIndex];
            [meta.binder bindEntity:entity withView:uiElement atRow:row usingMeta:meta];

            uiElement.hidden = meta.hiddenWhenMouseNotInRow;

            startMouseEnteredEvents |= meta.hiddenWhenMouseNotInRow;

            uiElementIndex++;
        }

        if (startMouseEnteredEvents && [rowView mouseEnteredEventsStarted] == NO) {
            [rowView startMouseEnteredEvents];
        }
    }

    return cellView;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView
                rowViewForRow:(NSInteger)row {

    PBTableRowView *rowView = nil;
    id entity = [self entityAtRow:row];

    if (entity != nil) {

        NSString *reuseKey =
        [NSString stringWithFormat:@"ROW%@-%ld",
         NSStringFromClass([entity class]),
         [entity listViewEntityDepth]];

        rowView =
        [tableView
         makeViewWithIdentifier:reuseKey
         owner:self];

        if (rowView == nil) {
            rowView =
            (id)[self
                 buildRowViewForEntity:entity
                 atRow:row
                 withTotalEntities:self.sourceArray.count];
        }

        NSImage *backgroundImage =
        [self backgroundImageForRow:row];

        if (backgroundImage != nil) {

            if (rowView.backgroundImageView == nil) {
                NSImageView *imageView =
                [[NSImageView alloc] initWithFrame:rowView.bounds];
                imageView.translatesAutoresizingMaskIntoConstraints = NO;
                imageView.imageScaling = NSImageScaleAxesIndependently;
                imageView.imageAlignment = NSImageAlignCenter;

                [rowView addSubview:imageView];

                [NSLayoutConstraint expandToSuperview:imageView];
                rowView.backgroundImageView = imageView;
            }
            
            rowView.backgroundImageView.image = backgroundImage;
        }

        rowView.selectedBackgroundColor = _listViewConfig.selectedBackgroundColor;
        rowView.selectedBorderColor = _listViewConfig.selectedBorderColor;
        rowView.selectedBorderRadius = _listViewConfig.selectedBorderRadius;

        [rowView stopMouseEnteredEvents];        
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
            rowHeight = [_listViewConfig rowHeightForEntityType:[entity class]];
        }
    }

    if (rowHeight == 0) {
        rowHeight = self.rowHeight;
    }

    return rowHeight;
}

#pragma mark - Selection

- (void)tableViewSelectionDidChange:(NSNotification *)notification {

    NSMutableSet *affectedRows = [NSMutableSet set];

    [_previousSelection enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [affectedRows addObject:@(idx)];
    }];

    [self.selectedRowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [affectedRows addObject:@(idx)];
    }];

    for (NSNumber *row in affectedRows) {
        NSTableRowView *rowView = [self rowViewAtRow:row.integerValue makeIfNecessary:NO];
        [rowView setNeedsDisplay:YES];
    }

    self.previousSelection = [self.selectedRowIndexes copy];
}

#pragma mark - PBTableRowDelegate Conformance

- (void)rowViewSetHoverState:(PBTableRowView *)rowView {
    [self setStateForUIElementsForRowView:rowView hidden:NO];
}

- (void)rowViewClearHoverState:(PBTableRowView *)rowView {
    [self setStateForUIElementsForRowView:rowView hidden:YES];
}

- (void)setStateForUIElementsForRowView:(PBTableRowView *)rowView
                                 hidden:(BOOL)hidden {

    NSInteger row = [self rowForView:rowView];

    id entity = [self entityAtRow:row];

    if (entity != nil) {

        NSArray *metaList =
        [_listViewConfig
         metaListForEntityType:[entity class]
         atDepth:[entity listViewEntityDepth]];

        NSInteger uiElementIndex = 0;

        NSTableCellView *cellView = [rowView viewAtColumn:0];

        for (PBListViewUIElementMeta *meta in metaList) {
            NSView *uiElement =
            [cellView.subviews objectAtIndex:uiElementIndex];

            if (meta.hiddenWhenMouseNotInRow) {
                uiElement.hidden = hidden;
            }
            uiElementIndex++;

            if (hidden) {
                if ([uiElement respondsToSelector:@selector(stopTracking)]) {
                    [uiElement performSelector:@selector(stopTracking)];
                }
            } else {
                if ([uiElement respondsToSelector:@selector(startTracking)]) {
                    [uiElement performSelector:@selector(startTracking)];
                }
            }
        }
    }

}

#pragma mark - User Interaction

//- (void)mouseDown:(NSEvent *)event {
//
//    [super mouseDown:event];
//
//    NSPoint location = [self convertPoint:[event locationInWindow] fromView:nil];
//    NSInteger row = [self rowAtPoint:location];
//
//    if (row < 0) return;
//
//    NSTableRowView *rowView = [self rowViewAtRow:row makeIfNecessary:NO];
//
//    if (rowView == nil) return;
//
//    if (_trackingArea != nil) {
//        [self removeTrackingArea:_trackingArea];
//    }
//
//    self.trackingArea =
//    [[NSTrackingArea alloc]
//     initWithRect:rowView.frame
//     options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways | NSTrackingInVisibleRect | NSTrackingEnabledDuringMouseDrag
//     owner:self
//     userInfo:nil];
//    [self addTrackingArea:_trackingArea];
//
//}


@end
