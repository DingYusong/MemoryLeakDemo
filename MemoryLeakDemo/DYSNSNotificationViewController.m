//
//  DYSNSNotificationViewController.m
//  MemoryLeakDemo
//
//  Created by 丁玉松 on 2018/11/6.
//  Copyright © 2018 丁玉松. All rights reserved.
//

#import "DYSNSNotificationViewController.h"
#import "DYSBird.h"

@interface DYSNSNotificationViewController ()
@property (nonatomic, copy) NSString *name;

@end

@implementation DYSNSNotificationViewController

NSString *NSNotificationNameUserLogin = @"NSNotificationNameUserLogin";

- (void)dealloc {
    NSLog(@"%@释放了",NSStringFromClass([self class]));
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSNotificationNameUserLogin object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.name = @"丁玉松";


    for (int i = 0; i < 3; i++) {

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyUserLogin) name:NSNotificationNameUserLogin object:nil];
    }
    DYSBird *bird = [DYSBird new];
    [bird sendNotification];

    
    
    __weak typeof(self)weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:NSNotificationNameUserLogin object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        NSLog(@"%@",strongSelf.name);
    }];
    
    
}

- (void)notifyUserLogin{
    NSLog(@"用户登录");
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
