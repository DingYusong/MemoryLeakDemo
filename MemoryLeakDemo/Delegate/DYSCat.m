//
//  DYSCat.m
//  MemoryLeakDemo
//
//  Created by 丁玉松 on 2018/11/7.
//  Copyright © 2018 丁玉松. All rights reserved.
//

#import "DYSCat.h"

@implementation DYSCat


/**
 狗狗要吃饭
 */
- (void)eat{
    
    if (!self.delegate) {
        NSLog(@"没有铲屎官提供食物，要饿死啦");
        return;
    }
    
    if (![self.delegate respondsToSelector:@selector(provideFood)]) {
        NSLog(@"铲屎官没有提供食物，挨饿呀");
        return;
    }
    
    NSInteger foodAmount = [self.delegate provideFood];
    NSLog(@"铲屎官提供%ld份食物，饱餐一顿",(long)foodAmount);    
}


@end
