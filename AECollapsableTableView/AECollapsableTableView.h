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

/*
 * @parameter initialCollapsedStatus
 * @remark 控制tableview中初始的section是否处于收缩状态，
 * 定义：Map    key = section index, value = YES|NO
 * 如果某个section没有置顶是否是collapsed，那么默认就是expanded
 * 如果在storyboard中定义了initialCollapsedAll，那该设置会被忽略
 */
@property (nonatomic,strong) NSDictionary* initialCollapsedStatus;

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
