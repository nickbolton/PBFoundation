//
//  PBListView.h
//  PBListView
//
//  Created by Nick Bolton on 2/4/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PBListViewConfig.h"
#import "PBListViewUIElementMeta.h"
#import "PBListViewRowMeta.h"
#import "PBListViewUIElementBinder.h"
#import "PBListViewTextFieldBinder.h"
#import "PBListViewButtonBinder.h"
#import "PBListViewSwitchButtonBinder.h"
#import "PBListViewExpandButtonBinder.h"
#import "PBListViewMenuButtonBinder.h"
#import "PBListViewImageBinder.h"
#import "PBListViewCommand.h"
#import "PBButton.h"
#import "PBMenu.h"

@class PBListView;

@protocol PBListViewEntity <NSObject>

@required
- (NSUInteger)listViewEntityDepth;
@property (nonatomic, getter = isListViewEntityExpanded) BOOL listViewEntityExpanded;

@optional
- (NSArray *)listViewChildren;

@end

@protocol PBListViewDelegate <NSObject>

@optional
- (void)listViewUserInitiatedReload:(PBListView *)tableView;
- (void)listViewUserInitiatedDelete:(PBListView *)tableView;
- (void)listViewUserInitiatedSelect:(PBListView *)tableView;
- (void)listView:(PBListView *)listView willExpandRow:(NSInteger)row;
- (void)listView:(PBListView *)listView didExpandRow:(NSInteger)row;
- (void)listView:(PBListView *)listView willCollapseRow:(NSInteger)row;
- (void)listView:(PBListView *)listView didCollapseRow:(NSInteger)row;
@end

@class PBListViewUIElementMeta;

@interface PBListView : NSTableView

@property (nonatomic, strong) NSArray *dataSourceEntities;
@property (nonatomic, readonly) PBListViewConfig *listViewConfig;
@property (nonatomic) NSUInteger userReloadKeyCode;
@property (nonatomic) NSUInteger userReloadKeyModifiers;
@property (nonatomic) NSUInteger userDeleteKeyCode;
@property (nonatomic) NSUInteger userDeleteKeyModifiers;
@property (nonatomic) NSUInteger userSelectKeyCode;
@property (nonatomic) NSUInteger userSelectKeyModifiers;
@property (nonatomic) NSUInteger userExpandKeyCode;
@property (nonatomic) NSUInteger userExpandKeyModifiers;
@property (nonatomic) NSUInteger userCollapseKeyCode;
@property (nonatomic) NSUInteger userCollapseKeyModifiers;
@property (nonatomic, weak) id <PBListViewDelegate> listViewDelegate;

- (void)visualizeConstraints;

- (void)expandRow:(NSInteger)row
          animate:(BOOL)animate
       completion:(void(^)(void))completion;
- (void)collapseRow:(NSInteger)row
            animate:(BOOL)animate
         completion:(void(^)(void))completion;
- (BOOL)isRowExpanded:(NSInteger)row;

@end
