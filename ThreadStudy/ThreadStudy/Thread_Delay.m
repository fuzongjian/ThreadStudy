//
//  Thread_Delay.m
//  ThreadStudy
//
//  Created by 陈舒澳 on 16/4/13.
//  Copyright © 2016年 xingbida. All rights reserved.
//

#import "Thread_Delay.h"

@implementation Thread_Delay
- (void)thread_delay_first{
    [self performSelector:@selector(downLoad:) withObject:@"thread_delay_first" afterDelay:3];
}
- (void)thread_delay_second{
    //三秒之后回到主线程执行block中的代码
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
    });
    //三秒之后自动开启新的线程，并执行block中的代码
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), queue, ^{
        
    });
}
- (void)thread_delay_third{
    // 会卡住当前线程，所以延迟操作不要用sleep
    [NSThread sleepForTimeInterval:5];//休眠五秒
    
    NSDate * date = [NSDate dateWithTimeIntervalSinceNow:3];//休眠3秒
    [NSThread sleepUntilDate:date];
}
- (void)downLoad:(NSString *)url{
     NSLog(@"%@",url);
}
@end
