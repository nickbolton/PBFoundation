//
//  UINavigationController+PBFoundation.m
//  PBFoundation
//
//  Created by Nick Bolton on 11/30/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "UINavigationController+PBFoundation.h"

@implementation UINavigationController (PBFoundation)

+ (UINavigationController *)presentViewController:(UIViewController *)viewController
                               fromViewController:(UIViewController *)presentingViewController
                                       completion:(void(^)(void))completionBlock {
    return
    [self 
     presentViewController:viewController
     fromViewController:presentingViewController
     transitioningDelegate:nil
     completion:completionBlock];
}

+ (UINavigationController *)presentViewController:(UIViewController *)viewController
                               fromViewController:(UIViewController *)presentingViewController
                            transitioningDelegate:(id <UIViewControllerTransitioningDelegate>)transitioningDelegate
                                       completion:(void(^)(void))completionBlock {

    UINavigationController *navigationController =
    [[UINavigationController alloc]
     initWithRootViewController:viewController];

    navigationController.transitioningDelegate = transitioningDelegate;

    [presentingViewController
     presentViewController:navigationController
     animated:YES
     completion:completionBlock];

    return navigationController;
}

@end
