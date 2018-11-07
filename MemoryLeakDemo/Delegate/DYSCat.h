//
//  DYSCat.h
//  MemoryLeakDemo
//
//  Created by 丁玉松 on 2018/11/7.
//  Copyright © 2018 丁玉松. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol DYSCatFoodProvider <NSObject>
- (NSInteger)provideFood;

@end

@interface DYSCat : NSObject
@property (nonatomic, weak) id<DYSCatFoodProvider> delegate;
//assign在delegate释放时候不会自动置为nil,易出野指针错误
//@property (nonatomic, assign) id<DYSCatFoodProvider> delegate;
//DYSCat 和 DYSDelegateViewController 两个对象相互强引用形成闭环，无法释放，造成内存泄漏
//@property (nonatomic, strong) id<DYSCatFoodProvider> delegate;

- (void)eat;
@end

