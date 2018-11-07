//
//  DYSNSTimerViewController.m
//  MemoryLeakDemo
//
//  Created by 丁玉松 on 2018/11/6.
//  Copyright © 2018 丁玉松. All rights reserved.
//

#import "DYSNSTimerViewController.h"
#import "DYSWeakTimer.h"
#import "DYSTimerProxy.h"
#import <objc/runtime.h>
#import "NSTimer+DYSWeakTimer.h"

@interface DYSNSTimerViewController ()

/**
 self强引用timer，timer强引用self,形成引用循环不能释放，引用计数不会为0，除非强制某一方为nil（例如：[self.timer invalidate]）
 */
//@property (nonatomic, strong) NSTimer *timer;

/**
 timer强引用self,timer不释放（self.timer = nil 只是将指针置为nil，并不会销毁timer实例），self就不能释放。
 */
@property (nonatomic, weak) NSTimer *timer;

@end

@implementation DYSNSTimerViewController

static const NSTimeInterval timerInterval = 1;

static NSInteger count = 1;

/**
 　由于Objective-C采用引用计数管理对象的生命周期，所以为了避免循环引用导致对象无法释放，最终导致内存泄漏，这里Target-Action中的Target通常不会被retain的，所以这就需要我们保证Target不被过早地释放。但是，这里有一个特例NSTimer， 其机制类似于延时触发，为了保证timer耗尽时target还未被释放，NSTimer会持有Target直到NSTimer收到invalidate消息。这一点尤其需要注意，大部分的Target都不会被持有，只有NSTimer 除外，因为其延时触发的机制所需要。另外，对于一个repeat NSTimer在不需要时，一定要调用NSTimer的invalidate消息，否则target不会被释放。此外，调用invalidate消息的地方也很重要，通常是在Action方法中调用invalidate消息，有些同学可能会在Target的dealloc方法中调用NSTimer的invalidate消息，这样是会出问题的，由于NSTimer持有Target，所以只有NSTimer释放之后才有机会调用Target的dealloc方法，这钟写法将导致内存泄漏。
 */
-(void)dealloc {
    if (self.timer.isValid) {
        [self.timer invalidate];
    }
    NSLog(@"%@释放了",NSStringFromClass([self class]));
}

static const void *weakTarget = @"weakTarget";

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    __weak typeof(self)weakSelf = self;
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:timerInterval target:weakSelf selector:@selector(timerPolling) userInfo:nil repeats:YES];

    
    //方案2：timer 持有 DYSWeakTimer ，DYSWeakTimer若持有self，self持有timer，强引用循环被打破，self退栈能正常释放了。
//    self.timer = [DYSWeakTimer weekScheduledTimerWithTimeInterval:timerInterval target:weakSelf selector:@selector(timerPolling) userInfo:nil repeats:YES];
    
    //方案3：利用NSProxy进行消息转发，NSProxy弱持有self。
//    DYSTimerProxy *timerProxy = [[DYSTimerProxy alloc] initWithTarget:self];
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:timerInterval target:timerProxy selector:@selector(timerPolling) userInfo:nil repeats:YES];
    
    //方案4：有利用runtime动态添加方法和弱引用关联对象，原理和方案2一样。
//    NSObject *targetObj = [NSObject new];
//    class_addMethod([targetObj class], @selector(timerPolling), (IMP)timerPollingImp, "v@:");
//    objc_setAssociatedObject(targetObj, weakTarget, self, OBJC_ASSOCIATION_ASSIGN);
//
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:timerInterval target:targetObj selector:@selector(timerPolling) userInfo:nil repeats:YES];

    //方案5：替换target-selector，设置timer的target为自己，用userInfo来传递block。不会出现循环引用。
    __weak typeof(self)weakSelf = self;
    self.timer = [NSTimer weakScheduledTimerWithTimeInterval:timerInterval repeats:YES block:^(NSTimer * _Nonnull timer) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        NSLog(@"do something");
        count++;
        if (5 == count) {
            if (weakSelf.timer.isValid) {
                [weakSelf.timer invalidate];
            }
        }
    }];
    
    
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    // Do any additional setup after loading the view.
}


/**
 (IMP)timerPollingImp 取方法指针
 
 @param self 此处的self是targetObj
 @param _cmd 此处的SEL是timerPolling
 */
void timerPollingImp(id self,SEL _cmd) {
    DYSNSTimerViewController *vc = objc_getAssociatedObject(self, weakTarget);
    if ([vc respondsToSelector:_cmd]) {
        [vc performSelector:_cmd];
    }
}

- (void)timerPolling {
    NSLog(@"do something");
    count++;
    
    //方案1：在合适的时机直接释放timer
//    if (5 == count) {
//        if (self.timer.isValid) {
//            [self.timer invalidate];
//        }
//    }
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //方案1：在合适的时机直接释放timer（不推荐）
//    if (self.timer.isValid) {
//        [self.timer invalidate];
//    }
//    [self.timer invalidate];
//    self.timer = nil;
    
    
}





/*
 总结一些同学们容易犯的问题：
 
 1.timer默认运行在runloop的NSDefaultRunLoopMode 模式下，这在scrollView滑动时，主线程切换到另外一种模式的时候就不会响应，所以需要添加到NSRunLoopCommonModes，具体请见之前文章。
 [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
 
 2.dealloc方法里面写timer的释放是不靠谱的。
    默认timer强持有self，timer不释放，self不会释放。
 
 3.self.timer = nil;的方法来释放timer是不靠谱的，这种写法只是将指针置为nil，而timer实例对象与此关系不大。
    为什么关系不大？有同学问。如果用week修饰timer，那么self.timer = nil;对其引用计数没有任何影响，如果是strong强引用，引用计数会减一，但是不一定到0啊，因为还有runloop对他的强引用。释放timer靠谱的方式是invalidate。
 
 4.在viewDidDisappear写timer的释放是不靠谱的。因为timer的逻辑不一定走完了，如果是进入下一级页面，上级页面逻辑还有用就玩玩啦，这样写太粗暴。
 
 5.传入weaksSelf和weakTimer也不靠谱，传入两个指针变量，虽然是弱类型的，但是传入方法后是怎么引用的没开源，但是从表现来看，应该是强引用了。
 __weak typeof(self)weakSelf = self;
 self.timer = [NSTimer scheduledTimerWithTimeInterval:timerInterval target:weakSelf selector:@selector(timerPolling) userInfo:nil repeats:YES];
 
 __weak typeof(self.timer)weakTimer = self.timer;
 [[NSRunLoop currentRunLoop] addTimer:weakTimer forMode:NSRunLoopCommonModes];

 如何解决循环引用的问题：
    1.找到合适的invalidate的时机。比如倒计时完成就将其invalid，或者确定viewDidDisappear之后不再用了也行。
 
    2.打破强引用循环。
        具体可见方案2，3，4，5。这种情况，最好走dealloc的时候销毁掉timer。
 
*/

@end
