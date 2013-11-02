//
//  BDView.h
//  BerlinDecision
//
//  Created by Nick Bolton on 7/13/13.
//  Copyright (c) 2013 MutualMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BDView : UIView

@property (nonatomic, strong) UIBezierPath *bezierPath;
@property (nonatomic, strong) UIColor *pathStrokeColor;
@property (nonatomic, strong) UIColor *pathFillColor;
@property (nonatomic, strong) UIImage *blurImage;

@end
