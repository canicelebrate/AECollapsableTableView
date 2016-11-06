//
//  ViewController.m
//  AECollapsableTableViewDemo
//
//  Created by WangLin on 16/9/28.
//  Copyright © 2016年 amberease. All rights reserved.
//

#import "ViewController.h"
#import "AECollapsableTableView.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) NSArray* metaData;
@property (weak, nonatomic) IBOutlet AECollapsableTableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _metaData = @[@{@"title":@"header",@"data":@[@"item",@"item",@"item",@"item"]},
                  @{@"title":@"header",@"data":@[@"item",@"item",@"item",@"item"]},
                  @{@"title":@"header",@"data":@[@"item",@"item",@"item",@"item"]},
                  @{@"title":@"header",@"data":@[@"item",@"item",@"item",@"item"]}];
    UINib* nib = [UINib nibWithNibName:@"HeaderView" bundle:nil];
    [self.tableView registerNib:nib forHeaderFooterViewReuseIdentifier:@"Header"];
    
    self.tableView.initialCollapsedStatus = @{@1:@YES};
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    UILabel* lbl = [cell.contentView viewWithTag:2];
    
    NSArray* items = [self.metaData[indexPath.section] objectForKey:@"data"];
    NSString* item = items[indexPath.row];
    
    [lbl setText:[NSString stringWithFormat:@"%@%ld",item,indexPath.row]];
    
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.metaData.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray* items = [self.metaData[section] objectForKey:@"data"];
    return items.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}


#pragma mark - UITableViewDelegate
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UITableViewHeaderFooterView* header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"Header"];
    UILabel* lbl = [header viewWithTag:1];
    
    NSString* headerTitle = [self.metaData[section] objectForKey:@"title"];
    
    NSString* expandedSign = @"+";
    if([self.tableView isExpandedSection:section]){
        expandedSign = @"-";
    }
    
    [lbl setText:[NSString stringWithFormat:@"%@    %@%ld",expandedSign,headerTitle,section]];
    
    
    if([self headerViewInitialized:header] == NO){
        UITapGestureRecognizer* tapGestr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onHeadTapped:)];
        tapGestr.cancelsTouchesInView = NO;
        
        [header addGestureRecognizer:tapGestr];
    }
    
    header.tag = section;
    return header;
 
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}


#pragma mark - Event Handlers
-(void)onHeadTapped:(UITapGestureRecognizer*)gestr{
    UIView* headerView = [gestr view];

    
    [self.tableView toggleCollapsableSection:headerView.tag];

    
}

-(BOOL)headerViewInitialized:(UIView*)container{
    for (UIGestureRecognizer* gestr in container.gestureRecognizers) {
        if([gestr isKindOfClass:[UITapGestureRecognizer class]]){
            return YES;
        }
    }
    return NO;
}

- (IBAction)onCollapsedAllTapped:(id)sender {
    [self.tableView collapseAllSections];
}

- (IBAction)onExpandAllTapped:(id)sender {
    [self.tableView expandAllSections];
}


@end
