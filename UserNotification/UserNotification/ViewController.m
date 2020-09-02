//
//  ViewController.m
//  UserNotification
//
//  Created by stone on 2020/9/2.
//  Copyright © 2020 3kMac. All rights reserved.
//

#import "ViewController.h"
#import <UserNotifications/UserNotifications.h>


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

static int i = 0;
- (IBAction)localNotification:(id)sender NS_AVAILABLE_IOS(10_0) {
    NSString *dateString = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
    NSString *threadIdentifier = [NSString stringWithFormat:@"group%d", i%2];

    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];

    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.body = dateString;//@"body";
    content.title = @"title";
    content.subtitle = @"subtitle";
    content.userInfo = @{@"key" : @"value"};

    // 设置后无效，需研究
    content.launchImageName = @"Image";
    
    // 分组标识
    content.threadIdentifier = threadIdentifier;
    
    // 摘要
    if (@available(iOS 12.0, *)) {
        content.summaryArgument = @"my app";
        content.summaryArgumentCount = 1;
        
        // 交互按钮
        UNNotificationAction *action1 = [UNNotificationAction actionWithIdentifier:@"action1" title:@"按钮" options:UNNotificationActionOptionNone];
        // 交互输入框
        UNTextInputNotificationAction *action2 = [UNTextInputNotificationAction actionWithIdentifier:@"action2" title:@"回复" options:UNNotificationActionOptionNone textInputButtonTitle:@"发送" textInputPlaceholder:@"默认回复语句"];
        
        UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:@"category" actions:@[action1, action2] intentIdentifiers:@[] hiddenPreviewsBodyPlaceholder:nil categorySummaryFormat:nil options:UNNotificationCategoryOptionCustomDismissAction];
        // 必须设置可以显示的category集合
        [center setNotificationCategories:[NSSet setWithObject:category]];
    }
    
    // 必须设置且与category的标志一致
    content.categoryIdentifier = @"category";
    
    NSURL *attachmentURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"1" ofType:@"jpg"]];
    UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"attachment"
                                                                                          URL:attachmentURL
                                                                                      options:nil
                                                                                        error:nil];
    content.attachments = @[attachment];
    
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:5 repeats:NO];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:dateString
                                                                          content:content
                                                                          trigger:trigger];
    [center addNotificationRequest:request withCompletionHandler:^(NSError *error) {
        NSLog(@"创建本地通知成功");
    }];
}

@end
