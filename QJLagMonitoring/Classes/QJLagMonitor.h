//
//  QJLagMonitor.h
//  FBSnapshotTestCase
//
//  Created by Q14 on 2020/5/29.
//

#import <Foundation/Foundation.h>

//NS_ASSUME_NONNULL_BEGIN

@interface QJLagMonitor : NSObject
/// 创建单例对象
+ (instancetype)sharedInstance;

/// 是否正在监测卡顿中
@property (nonatomic, assign) BOOL isMonitoring;

//开始监控
- (void)beginMonitor;
//结束监控
- (void)endMonitor;
@end

//NS_ASSUME_NONNULL_END
