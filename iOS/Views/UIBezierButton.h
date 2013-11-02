//
//  UIBezierButton.h
//  PBFoundation
//
//  Created by Nick Bolton on 11/26/12.
//  Copyright (c) 2012 Pixelbleed LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBezierButton : UIButton

- (void)setBezierPath:(UIBezierPath *)bezierPath
      forControlState:(UIControlState)controlState;
- (void)setPathStrokeColor:(UIColor *)pathStrokeColor
           forControlState:(UIControlState)controlState;
- (void)setPathFillColor:(UIColor *)pathFillColor
         forControlState:(UIControlState)controlState;

@end
