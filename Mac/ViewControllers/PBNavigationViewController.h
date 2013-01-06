//
//  PBNavigationViewController.h
//  SocialScreen
//
//  Created by Nick Bolton on 1/5/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol TCNavigationViewProtocol <NSObject>

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

@property (nonatomic, readonly) NSViewController *currentViewController;

- (void)pushViewController:(NSViewController<TCNavigationViewProtocol> *)viewController
                   animate:(BOOL)animate;
- (void)popViewController:(BOOL)animate;
- (BOOL)isViewControllerInNavigationStack:(NSViewController<TCNavigationViewProtocol> *)viewController;

@end
