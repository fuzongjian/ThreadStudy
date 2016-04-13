//
//  Thread_BlockOperation.m
//  ThreadStudy
//
//  Created by 陈舒澳 on 16/4/13.
//  Copyright © 2016年 xingbida. All rights reserved.
//

#import "Thread_BlockOperation.h"

@implementation Thread_BlockOperation
+ (void)thread_blockOperation{
    NSBlockOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"---下载图片----1---%@", [NSThread currentThread]);
    }];
    
    [operation1 addExecutionBlock:^{
        NSLog(@"---下载图片----2---%@", [NSThread currentThread]);
    }];
    
    NSBlockOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"---下载图片----3---%@", [NSThread currentThread]);
    }];
    
    NSBlockOperation *operation3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"---下载图片----3---%@", [NSThread currentThread]);
    }];
    
    NSBlockOperation *operation4 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"---下载图片----4---%@", [NSThread currentThread]);
    }];
    
    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // 主队列(主线程执行)
    // NSOperationQueue *queue = [NSOperationQueue mainQueue];
    
    // 2.添加操作到队列中（自动异步执行）
    [queue addOperation:operation1];
    [queue addOperation:operation2];
    [queue addOperation:operation3];
    [queue addOperation:operation4];
    
    
    [self thread_operation];
    
}
+ (void)thread_operation{
    // 任务数量 > 1，才会开始异步执行
    //主队列执行
    NSBlockOperation *operation = [[NSBlockOperation alloc] init];
    
    [operation addExecutionBlock:^{
        NSLog(@"---下载图片----fu---%@", [NSThread currentThread]);
    }];
    
    [operation addExecutionBlock:^{
        NSLog(@"---下载图片----zong---%@", [NSThread currentThread]);
    }];
    
    [operation addExecutionBlock:^{
        NSLog(@"---下载图片----jian---%@", [NSThread currentThread]);
    }];
    
    [operation start];
    
}

@end
