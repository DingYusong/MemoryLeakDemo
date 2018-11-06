//
//  DYSNSTimerViewController.m
//  MemoryLeakDemo
//
//  Created by 丁玉松 on 2018/11/6.
//  Copyright © 2018 丁玉松. All rights reserved.
//

#import "DYSNSTimerViewController.h"

@interface DYSNSTimerViewController ()


/**
 self强引用timer，timer强引用self,形成引用循环不能释放，引用计数不会为0，除非强制某一方为nil
 */
//@property (nonatomic, strong) NSTimer *timer;


/**
 timer强引用
 */
@property (nonatomic, weak) NSTimer *timer;

@end

@implementation DYSNSTimerViewController

static const NSTimeInterval timerInterval = 2;

/**
 　由于Objective-C采用引用计数管理对象的生命周期，所以为了避免循环引用导致对象无法释放，最终导致内存泄漏，这里Target-Action中的Target通常不会被retain的，所以这就需要我们保证Target不被过早地释放。但是，这里有一个特例NSTimer， 其机制类似于延时触发，为了保证timer耗尽时target还未被释放，NSTimer会持有Target直到NSTimer收到invalidate消息。这一点尤其需要注意，大部分的Target都不会被持有，只有NSTimer 除外，因为其延时触发的机制所需要。另外，对于一个repeat NSTimer在不需要时，一定要调用NSTimer的invalidate消息，否则target不会被释放。此外，调用invalidate消息的地方也很重要，通常是在Action方法中调用invalidate消息，有些同学可能会在Target的dealloc方法中调用NSTimer的invalidate消息，这样是会出问题的，由于NSTimer持有Target，所以只有NSTimer释放之后才有机会调用Target的dealloc方法，这钟写法将导致内存泄漏。
 */
-(void)dealloc {
    [self.timer invalidate];
    NSLog(@"%@释放了",NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self)weakSelf = self;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:timerInterval target:weakSelf selector:@selector(timerPolling) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    // Do any additional setup after loading the view.
}

- (void)timerPolling {
    NSLog(@"do something");
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.timer invalidate];
//    self.timer = nil;
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
