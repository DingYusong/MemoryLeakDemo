//
//  DYSTimerProxy.m
//  MemoryLeakDemo
//
//  Created by 丁玉松 on 2018/11/7.
//  Copyright © 2018 丁玉松. All rights reserved.
//

#import "DYSTimerProxy.h"


/**
 将timer的target设置为自己，当接收到selector消息后进行消息转发，让其他对象去处理。
 */
@interface DYSTimerProxy ()
@property (nonatomic, weak) id target;

@end

@implementation DYSTimerProxy

- (instancetype)initWithTarget:(id)target{
    self.target = target;
    return self;
}


- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [self.target methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    SEL sel = [invocation selector];
    if ([self.target respondsToSelector:sel]) {
        [invocation invokeWithTarget:self.target];
    }
}

@end
