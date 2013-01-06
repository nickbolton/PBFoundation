//
//  PBNavigationViewController.m
//  SocialScreen
//
//  Created by Nick Bolton on 1/5/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "PBNavigationViewController.h"
#import <QuartzCore/QuartzCore.h>

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

- (void)commonInit {
    self.viewControllerStack = [NSMutableArray array];
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (NSViewController *)currentViewController {
    return [_viewControllerStack lastObject];
}

- (BOOL)isViewControllerInNavigationStack:(NSViewController<TCNavigationViewProtocol> *)viewController {
    return [_viewControllerStack containsObject:viewController];
}

- (void)pushViewController:(NSViewController<TCNavigationViewProtocol> *)nextViewController
                   animate:(BOOL)animate {

    NSViewController *previousViewController = [_viewControllerStack lastObject];

    [previousViewController performIfRespondsToSelector:@selector(viewWillDeactivate)];
    [nextViewController performIfRespondsToSelector:@selector(viewWillActivate)];

    [_viewControllerStack addObject:nextViewController];

    if (_viewControllerStack.count == 1) {
        [self.view addSubview:nextViewController.view];
        [nextViewController performIfRespondsToSelector:@selector(viewDidActivate)
                                             afterDelay:.01f];
    } else {

        NSView *currentView = previousViewController.view;
        NSView *newView = nextViewController.view;

        if (animate) {

            pushing_ = YES;

            NSRect newRect = NSMakeRect(self.view.frame.origin.x-currentView.frame.size.width,
                                        self.view.frame.origin.y,
                                        self.view.frame.size.width,
                                        self.view.frame.size.height);

            // make sure the current view is aligned on the left side

            NSRect frame = currentView.frame;
            frame.origin.x = 0;
            currentView.frame = frame;

            // place the new view
            newView.frame = NSMakeRect(currentView.frame.size.width,
                                       currentView.frame.origin.y,
                                       newView.frame.size.width,
                                       newView.frame.size.height);

            [self.view addSubview:newView];

            [self.view
             animateToNewFrame:newRect
             duration:PB_WINDOW_ANIMATION_DURATION
             timingFunction:PB_EASE_INOUT
             completionBlock:^{

                 // readjust the container and current view;

                 NSRect frame = self.view.frame;
                 frame.origin.x = 0;
                 self.view.frame = frame;

                 frame = newView.frame;
                 frame.origin.x = 0;
                 newView.frame = frame;

                 NSViewController *previousController = [_viewControllerStack objectAtIndex:_viewControllerStack.count - 2];

                 [previousController.view removeFromSuperview];
                 //                             [previousController performIfRespondsToSelector:@selector(viewDidDeactivate)];
                 [self.currentViewController performIfRespondsToSelector:@selector(viewDidActivate)
                                                              afterDelay:.01f];
             }];
        } else {

            NSRect frame = newView.frame;
            frame.origin.x = 0;
            newView.frame = frame;

            [self.view replaceSubview:currentView with:newView];
            //            [previousViewController performIfRespondsToSelector:@selector(viewDidDeactivate)];
            [nextViewController performIfRespondsToSelector:@selector(viewDidActivate)
                                                 afterDelay:.01f];
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
            self.view.frame = NSMakeRect(-newView.frame.size.width,
                                         self.view.frame.origin.y,
                                         self.view.frame.size.width,
                                         self.view.frame.size.height);

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

            [self.view addSubview:newView];

            NSRect newRect = NSMakeRect(0,
                                        self.view.frame.origin.y,
                                        self.view.frame.size.width,
                                        self.view.frame.size.height);

            [self.view
             animateToNewFrame:newRect
             duration:PB_WINDOW_ANIMATION_DURATION
             timingFunction:PB_EASE_INOUT
             completionBlock:^{
                 NSViewController *nextViewController = [_viewControllerStack objectAtIndex:_viewControllerStack.count - 2];
                 [self.currentViewController.view removeFromSuperview];
                 [self.currentViewController performIfRespondsToSelector:@selector(viewDidDeactivate)
                                                              afterDelay:.01f];
                 [nextViewController performIfRespondsToSelector:@selector(viewDidAppear)
                                                      afterDelay:.01f];
                 [_viewControllerStack removeLastObject];
             }];

        } else {
            [self.view replaceSubview:currentView with:newView];
            [currentViewController performIfRespondsToSelector:@selector(viewDidDeactivate)
                                                    afterDelay:.01f];
            [nextViewController performIfRespondsToSelector:@selector(viewDidAppear)
                                                 afterDelay:.01f];
            [_viewControllerStack removeLastObject];
        }
    }
}

@end
