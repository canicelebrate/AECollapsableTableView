//
//  AECollapsableTableView.m
//  AECollapsableTableViewDemo
//
//  Created by WangLin on 16/9/28.
//  Copyright © 2016年 amberease. All rights reserved.
//

#import "AECollapsableTableView.h"

@interface AECollapsableTableView()<UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray* expandedSections;
@property (nonatomic, weak) id<UITableViewDataSource> myDataSource;

@end

@implementation AECollapsableTableView

#pragma mark - Constructors
/*
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}
//*/

#pragma mark - Public Methods
- (NSMutableArray *)expandedSections {
    if (!_expandedSections) {
        _expandedSections = [NSMutableArray array];
        NSInteger maxI = [self.dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)] ? [self.dataSource numberOfSectionsInTableView:self] : 0;
        for (NSInteger i = 0; i < maxI; i++) {
            NSNumber* value = @YES;
            if(self.initialCollapsedAll){
                value = @NO;
            }
            else{
                BOOL isCollapsedSection = [self.initialCollapsedStatus[@(i)] boolValue];
                if(isCollapsedSection){
                    value = @NO;
                }
            }
            [_expandedSections addObject:value];
        }
    }
    return _expandedSections;
}


- (BOOL)isExpandedSection:(NSInteger)section {
    return [self.expandedSections[section] boolValue];
}


- (void)collapseAllSections {
    NSArray* expandedSectionIndexPaths = [self expandedSectionIndexPaths];
    NSArray* itemsNeedToBeCollapsed = [self indexPathsForSectionIndexPaths:expandedSectionIndexPaths];
    
    if(expandedSectionIndexPaths.count > 0){
        //1.row changes
        [self beginUpdates];
        //a. refect changes in model
        [self updateSectionsForSectionIndexPaths:expandedSectionIndexPaths asExpanded:NO];
        
        //b. delete roes animation
        [self deleteRowsAtIndexPaths:itemsNeedToBeCollapsed withRowAnimation:UITableViewRowAnimationAutomatic];
        
        //c.reload affected sections
        NSMutableIndexSet* indexSet = [[NSMutableIndexSet alloc] init];
        for(NSIndexPath* sectionIndexPath in expandedSectionIndexPaths){
            [indexSet addIndex:sectionIndexPath.section];
        }
        [self reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
        
        [self endUpdates];
        
        
    }
}

-(void)expandAllSections{
    NSArray* collapsedSectionIndexPaths = [self collapsedSectionIndexPaths];
    NSArray* itemsNeedToBeExpanded = [self indexPathsForSectionIndexPaths:collapsedSectionIndexPaths];
    
    if(collapsedSectionIndexPaths.count > 0){
        //row changes animation
        
        [self beginUpdates];
        //a. refect changes in model
        [self updateSectionsForSectionIndexPaths:collapsedSectionIndexPaths asExpanded:YES];
        

        //b. insert rows
        [self insertRowsAtIndexPaths:itemsNeedToBeExpanded withRowAnimation:UITableViewRowAnimationAutomatic];
 
        
        //c. reload affected section
        NSMutableIndexSet* indexSet = [[NSMutableIndexSet alloc] init];
        for(NSIndexPath* sectionIndexPath in collapsedSectionIndexPaths){
            [indexSet addIndex:sectionIndexPath.section];
        }
        [self reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
        
        
        [self endUpdates];
        
    }
}

-(void)toggleCollapsableSection:(NSInteger)section{
    
    BOOL willOpen = ![self.expandedSections[section] boolValue];
    NSArray* indexPaths = [self indexPathsForSection:section];
//    NSArray* expandedSectionIndexPaths = willOpen ? [self expandedSectionIndexPaths] : @[];
    CGFloat oldContentHeight = self.contentSize.height;
    __block CGFloat newContentHeight = 0.0f;
    
    [self beginUpdates];
    
    if(willOpen){
        //delete the dummy cell with zero frame
        //[self deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:section]] withRowAnimation:UITableViewRowAnimationNone];
        
        [self insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    }
    else{
        [self deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        
        //insert the dummy cell with zero frame
        //[self insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:section]] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    //[self updateExpandedSectionsForSectionIndexPaths:expandedSectionIndexPaths];
    self.expandedSections[section] = @(willOpen);
    
    [self reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
    [self endUpdates];
    
    

    

    
    //update scroll offset
    if (willOpen) {
        newContentHeight = self.contentSize.height;
        CGFloat offset = newContentHeight - oldContentHeight;
        
        
        CGFloat boundsHeight = self.bounds.size.height;
        
        UIView* headerView = [self headerViewForSection:section];
        
        CGFloat sectionTop = headerView.frame.origin.y;
        CGFloat headerHeight = headerView.frame.size.height;
        
        if ((sectionTop + offset + headerHeight) <= (self.contentOffset.y + boundsHeight)) {
            //展开后，如果section头位置不动，当前视窗可以容纳所有新内容
            //什么也不做
            //Current window can accomodate the content of expanded section without scrolling the section head
            //no need to do anything
            
        }
        else{
            if((headerHeight + offset) > boundsHeight){
                //展开后新的section的内容的高度，超过整个窗体的大小,将当前的section头置顶
                //The content size of the expanded section exceeded the size of the bounds of the UICollectionView, we need to have the section head pin to top edge of the UICollectionView
                [self setContentOffset:CGPointMake(0,sectionTop) animated:YES];
            }
            else{
                //展开后，需要将内容向上滚动以显示所有新的内容
                //Otherwise, Have the bottom edge of the section pin to the bottom edge of the UICollectionView's bounds
                CGFloat offsetMovement =  (sectionTop + headerHeight + offset) - (self.contentOffset.y + boundsHeight);
                [self setContentOffset:CGPointMake(0, self.contentOffset.y + offsetMovement)];
                
            }
        }
        
        /*
         if ([self.delegate respondsToSelector:@selector(collectionView:didExpandItemAtSection:)]) {
         [self.delegate collectionView:self didExpandItemAtSection:section];
         }
         //*/
    }
    
    
    
}

#pragma mark - Help Methods

- (NSArray*)indexPathsForSection:(NSInteger)section {
    NSMutableArray* indexPaths = [NSMutableArray array];
    NSInteger maxI = [self.myDataSource tableView:self numberOfRowsInSection:section];
    for (NSInteger i = 0;i < maxI; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:section]];
    }
    return [indexPaths copy];
}

- (NSArray*)expandedSectionIndexPaths {
    NSMutableArray* sectionIndexPaths = [NSMutableArray array];

    for (NSInteger i = 0; i < self.numberOfSections; i++) {
        if ([self isExpandedSection:i]) {
            [sectionIndexPaths addObject:[NSIndexPath indexPathForItem:0 inSection:i]];
        }
        
    }
    return [sectionIndexPaths copy];
}


-(NSArray*)collapsedSectionIndexPaths{
    NSMutableArray* sectionIndexPaths = [NSMutableArray array];
    
    for (NSInteger i = 0; i < self.numberOfSections; i++) {
        if (![self isExpandedSection:i]) {
            [sectionIndexPaths addObject:[NSIndexPath indexPathForItem:0 inSection:i]];
        }
        
    }
    return [sectionIndexPaths copy];
}

/**
 *  根据包含分区信息的数组获得含有指定分区中的所有行的数组
 */
- (NSArray*)indexPathsForSectionIndexPaths:(NSArray*)sectionIndexPaths {
    NSArray* indexPaths = @[];
    for (NSIndexPath* sectionIndexPath in sectionIndexPaths) {
        indexPaths = [indexPaths arrayByAddingObjectsFromArray:[self indexPathsForSection:sectionIndexPath.section]];
    }
    return indexPaths;
}

/**
 *  恢复expandedSections中所有数组元素的初始值为NO
 */
- (void)updateSectionsForSectionIndexPaths:(NSArray*)sectionIndexPaths asExpanded:(BOOL)expanded{
    for (NSIndexPath* sectionIndexPath in sectionIndexPaths) {
        self.expandedSections[sectionIndexPath.section] = @(expanded);
    }
}



#pragma mark - Override Methods
- (id<UITableViewDataSource>)dataSource {
    return [super dataSource];
}

- (void)setDataSource:(id<UITableViewDataSource>)dataSource {
    _myDataSource = dataSource;
    [super setDataSource:self];
}

#pragma mark - UITableViewDataSource

#pragma mark - UITableViewDataSource Core
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger numberOfRowsInSection = [self.myDataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)]?[self.myDataSource tableView:self numberOfRowsInSection:section]:0;
    
    if([self isExpandedSection:section] == YES)
    {
        return numberOfRowsInSection;
    }
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.myDataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]?[self.myDataSource numberOfSectionsInTableView:tableView]:0;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.myDataSource respondsToSelector:@selector(tableView:cellForRowAtIndexPath:)]?[self.myDataSource tableView:tableView cellForRowAtIndexPath:indexPath]:[[UITableViewCell alloc] initWithFrame:CGRectZero];
}

#pragma mark - UITableViewDataSource Other Methods
// fixed font style. use custom view (UILabel) if you want something different
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [self.myDataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)]?[self.myDataSource tableView:tableView titleForHeaderInSection:section]:nil;
}


- (nullable NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    return [self.myDataSource respondsToSelector:@selector(tableView:titleForFooterInSection:)]?[self.myDataSource tableView:tableView titleForFooterInSection:section]:nil;
}

// Editing

// Individual rows can opt out of having the -editing property set for them. If not implemented, all rows are assumed to be editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.myDataSource respondsToSelector:@selector(tableView:canEditRowAtIndexPath:)]?[self.myDataSource tableView:tableView canEditRowAtIndexPath:indexPath]:NO;
}

// Moving/reordering

// Allows the reorder accessory view to optionally be shown for a particular row. By default, the reorder control will be shown only if the datasource implements -tableView:moveRowAtIndexPath:toIndexPath:
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.myDataSource respondsToSelector:@selector(tableView:canMoveRowAtIndexPath:)]?[self.myDataSource tableView:tableView canMoveRowAtIndexPath:indexPath]:NO;
}

// Index

// return list of section titles to display in section index view (e.g. "ABCD...Z#")
- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView __TVOS_PROHIBITED{
    return [self.myDataSource respondsToSelector:@selector(sectionIndexTitlesForTableView:)]?[self.dataSource sectionIndexTitlesForTableView:tableView]:nil;
}

// tell table which section corresponds to section title/index (e.g. "B",1))
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index __TVOS_PROHIBITED{
    return [self.myDataSource respondsToSelector:@selector(tableView:sectionForSectionIndexTitle:atIndex:)]?[self.myDataSource tableView:tableView sectionForSectionIndexTitle:title atIndex:index]:0;
}

// Data manipulation - insert and delete support

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
// Not called for edit actions using UITableViewRowAction - the action's handler will be invoked instead
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if([self.myDataSource respondsToSelector:@selector(tableView:commitEditingStyle:forRowAtIndexPath:)]){
        [self.myDataSource tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }
}

// Data manipulation - reorder / moving support

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    if([self.myDataSource respondsToSelector:@selector(tableView:moveRowAtIndexPath:toIndexPath:)]){
        [self.myDataSource tableView:tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
    }
}



@end
