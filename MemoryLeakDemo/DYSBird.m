//
//  DYSBird.m
//  MemoryLeakDemo
//
//  Created by 丁玉松 on 2018/11/7.
//  Copyright © 2018 丁玉松. All rights reserved.
//

#import "DYSBird.h"
#import "DYSNSNotificationViewController.h"

@implementation DYSBird

- (void)sendNotification {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NSNotificationNameUserLogin object:nil];
    });
}

@end
