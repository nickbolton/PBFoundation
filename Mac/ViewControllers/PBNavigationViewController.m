//
//  PBNavigationViewController.m
//  SocialScreen
//
//  Created by Nick Bolton on 1/5/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBNavigationViewController.h"
#import <QuartzCore/QuartzCore.h>

NSString *kPBNavigationUpdateFrameNotification = @"kPBNavigationUpdateFrameNotification";
NSString *kPBNavigationUpdateContainerNotification = @"kPBNavigationUpdateContainerNotification";

@interface PBNavigationViewController () {
    BOOL pushing_;
}

@property (nonatomic, strong) NSMutableArray *viewControllerStack;

@end

@implementation PBNavigationViewController

- (id)init {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.viewControllerStack = [NSMutableArray array];
}

- (void)awakeFromNib {
    [super awakeFromNib];

    [_navContainer setTranslatesAutoresizingMaskIntoConstraints:NO];
}

- (void)setTitle:(NSString *)title {
    _titleField.stringValue = title;
}

- (NSViewController *)currentViewController {
    return [_viewControllerStack lastObject];
}

- (BOOL)isViewControllerInNavigationStack:(NSViewController<PBNavigationViewProtocol> *)viewController {
    return [_viewControllerStack containsObject:viewController];
}

- (void)pushViewController:(NSViewController<PBNavigationViewProtocol> *)nextViewController
                   animate:(BOOL)animate {

    nextViewController.navigationViewController = self;
    [nextViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];

    NSRect frame = nextViewController.view.frame;
    frame.origin.y = 0;
    frame.size.height = NSHeight(_navContainer.frame);
    nextViewController.view.frame = frame;

    NSString *title = [nextViewController title];

    _titleField.stringValue = title;

    NSViewController *previousViewController = [_viewControllerStack lastObject];

    [previousViewController performIfRespondsToSelector:@selector(viewWillDeactivate)];
    [nextViewController performIfRespondsToSelector:@selector(viewWillActivate)];

    [_viewControllerStack addObject:nextViewController];

    if (_viewControllerStack.count == 1) {
        
        [_navContainer addSubview:nextViewController.view];

        [PBAnimator
         animateWithDuration:PB_WINDOW_ANIMATION_DURATION
         timingFunction:PB_EASE_INOUT
         animation:^{

             [[NSNotificationCenter defaultCenter]
              postNotificationName:kPBNavigationUpdateFrameNotification
              object:self
              userInfo:nil];
             
         } completion:^{
             [nextViewController performIfRespondsToSelector:@selector(viewDidActivate)];
         }];
        
    } else {

        NSView *currentView = previousViewController.view;
        NSView *newView = nextViewController.view;

        if (animate) {

            pushing_ = YES;

            NSRect newRect = NSMakeRect(_navContainer.frame.origin.x-currentView.frame.size.width,
                                        _navContainer.frame.origin.y,
                                        _navContainer.frame.size.width,
                                        _navContainer.frame.size.height);

            // make sure the current view is aligned on the left side

            NSRect frame = currentView.frame;
            frame.origin.x = 0;
            currentView.frame = frame;

            // place the new view
            newView.frame = NSMakeRect(currentView.frame.size.width,
                                       currentView.frame.origin.y,
                                       newView.frame.size.width,
                                       newView.frame.size.height);

            [_navContainer addSubview:newView];

            [_navContainer
             animateToNewFrame:newRect
             duration:PB_WINDOW_ANIMATION_DURATION
             timingFunction:PB_EASE_INOUT
             completionBlock:^{

                 // readjust the container and current view;

                 NSRect frame = _navContainer.frame;
                 frame.origin.x = 0;
                 _navContainer.frame = frame;

                 frame = newView.frame;
                 frame.origin.x = 0;
                 newView.frame = frame;

                 NSViewController *previousController = [_viewControllerStack objectAtIndex:_viewControllerStack.count - 2];

                 [previousController.view removeFromSuperview];
                 //                             [previousController performIfRespondsToSelector:@selector(viewDidDeactivate)];

                 [PBAnimator
                  animateWithDuration:PB_WINDOW_ANIMATION_DURATION
                  timingFunction:PB_EASE_INOUT
                  animation:^{

                      [[NSNotificationCenter defaultCenter]
                       postNotificationName:kPBNavigationUpdateFrameNotification
                       object:self
                       userInfo:nil];

                  } completion:^{
                      [self.currentViewController performIfRespondsToSelector:@selector(viewDidActivate)];
                  }];
                 
             }];
        } else {

            NSRect frame = newView.frame;
            frame.origin.x = 0;
            newView.frame = frame;

            [_navContainer replaceSubview:currentView with:newView];
            [PBAnimator
             animateWithDuration:PB_WINDOW_ANIMATION_DURATION
             timingFunction:PB_EASE_INOUT
             animation:^{

                 [[NSNotificationCenter defaultCenter]
                  postNotificationName:kPBNavigationUpdateFrameNotification
                  object:self
                  userInfo:nil];

             } completion:^{
                 [nextViewController performIfRespondsToSelector:@selector(viewDidActivate)];
             }];
        }
    }
}

- (void)popViewController:(BOOL)animate {
    if (_viewControllerStack.count > 1) {

        NSViewController *currentViewController = self.currentViewController;
        NSViewController *nextViewController = [_viewControllerStack objectAtIndex:_viewControllerStack.count - 2];

        [currentViewController performIfRespondsToSelector:@selector(viewWillDeactivate)];
        [nextViewController performIfRespondsToSelector:@selector(viewWillAppear)];

        NSView *currentView = currentViewController.view;
        NSView *newView = nextViewController.view;

        if (animate) {

            pushing_ = NO;

            // move the parent frame
            _navContainer.frame = NSMakeRect(-newView.frame.size.width,
                                         _navContainer.frame.origin.y,
                                         _navContainer.frame.size.width,
                                         _navContainer.frame.size.height);

            // place the current view
            currentView.frame = NSMakeRect(newView.frame.size.width,
                                           currentView.frame.origin.y,
                                           currentView.frame.size.width,
                                           currentView.frame.size.height);

            // reposition the new view
            newView.frame = NSMakeRect(0,
                                       currentView.frame.origin.y,
                                       currentView.frame.size.width,
                                       currentView.frame.size.height);

            [_navContainer addSubview:newView];

            NSRect newRect = NSMakeRect(0,
                                        _navContainer.frame.origin.y,
                                        _navContainer.frame.size.width,
                                        _navContainer.frame.size.height);

            [_navContainer
             animateToNewFrame:newRect
             duration:PB_WINDOW_ANIMATION_DURATION
             timingFunction:PB_EASE_INOUT
             completionBlock:^{
                 NSViewController *nextViewController = [_viewControllerStack objectAtIndex:_viewControllerStack.count - 2];
                 [self.currentViewController.view removeFromSuperview];

                 [PBAnimator
                  animateWithDuration:PB_WINDOW_ANIMATION_DURATION
                  timingFunction:PB_EASE_INOUT
                  animation:^{

                      [[NSNotificationCenter defaultCenter]
                       postNotificationName:kPBNavigationUpdateFrameNotification
                       object:self
                       userInfo:nil];

                  } completion:^{
                      [self.currentViewController performIfRespondsToSelector:@selector(viewDidDeactivate)];
                      [nextViewController performIfRespondsToSelector:@selector(viewDidAppear)];
                      [_viewControllerStack removeLastObject];
                  }];
             }];

        } else {
            [_navContainer replaceSubview:currentView with:newView];

            [PBAnimator
             animateWithDuration:PB_WINDOW_ANIMATION_DURATION
             timingFunction:PB_EASE_INOUT
             animation:^{

                 [[NSNotificationCenter defaultCenter]
                  postNotificationName:kPBNavigationUpdateFrameNotification
                  object:self
                  userInfo:nil];

             } completion:^{
                 [currentViewController performIfRespondsToSelector:@selector(viewDidDeactivate)];
                 [nextViewController performIfRespondsToSelector:@selector(viewDidAppear)];
                 [_viewControllerStack removeLastObject];
             }];
        }
    }
}

@end
