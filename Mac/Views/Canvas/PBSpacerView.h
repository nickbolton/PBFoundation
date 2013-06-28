//
//  PBSpacerView.h
//  Pods
//
//  Created by Nick Bolton on 6/26/13.
//
//

#import <Cocoa/Cocoa.h>

@class PBGuideView;
@class PBResizeableView;

@interface PBSpacerView : NSView

+ (void)setUpSpacerImage:(NSImage *)image;
+ (void)setDownSpacerImage:(NSImage *)image;
+ (void)setLeftSpacerImage:(NSImage *)image;
+ (void)setRightSpacerImage:(NSImage *)image;

- (id)initWithLeftView:(PBGuideView *)leftView
             rightView:(PBGuideView *)rightView
                 value:(CGFloat)value;

- (id)initWithTopView:(PBGuideView *)topView
           bottomView:(PBGuideView *)bottomView
                value:(CGFloat)value;

@property (nonatomic, readonly) PBResizeableView *view1;
@property (nonatomic, readonly) PBResizeableView *view2;

- (void)updateWidth;
- (void)updateHeight;

@end
