//
//  QJLagMonitor.m
//  FBSnapshotTestCase
//
//  Created by Q14 on 2020/5/29.
//

#import "QJLagMonitor.h"
#import <CrashReporter/PLCrashReporter.h>
#import <CrashReporter/PLCrashReport.h>
#import <CrashReporter/PLCrashReportTextFormatter.h>

//#define STUCKMONITORRATE 88
static NSInteger const STUCKMONITORRATE = 88;

@interface QJLagMonitor(){
    int timeoutCount;
    CFRunLoopObserverRef runLoopObserver;
    @public
    dispatch_semaphore_t dispatchSemaphore;
    CFRunLoopActivity runLoopActivity;
}
@end
@implementation QJLagMonitor
+ (instancetype)sharedInstance {
    static QJLagMonitor *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;;
}

- (void)beginMonitor {
    self.isMonitoring = YES;
    if (runLoopObserver) {
        return;
    }
    //创建一个信号量
    dispatchSemaphore = dispatch_semaphore_create(0);
    // 创建一个runloopObserver(观察者)
    CFRunLoopObserverContext context = {0,(__bridge void*)self,NULL,NULL};
    runLoopObserver = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, &runLoopObserverCallBack, &context);
    // 将runloopObserver 添加到主线程的CommonModes下
    CFRunLoopAddObserver(CFRunLoopGetMain(), runLoopObserver, kCFRunLoopCommonModes);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //子线程开启一个持续的loop用来进行监控
        while (YES) {
            long semaphoreWait = dispatch_semaphore_wait(dispatchSemaphore, dispatch_time(DISPATCH_TIME_NOW, STUCKMONITORRATE * NSEC_PER_MSEC));
            if (semaphoreWait != 0) {
                if (!runLoopObserver) {
                    timeoutCount = 0;
                    dispatchSemaphore = 0;
                    runLoopActivity = 0;
                    return;
                }
                
                //两个runloop的状态，BeforeSources和AfterWaiting这两个状态区间时间能够检测到是否卡顿
                if (runLoopActivity == kCFRunLoopBeforeSources || runLoopActivity == kCFRunLoopBeforeWaiting) {
                    //出现三次出结果
                    if (++timeoutCount < 3) {
                        continue;
                    }
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                       //打印调用堆栈信息

                        // 获取数据
                        NSData *lagData = [[[PLCrashReporter alloc]
                                            initWithConfiguration:[[PLCrashReporterConfig alloc] initWithSignalHandlerType:PLCrashReporterSignalHandlerTypeBSD symbolicationStrategy:PLCrashReporterSymbolicationStrategyAll]] generateLiveReport];
                        // 转换成 PLCrashReport 对象
                        PLCrashReport *lagReport = [[PLCrashReport alloc] initWithData:lagData error:NULL];
                        // 进行字符串格式化处理
                        NSString *lagReportString = [PLCrashReportTextFormatter stringValueForCrashReport:lagReport withTextFormat:PLCrashReportTextFormatiOS];
                        //将字符串上传服务器
                        NSLog(@"lag happen, detail below: \n %@",lagReportString);


                    });
                }

            }
        }
    });
    
}

static void runLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info){
    QJLagMonitor *lagMonitor = (__bridge QJLagMonitor*)info;
    lagMonitor->runLoopActivity = activity;
    
    dispatch_semaphore_t semaphore = lagMonitor->dispatchSemaphore;
    dispatch_semaphore_signal(semaphore);
}

- (void)endMonitor {
    
}
// 重写方法【必不可少】
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

// 重写方法【必不可少】
- (id)copyWithZone:(NSZone *)zone {
    return self;
}

// 重写方法【必不可少】
- (id)mutableCopyWithZone:(NSZone *)zone {
    return self;
}
@end
