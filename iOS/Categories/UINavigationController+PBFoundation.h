//
//  UINavigationController+PBFoundation.h
//  PBFoundation
//
//  Created by Nick Bolton on 11/30/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (PBFoundation)

+ (UINavigationController *)presentViewController:(UIViewController *)viewController
                               fromViewController:(UIViewController *)presentingViewController
                                       completion:(void(^)(void))completionBlock;

+ (UINavigationController *)presentViewController:(UIViewController *)viewController
                               fromViewController:(UIViewController *)presentingViewController
                            transitioningDelegate:(id <UIViewControllerTransitioningDelegate>)transitioningDelegate
                                       completion:(void(^)(void))completionBlock;

@end
