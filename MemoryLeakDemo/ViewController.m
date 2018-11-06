//
//  ViewController.m
//  MemoryLeakDemo
//
//  Created by 丁玉松 on 2018/11/6.
//  Copyright © 2018 丁玉松. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, copy) NSArray *dataSourceArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"内存泄露";
    
    self.dataSourceArray = @[
                             @{
                                 @"title":@"DYSKVOViewController",
                                 @"page":@"DYSKVOViewController"
                                 },
                             @{
                                 @"title":@"DYSNSNotificationViewController",
                                 @"page":@"DYSNSNotificationViewController"
                                 },
                             @{
                                 @"title":@"DYSDelegateViewController",
                                 @"page":@"DYSDelegateViewController"
                                 },
                             @{
                                 @"title":@"DYSBlockViewController",
                                 @"page":@"DYSBlockViewController"
                                 },
                             @{
                                 @"title":@"DYSNSTimerViewController",
                                 @"page":@"DYSNSTimerViewController"
                                 }];
    
    self.tableView.rowHeight = 50;

    // Do any additional setup after loading the view, typically from a nib.
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellID"];
    }
    
    NSDictionary *dict = [self.dataSourceArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [dict objectForKey:@"title"];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dict = [self.dataSourceArray objectAtIndex:indexPath.row];
    NSString *classString = [dict objectForKey:@"page"];
    UIViewController *vc = [NSClassFromString(classString) new];
    vc.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSourceArray.count;
}



@end
