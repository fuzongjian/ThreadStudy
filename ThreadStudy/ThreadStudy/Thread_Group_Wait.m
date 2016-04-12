//
//  Thread_Group_Wait.m
//  ThreadStudy
//
//  Created by 陈舒澳 on 16/4/12.
//  Copyright © 2016年 xingbida. All rights reserved.
//

#import "Thread_Group_Wait.h"

@implementation Thread_Group_Wait
+ (void)thread_group_wait{
    int data = 3;
    __block int mainData = 0;
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("block", NULL);
    dispatch_group_async(group, queue, ^{
        int sum = 0;
        for(int i = 0; i < 5; i++)
        {
            sum += data;
            
            NSLog(@" >> Sum: %d", sum);
        }
    });
#pragma mark --- 等待上面的输出执行完毕之后，才会调用下面的方法
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    for(int j=0;j<5;j++)
    {
        mainData++;
        NSLog(@">> Main Data: %d",mainData);
    }
#pragma mark --- 提供一个结束点，然后再调用下面的方法，和上面的方法异曲同工
    dispatch_group_notify(group, queue, ^{
        for(int j=0;j<5;j++)
        {
            mainData++;
            NSLog(@">> Main Data: %d",mainData);
        }
    });
}
@end
