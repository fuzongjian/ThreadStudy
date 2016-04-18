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
#import "Thread_BlockOperation.h"

#import "Thread_GCD_Serial.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic,strong) UIImage  * image1;
@property (nonatomic,strong) UIImage * image2;
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
//    [self thread_gcd_communication];
//    [self thread_group_download_third];
//    [Thread_GCD_Serial thread_gcd_serial];
//    [self thread_gcd_first];
//    [self thread_gcd_second];
    [self thread_gcd_third];
    
    
//    [self thread_operation];
//    [Thread_BlockOperation thread_blockOperation];
//    [self thread_operation_forth];
}
/*-----------------------------执行的顺序问题------------------------------*/
#pragma mark --- 执行的先后等级
- (void)thread_gcd_first{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"DISPATCH_QUEUE_PRIORITY_DEFAULT--2");
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSLog(@"DISPATCH_QUEUE_PRIORITY_HIGH--1");
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSLog(@"DISPATCH_QUEUE_PRIORITY_LOW--3");
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSLog(@"DISPATCH_QUEUE_PRIORITY_BACKGROUND--4");
    });
    
}
#pragma mark --- 串行子队列的优先等级
/**  DISPATCH_QUEUE_SERIAL
 *  生成一个串行队列，队列中的block按照先进先出（FIFO）的顺序执行，实际上为单线程执行。
 */
- (void)thread_gcd_second{
    //创建串行队列 --- DISPATCH_QUEUE_SERIAL
   dispatch_queue_t serialQueue = dispatch_queue_create("fuzongjian", DISPATCH_QUEUE_SERIAL);
    //将队列放到全局队列中，
    dispatch_set_target_queue(serialQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0));
    dispatch_async(serialQueue, ^{
        NSLog(@"fu--2");
    });
    dispatch_async(serialQueue, ^{
        NSLog(@"zong--2");
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"jian--1");
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"jianjian--1");
    });
}
#pragma mark --- 并行子队列的优先等级
/**  DISPATCH_QUEUE_CONCURRENT
 *  生成一个并发队列，队列中的block被分发到多个线程去执行。
 */
- (void)thread_gcd_third{
    //创建串行队列 --- DISPATCH_QUEUE_CONCURRENT
    dispatch_queue_t serialQueue = dispatch_queue_create("fuzongjian", DISPATCH_QUEUE_CONCURRENT);
    //将队列放到全局队列中，
    dispatch_set_target_queue(serialQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0));
    dispatch_async(serialQueue, ^{
        NSLog(@"fu--2");
    });
    dispatch_async(serialQueue, ^{
        NSLog(@"zong--2");
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"jian--1");
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"jianjian--1");
    });
}
/*-----------------------------执行的顺序问题------------------------------*/
#pragma mark --- NSBlockOperation

#pragma mark --- NSOperationQueue
- (void)thread_operation_first{
    //创建队列
    NSOperationQueue * queue = [[NSOperationQueue alloc] init];
    //创建操作
    NSInvocationOperation * operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(download:) object:@"thread_operation"];
    
//    operation直接调用start，是同步执行（在当前线程执行）
//    [operation start];
    
    //添加操作到队列中，会自动异步执行
    [queue addOperation:operation];
}
- (void)download:(NSString *)url{
    NSLog(@"-----%@",[NSThread currentThread]);
}
/*--------------------------------------华丽分割线--------------------------------------------------*/
- (void)thread_operation_second{
    NSOperationQueue * queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        NSURL * url = [NSURL URLWithString:@"http://d.hiphotos.baidu.com/image/pic/item/37d3d539b6003af3290eaf5d362ac65c1038b652.jpg"];
        NSData * data = [NSData dataWithContentsOfURL:url];
        UIImage * image = [UIImage imageWithData:data];
        //回到主线程
        
        //1.
        //[self performSelectorOnMainThread:@selector(resetImage:) withObject:image waitUntilDone:NO];
        
        //2.
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = image;
        });
        
        //3.
//        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//            self.imageView.image = image;
//        }];
    }];
}
- (void)resetImage:(UIImage *)image{
    self.imageView.image = image;
}
/*--------------------------------------华丽分割线--------------------------------------------------*/
/**
 *  异步操作，相互依赖
 *  B操作依赖于A操作，只有A操作执行完毕之后，B操作才会去执行
 */
- (void)thread_operation_third{
    //创建队列（非主队列）
    NSOperationQueue * queue = [[NSOperationQueue alloc] init];
    //创建3个操作
    NSBlockOperation * operation1 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 20; i ++) {
             NSLog(@"%d--%@1",i,[NSThread currentThread]);
        }
    }];
    NSBlockOperation * operation2 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 10; i ++) {
            NSLog(@"%d--%@2",i,[NSThread currentThread]);
        }
    }];
    NSBlockOperation * operation3 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 10; i ++) {
            NSLog(@"%d--%@3",i,[NSThread currentThread]);
        }
    }];
    //设置依赖
    [operation2 addDependency:operation1];
    [operation3 addDependency:operation2];
    //将操作添加到主队列中（自动异步操作执行）
    [queue addOperation:operation1];
    [queue addOperation:operation2];
    [queue addOperation:operation3];
}
/*--------------------------------------华丽分割线--------------------------------------------------*/
/**
 *  设置最多有几个操作可以同时异步执行,只有当前面的操作完成之后，才会向下执行下面的操作
 */
- (void)thread_operation_forth{
    //创建队列（非主队列）
    NSOperationQueue * queue = [[NSOperationQueue alloc] init];
    //设置最大并发（最多可以同时执行4个任务）
    queue.maxConcurrentOperationCount = 4;
    //添加操作到队列中，（自动异步执行任务,并发）
    NSBlockOperation * operation1 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 20; i ++) {
            NSLog(@"%d--%@1",i,[NSThread currentThread]);
        }
    }];
    NSBlockOperation * operation2 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 20; i ++) {
            NSLog(@"%d--%@2",i,[NSThread currentThread]);
        }
    }];
    NSBlockOperation * operation3 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 20; i ++) {
            NSLog(@"%d--%@3",i,[NSThread currentThread]);
        }
    }];
    NSBlockOperation * operation4 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 20; i ++) {
            NSLog(@"%d--%@4",i,[NSThread currentThread]);
        }
    }];
    NSBlockOperation * operation5 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 20; i ++) {
            NSLog(@"%d--%@5",i,[NSThread currentThread]);
        }
    }];
    NSBlockOperation * operation6 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 20; i ++) {
            NSLog(@"%d--%@6",i,[NSThread currentThread]);
        }
    }];
    NSBlockOperation * operation7 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 20; i ++) {
            NSLog(@"%d--%@7",i,[NSThread currentThread]);
        }
    }];
    NSBlockOperation * operation8 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 20; i ++) {
            NSLog(@"%d--%@8",i,[NSThread currentThread]);
        }
    }];
    NSBlockOperation * operation9 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 20; i ++) {
            NSLog(@"%d--%@9",i,[NSThread currentThread]);
        }
    }];
    
    [queue addOperation:operation1];
    [queue addOperation:operation2];
    [queue addOperation:operation3];
    [queue addOperation:operation4];
    [queue addOperation:operation5];
    [queue addOperation:operation6];
    [queue addOperation:operation7];
    [queue addOperation:operation8];
    [queue addOperation:operation9];
    
    //取消队列中的所有任务,不可恢复
    [queue cancelAllOperations];
    //暂停队列中的所有任务
    queue.suspended = YES;
    //恢复队列中的所有任务
    queue.suspended = NO;
}
#pragma mark --- 队列组  下载实践
- (void)thread_group_download_third{
    //  异步下载
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL * urlOne = [NSURL URLWithString:@"http://d.hiphotos.baidu.com/image/pic/item/37d3d539b6003af3290eaf5d362ac65c1038b652.jpg"];
        NSData * dataOne = [NSData dataWithContentsOfURL:urlOne];
        self.image1 = [UIImage imageWithData:dataOne];
        [self drawImage];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL * urlTwo = [NSURL URLWithString:@"http://hiphotos.baidu.com/%CE%DE%CB%F9%D8%BC%B2%BB%BF%C9%C4%DC/pic/item/6d00747414085927b051b98c.jpg"];
        NSData * dataTwo = [NSData dataWithContentsOfURL:urlTwo];
        self.image2 = [UIImage imageWithData:dataTwo];
        [self drawImage];
    });
    
}
- (void)drawImage{
    if (self.image1 == nil || self.image2 == nil) return;
    // 3.合并图片
    // 开启一个位图上下文
    UIGraphicsBeginImageContextWithOptions(self.image1.size, NO, 0.0);
    
    // 绘制第1张图片
    CGFloat image1W = self.image1.size.width;
    CGFloat image1H = self.image1.size.height;
    [self.image1 drawInRect:CGRectMake(0, 0, image1W, image1H)];
    
    // 绘制第2张图片
    CGFloat image2W = self.image2.size.width * 0.5;
    CGFloat image2H = self.image2.size.height * 0.5;
    CGFloat image2Y = image1H - image2H;
    [self.image2 drawInRect:CGRectMake(0, image2Y, image2W, image2H)];
    
    // 得到上下文中的图片
    UIImage *fullImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 结束上下文
    UIGraphicsEndImageContext();
    
    // 4.回到主线程显示图片
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.image = fullImage;
    });

}
- (void)thread_group_download_second{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         UIImage * imageOne = nil;
         UIImage * imageTwo = nil;
        NSURL * urlOne = [NSURL URLWithString:@"http://d.hiphotos.baidu.com/image/pic/item/37d3d539b6003af3290eaf5d362ac65c1038b652.jpg"];
        NSData * dataOne = [NSData dataWithContentsOfURL:urlOne];
        imageOne = [UIImage imageWithData:dataOne];
        NSURL * urlTwo = [NSURL URLWithString:@"http://hiphotos.baidu.com/%CE%DE%CB%F9%D8%BC%B2%BB%BF%C9%C4%DC/pic/item/6d00747414085927b051b98c.jpg"];
        NSData * dataTwo = [NSData dataWithContentsOfURL:urlTwo];
        imageTwo = [UIImage imageWithData:dataTwo];
        //开启上下文
        UIGraphicsBeginImageContextWithOptions(imageOne.size, NO, 0.0);
        //绘制第一张图片
        CGFloat image1W = imageOne.size.width;
        CGFloat image1H = imageOne.size.height;
        [imageOne drawInRect:CGRectMake(0, 0, image1W, image1H)];
        
        //绘制第二张图片
        CGFloat image2W = imageTwo.size.width * 0.2;
        CGFloat image2H = imageTwo.size.height * 0.2;
        CGFloat image2Y = image1H - image2H;
        CGFloat image2X = image1W - image2W;
        [imageTwo drawInRect:CGRectMake(image2X, image2Y, image2W, image2H)];
        
        //得到上下文中的图片
        UIImage * fullImage = UIGraphicsGetImageFromCurrentImageContext();
        //结束上下文
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = fullImage;
        });

    });
}
- (void)thread_group_downLoad_first{
    //队列组
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue   = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //下载图片一
    __block UIImage * imageOne = nil;
    dispatch_group_async(group, queue, ^{
        NSLog(@"download1");
       NSURL * url = [NSURL URLWithString:@"http://d.hiphotos.baidu.com/image/pic/item/37d3d539b6003af3290eaf5d362ac65c1038b652.jpg"];
        NSData * data = [NSData dataWithContentsOfURL:url];
        imageOne = [UIImage imageWithData:data];
    });
    //下载图片二
    __block UIImage * imageTwo = nil;
    dispatch_group_async(group, queue, ^{
        NSLog(@"download2");
        NSURL * url = [NSURL URLWithString:@"http://hiphotos.baidu.com/%CE%DE%CB%F9%D8%BC%B2%BB%BF%C9%C4%DC/pic/item/6d00747414085927b051b98c.jpg"];
        NSData * data = [NSData dataWithContentsOfURL:url];
        imageTwo = [UIImage imageWithData:data];
    });
    //合并图片
    dispatch_group_notify(group, queue, ^{
        NSLog(@"output");
       //开启上下文
        UIGraphicsBeginImageContextWithOptions(imageOne.size, NO, 0.0);
        //绘制第一张图片
        CGFloat image1W = imageOne.size.width;
        CGFloat image1H = imageOne.size.height;
        [imageOne drawInRect:CGRectMake(0, 0, image1W, image1H)];
        
        //绘制第二张图片
        CGFloat image2W = imageTwo.size.width * 0.2;
        CGFloat image2H = imageTwo.size.height * 0.2;
        CGFloat image2Y = image1H - image2H;
        CGFloat image2X = image1W - image2W;
        [imageTwo drawInRect:CGRectMake(image2X, image2Y, image2W, image2H)];
        
        //得到上下文中的图片
        UIImage * fullImage = UIGraphicsGetImageFromCurrentImageContext();
        //结束上下文
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = fullImage;
        });
    });
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
