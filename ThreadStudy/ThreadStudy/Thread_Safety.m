//
//  Thread_Safety.m
//  ThreadStudy
//
//  Created by 陈舒澳 on 16/4/12.
//  Copyright © 2016年 xingbida. All rights reserved.
//

#import "Thread_Safety.h"
@interface Thread_Safety ()
@property (nonatomic,strong) NSThread * threadOne;
@property (nonatomic,strong) NSThread * threadTwo;
@property (nonatomic,strong) NSThread * threadThree;
@property (nonatomic,assign) int  leftCount;
@end
@implementation Thread_Safety
- (void)thread_safety{
    
    self.leftCount = 50;
    
    self.threadOne = [[NSThread alloc] initWithTarget:self selector:@selector(saleTicket) object:nil];
    self.threadOne.name = @"threadOne";
    self.threadTwo = [[NSThread alloc] initWithTarget:self selector:@selector(saleTicket) object:nil];
    self.threadTwo.name = @"threadTwo";
    self.threadThree = [[NSThread alloc] initWithTarget:self selector:@selector(saleTicket) object:nil];
    self.threadThree.name = @"threadThree";
    
    [self.threadOne start];
    [self.threadTwo start];
    [self.threadThree start];
    
}
- (void)saleTicket{
    while (1) {
        @synchronized(self) {//加锁,保证线程安全
            if (self.leftCount > 0) {
                self.leftCount --;
                 NSLog(@"%@卖了一张票，剩余%d张票",[NSThread currentThread].name,self.leftCount);
            }else{
                return;//退出线程
            }
        }
    }
}
@end
