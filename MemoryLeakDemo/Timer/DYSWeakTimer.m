//
//  DYSWeakTimer.m
//  MemoryLeakDemo
//
//  Created by 丁玉松 on 2018/11/7.
//  Copyright © 2018 丁玉松. All rights reserved.
//

#import "DYSWeakTimer.h"

@interface DYSWeakTimer ()

@property (nonatomic, weak) id aTarget;
@property (nonatomic, assign) SEL aSelector;

@end

@implementation DYSWeakTimer

+ (NSTimer *)weekScheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo {
    DYSWeakTimer *weakTimer = [DYSWeakTimer new];
    weakTimer.aTarget = aTarget;
    weakTimer.aSelector = aSelector;
    
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:ti target:weakTimer selector:@selector(weakTimerAction:) userInfo:userInfo repeats:yesOrNo];
    return timer;
}

- (void)weakTimerAction:(id)info{
    [self.aTarget performSelector:self.aSelector withObject:info];
}


@end
