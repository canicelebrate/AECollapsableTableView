//
//  AECollapsableTableView.h
//  AECollapsableTableViewDemo
//
//  Created by WangLin on 16/9/28.
//  Copyright © 2016年 amberease. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface AECollapsableTableView : UITableView
@property IBInspectable (nonatomic,assign) BOOL initialCollapsedAll;

/** Returns YES if the specified section is expanded. */
- (BOOL)isExpandedSection:(NSInteger)section;

/** Collapses all expanded sections.
 */
- (void)collapseAllSections;

/** Expand all collapsed sections.
 */
-(void)expandAllSections;

/**
 *  Toggle section's collapsable state between collapsed and expanded
 */
-(void)toggleCollapsableSection:(NSInteger)section;
@end
