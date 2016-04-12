//
//  Thread_Thread_Build.m
//  ThreadStudy
//
//  Created by 陈舒澳 on 16/4/12.
//  Copyright © 2016年 xingbida. All rights reserved.
//

#import "Thread_Thread_Build.h"
@implementation Thread_Thread_Build
+ (void)thread_thread_build{
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[Thread_Thread_Build new] create_thread_first];
    });
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[Thread_Thread_Build new] create_thread_second];
    });
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       [[Thread_Thread_Build new] create_thread_third];
    });
}
#pragma mark --- 创建线程方式1
- (void)create_thread_first{
    NSThread * thread = [[NSThread alloc] initWithTarget:self selector:@selector(download:) object:@"create_thread_first"];
    thread.name = @"线程名字";
    [thread start];
}
#pragma mark --- 创建线程方式2
- (void)create_thread_second{
    [self performSelectorInBackground:@selector(download:) withObject:@"create_thread_second"];
}
#pragma mark --- 创建线程方式3
- (void)create_thread_third{
    [NSThread detachNewThreadSelector:@selector(download:) toTarget:self withObject:@"create_thread_third"];
}
- (void)download:(NSString *)url{
    
    [NSThread sleepForTimeInterval:5];//休眠五秒
    
    NSDate * date = [NSDate dateWithTimeIntervalSinceNow:3];//休眠3秒
    [NSThread sleepUntilDate:date];
    
    
     NSLog(@"%@--%@",url,[NSThread currentThread]);
}
@end
