//
//  DYSDelegateViewController.m
//  MemoryLeakDemo
//
//  Created by 丁玉松 on 2018/11/6.
//  Copyright © 2018 丁玉松. All rights reserved.
//

#import "DYSDelegateViewController.h"
#import "DYSCat.h"

@interface DYSDelegateViewController ()<DYSCatFoodProvider>

@property (nonatomic, strong) DYSCat *cat;

@end

@implementation DYSDelegateViewController

- (void)dealloc {
    NSLog(@"%@释放了",NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    DYSCat *cat = [DYSCat new];
    [cat eat];
    //2018-11-07 17:22:04.645107+0800 MemoryLeakDemo[36038:3718921] 没有铲屎官提供食物，要饿死啦

    cat.delegate = self;
    [cat eat];
    //2018-11-07 17:22:51.230623+0800 MemoryLeakDemo[36068:3720876] 铲屎官没有提供食物，挨饿呀
    
    //实现提供食物方法后
    //2018-11-07 17:38:49.658927+0800 MemoryLeakDemo[36266:3738381] 铲屎官提供5份食物，饱餐一顿

    self.cat = cat;
}

- (NSInteger)provideFood{
    return 5;
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
