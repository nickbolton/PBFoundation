//
//  PBNavigationViewController.h
//  SocialScreen
//
//  Created by Nick Bolton on 1/5/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBFlexibleBackgroundViewController.h"

extern NSString *kPBNavigationUpdateFrameNotification;
extern NSString *kPBNavigationUpdateContainerNotification;
extern NSString *kPBNavigationEnableUserInteractionNotification;
extern NSString *kPBNavigationDisableUserInteractionNotification;

@class PBNavigationViewController;
@class PBMiddleAlignedTextFieldCell;

@protocol PBNavigationViewProtocol <NSObject>

@required
@property (nonatomic, weak) PBNavigationViewController *navigationViewController;

@optional
- (BOOL)needsEditableTitleField;
- (void)titleChanged:(NSString *)title;
- (NSString *)placeholderTitleText;
- (BOOL)shouldLeaveViewController;

@required
- (NSString *)title;

@optional
- (NSView *)toolBarView;
- (NSView *)statusBarView;
- (void)viewWillActivate;
- (void)viewDidActivate;
- (void)viewWillDeactivate;
- (void)viewDidDeactivate;
- (void)viewWillAppear;
- (void)viewWillDisappear;
- (void)viewDidAppear;
@end

@interface PBNavigationViewController : PBFlexibleBackgroundViewController

@property (nonatomic, weak) IBOutlet NSView *containerView;
@property (nonatomic, weak) IBOutlet NSView *navContainer;
@property (nonatomic, weak) IBOutlet NSTextField *titleField;
@property (nonatomic, weak) IBOutlet NSTextField *editableTitleField;
@property (nonatomic, weak) IBOutlet PBMiddleAlignedTextFieldCell *editableTitleFieldCell;
@property (nonatomic, readonly) NSMutableArray *viewControllerStack;

@property (nonatomic, readonly) NSViewController<PBNavigationViewProtocol> *currentViewController;

- (void)pushViewController:(NSViewController<PBNavigationViewProtocol> *)viewController
                   animate:(BOOL)animate;
- (void)popViewController:(BOOL)animate;
- (BOOL)isViewControllerInNavigationStack:(NSViewController<PBNavigationViewProtocol> *)viewController;
- (void)startPushNavigation:(BOOL)animate duration:(NSTimeInterval)duration;
- (void)startPopNavigation:(BOOL)animate duration:(NSTimeInterval)duration;
- (void)navigationFinished;
- (void)updateTitle;

@end
