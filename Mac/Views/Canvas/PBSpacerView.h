//
//  PBSpacerView.h
//  Pods
//
//  Created by Nick Bolton on 6/26/13.
//
//

#import "PBAcceptsFirstView.h"

@class PBGuideView;
@class PBResizableView;
@class PBSpacerView;

@protocol PBSpacerProtocol <PBAcceptsFirstViewDelegate>

@optional
- (void)spacerViewClicked:(PBSpacerView *)spacerView;

@end

@interface PBSpacerView : PBAcceptsFirstView

- (id)initWithLeftView:(PBGuideView *)leftView
             rightView:(PBGuideView *)rightView
                 value:(CGFloat)value;

- (id)initWithTopView:(PBGuideView *)topView
           bottomView:(PBGuideView *)bottomView
                value:(CGFloat)value;

@property (nonatomic, strong) PBResizableView *view1;
@property (nonatomic, strong) PBResizableView *view2;
@property (nonatomic, strong) NSColor *spacerColor;
@property (nonatomic, strong) NSColor *constrainingSpacerColor;
@property (nonatomic, getter = isConstraining) BOOL constraining;
@property (nonatomic) CGFloat value;
@property (nonatomic) CGFloat scale;

- (void)updateValue:(CGFloat)value
            forView:(PBResizableView *)view
       andViewFrame:(NSRect)viewFrame
            animate:(BOOL)animate;

- (NSDictionary *)dataSource;
- (void)updateFromDataSource:(NSDictionary *)dataSource;
- (PBSpacerView *)overlappingSpacerView;

@end
