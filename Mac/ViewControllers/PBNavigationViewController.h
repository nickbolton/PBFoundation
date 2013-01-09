//
//  PBNavigationViewController.h
//  SocialScreen
//
//  Created by Nick Bolton on 1/5/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *kPBNavigationUpdateFrameNotification;
extern NSString *kPBNavigationUpdateContainerNotification;

@class PBNavigationViewController;

@protocol PBNavigationViewProtocol <NSObject>

@property (nonatomic, weak) PBNavigationViewController *navigationViewController;

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
@end

@interface PBNavigationViewController : NSViewController

@property (nonatomic, weak) IBOutlet NSView *containerView;
@property (nonatomic, weak) IBOutlet NSView *navContainer;
@property (nonatomic, weak) IBOutlet NSTextField *titleField;

@property (nonatomic, readonly) NSViewController *currentViewController;

- (void)pushViewController:(NSViewController<PBNavigationViewProtocol> *)viewController
                   animate:(BOOL)animate;
- (void)popViewController:(BOOL)animate;
- (BOOL)isViewControllerInNavigationStack:(NSViewController<PBNavigationViewProtocol> *)viewController;

@end
