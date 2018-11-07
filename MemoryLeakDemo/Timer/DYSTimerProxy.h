//
//  DYSTimerProxy.h
//  MemoryLeakDemo
//
//  Created by 丁玉松 on 2018/11/7.
//  Copyright © 2018 丁玉松. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DYSTimerProxy : NSProxy

- (instancetype)initWithTarget:(id)target;

@end

NS_ASSUME_NONNULL_END
