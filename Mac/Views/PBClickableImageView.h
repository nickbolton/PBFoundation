//
//  PBClickableImageView.h
//  Pods
//
//  Created by Nick Bolton on 6/11/13.
//
//

#import <Cocoa/Cocoa.h>
#import "PBMoveableView.h"

@interface PBClickableImageView : NSImageView

@property (nonatomic, weak) IBOutlet id <PBMoveableViewDelegate> delegate;

@property (nonatomic, getter = isEnabled) BOOL enabled;
@property (nonatomic, getter = isDragging, readonly) BOOL dragging;
@property (nonatomic) NSEdgeInsets screenInsets;
@property (nonatomic) SEL doubleAction;

- (void)commonInit;

@end
