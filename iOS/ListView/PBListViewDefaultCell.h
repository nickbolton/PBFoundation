//
//  PBListViewDefaultCell.h
//  Pods
//
//  Created by Nick Bolton on 12/9/13.
//
//

#import <UIKit/UIKit.h>

@class PBListViewItem;

@interface PBListViewDefaultCell : UITableViewCell

@property (nonatomic, strong) PBListViewItem *item;
@property (nonatomic) UITableView *tableView;

@end
