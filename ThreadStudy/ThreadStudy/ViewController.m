//
//  ViewController.m
//  ThreadStudy
//
//  Created by 陈舒澳 on 16/4/12.
//  Copyright © 2016年 xingbida. All rights reserved.
//

#import "ViewController.h"
#import "Thread_Semaphore.h"
#import "Thread_Group.h"
#import "Thread_Group_Wait.h"
#import "Thread_Thread_Build.h"
#import "Thread_Safety.h"
#import "Thread_GCD_Sync.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [Thread_Semaphore thread_semaphore];
//    [Thread_Group thread_group];
//    [Thread_Group_Wait thread_group_wait];
//    [Thread_Thread_Build thread_thread_build];
//    [[Thread_Safety new] thread_safety];
//    [self thread_communication];
//    [Thread_GCD_Sync thread_gcd_sync];
    [self thread_gcd_communication];
    
}
#pragma mark --- 线程之间的通信
- (void)thread_communication{
    [self performSelectorInBackground:@selector(downLoad) withObject:nil];
}
- (void)downLoad{
     NSLog(@"download----%@",[NSThread currentThread]);
    NSURL * url = [NSURL URLWithString:@"http://d.hiphotos.baidu.com/image/pic/item/37d3d539b6003af3290eaf5d362ac65c1038b652.jpg"];
    NSLog(@"开始下载了");
    NSData * data = [NSData dataWithContentsOfURL:url];
    NSLog(@"下载完成");
    UIImage * image = [UIImage imageWithData:data];
    
    //回到主线程方式一
//    [self performSelectorOnMainThread:@selector(downLoadFinish:) withObject:image waitUntilDone:NO];
    //回到主线程方式二
    [self performSelector:@selector(downLoadFinish:) onThread:[NSThread mainThread] withObject:image waitUntilDone:YES];
    //回到主线程方式三
//    [self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:YES];
    
    NSLog(@"done");
}
- (void)downLoadFinish:(UIImage * )image{
     NSLog(@"%@",[NSThread currentThread]);
    self.imageView.image = image;
}
#pragma mark --- GCD线程之间的通信
- (void)thread_gcd_communication{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"download----%@",[NSThread currentThread]);
        NSURL * url = [NSURL URLWithString:@"http://d.hiphotos.baidu.com/image/pic/item/37d3d539b6003af3290eaf5d362ac65c1038b652.jpg"];
        NSLog(@"开始下载了");
        NSData * data = [NSData dataWithContentsOfURL:url];
        NSLog(@"下载完成");
        UIImage * image = [UIImage imageWithData:data];
       dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%@",[NSThread currentThread]);
           self.imageView.image = image;
       });
    });
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
