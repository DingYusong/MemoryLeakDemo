//
//  DYSDog.h
//  MemoryLeakDemo
//
//  Created by 丁玉松 on 2018/11/6.
//  Copyright © 2018 丁玉松. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DYSDog : NSObject
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, copy) NSString *name;
@end

NS_ASSUME_NONNULL_END
