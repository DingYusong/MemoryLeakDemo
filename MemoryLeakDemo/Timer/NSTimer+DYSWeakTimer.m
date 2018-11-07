//
//  NSTimer+DYSWeakTimer.m
//  MemoryLeakDemo
//
//  Created by 丁玉松 on 2018/11/7.
//  Copyright © 2018 丁玉松. All rights reserved.
//

#import "NSTimer+DYSWeakTimer.h"

@implementation NSTimer (DYSWeakTimer)

+ (NSTimer *)weakScheduledTimerWithTimeInterval:(NSTimeInterval)inerval
                                        repeats:(BOOL)repeats
                                          block:(void(^)(NSTimer *timer))block{
    return [NSTimer scheduledTimerWithTimeInterval:inerval target:self selector:@selector(weakBlcokInvoke:) userInfo:[block copy] repeats:repeats];
}

+ (void)weakBlcokInvoke:(NSTimer *)timer {
    void (^block)(NSTimer *timer) = timer.userInfo;
    if (block) {
        block(timer);
    }
}


@end
