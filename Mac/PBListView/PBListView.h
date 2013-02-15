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
#import "PBListViewUIElementBinder.h"
#import "PBListViewTextFieldBinder.h"
#import "PBListViewButtonBinder.h"
#import "PBListViewSwitchButtonBinder.h"
#import "PBListViewMenuButtonBinder.h"
#import "PBListViewImageBinder.h"
#import "PBListViewCommand.h"
#import "PBButton.h"
#import "PBMenu.h"

@protocol PBListViewEntity <NSObject>

@required
- (NSUInteger)listViewEntityDepth;

@optional
- (NSArray *)listViewChildren;

@end

@protocol PBListViewActionDelegate <NSObject>

@optional
- (void)userInitiatedReload:(NSTableView *)tableView;
- (void)userInitiatedDelete:(NSTableView *)tableView;
- (void)userInitiatedSelect:(NSTableView *)tableView;

@end

@class PBListViewUIElementMeta;

@interface PBListView : NSTableView

@property (nonatomic, strong) Class parentEntityType;
@property (nonatomic, strong) NSArray *staticEntities;
@property (nonatomic, readonly) PBListViewConfig *listViewConfig;
@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic) NSUInteger userReloadKeyCode;
@property (nonatomic) NSUInteger userReloadKeyModifiers;
@property (nonatomic) NSUInteger userDeleteKeyCode;
@property (nonatomic) NSUInteger userDeleteKeyModifiers;
@property (nonatomic) NSUInteger userSelectKeyCode;
@property (nonatomic) NSUInteger userSelectKeyModifiers;
@property (nonatomic, weak) id <PBListViewActionDelegate> actionDelegate;

- (void)visualizeConstraints;

@end