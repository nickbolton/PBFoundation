//
//  PBNavigationViewController.m
//  SocialScreen
//
//  Created by Nick Bolton on 1/5/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBNavigationViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <Carbon/Carbon.h>
#import "PBPopoverView.h"

NSString *kPBNavigationEnableUserInteractionNotification = @"kPBNavigationEnableUserInteractionNotification";
NSString *kPBNavigationDisableUserInteractionNotification = @"kPBNavigationDisableUserInteractionNotification";

@interface PBNavigationViewController () {

    NSSize _previousContainerSize;
    NSSize _previousContentSize;
    BOOL _firstAnimation;
}

@property (nonatomic, readwrite) NSMutableArray *viewControllerStack;
@property (nonatomic, readwrite) NSEdgeInsets mainContentInsets;
@property (nonatomic, strong) NSViewController *altCurrentViewController;
@property (nonatomic, strong) NSView *modalView;

@end

@implementation PBNavigationViewController

- (id)init {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    [super commonInit];
    self.viewControllerStack = [NSMutableArray array];
}

- (void)throwAway {

//    _navBarContainer.wantsLayer = YES;
//    _mainContainer.wantsLayer = YES;
//    _mainContentContainer.wantsLayer = YES;
//    _mainContentContainer.layer.masksToBounds;
//
//    _navBarContainer.layer.backgroundColor = [NSColor redColor].CGColor;
//    _mainContainer.layer.backgroundColor = [NSColor yellowColor].CGColor;
//    _mainContentContainer.layer.backgroundColor = [NSColor greenColor].CGColor;
}

- (void)setupNavigationContainer {

    _modalContainer.hidden = YES;
    _modalContainer.alphaValue = 1.0f;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    NSAssert([self.backgroundView isKindOfClass:[PBPopoverView class]],
             @"Root view must be a PBPopoverView");
    self.backgroundView.flipped = NO;

    [self setupNavigationContainer];
    [self throwAway];
}

- (void)setTitle:(NSString *)title {
    _navBarTitleField.stringValue = title;
}

- (void)updateTitle:(BOOL)animated {

    void (^executionBlock)(void) = ^{
        _navBarTitleField.stringValue =
        [NSString safeString:[self.currentViewController title]];
    };

    if (animated) {

        [_navBarTitleField
         animateFadeOutIn:PB_WINDOW_ANIMATION_DURATION
         middleBlock:executionBlock
         completionBlock:nil];
        
    } else {
        executionBlock();
    }
}

- (IBAction)backPressed:(id)sender {

    if (self.isModal) {

        if ([self.currentViewController respondsToSelector:@selector(viewWillDismissModal)]) {
            [self.currentViewController viewWillDismissModal];
        }

    } else {
        [self popViewController:YES];
    }
}

- (NSViewController *)currentViewController {
    return [_viewControllerStack lastObject];
}

- (BOOL)isViewControllerInNavigationStack:(NSViewController<PBNavigationViewProtocol> *)viewController {
    return [_viewControllerStack containsObject:viewController];
}

- (void)startPushNavigation:(BOOL)animate duration:(NSTimeInterval)duration {
}

- (void)startPopNavigation:(BOOL)animate duration:(NSTimeInterval)duration {
}

- (NSString *)viewKey:(NSView *)view {
    return [NSString stringWithFormat:@"%p", view];
}

- (void)clearModalContainer {

    NSArray *subviews = [self.modalContainer.subviews copy];
    for (NSView *child in subviews) {

        if (child != _modalPillContainer) {
            [child removeFromSuperview];
        }
    }

    self.modalContainer.hidden = YES;
}

- (void)setModalTitle:(NSAttributedString *)title {

    static CGFloat padding = -5.0f;
    static CGFloat extraTextWidth = 9.0f;
    static CGFloat rightPadding = 9.0f;

    _modalLabel.attributedStringValue = title;

    NSSize textSize =
    [title.string sizeWithAttributes:@{NSFontAttributeName : _modalLabel.font}];
    textSize.width += extraTextWidth;

    NSRect frame = _modalPillContainer.frame;

    frame.size.width =
    NSWidth(_modalBackButton.frame) +
    padding +
    textSize.width +
    rightPadding;

    frame.origin.x =
    (NSWidth(_modalPillContainer.superview.frame) - NSWidth(frame)) / 2.0f;

    _modalPillContainer.frame = frame;

    frame = _modalBackButton.frame;
    frame.origin.x = 0.0f;
    _modalBackButton.frame = frame;

    frame = _modalLabel.frame;
    frame.origin.x = padding + NSMaxX(_modalBackButton.frame);
    frame.size.width = textSize.width;
    _modalLabel.frame = frame;
}

- (void)showModalView:(NSView *)view
            withTitle:(NSAttributedString *)title
          desiredSize:(NSSize)desiredSize
           animations:(void(^)(void))animations
           completion:(void(^)(void))completionBlock {

    if (view != nil) {

        _modal = YES;

        self.modalView = view;

        [self clearModalContainer];

        self.modalContainer.hidden = NO;
        self.modalContainer.alphaValue = 0.0f;

        view.frame = self.modalContainer.bounds;
        [self.modalContainer addSubview:view positioned:NSWindowBelow relativeTo:_modalPillContainer];

        view.autoresizingMask =
        NSViewWidthSizable | NSViewHeightSizable;

        if (NSEqualSizes(_previousContainerSize, NSZeroSize)) {
            _previousContainerSize = self.view.window.frame.size;
        }

        [self setModalTitle:title];

        desiredSize.width = MAX(NSWidth(_modalPillContainer.frame) + 40.0f, desiredSize.width);

        [self
         updateContainer:desiredSize
         adjusted:YES
         animations:^{

             [[self.navBarContainer animator] setAlphaValue:0.0f];
             [[self.mainContentContainer animator] setAlphaValue:0.0f];
             [[self.modalContainer animator] setAlphaValue:1.0f];

         } completion:^{

             if (completionBlock != nil) {
                 completionBlock();
             }
         }];
    }
}

- (void)dismissModal:(void(^)(void))animations
          completion:(void(^)(void))completionBlock {

    _modal = NO;

    [self
     updateContainer:_previousContainerSize
     adjusted:YES
     animations:^{

         [[self.navBarContainer animator] setAlphaValue:1.0f];
         [[self.mainContentContainer animator] setAlphaValue:1.0f];
         [[self.modalContainer animator] setAlphaValue:0.0f];
         
     } completion:^{

         [self.modalView removeFromSuperview];
         self.modalView = nil;
         
         [self clearModalContainer];
         _previousContainerSize = NSZeroSize;
     }];
}

- (void)navigationFinished {
}

- (void)updateContainer:(NSSize)size
               adjusted:(BOOL)adjusted
             animations:(void(^)(void))animations
             completion:(void(^)(void))completionBlock {
}

- (void)updateContentContainer:(NSSize)contentSize
                      adjusted:(BOOL)adjusted
                    animations:(void(^)(void))animations
                    completion:(void(^)(void))completionBlock {

    NSSize containerSize =
    NSMakeSize(NSWidth(self.view.window.frame),
               contentSize.height + self.mainContentInsets.top + self.mainContentInsets.bottom);

    [self
     updateContainer:containerSize
     adjusted:NO
     animations:nil
     completion:completionBlock];
}

- (void)pushViewController:(NSViewController<PBNavigationViewProtocol> *)nextViewController
                   animate:(BOOL)animate {
    [self pushViewController:nextViewController animate:animate completion:nil];
}

- (void)pushViewController:(NSViewController<PBNavigationViewProtocol> *)nextViewController
                   animate:(BOOL)animate
                completion:(void (^)(void))completionBlock {
    [self
     pushViewController:nextViewController
     animate:animate
     fromRoot:NO
     completion:completionBlock];
}

- (void)pushViewController:(NSViewController<PBNavigationViewProtocol> *)nextViewController
                   animate:(BOOL)animate
                  fromRoot:(BOOL)fromRoot
                completion:(void(^)(void))completionBlock {

    BOOL shouldLeaveCurrentViewController = YES;

    if ([self.currentViewController respondsToSelector:@selector(shouldLeaveViewController)]) {
        shouldLeaveCurrentViewController =
        [self.currentViewController shouldLeaveViewController];
    }

    if (shouldLeaveCurrentViewController == NO) {
        if (completionBlock != nil) {
            completionBlock();
        }
        return;
    }

    NSTimeInterval duration = PB_WINDOW_ANIMATION_DURATION;

    nextViewController.navigationViewController = self;

    _navBarTitleField.stringValue = [nextViewController title];

    NSViewController<PBNavigationViewProtocol> *previousViewController = [_viewControllerStack lastObject];

    if ([previousViewController respondsToSelector:@selector(viewWillDeactivate)]) {
        [previousViewController viewWillDeactivate];
    }

    if ([nextViewController respondsToSelector:@selector(viewWillActivate)]) {
        [nextViewController viewWillActivate];
    }

    if (fromRoot) {
        while (_viewControllerStack.count > 1) {

            NSViewController<PBNavigationViewProtocol> *viewController =
            _viewControllerStack.lastObject;

            if ([viewController respondsToSelector:@selector(viewWillDeactivate)]) {
                [viewController viewWillDeactivate];
            }

            [viewController.view removeFromSuperview];
            [_viewControllerStack removeLastObject];

            if ([viewController respondsToSelector:@selector(viewDidDeactivate)]) {
                [viewController viewDidDeactivate];
            }
        }
    }

    [_viewControllerStack addObject:nextViewController];

    if (_viewControllerStack.count == 1) {

        [self startPushNavigation:NO duration:0.0f];

        nextViewController.view.frame = _mainContentContainer.bounds;
        nextViewController.view.autoresizingMask =
        NSViewWidthSizable | NSViewHeightSizable;

        [_mainContentContainer addSubview:nextViewController.view];

        [PBAnimator
         animateWithDuration:duration
         timingFunction:PB_EASE_INOUT
         animation:^{

             if ([self.currentViewController respondsToSelector:@selector(performFrameUpdates)]) {
                 [self.currentViewController performFrameUpdates];
             }
             
         } completion:^{

             NSSize windowSize = self.view.window.frame.size;
             NSRect frameInWindow =
             [self.mainContentContainer
              convertRect:self.mainContentContainer.bounds
              toView:nil];

             CGFloat top = windowSize.height - NSMaxY(frameInWindow);
             CGFloat bottom = NSMinY(frameInWindow);
             CGFloat left = NSMinX(frameInWindow);
             CGFloat right = windowSize.width - NSMaxX(frameInWindow);

             bottom += NSHeight(_mainContentContainer.frame) - nextViewController.desiredSize.height;

             _mainContentInsets = NSEdgeInsetsMake(top, left, bottom, right);

             [self navigationFinished];

             if ([nextViewController respondsToSelector:@selector(viewDidActivate)]) {
                 [nextViewController viewDidActivate];
             }

             if (completionBlock != nil) {
                 completionBlock();
             }
         }];

    } else {

        NSView *currentView = previousViewController.view;
        NSView *newView = nextViewController.view;

        CGFloat viewWidth = NSWidth(currentView.frame);

        if (animate) {

            [self startPushNavigation:YES duration:duration];

            // place the new view
            NSRect frame = _mainContentContainer.bounds;
            frame.origin.x = viewWidth;
            newView.frame = frame;

            [_mainContentContainer addSubview:newView];

            CGFloat currentHeight = NSHeight(_mainContentContainer.bounds);

            [PBAnimator
             animateWithDuration:duration
             timingFunction:PB_EASE_INOUT
             animation:^{

                 NSRect frame = currentView.frame;
                 frame.origin.x -= viewWidth;

                 [[currentView animator] setFrame:frame];

                 frame = newView.frame;
                 frame.origin.x = 0;

                 [[newView animator] setFrame:frame];

             } completion:^{

                 [currentView removeFromSuperview];

                 [self
                  updateContentContainer:nextViewController.desiredSize
                  adjusted:NO
                  animations:nil
                  completion:^{

                      [self navigationFinished];

                      if ([nextViewController respondsToSelector:@selector(viewDidActivate)]) {
                          [nextViewController viewDidActivate];
                      }

                      if (completionBlock != nil) {
                          completionBlock();
                      }
                  }];
             }];

        } else {

            [self startPushNavigation:NO duration:0.0f];

            [_mainContentContainer addSubview:nextViewController.view];
            [previousViewController.view removeFromSuperview];

            [PBAnimator
             animateWithDuration:duration
             timingFunction:PB_EASE_INOUT
             animation:^{

                 if ([self.currentViewController respondsToSelector:@selector(performFrameUpdates)]) {
                     [self.currentViewController performFrameUpdates];
                 }

             } completion:^{

                 [self navigationFinished];

                 if ([nextViewController respondsToSelector:@selector(viewDidActivate)]) {
                     [nextViewController viewDidActivate];
                 }

                 if (completionBlock != nil) {
                     completionBlock();
                 }
             }];
        }
    }
}

- (void)popToRootViewController:(BOOL)animate
                     completion:(void(^)(void))completionBlock {

    self.altCurrentViewController = self.currentViewController;

    while (_viewControllerStack.count > 2) {

        NSViewController<PBNavigationViewProtocol> *viewController =
        _viewControllerStack.lastObject;

        if ([viewController respondsToSelector:@selector(viewWillDeactivate)]) {
            [viewController viewWillDeactivate];
        }

        [viewController.view removeFromSuperview];
        [_viewControllerStack removeLastObject];

        if ([viewController respondsToSelector:@selector(viewDidDeactivate)]) {
            [viewController viewDidDeactivate];
        }
    }

    [self popViewController:animate completion:completionBlock];

    self.altCurrentViewController = nil;
}

- (void)popViewController:(BOOL)animate {
    [self popViewController:animate completion:nil];
}

- (void)popViewController:(BOOL)animate
               completion:(void(^)(void))completionBlock {

    if (_viewControllerStack.count > 1) {

        BOOL shouldLeaveCurrentViewController = YES;

        if ([self.currentViewController respondsToSelector:@selector(shouldLeaveViewController)]) {
            shouldLeaveCurrentViewController =
            [self.currentViewController shouldLeaveViewController];
        }

        if (shouldLeaveCurrentViewController == NO) {

            if (completionBlock != nil) {
                completionBlock();
            }
            return;
        }

        NSTimeInterval duration = PB_WINDOW_ANIMATION_DURATION;

        NSViewController<PBNavigationViewProtocol> *currentViewController;
        NSViewController<PBNavigationViewProtocol> *nextViewController =
        _viewControllerStack[_viewControllerStack.count - 2];

        if (_altCurrentViewController != nil) {
            currentViewController = _altCurrentViewController;
        } else {
            currentViewController = self.currentViewController;
        }

        if ([currentViewController respondsToSelector:@selector(viewWillDeactivate)]) {
            [currentViewController viewWillDeactivate];
        }

        if ([nextViewController respondsToSelector:@selector(viewWillAppear)]) {
            [nextViewController viewWillAppear];
        }

        NSView *currentView = currentViewController.view;
        NSView *newView = nextViewController.view;

        CGFloat viewWidth = NSWidth(currentView.frame);

        _navBarTitleField.stringValue = [nextViewController title];

        if (animate) {

            [self startPopNavigation:YES duration:duration];

            // place the new view
            newView.frame =
            NSMakeRect(-viewWidth,
                       NSMinY(currentView.frame),
                       viewWidth,
                       NSHeight(currentView.frame));

            [_mainContentContainer addSubview:newView];

            [PBAnimator
             animateWithDuration:duration
             timingFunction:PB_EASE_INOUT
             animation:^{

                 NSRect frame = currentView.frame;
                 frame.origin.x += viewWidth;

                 [[currentView animator] setFrame:frame];

                 frame = newView.frame;
                 frame.origin.x = 0;

                 [[newView animator] setFrame:frame];

             } completion:^{

                 [currentView removeFromSuperview];

                 [self
                  updateContentContainer:nextViewController.desiredSize
                  adjusted:NO
                  animations:nil
                  completion:^{

                      [self navigationFinished];

                      if ([currentViewController respondsToSelector:@selector(viewDidDeactivate)]) {
                          [currentViewController viewDidDeactivate];
                      }

                      if ([nextViewController respondsToSelector:@selector(viewDidAppear)]) {
                          [nextViewController viewDidAppear];
                      }

                      [_viewControllerStack removeLastObject];

                      if (completionBlock != nil) {
                          completionBlock();
                      }
                  }];
             }];

        } else {

            [self startPopNavigation:NO duration:0.0f];
            
//            [_navContainer replaceSubview:currentView with:newView];
//
//            [PBAnimator
//             animateWithDuration:duration
//             timingFunction:PB_EASE_INOUT
//             animation:^{
//
//                 [[NSNotificationCenter defaultCenter]
//                  postNotificationName:kPBNavigationUpdateFrameNotification
//                  object:self
//                  userInfo:nil];
//
//             } completion:^{
//
//                 [self navigationFinished];
//
//                 if ([currentViewController respondsToSelector:@selector(viewDidDeactivate)]) {
//                     [currentViewController viewDidDeactivate];
//                 }
//
//                 if ([nextViewController respondsToSelector:@selector(viewDidAppear)]) {
//                     [nextViewController viewDidAppear];
//                 }
//
//                 [_viewControllerStack removeLastObject];
//                 
//                 if (completionBlock != nil) {
//                     completionBlock();
//                 }
//             }];
        }
    } else {

        if (completionBlock != nil) {
            completionBlock();
        }
    }
}

#pragma mark - Key handling

- (void)keyDown:(NSEvent *)event {

    NSInteger allControlsMask = NSCommandKeyMask | NSShiftKeyMask | NSControlKeyMask | NSAlternateKeyMask | NSFunctionKeyMask;

    if (([event modifierFlags] & allControlsMask) == 0) {

        switch ([event keyCode]) {
            case kVK_Escape:
                [self popViewController:YES];
                break;
        }
    }

}

#pragma mark - PBClickableLabelDelegate Conformance

- (void)labelClicked:(PBClickableLabel *)label {
}

- (void)labelMouseUp:(PBClickableLabel *)label {
}

- (void)labelDoubleClicked:(PBClickableLabel *)label {
}

@end
