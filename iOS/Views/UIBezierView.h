//
//  UIBezierView.h
//  PBFoundation
//
//  Created by Nick Bolton on 11/26/12.
//  Copyright (c) 2012 Pixelbleed LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBezierView : UIView

@property (nonatomic, strong) UIBezierPath *bezierPath;
@property (nonatomic, strong) UIColor *pathStrokeColor;
@property (nonatomic, strong) UIColor *pathFillColor;
@property (nonatomic, strong) UIImage *blurImage;

@end
