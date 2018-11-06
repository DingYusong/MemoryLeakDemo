//
//  DYSKVOSuperViewController.m
//  MemoryLeakDemo
//
//  Created by 丁玉松 on 2018/11/6.
//  Copyright © 2018 丁玉松. All rights reserved.
//

#import "DYSKVOSuperViewController.h"

static void *DYSKVOSuperViewControllerObserverContextName = &DYSKVOSuperViewControllerObserverContextName;

@interface DYSKVOSuperViewController ()

@end

@implementation DYSKVOSuperViewController

- (void)dealloc {
    //场景1
//    [self.dog removeObserver:self forKeyPath:@"name"];
//    [self.dog removeObserver:self forKeyPath:@"name"];
    
    //场景2
//    @try {
//        [self.dog removeObserver:self forKeyPath:@"name"];
//        [self.dog removeObserver:self forKeyPath:@"name"];
//    } @catch (NSException *exception) {
//        NSLog(@"%@",exception.reason);
//    } @finally {
//
//    }
    //场景3
    [self.dog removeObserver:self forKeyPath:@"name" context:DYSKVOSuperViewControllerObserverContextName];
    
    NSLog(@"%@释放了",NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    DYSDog *dog = [DYSDog new];
    dog.name = @"欢欢";
    dog.age = 3;
    self.dog = dog;
    
    //场景1
    //[self.dog addObserver:self forKeyPath:NSStringFromSelector(@selector(name)) options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];

    [self.dog addObserver:self forKeyPath:NSStringFromSelector(@selector(name)) options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:DYSKVOSuperViewControllerObserverContextName];
    
//    对象监听在对象实例化事前，会导致crash
//    DYSDog *dog = [DYSDog new];
//    dog.name = @"欢欢";
//    dog.age = 3;
//    self.dog = dog;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    if (object == self.dog && [keyPath isEqualToString:@"name"] && context == DYSKVOSuperViewControllerObserverContextName) {
        NSLog(@"欢欢改名了叫：%@",self.dog.name);
    }
    else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

@end
