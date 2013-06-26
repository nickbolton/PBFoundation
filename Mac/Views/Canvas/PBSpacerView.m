//
//  PBSpacerView.m
//  Pods
//
//  Created by Nick Bolton on 6/26/13.
//
//

#import "PBSpacerView.h"
#import "PBGuideView.h"
#import "PBDrawingCanvas.h"

static NSImage *PBSpacerViewUpImage = nil;
static NSImage *PBSpacerViewDownImage = nil;
static NSImage *PBSpacerViewLeftImage = nil;
static NSImage *PBSpacerViewRightImage = nil;

@interface PBSpacerView() {

    BOOL _vertical;
}

@property (nonatomic, readwrite) PBGuideView *view1;
@property (nonatomic, readwrite) PBGuideView *view2;
@property (nonatomic) CGFloat value;

@end

@implementation PBSpacerView

+ (void)setUpSpacerImage:(NSImage *)image {
    PBSpacerViewUpImage = image;
}

+ (void)setDownSpacerImage:(NSImage *)image {
    PBSpacerViewDownImage = image;
}

+ (void)setLeftSpacerImage:(NSImage *)image {
    PBSpacerViewLeftImage = image;
}

+ (void)setRightSpacerImage:(NSImage *)image {
    PBSpacerViewRightImage = image;
}

+ (NSImage *)upSpacerImage {
    if (PBSpacerViewUpImage == nil) {
        PBSpacerViewUpImage = [NSImage imageNamed:@"arrowUp"];
    }
    return PBSpacerViewUpImage;
}

+ (NSImage *)downSpacerImage {
    if (PBSpacerViewDownImage == nil) {
        PBSpacerViewDownImage = [NSImage imageNamed:@"arrowDown"];
    }
    return PBSpacerViewDownImage;
}

+ (NSImage *)leftSpacerImage {
    if (PBSpacerViewLeftImage == nil) {
        PBSpacerViewLeftImage = [NSImage imageNamed:@"arrowLeft"];
    }
    return PBSpacerViewLeftImage;
}

+ (NSImage *)rightSpacerImage {
    if (PBSpacerViewRightImage == nil) {
        PBSpacerViewRightImage = [NSImage imageNamed:@"arrowRight"];
    }
    return PBSpacerViewRightImage;
}

- (id)initWithLeftView:(PBGuideView *)leftView
             rightView:(PBGuideView *)rightView
                 value:(CGFloat)value {

    CGFloat height =
    MAX([PBSpacerView leftSpacerImage].size.height,
        [PBSpacerView rightSpacerImage].size.height);

    NSRect frame = NSMakeRect(0.0f, 0.0f, value, height);

    self = [super initWithFrame:frame];

    if (self != nil) {
        self.view1 = leftView;
        self.view2 = rightView;
        self.value = value;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self initializeHorizontal];
    }

    return self;
}

- (id)initWithTopView:(PBGuideView *)topView
           bottomView:(PBGuideView *)bottomView
                value:(CGFloat)value {

    CGFloat height =
    MAX([PBSpacerView leftSpacerImage].size.height,
        [PBSpacerView rightSpacerImage].size.height);

    NSRect frame = NSMakeRect(0.0f, 0.0f, value, height);

    self = [super initWithFrame:frame];

    if (self != nil) {
        self.view1 = topView;
        self.view2 = bottomView;
        self.value = value;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self initializeVertical];
    }

    return self;

}

- (void)initializeHorizontal {

    _vertical = NO;

    NSRect frame =
    NSMakeRect(0.0,
               (NSHeight(self.frame) - 1.0f) / 2.0f,
               _value,
               1.0f);

    PBGuideView *guideView = [self buildGuideView:frame];
    guideView.frame = frame;
    guideView.translatesAutoresizingMaskIntoConstraints = NO;

    [self addSubview:guideView];

    [NSLayoutConstraint addHeightConstraint:1.0f toView:guideView];
    [NSLayoutConstraint expandWidthToSuperview:guideView];
    [NSLayoutConstraint verticallyCenterView:guideView];
}

- (void)initializeVertical {

    _vertical = YES;
    
    NSRect frame =
    NSMakeRect((NSWidth(self.frame) - 1.0f) / 2.0f,
               0.0f,
               1.0f,
               _value);

    PBGuideView *guideView = [self buildGuideView:frame];
    guideView.frame = frame;
    guideView.translatesAutoresizingMaskIntoConstraints = NO;

    [self addSubview:guideView];

    [NSLayoutConstraint addWidthConstraint:1.0f toView:guideView];
    [NSLayoutConstraint expandHeightToSuperview:guideView];
}

- (PBGuideView *)buildGuideView:(NSRect)frame {
    PBGuideView *view = [[PBGuideView alloc] initWithFrame:frame];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.vertical = _vertical;
    return view;
}

- (void)alignToViews {

    if (_vertical) {

        [self constrainCenterToLeftOfView:_view1];
        [self constrainCenterToRightOfView:_view1];
        [self constrainCenterToLeftOfView:_view2];
        [self constrainCenterToRightOfView:_view2];

    } else {

        [self constrainCenterToTopOfView:_view1];
        [self constrainCenterToBottomOfView:_view1];
        [self constrainCenterToTopOfView:_view2];
        [self constrainCenterToBottomOfView:_view2];
    }
}

- (void)constrainCenterToBottomOfView:(NSView *)view {

    NSLayoutConstraint *constraint =
    [NSLayoutConstraint
     constraintWithItem:self
     attribute:NSLayoutAttributeCenterY
     relatedBy:NSLayoutRelationGreaterThanOrEqual
     toItem:view
     attribute:NSLayoutAttributeBottom
     multiplier:1.0f
     constant:0.0f];
    [self.superview addConstraint:constraint];
}

- (void)constrainCenterToTopOfView:(NSView *)view {

    NSLayoutConstraint *constraint =
    [NSLayoutConstraint
     constraintWithItem:self
     attribute:NSLayoutAttributeCenterY
     relatedBy:NSLayoutRelationLessThanOrEqual
     toItem:view
     attribute:NSLayoutAttributeTop
     multiplier:1.0f
     constant:0.0f];
    [self.superview addConstraint:constraint];
}

- (void)constrainCenterToLeftOfView:(NSView *)view {

    NSLayoutConstraint *constraint =
    [NSLayoutConstraint
     constraintWithItem:self
     attribute:NSLayoutAttributeCenterX
     relatedBy:NSLayoutRelationGreaterThanOrEqual
     toItem:view
     attribute:NSLayoutAttributeLeft
     multiplier:1.0f
     constant:0.0f];
    [self.superview addConstraint:constraint];
}

- (void)constrainCenterToRightOfView:(NSView *)view {

    NSLayoutConstraint *constraint =
    [NSLayoutConstraint
     constraintWithItem:self
     attribute:NSLayoutAttributeCenterX
     relatedBy:NSLayoutRelationLessThanOrEqual
     toItem:view
     attribute:NSLayoutAttributeRight
     multiplier:1.0f
     constant:0.0f];
    [self.superview addConstraint:constraint];
}

@end

