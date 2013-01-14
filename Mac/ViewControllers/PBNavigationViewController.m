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

NSString *kPBNavigationUpdateFrameNotification = @"kPBNavigationUpdateFrameNotification";
NSString *kPBNavigationUpdateContainerNotification = @"kPBNavigationUpdateContainerNotification";
NSString *kPBNavigationEnableUserInteractionNotification = @"kPBNavigationEnableUserInteractionNotification";
NSString *kPBNavigationDisableUserInteractionNotification = @"kPBNavigationDisableUserInteractionNotification";

@interface PBNavigationViewController () <NSTextFieldDelegate> {
    BOOL _editingTitle;
}

@property (nonatomic, readwrite) NSMutableArray *viewControllerStack;

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

    _editableTitleField.delegate = self;
    _editableTitleField;
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

- (void)startPushNavigation:(BOOL)animate duration:(NSTimeInterval)duration {
}

- (void)startPopNavigation:(BOOL)animate duration:(NSTimeInterval)duration {
}

- (void)navigationFinished {
}

- (void)pushViewController:(NSViewController<PBNavigationViewProtocol> *)nextViewController
                   animate:(BOOL)animate {

    if (_editingTitle && _editableTitleField.stringValue.length == 0) {
        NSBeep();
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

    if ([nextViewController respondsToSelector:@selector(needsEditableTitleField)]) {
        _editingTitle = [nextViewController needsEditableTitleField];
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
                  }];                 
             }];
        } else {

            [self startPushNavigation:NO duration:0.0f];

            NSRect frame = newView.frame;
            frame.origin.x = 0;
            newView.frame = frame;

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
                 if ([self.currentViewController respondsToSelector:@selector(viewDidActivate)]) {
                     [self.currentViewController viewDidActivate];
                 }
                 [self navigationFinished];
             }];
        }
    }

}

- (void)popViewController:(BOOL)animate {

    if (_viewControllerStack.count > 1) {

        NSTimeInterval duration = PB_WINDOW_ANIMATION_DURATION;

        NSViewController<PBNavigationViewProtocol> *currentViewController = self.currentViewController;
        NSViewController<PBNavigationViewProtocol> *nextViewController = [_viewControllerStack objectAtIndex:_viewControllerStack.count - 2];

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
                 [self.currentViewController.view removeFromSuperview];

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

                      if ([self.currentViewController respondsToSelector:@selector(viewDidDeactivate)]) {
                          [self.currentViewController viewDidDeactivate];
                      }

                      if ([nextViewController respondsToSelector:@selector(viewDidAppear)]) {
                          [nextViewController viewDidAppear];
                      }

                      [_viewControllerStack removeLastObject];
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
             }];
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
        if ([self.currentViewController respondsToSelector:@selector(titleChanged:)]) {
            [self.currentViewController titleChanged:object];
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
