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

NSString *kPBNavigationUpdateFrameNotification = @"kPBNavigationUpdateFrameNotification";
NSString *kPBNavigationUpdateContainerNotification = @"kPBNavigationUpdateContainerNotification";
NSString *kPBNavigationEnableUserInteractionNotification = @"kPBNavigationEnableUserInteractionNotification";
NSString *kPBNavigationDisableUserInteractionNotification = @"kPBNavigationDisableUserInteractionNotification";

@interface PBNavigationViewController () <NSTextFieldDelegate> {
    BOOL _editingTitle;
}

@property (nonatomic, readwrite) NSMutableArray *viewControllerStack;
@property (nonatomic, strong) NSViewController <PBNavigationViewProtocol> *editingTitleViewController;
@property (nonatomic, strong) NSViewController *altCurrentViewController;

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
    [super commonInit];
    self.viewControllerStack = [NSMutableArray array];
}

- (void)awakeFromNib {
    [super awakeFromNib];

    [_navContainer setTranslatesAutoresizingMaskIntoConstraints:NO];

    _editableTitleField.delegate = self;
    _editableTitleField;

    NSAssert([self.backgroundView isKindOfClass:[PBPopoverView class]],
             @"Root view must be a PBPopoverView");
    self.backgroundView.flipped = NO;
}

- (void)setTitle:(NSString *)title {
    _titleField.stringValue = title;
}

- (void)updateTitle {
    _titleField.stringValue = [NSString safeString:[self.currentViewController title]];
}

- (CGFloat)containerHeight {
    return NSWidth(self.containerView.frame);
}

- (void)setModalTitle:(NSAttributedString *)title {
}

- (NSSize)adjustedContainerSize:(CGSize)size {
    return NSZeroSize;
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

- (void)navigationFinished {
}

- (void)updateContainer:(NSSize)size
             animations:(void(^)(void))animations
             completion:(void(^)(void))completionBlock {
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

    if ([self.editingTitleViewController needsEditableTitleField]) {
        if ([self.editingTitleViewController respondsToSelector:@selector(titleChanged:)]) {
            [self.editingTitleViewController titleChanged:_editableTitleField.stringValue];
        }
    }

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
    [nextViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];

    NSRect frame = nextViewController.view.frame;
    frame.origin.y = 0;
    frame.size.height = NSHeight(_navContainer.frame);
    nextViewController.view.frame = frame;

    _titleField.stringValue = [nextViewController title];
    _editableTitleField.stringValue = _titleField.stringValue;
    _editingTitle = NO;
    self.editingTitleViewController = nil;

    if ([nextViewController respondsToSelector:@selector(needsEditableTitleField)]) {
        _editingTitle = [nextViewController needsEditableTitleField];
        self.editingTitleViewController = nextViewController;
    }

    _titleField.hidden = _editingTitle;
    _editableTitleField.hidden = !_editingTitle;

    if ([nextViewController respondsToSelector:@selector(placeholderTitleText)]) {
        ((NSTextFieldCell *)_editableTitleField.cell).placeholderString =
        [nextViewController placeholderTitleText];
    } else {
        ((NSTextFieldCell *)_editableTitleField.cell).placeholderString = nil;
    }

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

        [_navContainer addSubview:nextViewController.view];

        [PBAnimator
         animateWithDuration:duration
         timingFunction:PB_EASE_INOUT
         animation:^{

             [[NSNotificationCenter defaultCenter]
              postNotificationName:kPBNavigationUpdateFrameNotification
              object:self
              userInfo:nil];
             
         } completion:^{

             if ([nextViewController respondsToSelector:@selector(viewDidActivate)]) {
                 [nextViewController viewDidActivate];
             }

             [self navigationFinished];

             if (completionBlock != nil) {
                 completionBlock();
             }
         }];
        
    } else {

        NSView *currentView = previousViewController.view;
        NSView *newView = nextViewController.view;

        if (animate) {

            [self startPushNavigation:YES duration:duration];

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
             duration:duration
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
                  animateWithDuration:duration
                  timingFunction:PB_EASE_INOUT
                  animation:^{

                      [[NSNotificationCenter defaultCenter]
                       postNotificationName:kPBNavigationUpdateFrameNotification
                       object:self
                       userInfo:nil];

                  } completion:^{
                      if ([self.currentViewController respondsToSelector:@selector(viewDidActivate)]) {
                          [self.currentViewController viewDidActivate];
                      }
                      [self navigationFinished];

                      if (completionBlock != nil) {
                          completionBlock();
                      }
                  }];                 
             }];
        } else {

            [self startPushNavigation:NO duration:0.0f];

            NSRect frame = newView.frame;
            frame.origin.x = 0;
            newView.frame = frame;

            [PBAnimator
             animateWithDuration:duration
             timingFunction:PB_EASE_INOUT
             animation:^{

                 [[NSNotificationCenter defaultCenter]
                  postNotificationName:kPBNavigationUpdateFrameNotification
                  object:self
                  userInfo:nil];

             } completion:^{

                 if ([self.currentViewController respondsToSelector:@selector(viewDidActivate)]) {
                     [self.currentViewController viewDidActivate];
                 }
                 [self navigationFinished];
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

        if ([self.editingTitleViewController needsEditableTitleField]) {
            if ([self.editingTitleViewController respondsToSelector:@selector(titleChanged:)]) {
                [self.editingTitleViewController titleChanged:_editableTitleField.stringValue];
            }
        }

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

        _titleField.stringValue = [nextViewController title];
        _editableTitleField.stringValue = _titleField.stringValue;
        _editingTitle = NO;
        self.editingTitleViewController = nil;

        if ([nextViewController respondsToSelector:@selector(needsEditableTitleField)]) {
            _editingTitle = [nextViewController needsEditableTitleField];
            self.editingTitleViewController = nextViewController;
        }

        if ([nextViewController respondsToSelector:@selector(placeholderTitleText)]) {
            ((NSTextFieldCell *)_editableTitleField.cell).placeholderString =
            [nextViewController placeholderTitleText];
        } else {
            ((NSTextFieldCell *)_editableTitleField.cell).placeholderString = nil;
        }

        BOOL _editingTitle = NO;

        if ([nextViewController respondsToSelector:@selector(needsEditableTitleField)]) {
            _editingTitle = [nextViewController needsEditableTitleField];
        }

        _titleField.hidden = _editingTitle;
        _editableTitleField.hidden = !_editingTitle;

        if (animate) {

            [self startPopNavigation:YES duration:duration];

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
             duration:duration
             timingFunction:PB_EASE_INOUT
             completionBlock:^{
                 NSViewController<PBNavigationViewProtocol> *nextViewController = [_viewControllerStack objectAtIndex:_viewControllerStack.count - 2];
                 [currentViewController.view removeFromSuperview];

                 [PBAnimator
                  animateWithDuration:duration
                  timingFunction:PB_EASE_INOUT
                  animation:^{

                      [[NSNotificationCenter defaultCenter]
                       postNotificationName:kPBNavigationUpdateFrameNotification
                       object:self
                       userInfo:nil];

                  } completion:^{
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
            
            [_navContainer replaceSubview:currentView with:newView];

            [PBAnimator
             animateWithDuration:duration
             timingFunction:PB_EASE_INOUT
             animation:^{

                 [[NSNotificationCenter defaultCenter]
                  postNotificationName:kPBNavigationUpdateFrameNotification
                  object:self
                  userInfo:nil];

             } completion:^{

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
        }
    } else {

        if (completionBlock != nil) {
            completionBlock();
        }
    }
}

#pragma mark - NSTextFieldDelegate Conformance

- (void)controlTextDidChange:(NSNotification *)notification {
}

- (BOOL)control:(NSControl *)control isValidObject:(id)object {

    BOOL valid = NO;

    if ([object isKindOfClass:[NSString class]]) {
        valid = ((NSString *)object).length > 0;
    }

    if (valid) {
        if ([self.editingTitleViewController respondsToSelector:@selector(titleChanged:)]) {
            [self.editingTitleViewController titleChanged:object];
        }
    }

    return valid;
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
    return fieldEditor.string.length > 0;
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

@end
