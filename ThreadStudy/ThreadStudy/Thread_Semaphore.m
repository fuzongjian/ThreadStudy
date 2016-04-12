//
//  Thread_Semaphore.m
//  ThreadStudy
//
//  Created by 陈舒澳 on 16/4/12.
//  Copyright © 2016年 xingbida. All rights reserved.
//

#import "Thread_Semaphore.h"

@implementation Thread_Semaphore
/**
    信号量是一个整形值并且具有一个初始计数值，支持两个操作：信号通知和等待。当一个信号量被信号通知时，其计数会被增加，当一个线程在一个信号量上等待时，线程会被阻塞。直至计数器大于零，然后线程会减少这个计数
 */
+ (void)thread_semaphore{
    
    //dispatch_semaphore 信号量基于计数器的一种多线程同步机制，在多线程访问共有资源时候，会因为多线程的特性而引发数据出错的问题
    
    int data = 3;
    int mainData = 0;
    
    //创建信号量，可以设置信号量的资源数，0表示没有资源，调用dispatch_semaphore_wait会立即等待
    
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);//整形的参数，可以理解为信号的总量
    dispatch_queue_t queue = dispatch_queue_create("StudyBlocks", NULL);
    dispatch_async(queue, ^(void) {
        int sum = 0;
        for(int i = 0; i < 5; i++)
        {
            sum += data;
            
            NSLog(@" >> Sum: %d", sum);
        }
        //通知信号，如果等待线程被唤醒则返回非0，否侧返回0
        dispatch_semaphore_signal(sem);//发送一个信号，信号量+1
    });
    //等待信号，可以设置超时参数，该函数返回0表示得到通知，非0表示超时
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);//等待信号，当信号总量小于0的时候就会一直等待，否则就可以正常的执行，并让信号总量-1，
    //通过信号量就可以保证，Main Data永远在Sum之后执行
    for(int j=0;j<5;j++)
    {
        mainData++;
        NSLog(@">> Main Data: %d",mainData);
    }

}
@end
