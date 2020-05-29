//
//  QJViewController.m
//  QJLagMonitoring
//
//  Created by Q14 on 05/29/2020.
//  Copyright (c) 2020 Q14. All rights reserved.
//

#import "QJViewController.h"
#import "QJLagMonitor.h"

@interface QJViewController ()

@end

@implementation QJViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    QJLagMonitor *signal1 = [[QJLagMonitor alloc] init];
    QJLagMonitor *signal2 = [QJLagMonitor sharedInstance];
    QJLagMonitor *signal3 = [QJLagMonitor sharedInstance];
    QJLagMonitor *signal4 = [QJLagMonitor new];
    QJLagMonitor *signal5 = [signal1 copy];
    QJLagMonitor *signal6 = [QJLagMonitor mutableCopy];
        
    NSLog(@"\nsignal1 = %@\nsignal2 = %@\nsignal3 = %@\nsignal4 = %@\nsignal5 = %@\nsignal6 = %@",signal1,signal2,signal3,signal4,signal5,signal6);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
