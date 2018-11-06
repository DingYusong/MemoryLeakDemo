//
//  DYSKVOViewController.m
//  MemoryLeakDemo
//
//  Created by 丁玉松 on 2018/11/6.
//  Copyright © 2018 丁玉松. All rights reserved.
//

#import "DYSKVOViewController.h"

//变量总是先声明后初始化的。其中初始化是可选的。所以当编译器看到static void* a的时候就可以认为是已经分配好了a的空间，这时a的地址也就有效了。
static void *DYSKVOViewControllerObserverContextName = &DYSKVOViewControllerObserverContextName;

@interface DYSKVOViewController ()
//@property (nonatomic, strong) DYSDog *dog;
@property (nonatomic, copy) NSArray *nameArray;

@end

@implementation DYSKVOViewController

- (void)dealloc {
    //      1. 已经remove过之后再次remove会导致程序crash。
//    [self.dog removeObserver:self forKeyPath:@"name"];
//    [self.dog removeObserver:self forKeyPath:@"name"];
    
//    @try {
//        [self.dog removeObserver:self forKeyPath:@"name"];
//        [self.dog removeObserver:self forKeyPath:@"name"];
//    } @catch (NSException *exception) {
//
//    } @finally {
//
//    }
    
    [self.dog removeObserver:self forKeyPath:NSStringFromSelector(@selector(fname)) context:DYSKVOViewControllerObserverContextName];

    /**
     1. 已经remove过之后再次remove会导致程序crash。
        在同一个类内remove两次，也可能是父类和子类remove同一个对象的监听。
        KVO的一种缺陷(其实不能称为缺陷，应该称为特性)是，当对同一个 keypath进行两次removeObserver时会导致程序crash，这种情况常常出现在父类有一个kvo，父类在dealloc中remove 了一次，子类又remove了一次的情况下。
     
     2018-11-06 13:05:28.596604+0800 MemoryLeakDemo[98221:1989615] [general] Caught exception during autorelease pool drain NSRangeException: Cannot remove an observer <DYSKVOViewController 0x7fbca44362f0> for the key path "name" from <DYSDog 0x600000517020> because it is not registered as an observer. userInfo: (null)
     2018-11-06 13:05:28.602346+0800 MemoryLeakDemo[98221:1989615] *** Terminating app due to uncaught exception 'NSRangeException', reason: 'Cannot remove an observer <DYSKVOViewController 0x7fbca44362f0> for the key path "name" from <DYSDog 0x600000517020> because it is not registered as an observer.'
     *** First throw call stack:
     (
     0   CoreFoundation                      0x0000000108fc31bb __exceptionPreprocess + 331
     1   libobjc.A.dylib                     0x0000000108561735 objc_exception_throw + 48
     2   CoreFoundation                      0x0000000108fc3015 +[NSException raise:format:] + 197
     3   Foundation                          0x0000000107f9e214 -[NSObject(NSKeyValueObserverRegistration) _removeObserver:forProperty:] + 488
     4   Foundation                          0x0000000107f9e69b -[NSObject(NSKeyValueObserverRegistration) removeObserver:forKeyPath:] + 84
     5   MemoryLeakDemo                      0x0000000107c3cb11 -[DYSKVOViewController dealloc] + 177
     6   UIKitCore                           0x000000010b8493de __destroy_helper_block_.150 + 80
     7   libsystem_blocks.dylib              0x000000010a9c2988 _Block_release + 109
     8   UIKitCore                           0x000000010c3068a2 -[UIViewAnimationBlockDelegate .cxx_destruct] + 58
     9   libobjc.A.dylib                     0x0000000108560275 _ZL27object_cxxDestructFromClassP11objc_objectP10objc_class + 127
     10  libobjc.A.dylib                     0x000000010856c12a objc_destructInstance + 136
     11  libobjc.A.dylib                     0x000000010856c161 object_dispose + 22
     12  libobjc.A.dylib                     0x0000000108573dcc _ZN11objc_object17sidetable_releaseEb + 202
     13  CoreFoundation                      0x0000000108fc193d -[__NSDictionaryI dealloc] + 125
     14  libobjc.A.dylib                     0x0000000108573dcc _ZN11objc_object17sidetable_releaseEb + 202
     15  libobjc.A.dylib                     0x00000001085744c7 _ZN12_GLOBAL__N_119AutoreleasePoolPage3popEPv + 795
     16  CoreFoundation                      0x0000000108fe22f6 _CFAutoreleasePoolPop + 22
     17  CoreFoundation                      0x0000000108f22a7e __CFRunLoopRun + 2350
     18  CoreFoundation                      0x0000000108f21e11 CFRunLoopRunSpecific + 625
     19  GraphicsServices                    0x00000001115ba1dd GSEventRunModal + 62
     20  UIKitCore                           0x000000010be2981d UIApplicationMain + 140
     21  MemoryLeakDemo                      0x0000000107c3dfa0 main + 112
     22  libdyld.dylib                       0x000000010a937575 start + 1
     23  ???                                 0x0000000000000001 0x0 + 1
     )
     libc++abi.dylib: terminating with uncaught exception of type NSException
     */
    
    NSLog(@"%@释放了",NSStringFromClass([self class]));
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:@"欢欢改名" forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 0, 100, 50);
    btn.center = self.view.center;
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    self.nameArray = @[@"欢欢",@"牛牛",@"大黄"];
    
//    DYSDog *dog = [DYSDog new];
//    dog.name = @"欢欢";
//    dog.age = 3;
//    self.dog = dog;
    
    [self.dog addObserver:self forKeyPath:NSStringFromSelector(@selector(name)) options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:DYSKVOViewControllerObserverContextName];
//    [self.dog addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];

}

- (void)btnClick:(UIButton *)btn{
    NSInteger num = arc4random()%3;
    self.dog.name = [self.nameArray objectAtIndex:num];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    if (object == self.dog && [keyPath isEqualToString:@"name"] && context == DYSKVOViewControllerObserverContextName) {
        NSLog(@"欢欢改名了叫：%@",self.dog.name);
    }
    else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
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
