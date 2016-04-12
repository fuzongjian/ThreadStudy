//
//  Thread_Group.m
//  ThreadStudy
//
//  Created by 陈舒澳 on 16/4/12.
//  Copyright © 2016年 xingbida. All rights reserved.
//

#import "Thread_Group.h"

@implementation Thread_Group
+ (void)thread_group{
    // 合并汇总结果, 并行的线程不分先后
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        // 并行执行的线程一
        for (int i = 0; i < 100; i ++) {
             NSLog(@"一%d",i);
        }
    });
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        for (int i = 0; i < 100; i ++) {
             NSLog(@"二%d",i);
        }
        // 并行执行的线程二
    });
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        // 上面并行线程结束后调用，汇总结果，
        NSLog(@"上面的结果全部输出完毕");
    });
}
@end
