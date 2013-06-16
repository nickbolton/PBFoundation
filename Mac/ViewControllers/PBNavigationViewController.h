//
//  PBNavigationViewController.h
//  SocialScreen
//
//  Created by Nick Bolton on 1/5/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBFlexibleBackgroundViewController.h"

extern NSString *kPBNavigationEnableUserInteractionNotification;
extern NSString *kPBNavigationDisableUserInteractionNotification;

@class PBNavigationViewController;
@class PBMiddleAlignedTextFieldCell;
@class PBClickableLabel;
@class PBStretchableBackgroundView;

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
- (NSSize)desiredSize;

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
- (void)viewWillDismissModal;
- (void)performFrameUpdates;

@end

@interface PBNavigationViewController : PBFlexibleBackgroundViewController

@property (nonatomic, weak) IBOutlet NSView *navBarContainer;
@property (nonatomic, weak) IBOutlet NSView *mainContainer;
@property (nonatomic, weak) IBOutlet NSView *mainContentContainer;
@property (nonatomic, weak) IBOutlet NSView *leftNavView;
@property (nonatomic, weak) IBOutlet NSView *rightNavView;
@property (nonatomic, weak) IBOutlet NSView *centerNavView;
@property (nonatomic, weak) IBOutlet NSTextField *navBarTitleField;
@property (nonatomic, weak) IBOutlet NSButton *navBarBackButton;
@property (nonatomic, weak) IBOutlet NSView *modalPillContainer;
@property (nonatomic, weak) IBOutlet NSView *modalContainer;
@property (nonatomic, weak) IBOutlet NSTextField *modalLabel;
@property (nonatomic, weak) IBOutlet NSButton *modalBackButton;
@property (nonatomic, weak) IBOutlet PBStretchableBackgroundView *modalPillCenterView;

@property (nonatomic, readonly) NSMutableArray *viewControllerStack;

@property (nonatomic, readonly) NSViewController<PBNavigationViewProtocol> *currentViewController;
@property (nonatomic, getter = isModal, readonly) BOOL modal;
@property (nonatomic) CGFloat defaultContainerWidth;

- (IBAction)backPressed:(id)sender;

- (void)pushViewController:(NSViewController<PBNavigationViewProtocol> *)viewController
                   animate:(BOOL)animate;
- (void)pushViewController:(NSViewController<PBNavigationViewProtocol> *)viewController
                   animate:(BOOL)animate
                completion:(void(^)(void))completionBlock;
- (void)pushViewController:(NSViewController<PBNavigationViewProtocol> *)viewController
                   animate:(BOOL)animate
                  fromRoot:(BOOL)fromRoot
                completion:(void(^)(void))completionBlock;
- (void)popViewController:(BOOL)animate;
- (void)popViewController:(BOOL)animate
               completion:(void(^)(void))completionBlock;
- (void)popToRootViewController:(BOOL)animate
                     completion:(void(^)(void))completionBlock;
- (BOOL)isViewControllerInNavigationStack:(NSViewController<PBNavigationViewProtocol> *)viewController;
- (void)startPushNavigation:(BOOL)animate duration:(NSTimeInterval)duration;
- (void)startPopNavigation:(BOOL)animate duration:(NSTimeInterval)duration;
- (void)navigationFinished;
- (void)updateTitle;
- (void)updateContainer:(NSSize)size
               adjusted:(BOOL)adjusted
             animations:(void(^)(void))animations
             completion:(void(^)(void))completionBlock;
- (NSSize)adjustedContainerSize:(CGSize)size;
- (void)dismissModal:(void(^)(void))animations
          completion:(void(^)(void))completionBlock;
- (void)showModalView:(NSView *)view
           withTitle:(NSAttributedString *)title
          desiredSize:(NSSize)desiredSize
          animations:(void(^)(void))animations
          completion:(void(^)(void))completionBlock;

- (void)labelClicked:(PBClickableLabel *)label;
- (void)labelMouseUp:(PBClickableLabel *)label;
- (void)labelDoubleClicked:(PBClickableLabel *)label;

@end
