//
//  BDButton.h
//  BerlinDecision
//
//  Created by Nick Bolton on 7/13/13.
//  Copyright (c) 2013 MutualMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BDButton : UIButton

- (void)setBezierPath:(UIBezierPath *)bezierPath
      forControlState:(UIControlState)controlState;
- (void)setPathStrokeColor:(UIColor *)pathStrokeColor
           forControlState:(UIControlState)controlState;
- (void)setPathFillColor:(UIColor *)pathFillColor
         forControlState:(UIControlState)controlState;

@end
